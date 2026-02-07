# AI Agent Application Architecture Depth

## Agent Orchestration Pattern

### ReAct (Reasoning + Acting)

**Best for**: Agents that need to use tools/functions (API calls, database queries, web search)

**How It Works**:
```
1. User: "What's the weather in Paris and book me a flight there?"
2. Agent thinks: "I need to call weather API first, then search flights"
3. Agent calls: get_weather("Paris")
4. Tool returns: "15°C, sunny"
5. Agent thinks: "Now I'll search flights"
6. Agent calls: search_flights(destination="Paris")
7. Tool returns: [Flight options]
8. Agent responds: "Weather is 15°C and sunny. Here are flights: ..."
```

**Implementation**:
```typescript
const messages = [
  { role: 'system', content: systemPrompt },
  { role: 'user', content: userQuery }
]

while (true) {
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-5',
    messages,
    tools: toolDefinitions,
    max_tokens: 4096
  })

  if (response.stop_reason === 'end_turn') {
    // Agent finished, return response
    return response.content[0].text
  }

  if (response.stop_reason === 'tool_use') {
    // Agent wants to call a tool
    for (const block of response.content) {
      if (block.type === 'tool_use') {
        const result = await executeTool(block.name, block.input)

        messages.push({
          role: 'user',
          content: [{
            type: 'tool_result',
            tool_use_id: block.id,
            content: JSON.stringify(result)
          }]
        })
      }
    }
    // Loop continues with tool results
  }
}
```

