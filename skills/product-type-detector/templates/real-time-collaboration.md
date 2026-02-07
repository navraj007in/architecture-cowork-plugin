# Real-time Collaboration Architecture Depth

## Message Delivery Model

### Ordering Guarantees

**Per-Channel FIFO via Sequence Numbers**:
- Each message gets monotonically increasing `sequence_number` per channel
- Server assigns sequence on write (prevents client tampering)
- Clients display messages ordered by `sequence_number`
- **Gap Detection**: Client detects missing sequences (e.g., received 42, 44 → fetch 43)

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  channel_id UUID NOT NULL,
  sequence_number BIGINT NOT NULL,
  user_id UUID NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (channel_id, sequence_number)
);

CREATE INDEX idx_messages_channel_seq ON messages(channel_id, sequence_number DESC);
```

**Why Not Timestamp Ordering?**
- ❌ Clock skew between servers breaks ordering
- ❌ Simultaneous messages (same millisecond) have undefined order
- ✅ Sequence numbers guarantee total order per channel

---

### Offline Message Delivery

**7-Day Queue with Sync on Reconnect**:
```
User goes offline at sequence 100
  ↓
Messages 101-150 arrive while offline
  ↓
User reconnects, sends: GET /messages?channel_id=X&after_sequence=100
  ↓
Server returns messages 101-150
  ↓
Client backfills and displays
```

**Implementation**:
- Server tracks last acknowledged sequence per user per channel (stored in Redis or database)
- On reconnect, client requests `after_sequence=last_seen`
- Paginate if > 100 missed messages (prevent huge payloads)

**Data Retention**:
- Messages older than 7 days: Archived to cold storage (S3)
- User can fetch via separate "load history" API
- Reduces database size (active messages only)

---

### Read Receipts

**Two-Phase Delivery Confirmation**:
1. **Delivered**: Message reached client device
2. **Read**: User viewed message in UI

```sql
CREATE TABLE message_receipts (
  message_id UUID NOT NULL,
  user_id UUID NOT NULL,
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  PRIMARY KEY (message_id, user_id)
);
```

**Delivery Flow**:
```
1. Server sends message via WebSocket
2. Client receives, displays, sends: { type: "delivered", message_id: "..." }
3. Server updates delivered_at
4. User scrolls message into view
5. Client sends: { type: "read", message_id: "..." }
6. Server updates read_at
7. Sender sees "Read by Alice, Bob" UI
```

**Optimization**:
- Batch receipts: Send every 2 seconds instead of per-message (reduce WebSocket traffic)
- Aggregate in UI: "Read by 5 people" instead of listing all names for large channels

---

### Fanout Architecture

**Pub/Sub Fanout for 1-to-N Delivery**:

**Option 1: Redis Pub/Sub** (Recommended for <100K concurrent users)
```
User posts message to #general (1000 subscribers)
  ↓
Server publishes to Redis channel: "channel:general"
  ↓
All WebSocket servers subscribed to "channel:general" receive message
  ↓
Each WebSocket server sends to connected clients in that channel
```

**Throughput**: Redis Pub/Sub handles ~100K messages/sec

**Option 2: PostgreSQL LISTEN/NOTIFY** (Lower throughput, simpler)
- Use if already on PostgreSQL and <10K concurrent users
- Throughput: ~5K messages/sec

**Option 3: Kafka** (Enterprise scale, 1M+ concurrent users)
- Partitioned by channel_id for parallelism
- Throughput: 1M+ messages/sec
- Complexity: High (operational overhead)

**Recommendation**:
- MVP → Redis Pub/Sub
- 100K+ users → Kafka

---

## Presence & Typing Indicators

### User Presence (Online/Offline/Away)

**WebSocket Heartbeat Pattern**:
```
Client sends heartbeat every 30 seconds:
  { type: "heartbeat", user_id: "..." }

Server updates Redis:
  SET user:alice:presence "online" EX 60

Server publishes presence change:
  PUBLISH presence:updates { user_id: "alice", status: "online" }

Other clients receive and update UI
```

**Statuses**:
- **Online**: Heartbeat received in last 60 seconds
- **Away**: No activity for 10 minutes (no typing, no clicks)
- **Offline**: No heartbeat for 60+ seconds

**Why Redis?**
- TTL auto-expires stale presence (no cleanup job needed)
- Fast reads for "who's online" queries
- Pub/Sub for real-time updates

---

### Typing Indicators

**Ephemeral, Not Persisted**:
```
User types in channel #general
  ↓
Client sends (debounced every 2 seconds):
  { type: "typing", channel_id: "...", user_id: "alice" }
  ↓
Server publishes to Redis:
  PUBLISH typing:channel:general { user_id: "alice" }
  ↓
Other clients show "Alice is typing..." for 5 seconds
  ↓
