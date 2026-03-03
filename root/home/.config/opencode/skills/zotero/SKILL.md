---
name: zotero
description: >
  Tools and workflows for interacting with the Zotero Web API. Use when managing Zotero libraries,
  organizing research papers, retrieving bibliographies, searching citations, or automating
  reference management. Triggers: Zotero API, bibliography, citations, research papers, reference
  management, literature review, paper organization, collection management, export citations,
  formatted references, BibTeX, RIS, CSL-JSON, academic research.
---

# Zotero API Skill

Comprehensive tools and workflows for interacting with Zotero libraries via the Web API.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Accessing Zotero libraries programmatically
- Retrieving papers or citations from Zotero
- Organizing research papers in collections
- Moving items between Zotero collections
- Exporting bibliographies in various formats
- Searching Zotero libraries
- Generating formatted citations
- Managing research literature
- Automating reference workflows
- Querying Zotero metadata

## What It Provides

This skill provides:
1. **Helper script** (`opencode-zotero`) for common Zotero API operations
2. **Python library** for programmatic access
3. **Workflows** for typical research tasks
4. **API documentation** and examples

## Quick Start

### 1. Get Your Credentials

You need two things:
- **User ID**: Found at https://www.zotero.org/settings/keys
- **API Key**: Create at https://www.zotero.org/settings/keys/new

### 2. Configure

```bash
# Set environment variables (add to ~/.bashrc or ~/.zshrc)
export ZOTERO_API_KEY="your_api_key_here"
export ZOTERO_USER_ID="your_user_id_here"
export ZOTERO_GROUP_ID="your_group_id_here"  # Optional, for group libraries
```

### 3. Use the Helper Script

```bash
# List all collections
opencode-zotero collections

# Get items from a collection
opencode-zotero items COLLECTION_KEY

# Search for papers
opencode-zotero search "memory systems"

# Export bibliography
opencode-zotero export COLLECTION_KEY --format bibtex

# Move papers between collections
opencode-zotero move ITEM_KEY --from COLLECTION_A --to COLLECTION_B
```

## Zotero API Basics

### Base URL
```
https://api.zotero.org
```

### Authentication
Include API key in requests:
```bash
curl -H "Zotero-API-Key: YOUR_KEY" \
     -H "Zotero-API-Version: 3" \
     "https://api.zotero.org/users/USER_ID/items"
```

### Library Types

**Personal Library:**
```
/users/{userID}/...
```

**Group Library:**
```
/groups/{groupID}/...
```

## Common Endpoints

### Collections

```bash
# List all collections
GET /users/{userID}/collections
GET /groups/{groupID}/collections

# Get specific collection
GET /users/{userID}/collections/{collectionKey}

# Get items in collection
GET /users/{userID}/collections/{collectionKey}/items
GET /users/{userID}/collections/{collectionKey}/items/top  # Top-level only
```

### Items

```bash
# All items
GET /users/{userID}/items

# Top-level items (no child attachments)
GET /users/{userID}/items/top

# Specific item
GET /users/{userID}/items/{itemKey}

# Items in trash
GET /users/{userID}/items/trash

# Search items
GET /users/{userID}/items?q=search+term

# Filter by tag
GET /users/{userID}/items?tag=machine+learning

# Filter by item type
GET /users/{userID}/items?itemType=journalArticle
```

### Export Formats

```bash
# Formatted bibliography (HTML)
GET /users/{userID}/collections/{key}/items?format=bib&style=apa

# BibTeX
GET /users/{userID}/items?format=bibtex

# RIS
GET /users/{userID}/items?format=ris

# CSL-JSON
GET /users/{userID}/items?format=csljson

# Other formats: biblatex, mods, refer, tei, wikipedia
```

### Response Formats

```bash
# JSON (default)
GET /users/{userID}/items

# Atom feed
GET /users/{userID}/items?format=atom

# Keys only (newline-separated)
GET /users/{userID}/items?format=keys

# Versions (key-version pairs)
GET /users/{userID}/items?format=versions
```

