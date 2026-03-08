#!/usr/bin/env bash
set -euo pipefail

# publish.sh - Convert a markdown file with YAML frontmatter into a blog post
# and add it to blog.html and the Recent Writing section on index.html.
#
# Usage:
#   bash publish.sh md/my-new-post.md
#
# The markdown file should have YAML frontmatter:
#   ---
#   title: My Post Title
#   date: 2026-03-07
#   ---
#   Post content here...

if [ $# -lt 1 ]; then
  echo "Usage: bash publish.sh <markdown-file>"
  echo "  The markdown file should have YAML frontmatter with title and date."
  exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: file '$INPUT' not found."
  exit 1
fi

if ! command -v pandoc &> /dev/null; then
  echo "Error: pandoc is not installed. Install it with: winget install pandoc"
  exit 1
fi

# --- Parse YAML frontmatter (or fall back to CLI args) ---
TITLE=""
DATE=""

if head -1 "$INPUT" | grep -q '^---$'; then
  FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$INPUT" | sed '1d;$d')
  TITLE=$(echo "$FRONTMATTER" | grep '^title:' | sed 's/^title:[[:space:]]*//')
  DATE=$(echo "$FRONTMATTER" | grep '^date:' | sed 's/^date:[[:space:]]*//')
fi

# Fall back to CLI args (old workflow: bash publish.sh file.md "Title")
if [ -z "$TITLE" ] && [ $# -ge 2 ]; then
  TITLE="$2"
fi

if [ -z "$TITLE" ]; then
  echo "Error: no title found. Add YAML frontmatter or pass title as second argument."
  echo "  Frontmatter: add '---' block with 'title: My Title' at top of file"
  echo "  CLI: bash publish.sh file.md \"My Title\""
  exit 1
fi

if [ -z "$DATE" ]; then
  DATE=$(date +%Y-%m-%d)
  echo "No date specified, using today: $DATE"
fi

echo "Title: $TITLE"
echo "Date:  $DATE"

# --- Derive filename ---
x="$INPUT"
FILENAME_WITH_EXT="${x##*/}"
FILENAME="${FILENAME_WITH_EXT%.md}"

echo "Output: blog/${FILENAME}.html"

# --- Ensure conversion directory exists ---
mkdir -p conversion

# --- Convert markdown to HTML ---
pandoc "$INPUT" -f markdown -t html -o "conversion/${FILENAME}_content.html"

# --- Build the blog post HTML from template ---
sed "s|{TITLE}|${TITLE}|g; s|{DATE}|${DATE}|g" "template/template.html" > "conversion/${FILENAME}.html"

sed -i "/{BODY}/{
	r conversion/${FILENAME}_content.html
	d
	}" "conversion/${FILENAME}.html"

rm "conversion/${FILENAME}_content.html"
mv "conversion/${FILENAME}.html" "blog/${FILENAME}.html"
echo "Created blog/${FILENAME}.html"

# --- Add entry to blog.html (prepend to list) ---
BLOG_ENTRY_FILE=$(mktemp)
cat > "$BLOG_ENTRY_FILE" << HEREDOC
            <li>
              <a href="./blog/${FILENAME}.html" class="blog-entry">
                <span class="post-title">${TITLE}</span>
                <span class="post-date">${DATE}</span>
              </a>
            </li>
HEREDOC

UPDATED_BLOG=$(mktemp)
awk -v entry_file="$BLOG_ENTRY_FILE" '
  /<ul class="blog-list fade-in">/ {
    print
    while ((getline line < entry_file) > 0) print line
    close(entry_file)
    next
  }
  { print }
' blog.html > "$UPDATED_BLOG"

mv "$UPDATED_BLOG" blog.html
rm "$BLOG_ENTRY_FILE"

echo "Added entry to blog.html"

# --- Update Recent Writing on index.html ---
# Write the new entry and existing top 2 to a temp file, then swap them in.
RECENT_FILE=$(mktemp)

cat > "$RECENT_FILE" << HEREDOC
              <li>
                <a href="./blog/${FILENAME}.html" class="blog-entry">
                  <span class="post-title">${TITLE}</span>
                  <span class="post-date">${DATE}</span>
                </a>
              </li>
HEREDOC

# Extract the first 2 existing <li>...</li> blocks from the recent writing section
# The recent writing ul has class="blog-list" (no fade-in), distinguishing it from blog.html
awk '
  /<ul class="blog-list">/ { in_list=1; next }
  /<\/ul>/ && in_list { exit }
  in_list && /<li>/ { count++ }
  in_list && count <= 2 { print }
' index.html >> "$RECENT_FILE"

# Now replace the content between <ul class="blog-list"> and </ul> in index.html
# Use awk for clean multiline replacement
UPDATED_INDEX=$(mktemp)
awk -v replacement_file="$RECENT_FILE" '
  /<ul class="blog-list">/ {
    print
    while ((getline line < replacement_file) > 0) print line
    close(replacement_file)
    skip=1
    next
  }
  /<\/ul>/ && skip {
    skip=0
    print
    next
  }
  !skip { print }
' index.html > "$UPDATED_INDEX"

mv "$UPDATED_INDEX" index.html
rm "$RECENT_FILE"

echo "Updated Recent Writing on index.html"

echo ""
echo "Done! Next steps:"
echo "  1. Review blog/${FILENAME}.html in your browser"
echo "  2. git add blog/${FILENAME}.html blog.html index.html"
echo "  3. git commit"