**Pros**:
- ✅ Handles multi-step tasks
- ✅ Can call multiple tools
- ✅ Explicit reasoning (can show user agent's thinking)

**Cons**:
- ❌ More tokens consumed (multiple LLM calls)
- ❌ Higher latency than simple prompt

---

### Chain-of-Thought (CoT)

**Best for**: Complex reasoning tasks without tools (math, logic, analysis)

**How It Works**:
```
System prompt:
"Think step by step. Show your reasoning before answering."

User: What are the economic impacts of remote work?

Agent: Let me break this down:
1. Real estate impact: Less office space needed → commercial real estate decline
2. Productivity: Studies show 5-15% increase for knowledge workers
3. Urban planning: Suburban growth, less commuting
4. Cost savings: Companies save $11K/year per remote worker (Global Workplace Analytics)
Therefore, remote work has major economic impacts across real estate, productivity, and urban development.
```

**When to Use**:
- Research assistants
- Analysis tools
- Educational tutors
- Complex Q&A

---

### Multi-Agent Workflow

**Best for**: Complex tasks requiring specialized agents

**Architecture**:
```
User query
  ↓
Orchestrator Agent (decides which agents to call)
  ↓
├─ Researcher Agent (finds sources)
├─ Writer Agent (drafts content)
├─ Editor Agent (improves draft)
└─ SEO Agent (optimizes)
  ↓
Final output
```

**Implementation**:
```typescript
// Each agent has specialized system prompt
const agents = {
  researcher: {
    systemPrompt: "You are a research specialist. Find credible sources...",
    tools: [search_web, extract_sources]
  },
  writer: {
    systemPrompt: "You are a content writer. Draft engaging articles...",
    tools: [generate_draft]
  },
  editor: {
    systemPrompt: "You are an editor. Improve clarity and grammar...",
    tools: [check_grammar, improve_clarity]
  }
}

// Sequential workflow
const sources = await callAgent('researcher', userQuery)
const draft = await callAgent('writer', { query: userQuery, sources })
const final = await callAgent('editor', { draft })
```

**Cost Optimization**:
- Use **Claude Sonnet** for complex agents (writer, editor)
- Use **Claude Haiku** for simple agents (researcher, SEO)

---

## Tool Definitions & Schemas

### JSON Schema Format

**Example: Customer Support Bot**
```typescript
const tools = [
  {
    name: "search_knowledge_base",
    description: "Search the knowledge base for answers to customer questions. Use this when the user asks about product features, pricing, or how-to questions.",
    input_schema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "The search query to find relevant articles"
        },
        category: {
          type: "string",
          enum: ["features", "pricing", "troubleshooting", "getting-started"],
          description: "Optional category to filter results"
        }
      },
      required: ["query"]
    }
  },
  {
    name: "create_support_ticket",
    description: "Create a support ticket and escalate to a human agent. Use this when you cannot answer the question or the user explicitly asks for human support.",
    input_schema: {
      type: "object",
      properties: {
        priority: {
          type: "string",
          enum: ["low", "medium", "high", "urgent"],
          description: "Ticket priority based on issue severity"
        },
        summary: {
          type: "string",
          description: "Brief summary of the issue"
        },
        details: {
          type: "string",
          description: "Full conversation context and issue details"
        }
      },
      required: ["priority", "summary", "details"]
    }
  }
]

// Tool execution
async function executeTool(name: string, input: any) {
  if (name === 'search_knowledge_base') {
    return await vectorSearch(input.query, input.category)
  }
  if (name === 'create_support_ticket') {
    return await zendesk.createTicket(input)
  }
}
```

### Tool Calling Best Practices

**1. Clear Descriptions**
- ❌ "Search for stuff"
- ✅ "Search the knowledge base for answers to customer questions about product features, pricing, and troubleshooting"

**2. Parameter Constraints**
- Use `enum` for limited choices
- Mark `required` fields
- Provide examples in descriptions

**3. Error Handling**
```typescript
async function executeTool(name, input) {
  try {
    const result = await tools[name](input)
    return { success: true, data: result }
  } catch (error) {
    return {
      success: false,
      error: "Tool execution failed. Please try rephrasing your request."
    }
  }
}
```

---

## Token Cost Modeling

### Input + Output Token Calculation

**Claude Pricing (as of 2026-02)**:
- **Haiku**: $0.25/MTok input, $1.25/MTok output
- **Sonnet**: $3/MTok input, $15/MTok output
- **Opus**: $15/MTok input, $75/MTok output

**Example: Customer Support Chatbot**

**Assumptions**:
- 1000 conversations/month
- Avg conversation: 10 turns (5 user + 5 agent messages)
- System prompt: 500 tokens
- Knowledge base context: 2000 tokens per query
- User message: 50 tokens avg
- Agent response: 150 tokens avg

**Token Math**:
```
Per conversation:
  Input tokens = system (500) + context (2000 × 5) + user messages (50 × 5) = 10,750 tokens
  Output tokens = agent responses (150 × 5) = 750 tokens

Monthly (1000 conversations):
  Input = 10,750 × 1000 = 10.75M tokens
  Output = 750 × 1000 = 0.75M tokens

Cost (Sonnet):
  Input: 10.75M × $3/MTok = $32.25
  Output: 0.75M × $15/MTok = $11.25
  Total: $43.50/month
```

**Cost Optimization Strategies**:
1. **Use Haiku for simple queries**: 80% of queries → Haiku ($7/month instead of $43)
2. **Cache system prompt**: Reduce repeated input tokens (Prompt Caching feature)
3. **Limit context**: Only include top 3 knowledge base results, not 10
4. **Streaming**: Start sending response before full generation (perceived faster, same cost)

---

## Guardrails & Safety

### Content Filtering

**Anthropic Built-in Safety**:
- Claude automatically refuses harmful requests
- No extra configuration needed

**Additional Filters for Domain-Specific Apps**:
```typescript
// PII detection (for healthcare, finance)
import { comprehend } from '@aws-sdk/client-comprehend'

async function detectPII(text: string) {
  const result = await comprehend.detectPiiEntities({
    Text: text,
    LanguageCode: 'en'
  })

  const hasPII = result.Entities.some(e =>
    ['SSN', 'CREDIT_CARD', 'EMAIL', 'PHONE'].includes(e.Type)
  )

  return hasPII
}

// Block responses containing PII
if (await detectPII(agentResponse)) {
  return "I cannot provide information containing personal data. Please rephrase."
}
```

---

### Hallucination Mitigation

**1. Cite Sources**
```typescript
// System prompt
`When answering from the knowledge base, always cite the source article.

Example:
"According to the Pricing FAQ, our Pro plan costs $99/month [Source: pricing-faq.md]"`
```

**2. Confidence Scoring**
```typescript
const tools = [{
  name: "search_knowledge_base",
  description: "Returns articles with confidence scores (0-1)"
}]

// If confidence < 0.7, escalate to human
if (searchResult.confidence < 0.7) {
  await createSupportTicket({ priority: 'medium', summary: userQuery })
  return "I'm not certain about this. I've created a ticket for our team."
}
```

**3. Fallback to Human**
```typescript
// Track turns in conversation
if (conversationTurns > 5 && !resolved) {
  return "I'm having trouble helping with this. Would you like me to connect you with a human agent?"
}
```

---

### Rate Limiting

**Per-User Limits**:
```typescript
const limiter = rateLimit({
  keyGenerator: (req) => req.userId,
  max: 100,  // 100 requests
  windowMs: 60 * 60 * 1000  // per hour
})

app.post('/chat', limiter, async (req, res) => {
  // Handle chat
})
```

**Token Budget Limits**:
```typescript
// Prevent runaway costs
const MAX_TOKENS_PER_USER_PER_DAY = 100000

const usage = await redis.get(`usage:${userId}:${today}`)
if (usage > MAX_TOKENS_PER_USER_PER_DAY) {
  return res.status(429).json({ error: 'Daily token limit exceeded' })
}
```

---

## Memory Strategy

### Short-Term: Conversation Context

**Last N Messages**:
```typescript
const messages = [
  { role: 'system', content: systemPrompt },
  ...conversationHistory.slice(-10),  // Last 10 messages
  { role: 'user', content: newMessage }
]
```

**Token Window Management**:
```typescript
function truncateToTokenLimit(messages, maxTokens = 100000) {
  let total = 0
  const result = []

  // Keep system prompt
  result.push(messages[0])
  total += countTokens(messages[0].content)

  // Add messages from newest to oldest until limit
  for (let i = messages.length - 1; i >= 1; i--) {
    const tokens = countTokens(messages[i].content)
    if (total + tokens > maxTokens) break
    result.unshift(messages[i])
    total += tokens
  }

  return result
}
```

---

### Long-Term: Vector Memory

**RAG (Retrieval-Augmented Generation)**:
```
User asks question
  ↓
Embed question (OpenAI ada-002: 1536 dimensions)
  ↓
Search vector DB for similar past conversations
  ↓
Include top 3 results in context
  ↓
LLM generates answer using retrieved context
```

**Implementation**:
```typescript
import { OpenAIEmbeddings } from '@langchain/openai'
import { Pinecone } from '@pinecone-database/pinecone'

// 1. Embed user question
const embeddings = new OpenAIEmbeddings()
const queryVector = await embeddings.embedQuery(userMessage)

// 2. Search Pinecone
const results = await pinecone.query({
  vector: queryVector,
  topK: 3,
  includeMetadata: true
})

// 3. Add to context
const context = results.matches.map(m => m.metadata.text).join('\n\n')

const messages = [
  { role: 'system', content: systemPrompt },
  {
    role: 'user',
    content: `Context from past conversations:\n${context}\n\nUser question: ${userMessage}`
  }
]
```

**Vector Database Options**:
- **Pinecone**: $70/month for 100K vectors (managed, easy)
- **Supabase Vector**: $25/month (if already using Supabase)
- **pgvector**: Free (self-hosted Postgres extension)

---

### User Profiles (Personalization)

**Store User Preferences**:
```sql
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY,
  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
  conversation_history JSONB[] NOT NULL DEFAULT ARRAY[]::jsonb[]
);

-- Example profile
{
  "name": "Alice",
  "timezone": "America/New_York",
  "language": "en",
  "interests": ["pricing", "API integration"],
  "preferred_response_style": "concise"
}
```

**Inject into System Prompt**:
```typescript
const profile = await db.query('SELECT preferences FROM user_profiles WHERE user_id = $1', [userId])

const systemPrompt = `You are a helpful assistant.
User profile:
- Name: ${profile.name}
- Preferred style: ${profile.preferred_response_style}
- Past topics of interest: ${profile.interests.join(', ')}

Adapt your responses to their preferences.`
```

---

## Performance Targets

### Latency

**First Token Time**:
- **Target**: <1 second (user perceives as "instant")
- **Claude Sonnet**: ~500ms typical
- **Claude Opus**: ~800ms typical

**Full Response**:
- **Target**: <3 seconds for 200-token response
- **Streaming**: Display tokens as generated (feels faster)

**Tool Execution**:
- **Target**: <500ms per tool call
- **Optimization**: Cache API results, use fast databases

---

### Throughput

**Concurrent Conversations**:
- **10 users**: Single API key handles easily
- **1000 users**: May need rate limit increase request
- **10K+ users**: Contact Anthropic for enterprise limits

**Queue Background Requests**:
```typescript
// For non-time-critical requests (email summaries, report generation)
await queue.add('generate-report', { userId, reportType })

worker.process('generate-report', async (job) => {
  const response = await anthropic.messages.create(...)
  await saveReport(job.data.userId, response)
})
```

---

## Database Schema

```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'active'  -- active, resolved, escalated
);

CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID NOT NULL,
  role TEXT NOT NULL,  -- user, assistant, system
  content TEXT NOT NULL,
  tokens_used INT,
  tool_calls JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tool_executions (
  id UUID PRIMARY KEY,
  message_id UUID NOT NULL,
  tool_name TEXT NOT NULL,
  input JSONB NOT NULL,
  output JSONB,
  success BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## Security Checklist

- [ ] Validate tool inputs (prevent injection attacks)
- [ ] Rate limit per user (prevent abuse)
- [ ] Token budget limits (prevent cost overruns)
- [ ] PII detection (for sensitive industries)
- [ ] Audit logging (all LLM calls logged)
- [ ] Content filtering (block harmful outputs)
- [ ] Cite sources (prevent hallucinations)
- [ ] Fallback to human (when confidence low)
- [ ] Secure API keys (never expose in client)

---

## Cost Implications

**Example: Support Chatbot (1000 conversations/month)**

**Option 1: All Sonnet**
- Cost: $43.50/month (calculated above)

**Option 2: 80% Haiku + 20% Sonnet**
- Haiku (800 convos): 800 × (10.75M input + 0.75M output) = 9.2M input + 0.6M output
  - Input: 9.2M × $0.25/MTok = $2.30
  - Output: 0.6M × $1.25/MTok = $0.75
- Sonnet (200 convos): 200 × 10.75M input + 0.75M output
  - Input: 2.15M × $3/MTok = $6.45
  - Output: 0.15M × $15/MTok = $2.25
- **Total**: $11.75/month (73% savings)

**Recommendation**: Use Haiku by default, upgrade to Sonnet if user query is complex or Haiku fails.

---

## Summary Checklist

- [ ] Choose orchestration pattern (ReAct, CoT, or multi-agent)
- [ ] Define tool schemas with clear descriptions
- [ ] Calculate token costs (input + output × pricing)
- [ ] Implement guardrails (PII, content filters, rate limits)
- [ ] Memory strategy (conversation context + vector search)
- [ ] Cite sources to prevent hallucinations
- [ ] Fallback to human when confidence low
- [ ] Stream responses for perceived speed
- [ ] Use Haiku for simple tasks (cost optimization)
- [ ] Cache system prompts (reduce input tokens)