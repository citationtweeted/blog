#!/usr/bin/env bash

# Usage: generate.sh PATH
#   PATH: path to directory containing blog source

set -e
cd $1

ENTRIES=entries/*.md
LIST=""
PREVIOUS=""
JSON_FEED='{
    "version": "https://jsonfeed.org/version/1",
    "title": "[citation tweeted]",
    "description": "Yet another geeky person'"'"'s unsolicited opinions on technology, politics, and life.",
    "home_page_url": "http://citationtweeted.com",
    "feed_url": "http://citationtweeted.com/feed.json",
    "items": ['

for ENTRY in ${ENTRIES}; do
    cat header1.html > "${ENTRY}.html"

#    Handle page title
    TITLE=$(head -n 1 ${ENTRY})
    TITLE=${TITLE:2}
    echo "${TITLE} [citation tweeted]" >> "${ENTRY}.html"  # Strip initial # from title
#    Generate list of blog entries for home page
    LIST="<li><a href='${ENTRY}.html'>$(basename ${ENTRY%%.*}) ${TITLE}</a></li>
    ${LIST}"
    cat header2.html >> "${ENTRY}.html"

    ENTRY_HTML=$(cmark ${ENTRY})
    ENTRY_HTML_NO_TITLE=$(tail -n +2 ${ENTRY} | cmark)
    echo ${ENTRY_HTML} >> "${ENTRY}.html"
    if [ ${PREVIOUS} != "" ]; then
        echo "<a href='../${PREVIOUS}.html'>Previous post</a>" >> "${ENTRY}.html"
        JSON_FEED="${JSON_FEED},"
    fi
#    JSON Feed
    JSON_FEED="${JSON_FEED}
    {
        \"id\": \"http://citationtweeted.com/entries/${ENTRY}.html\",
        \"title\": \"${TITLE//\"/\\\"}\",
        \"content_html\": \"${ENTRY_HTML_NO_TITLE//\"/\\\"}\",
        \"url\": \"http://citationtweeted.com/${ENTRY}.html\"
    }
    "

    PREVIOUS=${ENTRY};
    cat footer.html >> "${ENTRY}.html"
done

JSON_FEED="${JSON_FEED} ] }"
echo ${JSON_FEED} > feed.json

# Generate index
cat index1.html > index.html
echo ${LIST} >> index.html
cat index2.html >> index.html
cat footer.html >> index.html

exit 0
