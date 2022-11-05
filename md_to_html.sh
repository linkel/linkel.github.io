x=$1
# For some reason I can't put the $1 in the param expansion directly, so I'm assigning it to x.

filename_with_extension=${x##*/} # remove all prior to forward slash using parameter expansion from arg1
echo targeting file: ${filename_with_extension}
filename=${filename_with_extension%.md} # remove .md file extension from arg1
pandoc "$1" -f markdown -t html -o "conversion/${filename}_content.html"

# sed -e specifies that it's a separate script. Not necessary here, so removed.

sed "s/{TITLE}/$2/" "template/template.html" > "conversion/${filename}.html"

# Variable substitution doesn't occur inside of single apostrophes. Use double quotes. 

# the -i parameter will edit the file in-place.

sed -i "/{BODY}/{
	r conversion/${filename}_content.html
	d
	}" conversion/${filename}.html

echo deleting temp content file ${filename}_content.html
# delete the temp content file at the end
rm conversion/${filename}_content.html

echo moving ${filename}.html into blog folder
# move the converted file into the blog folder
mv conversion/${filename}.html blog/${filename}.html