## Common Workflows

### Workflow 1: Organize Papers by Relevance

**Scenario**: Review papers in "Advisor Review" collection and move less relevant ones to "In Lite Review"

```python
#!/usr/bin/env python3
import requests

API_KEY = "your_key"
GROUP_ID = "your_group_id"
BASE_URL = "https://api.zotero.org"

def get_headers(version=None):
    headers = {
        "Zotero-API-Key": API_KEY,
        "Zotero-API-Version": "3",
        "Content-Type": "application/json"
    }
    if version:
        headers["If-Unmodified-Since-Version"] = str(version)
    return headers

def get_collection_items(collection_key):
    url = f"{BASE_URL}/groups/{GROUP_ID}/collections/{collection_key}/items/top"
    response = requests.get(url, headers=get_headers())
    return response.json()

def move_item(item_key, from_collection, to_collection):
    # Get current item
    url = f"{BASE_URL}/groups/{GROUP_ID}/items/{item_key}"
    response = requests.get(url, headers=get_headers())
    item = response.json()
    
    # Update collections
    collections = item['data']['collections']
    collections = [c for c in collections if c != from_collection]
    if to_collection not in collections:
        collections.append(to_collection)
    
    # PATCH update
    patch_data = {"collections": collections}
    response = requests.patch(
        url,
        headers=get_headers(item['version']),
        json=patch_data
    )
    return response.status_code == 204

# Example usage
items = get_collection_items("ADVISOR_REVIEW_KEY")
for item in items:
    if should_move(item):  # Your logic here
        move_item(item['key'], "ADVISOR_REVIEW_KEY", "LITE_REVIEW_KEY")
```

### Workflow 2: Generate Bibliography for Website

```python
def get_formatted_bibliography(collection_key, style="apa"):
    url = f"{BASE_URL}/groups/{GROUP_ID}/collections/{collection_key}/items"
    params = {
        "format": "bib",
        "style": style,
        "linkwrap": "1"  # Make URLs clickable
    }
    response = requests.get(url, headers=get_headers(), params=params)
    return response.text

# Get APA-formatted bibliography
html = get_formatted_bibliography("MY_COLLECTION", style="apa")
print(html)
```

### Workflow 3: Search and Filter Papers

```python
def search_papers(query, item_type=None, tags=None):
    url = f"{BASE_URL}/groups/{GROUP_ID}/items"
    params = {"q": query}
    
    if item_type:
        params["itemType"] = item_type
    if tags:
        params["tag"] = " && ".join(tags)
    
    response = requests.get(url, headers=get_headers(), params=params)
    return response.json()

# Search for machine learning papers
papers = search_papers("machine learning", item_type="journalArticle")

# Search with multiple tags
papers = search_papers("neural networks", tags=["deep learning", "AI"])
```

### Workflow 4: Export to BibTeX

```bash
# Using curl
curl -H "Zotero-API-Key: YOUR_KEY" \
     "https://api.zotero.org/groups/GROUP_ID/collections/COLLECTION_KEY/items?format=bibtex" \
     > references.bib
```

```python
# Using Python
def export_bibtex(collection_key, output_file):
    url = f"{BASE_URL}/groups/{GROUP_ID}/collections/{collection_key}/items"
    params = {"format": "bibtex"}
    
    response = requests.get(url, headers=get_headers(), params=params)
    
    with open(output_file, 'w') as f:
        f.write(response.text)
    
    print(f"Exported to {output_file}")

export_bibtex("MY_COLLECTION", "references.bib")
```

### Workflow 5: Bulk Tag Management

