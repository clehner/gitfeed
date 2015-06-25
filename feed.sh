#!/bin/sh

test -z "$SITE_URL" && echo 'Define the SITE_URL env variable' >&2 && exit 1

dir=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))

cmd=
xslt_sheet=
for arg; do
  case $cmd in
    '') case "$arg" in
      --xslt) cmd=xslt;;
    xslt) xslt_sheet="$arg"; cmd=;;
    esac;;
  esac
done

hash uuidgen >&2 || uuidgen() {
    cat /proc/sys/kernel/random/uuid 2>&- ||\ # Linux
    cat /compat/linux/proc/sys/kernel/random/uuid 2>&- ||\ # FreeBSD
    python -c 'import uuid; print uuid.uuid1()'
}

: ${SITE_TITLE:=My Cool Site}
: ${SITE_ID:=$(cat site_id 2>&- || echo urn:uuid:$(uuidgen) | tee site_id)}
: ${FEED_ENTRIES:=15}
: ${FEED_WIDTH:=80}

echo '<?xml version="1.0" encoding="utf-8"?>'
if [ "$xslt_sheet" ]; then
  echo '<?xml-stylesheet type="text/xsl" href="'$xslt_sheet'" version="1.0"?>'
fi
cat <<EOF
  <feed xmlns="http://www.w3.org/2005/Atom">
    <title>$SITE_TITLE</title>
    <link rel="alternate" type="text/html" href="$SITE_URL"/>
    <link rel="self" type="application/rss+xml" href="${SITE_URL}feed.xml"/>
    <updated>$(date --iso-8601=seconds | sed 's/..$/:&/')</updated>
    <id>$SITE_ID</id>

EOF

content_delim=$(uuidgen)

git log -$FEED_ENTRIES --stat=$FEED_WIDTH --format=format:"entry $content_delim
title %s
id %H
name %aN
email %aE
updated %ai
content $content_delim
commit %H

%B
stat $content_delim" $@ | awk -f "$dir/xml.awk" -v site="$SITE_URL"

cat <<EOF
  </feed>

EOF
