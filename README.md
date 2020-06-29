# Introduction

Having a personal website is interesting. It feels simultaneously like too much work yet also not much work at all. When I sit down and get started with something on the site, I find that time passes pretty quickly. But it's difficult in the first place to get started with changes. 

To my horror, I discovered recently that I have forgotten about my LESS file when revamping the site and adding blog articles, and instead have been making edits to the CSS file. I'm going to have to refactor this...

# To Do:
* [ ] Maybe a redesign? 
* [ ] Opinion page on powerlifting, climbing, fitness
* [ ] Book Review page!
* [x] One blog post for 2020, perhaps?
 * [x] May 2020
 * [x] June 2020
 * [ ] July 2020
* [ ] Refactor the CSS!
* [x] How can I automate the pandoc conversion more and slap my headers on easily?

# Notes to Self

Converting from markdown to html is done by:

`pandoc test1.md -f markdown -t html -s -o test1.html`

- pandoc [name] is the markdown file name
- -f [type] is from type
- -t [type] is to type
- -s is standalone (HTML with a header and footer)
- -o [name] is output to what file

I wrote a script in this folder that I titled [md_to_html](md_to_html.sh) which runs pandoc and sed to convert from md to html, format my html headers, and stick the written content into the template. Should make it a lot easier to write articles and not worry about the manual html copy-pasting afterwards. 