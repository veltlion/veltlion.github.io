#!/usr/bin/env bash
# 空
# Valine to WordPress WXR
# 2019-07-03

comfile="$1"
site="$2"

line=$(grep comment $comfile |wc -l)

comment() {
    for ((j=0; j<$line; j++)); do
        linkc=$(jq -r ".results[$j].url" $comfile)
        if [[ $link == $linkc ]]; then
            comid=$(jq -r ".results[$j].objectId" $comfile)
            author=$(jq -r ".results[$j].nick" $comfile)
            email=$(jq -r ".results[$j].mail" $comfile)
            aurl=$(jq -r ".results[$j].link" $comfile | sed 's/^null$//')
            aip=$(jq -r ".results[$j].ip" $comfile)
            date=$(jq -r ".results[$j].createdAt" $comfile | sed 's/T/ /; s/\.[0-9]\{3\}Z//')
            parent=$(jq -r ".results[$j].rid" $comfile | sed 's/^null$//')
            content=$(jq -r ".results[$j].comment" $comfile)

            echo  "<wp:comment>
                    <wp:comment_id>$comid</wp:comment_id>
                    <wp:comment_author>$author</wp:comment_author>
                    <wp:comment_author_email>$email</wp:comment_author_email>
                    <wp:comment_author_url>$aurl</wp:comment_author_url>
                    <wp:comment_author_IP>$ip</wp:comment_author_IP>
                    <wp:comment_date_gmt>$date</wp:comment_date_gmt>
                    <wp:comment_content><"!"[CDATA[$content]]></wp:comment_content>
                    <wp:comment_approved>1</wp:comment_approved>
                    <wp:comment_parent>$parent</wp:comment_parent>
                  </wp:comment>"
        fi
    done
}

item() {
    for ((i=0; i<$line; i++)); do
        link=$(jq -r ".results[$i].url" $comfile)
        touch $comfile.xml
        check=$(grep $link $comfile.xml)
        if [[ $check != '' ]]; then
            continue
        fi
        if [[ $site != '' ]]; then
            page=$(curl -s $site$link)
            title=$(echo $page | grep -Po '(?<=\<title\>).*(?=\<\/title\>)')
        fi
        echo "<item>
            <title>$title</title>
            <link>$site$link</link>
            <content:encoded><"!"[CDATA[]]></content:encoded>
            <wp:post_date_gmt></wp:post_date_gmt>
            <wp:comment_status>open</wp:comment_status>
            $(comment)
            </item>">>$comfile.xml
    done
}


echo '<?xml version="1.0" encoding="utf-8"?><rss version="2.0" xmlns:wp="http://wordpress.org/export/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dsq="http://www.disqus.com/" xmlns:content="http://purl.org/rss/1.0/modules/content/"><channel>'>>$comfile.xml
item
echo '</channel></rss>'>>$comfile.xml
echo done!

