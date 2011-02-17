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
# wget's robots=off is BAD; routeviews prefer users to not do this, or at
# least throttle usage. I set a 5 second pause between each wget.
DELAY=5

while getopts  "o:d:" flag
do
	case $flag in
		o) outputdir=$OPTARG
			;;
		d) date_string=$OPTARG
			;;
	esac
done

if [ ! $date_string ] || [ ! $outputdir ]
then
	echo "Usage: $0 -d <date> -o <output directory>"
	exit
fi


cd $outputdir

mrt_repos="http://archive.routeviews.org/route-views.eqix/bgpdata
 http://archive.routeviews.org/route-views.isc/bgpdata
 http://archive.routeviews.org/route-views.kixp/bgpdata
 http://archive.routeviews.org/route-views.linx/bgpdata
 http://archive.routeviews.org/route-views.wide/bgpdata
 http://archive.routeviews.org/route-views4/bgpdata"

cisco_repos="http://archive.routeviews.org/oix-route-views
 http://archive.routeviews.org/route-views3"

for r in $mrt_repos
do
	day=`date --date $date_string +%d`
	month=`date --date $date_string +%m`
	year=`date --date $date_string +%Y`

	echo "--> $r"
	echo "--> $date_string"
	echo "--> $month $year"

	wget --quiet -O /tmp/index.tmp.html $r/$year.$month/RIBS/

	all_files=`egrep -o "rib.$year$month$day.[0-9]{4}.bz2" /tmp/index.tmp.html | sort -k1,1 | uniq`
	file=`echo $all_files | sed 's/ /\n/g' | head -n1`

	echo "Getting: $r/$year.$month/RIBS/$file"
	wget --quiet -x $r/$year.$month/RIBS/$file

	sleep $DELAY

	rm /tmp/index.tmp.html
done

for r in $cisco_repos
do
	day=`date --date $date_string +%d`
	month=`date --date $date_string +%m`
	year=`date --date $date_string +%Y`

	echo "--> $r"
	echo "--> $date_string"
	echo "--> $month $year"

	wget --quiet -O /tmp/index.tmp.html $r/$year.$month/

	all_files=`egrep -o "[a-z0-9-]*$year-$month-$day-[0-9]{4}.dat.bz2" /tmp/index.tmp.html | sort -k1,1 | uniq`
	file=`echo $all_files | sed 's/ /\n/g' | head -n1`

	echo "Getting: $r/$year.$month/$file"
	wget --quiet -x $r/$year.$month/$file

	sleep $DELAY

	rm /tmp/index.tmp.html
done
