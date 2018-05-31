
# NOTE! THIS SCRIPT -REQUIRES- THAT THE INPUT FIRST BE REMOVED OF ALL
# DOS NEWLINES; (dos2unix)

# Matches lines which start with an asterisk, followed by one of the
# valid flags the Cisco router may output.
/^[\* ][ d>ih] [0-9]/ {
	prefix = $2
	# Older tables contain assignments which don't list CIDR-style
	# netmasks.
	if (match(prefix, "[.]0[.]0[.]0$")) {
		first_octet = split(prefix, tmp, ".")
		if (first_octet < 128) {
			prefix = prefix"/8"
		}
		else if (first_octet < 192) {
			prefix = prefix"/16"
		}
		else if (first_octet < 224) {
			prefix = prefix"/24"
		}
		else {
			printf "prefix",prefix," is abnormal!" >"/dev/stderr"
		}
	}
	else if (match(prefix, "[.]0[.]0$")) {
		if (first_octet < 192) {
			prefix = prefix"/16"
		}
		else if (first_octet < 224) {
			prefix = prefix"/24"
		}
		else {
			printf "prefix",prefix," is abnormal!" >"/dev/stderr"
		}
	}
	else if (match(prefix, "[.]0$")) {
		if (first_octet < 224) {
			prefix = prefix"/24"
		}
		else {
			printf "prefix",prefix," is abnormal!" >"/dev/stderr"
		}
	}

	# Chop off additional chars in columns which have run together.
	# ASSUMPTION: This doesn't happen with /8's or /9's.
	else if (length(prefix) - index(prefix, "/") > 2) {
		prefix = substr(prefix, 0, index(prefix, "/") +2)
	}

	if (NF > 3) {
		printf "%s", prefix
		for (i = 5; i <= NF; i++) {
			if ($i != "0") { # This will skip over leading zeroes in the
							 # 'weight' column.
				printf " %s", $i
			}
		}
		printf "\n"
	}
}
# Some prefixes wrap onto a new line...
/^     / {
#	print "== NF: "NF"; == "$0
	if (prefix) {
		if (NF >= 3) {
			printf "%s", prefix
			for (i = 3; i <= NF; i++) {
				if ($i != "0") { # This will skip over leading zeroes in
				   				 # the 'weight' column.
					printf " %s", $i
				}
			}
			printf "\n"
		}
	}
}

/^\*[ sdh>i]  / {
#	print "== NF: "NF"; == "$0
	if (prefix) {
		if (NF > 3) {
			printf "%s", prefix
			for (i = 4; i <= NF; i++) {
				if ($i != "0") { # This will skip over leading zeroes in
								 # the 'weight' column.
					printf " %s", $i
				}
			}
			printf "\n"
		}
	}
}
