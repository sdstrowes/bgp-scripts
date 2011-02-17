# Copyright (c) 2011, Stephen D. Strowes
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#   * Redistributions of source code must retain the above copyright notice, 
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright 
#     notice, this list of conditions and the following disclaimer in the 
#     documentation and/or other materials provided with the distribution.
#   * The author named in the above copyright notice may not be used to
#     endorse or promote products derived from this software without
#     specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# NOTE! THIS SCRIPT -REQUIRES- THAT THE INPUT FIRST BE REMOVED OF ALL
# DOS NEWLINES; (dos2unix)

#{
#	print "##",$0
#}

# Matches lines which start with an asterisk, followed by one of the
# valid flags the Cisco router may output.
/^[\* ][ d>ih] [0-9]/ {
	prefix = $2
	# Older tables contain assignments which don't list CIDR-style
	# netmasks.
	if (match(prefix, "[.]0[.]0[.]0$")) {
		prefix = prefix"/8"
	}
	else if (match(prefix, "[.]0[.]0$")) {
		prefix = prefix"/16"
	}
	else if (match(prefix, "[.]0$")) {
		prefix = prefix"/24"
	}

	# Chop off additional chars in columns which have run together.
	# ASSUMPTION: This doesn't happen with /8's or /9's.
	else if (length(prefix) - index(prefix, "/") > 2) {
		prefix = substr(prefix, 0, index(prefix, "/") +2)
	}

	if (NF > 3) {
		printf "%s", prefix
		for (i = 5; i < NF; i++) {
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
			for (i = 3; i < NF; i++) {
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
			for (i = 4; i < NF; i++) {
				if ($i != "0") { # This will skip over leading zeroes in
								 # the 'weight' column.
					printf " %s", $i
				}
			}
			printf "\n"
		}
	}
}
