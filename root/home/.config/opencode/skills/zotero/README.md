# Zotero API Skill for OpenCode

Comprehensive tools and workflows for interacting with Zotero libraries via the Web API.

## Installation

The skill is already installed in `~/.config/opencode/skills/zotero/`.

### Setup

1. **Get your Zotero credentials:**
   - User ID: https://www.zotero.org/settings/keys
   - API Key: https://www.zotero.org/settings/keys/new

2. **Configure environment variables:**

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export ZOTERO_API_KEY="your_api_key_here"
export ZOTERO_USER_ID="your_user_id_here"
export ZOTERO_GROUP_ID="your_group_id_here"  # Optional, for group libraries
```

3. **Add script to PATH (optional):**

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.config/opencode/skills/zotero:$PATH"
```

Or create a symlink:

```bash
sudo ln -s ~/.config/opencode/skills/zotero/opencode-zotero /usr/local/bin/
```

## Quick Start

```bash
# List collections
opencode-zotero collections

# Get items from a collection
opencode-zotero items COLLECTION_KEY

# Search for papers
opencode-zotero search "machine learning"

# Export to BibTeX
opencode-zotero export COLLECTION_KEY --format bibtex --output refs.bib

# Show item details
opencode-zotero show ITEM_KEY

# Move papers between collections
opencode-zotero move ITEM1 ITEM2 --from COLLECTION_A --to COLLECTION_B

# Add tags
opencode-zotero tag ITEM1 ITEM2 --add "reviewed" "important"

# Show statistics
opencode-zotero stats COLLECTION_KEY
```

## Usage Examples

### Example 1: Export Bibliography for LaTeX

```bash
# Export entire collection to BibTeX
opencode-zotero export MY_COLLECTION_KEY \
  --format bibtex \
  --output references.bib

# Use in LaTeX
# \bibliography{references}
```

### Example 2: Organize Papers

```bash
# List all collections to find keys
opencode-zotero collections

# Move papers from "To Review" to "Reviewed"
opencode-zotero move PAPER1 PAPER2 PAPER3 \
  --from TO_REVIEW_KEY \
  --to REVIEWED_KEY

# Add "reviewed" tag
opencode-zotero tag PAPER1 PAPER2 PAPER3 --add "reviewed"
```

### Example 3: Generate Website Bibliography

```bash
# Export as formatted HTML bibliography
opencode-zotero export MY_COLLECTION_KEY \
  --format bib \
  --style apa \
  --output bibliography.html
```

### Example 4: Search and Filter

```bash
# Search for papers about neural networks
opencode-zotero search "neural networks"

# Filter by type
opencode-zotero search "deep learning" --type journalArticle

# Filter by tag
opencode-zotero search "AI" --tag "machine learning"
```

## Python Library Usage

For more complex operations, use the Python requests library:

```python
#!/usr/bin/env python3
import os
import requests

API_KEY = os.getenv("ZOTERO_API_KEY")
GROUP_ID = os.getenv("ZOTERO_GROUP_ID")
BASE_URL = "https://api.zotero.org"

headers = {
    "Zotero-API-Key": API_KEY,
    "Zotero-API-Version": "3"
}

# Get all items
url = f"{BASE_URL}/groups/{GROUP_ID}/items"
response = requests.get(url, headers=headers)
items = response.json()

for item in items:
    print(item['data']['title'])
```

## Troubleshooting

### "ZOTERO_API_KEY not set"

Make sure you've exported the environment variable:

```bash
export ZOTERO_API_KEY="your_key_here"
```

Add it to `~/.bashrc` or `~/.zshrc` to make it permanent.

### "403 Forbidden"

Your API key doesn't have permission. Check:
1. API key is correct
2. API key has read/write permissions for the library
3. You're using the correct user/group ID

### "404 Not Found"

The collection or item key doesn't exist. Use:

```bash
opencode-zotero collections  # List all collections
```

## Documentation

See `SKILL.md` for complete API documentation, workflows, and examples.

## Resources

- Zotero API Docs: https://www.zotero.org/support/dev/web_api/v3/start
- Citation Styles: https://www.zotero.org/styles/
- Python Library: https://github.com/urschrei/pyzotero
