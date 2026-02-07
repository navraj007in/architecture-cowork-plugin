---
name: export-docx
description: Convert architecture documents (blueprints, stakeholder presentations) from Markdown to professionally formatted Word (.docx) files. Applies corporate styling, embeds PNG diagrams, and creates presentation-ready documents.
---

# Markdown to Word Exporter

Convert architecture documents to **professionally formatted Word documents** (.docx) ready for stakeholder presentations, board meetings, and executive approvals.

**Perfect for**: Executive presentations, board decks, budget approvals, RFPs, investor updates, compliance documentation

---

## When to Use This Skill

Use this skill when you need to:
- Share architecture with stakeholders who prefer Word documents
- Present to executives, board members, or finance teams
- Submit RFPs or proposals to clients/agencies
- Create formal documentation for compliance or audits
- Generate printable architecture documents
- Integrate with corporate document management systems

**Input**: Markdown file (blueprint or stakeholder presentation)
**Output**: Professionally formatted .docx file

---

## Supported Document Types

### 1. Stakeholder Presentations
**Input**: `stakeholder-presentation.md` (from `/architect:stakeholder-doc`)
**Output**: `stakeholder-presentation.docx`

**Formatting**:
- Professional cover page with title, date, version
- Table of contents with page numbers
- Section headings with corporate styling
- Embedded PNG diagrams (from `diagrams/` folder)
- Tables with alternating row colors
- Approval checklist with signature fields
- Page numbers and headers/footers

### 2. Full Architecture Blueprints
**Input**: `blueprint.md` (from `/architect:blueprint`)
**Output**: `architecture-blueprint.docx`

**Formatting**:
- All 19 sections with proper hierarchy
- Syntax-highlighted code blocks
- Embedded diagrams
- Cross-references between sections
- Appendices with glossary and references

### 3. Sprint Backlogs
**Input**: Sprint backlog section or standalone sprint doc
**Output**: `sprint-backlog.docx`

**Formatting**:
- User stories as numbered lists
- Acceptance criteria as checkboxes
- Sprint timeline as table
- Priority indicators (High/Medium/Low with colors)

---

## How It Works

### Step 1: Detect Input Document Type

Analyze markdown to determine document type:
- Contains "Executive Summary" + "Approval Checklist" → Stakeholder presentation
- Contains 19 sections + "Architecture Assumptions" → Full blueprint
- Contains "Sprint X" + "User Stories" → Sprint backlog

### Step 2: Convert Markdown to DOCX

Use **Pandoc** (preferred) or **markdown-to-docx** library:

#### Option A: Pandoc (Recommended)

```bash
pandoc stakeholder-presentation.md \
  -o stakeholder-presentation.docx \
  --reference-doc=template.docx \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --highlight-style=tango
```

**Pandoc features**:
- Table of contents with page numbers
- Section numbering
- Syntax highlighting for code blocks
- Custom styling via reference template
- Image embedding
- Table formatting

#### Option B: markdown-to-docx (Fallback)

If Pandoc not available, use Node.js library:

```bash
npm install markdown-to-docx

# Convert with basic styling
markdown-to-docx --input stakeholder-presentation.md \
                 --output stakeholder-presentation.docx \
                 --style professional
```

### Step 3: Apply Corporate Styling

Use reference template (`template.docx`) with:

