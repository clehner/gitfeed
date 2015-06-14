#!/bin/sh

test -z "$SITE_URL" && echo 'Define the SITE_URL env variable' >&2 && exit 1

hash uuidgen >&2 || uuidgen() {
    cat /proc/sys/kernel/random/uuid 2>&- ||\ # Linux
    cat /compat/linux/proc/sys/kernel/random/uuid 2>&- ||\ # FreeBSD
    python -c 'import uuid; print uuid.uuid1()'
}

: ${SITE_TITLE:=My Cool Site}
: ${SITE_AUTHOR:=$(grep $(id -u) /etc/passwd | cut -d: -f 5 | cut -d, -f1)}
: ${SITE_ID:=$(cat site_id 2>&- || echo urn:uuid:$(uuidgen) | tee site_id)}
: ${FEED_ENTRIES:=15}
: ${FEED_WIDTH:=80}

cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
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
stat $content_delim" $@ | awk -f xml.awk -v site="$SITE_URL"

cat <<EOF
  </feed>

EOF
