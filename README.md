# gitfeed

Generate an [Atom](https://tools.ietf.org/html/rfc4287) feed from a git repo's
commit history. Each commit gets an entry in the feed showing its diff stat.

## Usage

First define some variables. The only required one is `SITE_URL` - the others
are optional.

    export SITE_TITLE='Example Site'
    export SITE_URL='http://example.org'
    export SITE_ENTRIES=30  # max number of entries in the feed
    export SITE_WIDTH=100   # width of diff stat. leave at 80 unless you have
                            # long filenames.

Then run the script to output the feed.

    ./feed.sh > ./feed.xml

**gitfeed** is designed to work well with a Makefile. For example, see the
Makefile included in this project.

# License

MIT
