function escape_html(text) {
	gsub(/&/, "\\&amp;", text)
	gsub(/</, "\\&lt;", text)
	gsub(/>/, "\\&gt;", text)
	gsub(/"/, "\\&quot;", text)
	return text
}

function get_value() {
	sub(/^[^ ]* */, "")
	return $0
}

function end() {
	print "&lt;/pre&gt;</content>"
	print "</entry>"
}

$1 == "entry" {
	if (in_content && $2 == end_of_content) {
		in_content = 0
		in_stat = 0
		end()
	}

	title = ""
	id = ""
	name = ""
	email = ""
	updated = ""

	next
}

$1 == "stat" && $2 == end_of_content {
	in_stat = 1
	next
}

$1 == "content" {
	end_of_content = $2
	print "<entry>"
	print "  <title>" escape_html(title) "</title>"
	print "  <id>" id "</id>"
	print "  <author>"
	print "    <name>" escape_html(name) "</name>"
	print "    <email>" escape_html(email) "</email>"
	print "  </author>"
	print "  <updated>" escape_html(updated) "</updated>"
	printf "  <content type=\"html\">&lt;pre&gt;"
	in_content = 1
	next
}

in_stat && /^ [^ ]* *\|/ {
	sub(/[^ ][^ ]*/, "<a href=\"" site "&\">&</a>")
}

in_stat && / \+*-*$/ {
	sub(/ \++/, "<span style=\"color:green\">&</span>")
	sub(/-+$/, "<span style=\"color:red\">&</span>")
}

in_content {
	print escape_html($0)
	next
}

$1 == "title" { title = get_value() }
$1 == "name" { name = get_value() }
$1 == "email" { email = get_value() }
$1 == "id" {
	id = get_value()
	id = site ".git/objects/" substr(id, 1, 2) "/" substr(id, 3)
}
$1 == "updated" {
	updated = $2 "T" $3 substr($4, 1, 3) ":" substr($4, 3, 2)
}

END {
	if (in_content)
		end()
}
