# Introduction

Having a personal website is interesting. It feels simultaneously like too much work yet also not much work at all. When I sit down and get started with something on the site, I find that time passes pretty quickly. But it's difficult in the first place to get started with changes. 

It's fun writing a blog. Currently I am using pandoc to convert my markdown to html. Eventually I'd like to make this process more automated.

To my horror, I discovered recently that I have forgotten about my LESS file when revamping the site and adding blog articles, and instead have been making edits to the CSS file. I'm going to have to refactor this...

# To Do:
* [ ] Opinion page on powerlifting, climbing, fitness
* [ ] Book Review page!
* [ ] One blog post for 2020, perhaps?
* [ ] Refactor the CSS!
* [ ] How can I automate the pandoc conversion more and slap my headers on easily?
* [ ] If I have a fun topic to give another talk on, I can put more slides up on the Talks page.

# Notes to Self

Converting from markdown to html is done by:

`pandoc test1.md -f markdown -t html -s -o test1.html`

- pandoc [name] is the markdown file name
- -f [type] is from type
- -t [type] is to type
- -s is standalone (HTML with a header and footer)
- -o [name] is output to what file

So it seems like if I want to automate this, I could have something run this pandoc command without the standalone, then run another command that takes that html output and slots it into html that's templatized for the title? 

1. An alias that runs the pandoc command with the target file to the output file (same name, but with md filetype replaced with html filetype)
2. Runs a script that makes a copy of a blog post template html file, copies all text in the outputted html file from the last step, and sticks it in the middle of the template html file, then replaces template variables {blah} with the blog post title...? so maybe my command would have to be `command targetfile desiredtitle`.