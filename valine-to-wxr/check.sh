site=https://veltlion.github.io
comfile=comment.json

line=$(grep comment $comfile |wc -l)
touch checktmp
for ((i=0; i<$line; i++)); do
    link=$(jq -r ".results[$i].url" $comfile)
    check=$(grep $link checktmp)
    if [[ $check != '' ]]; then
        continue
    fi
    status=$(curl -o /dev/null -s -w "%{http_code}\n" $site$link)
    echo $link $status
    echo $link $status>> checktmp
done
rm checktmp