#### Typography
- **Headings**: Calibri Bold
  - H1: 20pt, Dark Blue (#1F4E78)
  - H2: 16pt, Dark Blue (#1F4E78)
  - H3: 14pt, Dark Gray (#333333)
- **Body text**: Calibri 11pt, Black (#000000)
- **Code**: Consolas 10pt, Gray background (#F5F5F5)

#### Colors
- **Success/Recommended**: Green (#28A745) - for ✅ checkmarks
- **Warning/Risk**: Orange (#FFA500) - for ⚠️ warnings
- **Error/High Risk**: Red (#DC3545) - for ❌ items
- **Info**: Blue (#007BFF) - for ℹ️ notes

#### Page Layout
- **Margins**: 1 inch all sides
- **Page size**: Letter (8.5" × 11") or A4
- **Orientation**: Portrait
- **Header**: Document title + date (top right)
- **Footer**: Page numbers (bottom center) + "Confidential" (bottom left)

#### Tables
- **Header row**: Dark blue background (#1F4E78), white text, bold
- **Alternating rows**: White and light gray (#F9F9F9)
- **Borders**: 1pt solid gray (#CCCCCC)
- **Cell padding**: 8pt

#### Images/Diagrams
- **Alignment**: Center
- **Width**: 90% of page width (max 6 inches)
- **Caption**: Below image, 10pt italic, centered
- **Spacing**: 12pt before and after

### Step 4: Embed PNG Diagrams

Replace markdown image references with embedded PNGs:

**Markdown**:
```markdown
![Architecture Diagram](./diagrams/architecture-container.png)
*System components and how they connect*
```

**DOCX conversion**:
- Embed `diagrams/architecture-container.png` as inline image
- Resize to 6 inches wide (maintain aspect ratio)
- Add caption "Figure 1: System components and how they connect"
- Center-align

**Auto-numbering**: Figures numbered sequentially (Figure 1, Figure 2, etc.)

### Step 5: Format Special Elements

#### Checkboxes (Approval Checklist)
**Markdown**:
```markdown
- [ ] Budget approved
- [x] Timeline approved
```

**DOCX**:
- Unchecked: ☐ Budget approved
- Checked: ☑ Timeline approved
- Use checkbox form fields for interactive PDFs

#### Tables
**Markdown**:
```markdown
| Component | Cost |
|-----------|------|
| Frontend  | $20  |
```

**DOCX**:
- Apply table style with header row formatting
- Align numbers right, text left
- Add borders and alternating row colors

#### Code Blocks
**Markdown**:
````markdown
```bash
npm install
```
````

**DOCX**:
- Monospace font (Consolas 10pt)
- Light gray background (#F5F5F5)
- 1pt border
- Syntax highlighting if Pandoc used

#### Callouts/Admonitions
**Markdown**:
```markdown
> **Note**: Start with managed platforms, upgrade to AWS when >100K users.
```

**DOCX**:
- Light blue background (#E7F3FF)
- Blue left border (4pt, #007BFF)
- Italic text
- "Note:" in bold

### Step 6: Add Cover Page

For stakeholder presentations, generate professional cover page:

```
═══════════════════════════════════════════════════════

              [PROJECT NAME]
        Architecture & Implementation Plan

───────────────────────────────────────────────────────

Prepared for:    [Stakeholder Name/Team]
Prepared by:     Architect AI
Date:            [Generation Date]
Version:         1.0

[Optional: Company Logo]

═══════════════════════════════════════════════════════
```

**Styling**:
- Center-aligned
- Project name: 24pt bold, dark blue
- Subtitle: 16pt regular, gray
- Metadata: 11pt, left-aligned in centered block
- Full-page layout (no header/footer)

### Step 7: Add Table of Contents

Generate TOC with:
- All H2 and H3 headings
- Page numbers (right-aligned with dot leaders)
- Clickable links (in digital version)
- Max 3 levels deep

**Example**:
```
Table of Contents

Executive Summary................................................1
Solution Overview................................................3
  High-Level Architecture Diagram................................3
  Solution Components............................................4
  Key Capabilities...............................................5
Technology Stack & Decisions.....................................6
  Decision 1: Database - PostgreSQL..............................6
  Decision 2: Hosting - Managed Platforms........................7
Cost Breakdown...................................................9
  Infrastructure Costs..........................................9
  Development Costs.............................................10
[...]
```

### Step 8: Add Approval Section

For stakeholder presentations, format approval section as form:

```
═══════════════════════════════════════════════════════
                   APPROVAL SECTION
═══════════════════════════════════════════════════════

Budget Approved:         ☐ Yes   ☐ No

Timeline Approved:       ☐ Yes   ☐ No

Technical Approach:      ☐ Yes   ☐ No

Risk Mitigation:         ☐ Yes   ☐ No

───────────────────────────────────────────────────────

Decision Required By: ____________________

Approved By: __________________________  Date: _________

Title: _________________________________________________

Signature: ____________________________________________

───────────────────────────────────────────────────────
```

---

## Output Format

When invoked, generate:

```
📄 Converting markdown to Word document...

✅ Detected document type: Stakeholder Presentation
✅ Parsed markdown structure (11 sections, 47 pages)
✅ Embedded 6 PNG diagrams from diagrams/ folder
✅ Applied corporate styling (Calibri, professional theme)
✅ Generated table of contents (3 levels, 28 entries)
✅ Formatted 8 tables with headers and alternating rows
✅ Added cover page with metadata
✅ Added approval section with signature fields

📄 stakeholder-presentation.docx created (2.4 MB, 47 pages)

Ready for stakeholder review!

Next steps:
- Review document in Microsoft Word or Google Docs
- Customize cover page with company logo
- Adjust approval checklist if needed
- Export to PDF for distribution: File → Export → PDF
```

---

## Customization Options

**Optional parameters** (ask user if they want to customize):

1. **Company logo**: Upload logo for cover page (PNG/SVG, max 200px height)
2. **Color scheme**: Default (blue), Corporate (gray), Custom (specify hex codes)
3. **Page size**: Letter (default), A4, Legal
4. **Font**: Calibri (default), Arial, Times New Roman
5. **Confidentiality level**: Confidential (default), Internal Use Only, Public
6. **Version number**: 1.0 (default), custom

**Default behavior**: Blue color scheme, Letter size, Calibri font, "Confidential" footer, version 1.0.

---

## Export Options

### Option 1: DOCX only
```bash
/architect:export-docx
# → stakeholder-presentation.docx
```

### Option 2: DOCX + PDF
```bash
/architect:export-docx --pdf
# → stakeholder-presentation.docx
# → stakeholder-presentation.pdf
```

### Option 3: Custom styling
```bash
/architect:export-docx --logo=logo.png --color=corporate --size=a4
# → stakeholder-presentation.docx (A4, corporate colors, with logo)
```

---

## Technical Implementation

### Pandoc Conversion Command

```bash
#!/bin/bash
# Convert markdown to DOCX with full styling

INPUT="stakeholder-presentation.md"
OUTPUT="stakeholder-presentation.docx"
TEMPLATE="template.docx"  # Reference template with corporate styling

# Create reference template if it doesn't exist
if [ ! -f "$TEMPLATE" ]; then
  pandoc --print-default-data-file reference.docx > "$TEMPLATE"
  # Customize template.docx with corporate styling
fi

# Convert with Pandoc
pandoc "$INPUT" \
  -o "$OUTPUT" \
  --reference-doc="$TEMPLATE" \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --highlight-style=tango \
  --resource-path=".:diagrams" \
  --metadata title="Architecture & Implementation Plan" \
  --metadata author="Architect AI" \
  --metadata date="$(date +%Y-%m-%d)"

echo "✅ Created $OUTPUT"
```

### Reference Template Creation

```bash
# Generate default template
pandoc --print-default-data-file reference.docx > template.docx

# Customize template.docx:
# 1. Open in Microsoft Word
# 2. Modify styles (Heading 1, Heading 2, Normal, etc.)
# 3. Set page layout (margins, headers, footers)
# 4. Configure table styles
# 5. Save and close

# Template is now ready for repeated use
```

### PDF Export (if requested)

```bash
# Option A: Use LibreOffice (headless)
libreoffice --headless \
            --convert-to pdf \
            stakeholder-presentation.docx \
            --outdir .

# Option B: Use Pandoc with LaTeX
pandoc stakeholder-presentation.md \
  -o stakeholder-presentation.pdf \
  --pdf-engine=xelatex \
  --toc \
  --number-sections
```

---

## Error Handling

### If Pandoc not installed:
- **Action**: Fallback to markdown-to-docx library
- **Notify user**: "ℹ️ Using basic conversion (Pandoc not found). Install Pandoc for better formatting."
- **Install prompt**: "Run: brew install pandoc (Mac) or apt install pandoc (Linux)"

### If diagrams/ folder missing:
- **Action**: Continue conversion, skip image embedding
- **Notify user**: "⚠️ diagrams/ folder not found. Run `/architect:export-diagrams` first for embedded images."

### If reference template missing:
- **Action**: Generate default template on-the-fly
- **Notify user**: "ℹ️ Using default styling. Customize template.docx for corporate branding."

### If input markdown not found:
- **Action**: Error with guidance
- **Example**: "❌ stakeholder-presentation.md not found. Run `/architect:stakeholder-doc` first."

---

## Integration with Other Skills

### Recommended workflow:

```bash
# 1. Generate blueprint
/architect:blueprint

# 2. Create stakeholder presentation
/architect:stakeholder-doc

# 3. Export diagrams to PNG
/architect:export-diagrams

# 4. Convert to Word document
/architect:export-docx

# Result: stakeholder-presentation.docx ready for executives!
```

---

## Success Criteria

A successful DOCX export should:
- ✅ Preserve all markdown content (no data loss)
- ✅ Apply professional corporate styling
- ✅ Embed all PNG diagrams at appropriate sizes
- ✅ Generate table of contents with page numbers
- ✅ Format tables with headers and alternating rows
- ✅ Add cover page with metadata
- ✅ Add headers/footers with page numbers
- ✅ Include approval section with signature fields
- ✅ Be editable in Microsoft Word or Google Docs
- ✅ Be print-ready (proper margins, page breaks)

---

## Files Created

```
stakeholder-presentation.docx        # Main output (2-5 MB)
stakeholder-presentation.pdf         # Optional PDF export
template.docx                        # Reference template (reusable)
```

**File sizes**:
- DOCX: 2-5 MB (with embedded diagrams)
- PDF: 1-3 MB (compressed diagrams)
- Template: 50-100 KB

---

## Advanced Features

### Custom Branding

Replace default template with corporate template:

```bash
# 1. Create corporate template
# - Open template.docx in Word
# - Apply corporate fonts, colors, logo
# - Save as corporate-template.docx

# 2. Use custom template
/architect:export-docx --template=corporate-template.docx
```

### Batch Export

Export multiple documents at once:

```bash
# Export all markdown files in current directory
/architect:export-docx --batch *.md

# Output:
# ✅ blueprint.docx
# ✅ stakeholder-presentation.docx
# ✅ sprint-backlog.docx
```

### Version Control

Automatically version documents:

```bash
/architect:export-docx --version=2.1

# Output: stakeholder-presentation-v2.1.docx
# Footer: "Version 2.1 - Generated 2026-02-07"
```

---

## Examples

### Example 1: Basic Stakeholder Doc Export

```bash
/architect:export-docx

# Output:
# ✅ stakeholder-presentation.docx created (47 pages, 2.4 MB)
```

### Example 2: With Company Logo and PDF

```bash
/architect:export-docx --logo=acme-logo.png --pdf

# Output:
# ✅ stakeholder-presentation.docx (with Acme logo)
# ✅ stakeholder-presentation.pdf
```

### Example 3: Full Blueprint Export

```bash
/architect:export-docx blueprint.md --output=architecture-blueprint.docx

# Output:
# ✅ architecture-blueprint.docx (19 sections, 87 pages)
```

---

## Quality Assurance

Before considering export complete, verify:

- [ ] All sections from markdown are present in DOCX
- [ ] All diagrams are embedded and visible
- [ ] Table of contents has correct page numbers
- [ ] Tables are formatted with headers
- [ ] Code blocks use monospace font
- [ ] Cover page has correct metadata
- [ ] Approval section has signature fields
- [ ] Headers/footers are present on all pages (except cover)
- [ ] Page numbers start from correct page
- [ ] Document is editable without errors
- [ ] File size is reasonable (<10 MB)

---

## Troubleshooting

### Problem: Images are too large/small
**Solution**: Adjust max-width in Pandoc:
```bash
pandoc ... --metadata max-width=6in
```

### Problem: Table of contents missing
**Solution**: Ensure `--toc` flag is used and H2/H3 headings exist

### Problem: Code blocks lose formatting
**Solution**: Use `--highlight-style=tango` and monospace font in template

### Problem: PDF export fails
**Solution**: Install required LaTeX packages or use LibreOffice conversion

### Problem: Special characters corrupted
**Solution**: Ensure UTF-8 encoding:
```bash
pandoc ... --metadata charset=utf-8
```
