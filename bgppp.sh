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

# The pipeline is as follows:
# - wget the data
# - extract all unique paths in the data
# - extract all AS pairs in the path data to construct links
# - aggregate links together to create a complete map


classpath=~/build/

while getopts  "b:p:l:o:d:" flag
do
	case $flag in
		b) bgp_data_dir=$OPTARG
			;;
		p) path_data_dir=$OPTARG
			;;
		l) links_data_dir=$OPTARG
			;;
		o) aggregate_links_dir=$OPTARG
			;;
		d) date_string=$OPTARG
			;;
	esac
done

if [ ! $bgp_data_dir ] || [ ! $path_data_dir ] || [ ! $date_string ]
then
	echo "Usage: $0 -b <bgp storage directory> -l <links storage directory> -d <date>"
	echo "Optional parameters:"
	echo "	-p <path storage directory>"
	echo "	-o <aggregated links directory>"
	echo "If -p is omitted, then path data is thrown away. If -o is provided, then the "
	echo "paths generated will be aggregated, and stored in that location."
	exit
fi

#./wget_ribs.sh -o $bgp_data_dir -d $date_string

source bgprepos.sh

year=`date --date $date_string +%Y`
month=`date --date $date_string +%m`
day=`date --date $date_string +%d`

echo "Stripping unique paths from BGP data"

# For each repository:
#  - Get all files matching this date
#  - Grep out the unique paths in each
for r in `echo $mrt_repos | sed 's$http://$$g'`
do
	echo "--> $r"
	local_tag=`echo $mrt_local_tags | cut -d " " -f1`
	mrt_local_tags=`echo $mrt_local_tags | cut -d " " -f2-`
	for f in `find $bgp_data_dir -regex ".*$r.*$year$month$day.*"`
	do
		outdir=$path_data_dir/$local_tag/$year
		mkdir -p $outdir

		echo "Converting BGP $f to $outdir/`basename $f .bz2`.paths.bz2"

		./bgptouniqpaths.sh -i $f -o $outdir/`basename $f .bz2`.paths.bz2
	done
done
for r in `echo $cisco_repos | sed 's$http://$$g'`
do
	echo "--> $r"

	files=`find $bgp_data_dir -regex ".*$r.*$year-$month-$day.*"`

	local_tag=`echo $cisco_local_tags | cut -d " " -f1`
	cisco_local_tags=`echo $cisco_local_tags | cut -d " " -f2-`

	echo $local_tag

	if [ "$files" ]
	then

		outdir=$path_data_dir/$local_tag/$year
		mkdir -p $outdir

		for f in $files
		do
			echo "Converting BGP $f to $outdir/`basename $f .bz2`.paths.bz2"

			./bgptouniqpaths.sh -i $f -o $outdir/`basename $f .bz2`.paths.bz2 -c
		done
	fi
done

echo "-- Forming links from paths."
source bgprepos.sh
for r in $mrt_local_tags
do
	echo "--> $r"
	files=`find $path_data_dir -regex ".*$r.*$year-?$month-?$day.*"`
	if [ "$files" ]
	then
		local_tag=`echo $cisco_local_tags | cut -d " " -f1`
		cisco_local_tags=`echo $cisco_local_tags | cut -d " " -f2-`

		for f in $files
		do
			out=$links_data_dir/`basename $f | sed s/paths/links/g`
			mkdir -p `dirname $out`
			./bgppathstolinks.sh -i $f -o $out
		done
	fi
done
for r in $cisco_local_tags
do
	echo "--> $r"
	files=`find $path_data_dir -regex ".*$r.*$year-?$month-?$day.*"`
	if [ "$files" ]
	then
		local_tag=`echo $cisco_local_tags | cut -d " " -f1`
		cisco_local_tags=`echo $cisco_local_tags | cut -d " " -f2-`

		for f in $files
		do
			out=$links_data_dir/`basename $f | sed s/paths/links/g`
			mkdir -p `dirname $out`
			./bgppathstolinks.sh -i $f -o $out
		done
	fi
done


echo "-- Aggregating."
./bgpaggregatelinks.sh -i /mnt/ext/sds/links -o /mnt/ext/sds/bgp-links-aggregated -d $date_string


echo "-- Done."
