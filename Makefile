SITE_URL ?= http://localhost/

feed.xml: feed.sh xml.awk .git/logs/HEAD
	SITE_URL="$(SITE_URL)" ./$< > $@