```python
def add_tag_to_items(item_keys, tag):
    for item_key in item_keys:
        # Get item
        url = f"{BASE_URL}/groups/{GROUP_ID}/items/{item_key}"
        response = requests.get(url, headers=get_headers())
        item = response.json()
        
        # Add tag
        tags = item['data']['tags']
        if {"tag": tag} not in tags:
            tags.append({"tag": tag})
        
        # Update
        patch_data = {"tags": tags}
        requests.patch(
            url,
            headers=get_headers(item['version']),
            json=patch_data
        )

# Add "reviewed" tag to multiple papers
add_tag_to_items(["ITEM1", "ITEM2", "ITEM3"], "reviewed")
```

## API Parameters Reference

### Search Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `q` | string | Quick search (titles, creators) |
| `qmode` | `titleCreatorYear`, `everything` | Search mode |
| `tag` | string | Filter by tag (supports boolean: `tag1 && tag2`) |
| `itemType` | string | Filter by type (e.g., `book`, `journalArticle`) |
| `since` | integer | Only items modified after this version |

### Sorting & Pagination

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `sort` | `dateAdded`, `dateModified`, `title`, `creator` | `dateModified` | Sort field |
| `direction` | `asc`, `desc` | varies | Sort direction |
| `limit` | 1-100 | 25 | Results per page |
| `start` | integer | 0 | Starting index |

### Format Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `format` | `json`, `atom`, `bib`, `keys`, `versions`, export formats | Response format |
| `style` | string | Citation style (e.g., `apa`, `chicago`, `mla`) |
| `include` | `data`, `bib`, `citation` | Additional data to include |
| `linkwrap` | `0`, `1` | Wrap URLs as links in bibliography |

## Citation Styles

Popular styles available:
- `apa` - APA 7th edition
- `chicago-note-bibliography` - Chicago (default)
- `mla` - MLA 9th edition
- `harvard1` - Harvard
- `ieee` - IEEE
- `nature` - Nature
- `science` - Science
- `vancouver` - Vancouver

Full list: https://www.zotero.org/styles/

## Item Types

Common item types:
- `journalArticle` - Journal article
- `book` - Book
- `bookSection` - Book chapter
- `conferencePaper` - Conference paper
- `thesis` - Thesis/dissertation
- `preprint` - Preprint
- `webpage` - Web page
- `report` - Report
- `patent` - Patent

## Write Operations

### Update Item Collections

```python
# PATCH method (recommended for partial updates)
PATCH /groups/{groupID}/items/{itemKey}
Headers:
  If-Unmodified-Since-Version: {version}
  Content-Type: application/json
Body:
  {"collections": ["COLLECTION_KEY_1", "COLLECTION_KEY_2"]}
```

### Update Item Metadata

```python
# PATCH specific fields
PATCH /groups/{groupID}/items/{itemKey}
Headers:
  If-Unmodified-Since-Version: {version}
Body:
  {
    "title": "New Title",
    "date": "2024",
    "tags": [{"tag": "machine learning"}]
  }
```

### Create New Item

```python
# First get template
GET /items/new?itemType=journalArticle

# Then POST with data
POST /groups/{groupID}/items
Body:
  [{
    "itemType": "journalArticle",
    "title": "My Paper",
    "creators": [{"creatorType": "author", "firstName": "John", "lastName": "Doe"}],
    "collections": ["COLLECTION_KEY"]
  }]
```

## Rate Limiting

- Be prepared for `Backoff: <seconds>` header
- Handle `429 Too Many Requests` with exponential backoff
- Add delays between requests (0.5-1s recommended)

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 200 | Success | Process response |
| 204 | Success (no content) | Operation completed |
| 304 | Not Modified | Use cached data |
| 400 | Bad Request | Check request format |
| 403 | Forbidden | Check API key permissions |
| 404 | Not Found | Check item/collection key |
| 409 | Conflict | Library is locked, retry |
| 412 | Precondition Failed | Version mismatch, refetch |
| 429 | Too Many Requests | Rate limited, back off |

## Best Practices

