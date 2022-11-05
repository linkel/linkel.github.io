# Introduction

Having a personal website is interesting. It feels simultaneously like too much work yet also not much work at all. When I sit down and get started with something on the site, I find that time passes pretty quickly. But it's difficult in the first place to get started with changes. 

# To Do:
* [ ] Perhaps a page on powerlifting, climbing, fitness
* [ ] Maybe a page about birds?
* [ ] Book Review page!
* [x] Semi-automate pandoc conversion via template and bash script  

# Notes to Self

## Script Instructions
I wrote a script in this folder that I titled [md_to_html](md_to_html.sh) which runs pandoc and sed to convert from md to html, format my html headers, and stick the written content into the template. Should make it a lot easier to write articles and not worry about the manual html copy-pasting afterwards. 

`md_to_html.sh filename title` is the format. 

Example:
`. md_to_html.sh ./md/SQL-Server-GUID-Sort-Order.md "SQL Server GUID Sort Order"`

## Manual Instructions 
Converting from markdown to html is done by:

`pandoc test1.md -f markdown -t html -s -o test1.html`

- pandoc [name] is the markdown file name
- -f [type] is from type
- -t [type] is to type
- -s is standalone (HTML with a header and footer)
- -o [name] is output to what file