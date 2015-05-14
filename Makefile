feed.xml: feed.sh xml.awk .git/info/refs site_id
	./$< > $@