1. **Use conditional requests** with `If-Modified-Since-Version` to avoid unnecessary data transfer
2. **Cache responses** when data doesn't change frequently
3. **Use PATCH** instead of PUT for partial updates
4. **Batch operations** when possible (up to 50 items)
5. **Handle rate limits** gracefully with exponential backoff
6. **Store version numbers** to prevent conflicts
7. **Use `format=keys`** when you only need item keys (faster)
8. **Request only needed fields** with `include` parameter

## Troubleshooting

### Issue: 403 Forbidden
**Cause**: Invalid API key or insufficient permissions  
**Solution**: Check API key at https://www.zotero.org/settings/keys

### Issue: 412 Precondition Failed
**Cause**: Item version mismatch  
**Solution**: Refetch item to get latest version before updating

### Issue: Empty response
**Cause**: Collection/item doesn't exist or no items match query  
**Solution**: Verify collection/item keys, check query parameters

### Issue: Rate limiting (429)
**Cause**: Too many requests  
**Solution**: Add delays between requests, implement exponential backoff

## Examples

### Example 1: List All Collections

```bash
curl -H "Zotero-API-Key: YOUR_KEY" \
     "https://api.zotero.org/groups/GROUP_ID/collections?v=3" | \
     python3 -c "
import json, sys
collections = json.load(sys.stdin)
for c in collections:
    print(f'{c[\"data\"][\"name\"]} ({c[\"key\"]}): {c[\"meta\"][\"numItems\"]} items')
"
```

### Example 2: Get Paper Titles

```bash
curl -H "Zotero-API-Key: YOUR_KEY" \
     "https://api.zotero.org/groups/GROUP_ID/collections/COLLECTION_KEY/items/top?v=3" | \
     python3 -c "
import json, sys
items = json.load(sys.stdin)
for i, item in enumerate(items, 1):
    print(f'{i}. {item[\"data\"][\"title\"]}')
"
```

### Example 3: Search and Export

```python
#!/usr/bin/env python3
import requests
import sys

API_KEY = sys.argv[1]
GROUP_ID = sys.argv[2]
QUERY = sys.argv[3]

headers = {
    "Zotero-API-Key": API_KEY,
    "Zotero-API-Version": "3"
}

# Search
url = f"https://api.zotero.org/groups/{GROUP_ID}/items"
params = {"q": QUERY, "format": "bibtex"}

response = requests.get(url, headers=headers, params=params)
print(response.text)
```

Usage:
```bash
python3 search_export.py YOUR_KEY GROUP_ID "neural networks" > results.bib
```

## Resources

- **API Documentation**: https://www.zotero.org/support/dev/web_api/v3/start
- **Citation Styles**: https://www.zotero.org/styles/
- **Python Library**: https://github.com/urschrei/pyzotero
- **JavaScript Library**: https://github.com/tnajdek/zotero-api-client
- **Support Forum**: https://forums.zotero.org/

## Helper Script Usage

The `opencode-zotero` script provides convenient commands:

```bash
# List collections
opencode-zotero collections [--user USER_ID | --group GROUP_ID]

# Get items
opencode-zotero items COLLECTION_KEY [--format json|bib|bibtex]

# Search
opencode-zotero search QUERY [--type TYPE] [--tag TAG]

# Export
opencode-zotero export COLLECTION_KEY --format FORMAT --output FILE

# Move items
opencode-zotero move ITEM_KEY... --from COLLECTION --to COLLECTION

# Show item details
opencode-zotero show ITEM_KEY

# Add tags
opencode-zotero tag ITEM_KEY... --add TAG

# Statistics
opencode-zotero stats [COLLECTION_KEY]
```

## Notes

- Always use API version 3 (`Zotero-API-Version: 3` header)
- Personal libraries use `/users/{userID}`, group libraries use `/groups/{groupID}`
- Collection keys are 8-character alphanumeric strings
- Item keys are 8-character alphanumeric strings
- Version numbers are integers used for conflict detection
- Some operations require write permissions on your API key
