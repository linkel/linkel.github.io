# Personal Website

## To Do

- [ ] Book Review / reading page
- [ ] Career timeline on the About page
- [ ] Maybe a page about purchases I've made that I really like?
- [ ] Write a new blog post
- [x] Redesign site (Editor Surface theme, light/dark mode)
- [x] Restructure landing page
- [x] Move bio content to /about
- [x] Semi-automate pandoc conversion via template and bash script

## Publishing a Blog Post

Instructions for myself in case I forget. 

### Prerequisites

Install [pandoc](https://pandoc.org/installing.html):

Windows:
```
winget install pandoc
```

### Write your post

Create a markdown file in `md/` with YAML frontmatter:

```markdown
---
title: My Post Title
date: 2026-03-07
---

# My Post Title

Post content here...
```

### Publish

From PowerShell, Git Bash, or any terminal. I have a tragically confusing workflow right now because I have a linux personal laptop and a Windows 11 desktop that I mix n match for personal projects or game dev. 

```bash
bash publish.sh md/my-post-filename.md
```

The script requires bash (ships with Git for Windows). Running `bash publish.sh` from PowerShell should work...

This will:
1. Parse `title` and `date` from the frontmatter
2. Convert the markdown to HTML via pandoc
3. Wrap it in the blog template with date at top
4. Place the file in `blog/`
5. Add the entry to the top of `blog.html`
6. Update the "Recent Writing" section on `index.html`

### Review and commit

```bash
# check it in the browser first
git add blog/my-post-filename.html blog.html index.html
git commit -m "New post: My Post Title"
git push
```

### Backwards compatible

For markdown files without frontmatter, can pass the title as a CLI argument:

```bash
bash publish.sh md/old-file.md "Title As Argument"
```

This uses today's date automatically.

## Old script (deprecated)

My old `md_to_html.sh` still exists but doesn't update `blog.html` or `index.html`. Use `publish.sh` instead. But, old instructions as follows:

`md_to_html.sh filename title` is the format.

Example: `. md_to_html.sh ./md/SQL-Server-GUID-Sort-Order.md "SQL Server GUID Sort Order"`

## Manual pandoc conversion

If you ever need to convert markdown to HTML directly:

```
pandoc test1.md -f markdown -t html -s -o test1.html
```

- `-f markdown` — from markdown
- `-t html` — to html
- `-s` — standalone (includes header/footer)
- `-o test1.html` — output filename
