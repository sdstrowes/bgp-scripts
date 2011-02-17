#!/bin/bash

# Copyright (c) 2010, Stephen D. Strowes
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


classpath=~/build/

while getopts  "i:o:c" flag
do
	case $flag in
		i) input=$OPTARG
			;;
		o) output=$OPTARG
			;;
		c) clean=1
			;;
	esac
done

if [ ! $input ] || [ ! $output ]
then
	echo "Usage: $0 -i <input.bz2> -o <output.bz2> -c"
	exit
fi

mkdir -p `dirname $output`

bzcat $input |
if [ $clean ]
then
	awk -f bgp-clean-cisco-table.awk |
	cut -d " " -f2-
else
	bgpdump -m - | 
	awk 'BEGIN {FS="|"} {print $7}' 
fi | 
scala -cp $classpath com.sdstrowes.util.Uniq | 
bzip2 > $output
