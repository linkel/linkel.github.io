x=$1
# For some reason I can't put the $1 in the param expansion directly, so I'm assigning it to x.

removedir=${x##*/} # remove all prior to forward slash using parameter expansion from arg1
echo ${removedir}
removeext=${removedir%.md} # remove .md file extension from arg1
echo ${removeext}
pandoc "$1" -f markdown -t html -o "conversion/${removeext}_content.html"

# sed -e specifies that it's a separate script. Not necessary here, so removed.

sed "s/{TITLE}/$2/" "template/template.html" > "conversion/${removeext}.html"

# Variable substitution doesn't occur inside of single apostrophes. Use double quotes. 

# the -i parameter will edit the file in-place.

sed -i "/{BODY}/{
	r conversion/${removeext}_content.html
	d
	}" conversion/${removeext}.html
