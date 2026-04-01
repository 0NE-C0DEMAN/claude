@echo off
echo Creating product-self-knowledge skill files...

mkdir "product-self-knowledge" 2>nul

echo Writing product-self-knowledge\SKILL.md...
(
echo ---
echo name: product-self-knowledge
echo description: ^"Stop and consult this skill whenever your response would include specific facts about Anthropic's products. Covers: Claude Code ^(how to install, Node.js requirements, platform/OS support, MCP server integration, configuration^), Claude API ^(function calling/tool use, batch processing, SDK usage, rate limits, pricing, models, streaming^), and Claude.ai ^(Pro vs Team vs Enterprise plans, feature limits^). Trigger this even for coding tasks that use the Anthropic SDK, content creation mentioning Claude capabilities or pricing, or LLM provider comparisons. Any time you would otherwise rely on memory for Anthropic product details, verify here instead — your training data may be outdated or wrong.^"
echo ---
echo 
echo # Anthropic Product Knowledge
echo 
echo ## Core Principles
echo 
echo 1. **Accuracy over guessing** - Check official docs when uncertain
echo 2. **Distinguish products** - Claude.ai, Claude Code, and Claude API are separate products
echo 3. **Source everything** - Always include official documentation URLs
echo 4. **Right resource first** - Use the correct docs for each product ^(see routing below^)
echo 
echo ---
echo 
echo ## Question Routing
echo 
echo ### Claude API or Claude Code questions?
echo 
echo → **Check the docs maps first**, then navigate to specific pages:
echo 
echo - **Claude API ^& General:** https://docs.claude.com/en/docs_site_map.md
echo - **Claude Code:** https://docs.anthropic.com/en/docs/claude-code/claude_code_docs_map.md
echo 
echo ### Claude.ai questions?
echo 
echo → **Browse the support page:**
echo 
echo - **Claude.ai Help Center:** https://support.claude.com
echo 
echo ---
echo 
echo ## Response Workflow
echo 
echo 1. **Identify the product** - API, Claude Code, or Claude.ai?
echo 2. **Use the right resource** - Docs maps for API/Code, support page for Claude.ai
echo 3. **Verify details** - Navigate to specific documentation pages
echo 4. **Provide answer** - Include source link and specify which product
echo 5. **If uncertain** - Direct user to relevant docs: ^"For the most current information, see [URL]^"
echo 
echo ---
echo 
echo ## Quick Reference
echo 
echo **Claude API:**
echo 
echo - Documentation: https://docs.claude.com/en/api/overview
echo - Docs Map: https://docs.claude.com/en/docs_site_map.md
echo 
echo **Claude Code:**
echo 
echo - Documentation: https://docs.claude.com/en/docs/claude-code/overview
echo - Docs Map: https://docs.anthropic.com/en/docs/claude-code/claude_code_docs_map.md
echo - npm Package: https://www.npmjs.com/package/@anthropic-ai/claude-code
echo 
echo **Claude.ai:**
echo 
echo - Support Center: https://support.claude.com
echo - Getting Help: https://support.claude.com/en/articles/9015913-how-to-get-support
echo 
echo **Other:**
echo 
echo - Product News: https://www.anthropic.com/news
echo - Enterprise Sales: https://www.anthropic.com/contact-sales
) > "product-self-knowledge\SKILL.md"

echo.
echo Done! product-self-knowledge files created.
pause