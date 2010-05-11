#!/bin/bash

# Copyright (c) 2010, Stephen Strowes, University of Glasgow
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
#   * Neither the name of the University of Glasgow nor the names of its 
#     contributors may be used to endorse or promote products derived from 
#     this software without specific prior written permission.
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


# Years range from 1997 to 2009.
startYear=1997
endYear=2009

base=/media/sds-wd-1gb/sds/links/

#datasets=( route-views.oregon-ix.net route-views2.oregon-ix.net route-views.wide.routeviews.org )

datasets=( route-views.eqix.routeviews.org route-views.oregon-ix.net route-views2.oregon-ix.net route-views.isc.routeviews.org route-views3.routeviews.org route-views.kixp.routeviews.org route-views.wide.routeviews.org route-views4.routeviews.org route-views.linx.routeviews.org )


# This doesn't do anything smart with dates, but it certainly catches
# them all.
for year in `seq $startYear $endYear` ; do
	for month in `seq -w 01 12` ; do
		for day in `seq -w 01 31` ; do
			files=( )
			echo "-- $year $month $day"
			for dataset in ${datasets[@]} ; do
				if [ -d ${base}/${dataset}/${year} ] ; then
					files=( ${files[@]} `find ${base}/${dataset}/${year}/ -regex ".*${year}-?${month}-?${day}.*"` )
				fi

#				find ${base}/${dataset} -name "*${year}${month}${day}*"
			done

			echo Aggregating ${#files[@]} files

			if [ ${#files[@]} -eq 1 ] ; then
				if [ -f ${files[0]} ] ; then
					cp ${files[0]} ${base}/aggregated/all.${year}${month}${day}.links.bz2
				fi
			elif [ ${#files[@]} -gt 1 ] ; then
				if [ -f /tmp/agg.tmp ] ; then rm /tmp/agg.tmp; fi

				for file in ${files[@]} ; do
					cat $file | bunzip2 >> /tmp/agg.tmp
				done

				cat /tmp/agg.tmp | 
				scala -cp ~/PhD/build com.sdstrowes.util.Uniq | 
				bzip2 > ${base}/aggregated/all.${year}${month}${day}.links.bz2
			fi
#			echo "##" ${#files[@]}

			#for 

		done
	done
#	for dataset in ${datasets[@]} ; do
#		if [ -d ${base}/${dataset} ] ; then
#			find
#			scala -cp ~/PhD/build/ com.sdstrowes.util.Uniq
#		fi
#	done
done