Auto-hide after 5 seconds if no new typing event
```

**No Database Storage**:
- Typing is ephemeral (no need to persist)
- Reduces DB writes by 90%

**Rate Limiting**:
- Max 1 typing event per 2 seconds per user (prevent spam)

---

## Conflict Resolution (For Collaborative Editing)

**Operational Transformation (OT) vs CRDT**:

### When You Need This
- **Collaborative text editing** (Google Docs-style)
- **Shared whiteboards** (simultaneous drawing)
- **Co-editing forms/tables**

### If Just Chat/Messaging
- ❌ **Not needed** - messages are immutable (no concurrent edits)
- Use sequence numbers only

### If Collaborative Editing Required

**Option 1: Operational Transformation (OT)**
- **Library**: ShareDB, Yjs (with OT mode)
- **Complexity**: High (complex algorithm)
- **Latency**: Low (immediate conflict resolution)
- **Example**: Google Docs

**Option 2: CRDTs (Conflict-free Replicated Data Types)**
- **Library**: Yjs, Automerge
- **Complexity**: Medium (easier than OT)
- **Latency**: Low (eventually consistent)
- **Example**: Figma, Notion

**Recommendation**:
- **Text editing**: Yjs (supports both OT and CRDT, excellent ecosystem)
- **Drawing/canvas**: CRDT (better for spatial data)

**Example Yjs Integration**:
```typescript
import * as Y from 'yjs'
import { WebsocketProvider } from 'y-websocket'

const ydoc = new Y.Doc()
const ytext = ydoc.getText('shared-document')

// Connect to WebSocket server
const provider = new WebsocketProvider('ws://localhost:1234', 'my-room', ydoc)

// User edits trigger OT/CRDT sync automatically
ytext.insert(0, 'Hello')
```

---

## Performance Targets

### Latency Requirements

**Message Send → Delivery**:
- **Target**: <200ms p95 (95th percentile)
- **Breakdown**:
  - Client → Server: ~50ms (network)
  - Server processing: ~20ms (DB write, Redis publish)
  - Server → Other clients: ~50ms (fanout)
  - Client render: ~10ms

**Presence Updates**:
- **Target**: <500ms (not time-critical)

**Typing Indicators**:
- **Target**: <300ms (feels responsive but not critical)

---

### Throughput Targets

**Messages per Second** (for 10K concurrent users):
- **Total**: 1000 messages/sec (assume 10% active at any moment)
- **Per Channel**: ~10 messages/sec for active channels
- **Fanout**: If avg 100 subscribers per channel → 100K deliveries/sec

**Scaling Strategy**:
- **10K users**: Single Redis instance + 2-3 WebSocket servers
- **100K users**: Redis Cluster + 10-20 WebSocket servers
- **1M+ users**: Kafka + 100+ WebSocket servers

---

## WebSocket Architecture

### Connection Management

**Load Balancing**:
```
Client connects → ALB/nginx
  ↓
Sticky sessions (IP hash or cookie)
  ↓
WebSocket server keeps connection open
```

**Why Sticky Sessions?**
- WebSocket is stateful (reconnecting to different server loses context)
- Use `ip_hash` or `cookie` in nginx

**Reconnection Logic**:
```javascript
// Client-side
let ws = new WebSocket('wss://api.example.com/ws')

ws.onclose = () => {
  setTimeout(() => {
    // Exponential backoff: 1s, 2s, 4s, 8s (max 30s)
    reconnect()
  }, Math.min(1000 * Math.pow(2, retryCount), 30000))
}
```

---

### Message Protocol

**JSON over WebSocket**:
```json
// Client → Server
{
  "type": "message.send",
  "channel_id": "uuid",
  "content": "Hello world",
  "client_msg_id": "uuid"  // For idempotency
}

// Server → Client
{
  "type": "message.new",
  "id": "uuid",
  "channel_id": "uuid",
  "user_id": "uuid",
  "content": "Hello world",
  "sequence_number": 42,
  "created_at": "2026-02-07T10:00:00Z"
}
```

**Message Types**:
- `message.send` - Send new message
- `message.new` - New message from someone
- `message.edit` - Edit existing message
- `message.delete` - Delete message
- `typing` - User typing
- `presence` - Presence update
- `heartbeat` - Keep connection alive

---

## Database Schema Considerations

**Message Storage**:
```sql
-- Partition by created_at for efficient archival
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  channel_id UUID NOT NULL,
  user_id UUID NOT NULL,
  content TEXT NOT NULL,
  sequence_number BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  edited_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
) PARTITION BY RANGE (created_at);

-- Partition example: One partition per month
CREATE TABLE messages_2026_02 PARTITION OF messages
  FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
```

**Why Partition?**
- Archive old messages to S3 by dropping partitions
- Faster queries (scan only recent partitions)

---

## Cost Implications

**WebSocket Connections**:
- Each connection ~10KB memory
- 10K users = 100MB RAM
- 100K users = 1GB RAM
- **Vertical scaling**: Needed for connection memory

**Data Transfer**:
- Each message ~500 bytes
- 1M messages/day = 500MB/day = 15GB/month
- **Egress costs**: ~$1.35/month (AWS at $0.09/GB)

**Redis**:
- Presence + typing + pub/sub = ~100MB Redis for 10K users
- **Cost**: ~$50/month for managed Redis (AWS ElastiCache t3.small)

---

## Summary Checklist

- [ ] Message ordering via sequence numbers per channel
- [ ] Offline message sync (7-day queue)
- [ ] Read receipts (delivered_at, read_at)
- [ ] Redis Pub/Sub for message fanout
- [ ] WebSocket heartbeat for presence (60s TTL)
- [ ] Typing indicators (debounced, ephemeral)
- [ ] Sticky sessions for WebSocket load balancing
- [ ] Exponential backoff for reconnections
- [ ] Partitioned message table for archival
- [ ] If collaborative editing: Yjs for CRDT/OT
