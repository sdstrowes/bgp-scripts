#!/bin/bash

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


classpath=~/build/

while getopts  "i:o:d:" flag
do
	case $flag in
		i) inputdir=$OPTARG
			;;
		o) outputdir=$OPTARG
			;;
		d) date_string=$OPTARG
			;;
	esac
done

if [ ! $inputdir ] || [ ! $outputdir ] || [ ! $date_string ]
then
	echo "Usage: $0 -i <input directory> -o <output directory> -d <date>"
	exit
fi

year=`date --date $date_string +%Y`
month=`date --date $date_string +%m`
day=`date --date $date_string +%d`

inputs=`find $inputdir -regex ".*$year-?$month-?$day.*"`

for f in $inputs
do
	bzcat $f
done |
scala -cp $classpath com.sdstrowes.util.Uniq |
bzip2 > $outputdir/all.${year}${month}${day}.links.bz2
