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


# ---------------------------------------------------------------------
# To get the RIBs for a collector
# From /media/sds-wd-1gb/sds/ run:
#wget --no-parent --accept html -e robots=off -r http://archive.routeviews.org/route-views.wide/
# robots=off is bad; routeviews prefer users to not do this, or at
# least throttle usage.


cd /mnt/ext/sds/

# repositories="http://archive.routeviews.org/route-views.eqix/bgpdata
#  http://archive.routeviews.org/route-views.isc/bgpdata
#  http://archive.routeviews.org/route-views.kixp/bgpdata
#  http://archive.routeviews.org/route-views.linx/bgpdata
#  http://archive.routeviews.org/route-views.wide/bgpdata
#  http://archive.routeviews.org/route-views4/bgpdata"

repositories="http://archive.routeviews.org/route-views3"

# Given two dates and a collector
collector=$1
start=$2
end=`date --date "$3 + 1 day" +%Y-%m-%d`

cisco=1

for r in $repositories ; do 
	echo "--> $r"

	date=$start
	end_month=`date --date "$end + 1 month" +%Y-%m`
	until [ `date --date $date +%Y-%m` == $end_month ]
	do
		echo "--> $date"

		month=`date --date $date +%m`
		year=`date --date $date +%Y`

		echo "--> $month $year"

		if [ $cisco -eq 1 ]
		then
			wget --quiet -O index.tmp.html $r/$year.$month/
		else
			wget --quiet -O index.tmp.html $r/$year.$month/RIBS/
		fi

		if [ $cisco -eq 1 ]
		then
			files=`egrep -o "[a-z0-9-]*[12][0-9]{3}-[0-9]{2}-[0-9]{2}-[0-9]{4}.dat.bz2" index.tmp.html | sort -k2,2 | uniq`
			dates=`echo $files | sed 's/ /\n/g'| egrep -o "[12][0-9]{3}-[012][0-9]-[0-3][0-9]" | sort | uniq`
		else
			files=`egrep -o "rib.[12][0-9]{7}.[0-9]{4}.bz2" index.tmp.html | sort -k2,2 | uniq`
			dates=`echo $files | sed 's/ /\n/g'| awk 'BEGIN {FS="."} {print $2}' | sort | uniq`
		fi

		for i in $dates
		do
			file=`echo $files | sed 's/ /\n/g' | grep $i | head -n1`

			if [ $cisco -eq 1 ]
			then
				echo "Getting: $r/$year.$month/$file"
				wget --quiet -x $r/$year.$month/$file
			else
				echo "Getting: $r/$year.$month/RIBS/$file"
				wget --quiet -x $r/$year.$month/RIBS/$file
			fi
		done

		rm index.tmp.html

		date=`date --date "$date + 1 month" +%Y-%m-%d`
	done
done

exit


#files=`find . -name "index.html"  | grep RIBS`
#dates=`egrep -h -o "200[0-9][01][0-9][0-3][0-9]" $files | sort | uniq`

dates=`egrep -h -o "2010" index.*`

# Get the filenames to retreive
for i in ${dates[@]}
do
	echo -n "http://archive.routeviews.org/route-views.eqix/bgpdata/${i:0:4}.${i:4:2}/RIBS/"
	grep $i bgpdata/${i:0:4}.${i:4:2}/RIBS/index.html |
	cut -d "\"" -f 8 |
	head -n 1
done > urls

wget -e robots=off `cat urls `
