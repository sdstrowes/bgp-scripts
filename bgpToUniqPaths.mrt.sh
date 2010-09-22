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

# Example: ./bgpToUniqPaths.sh bo720-5-01 route-views.linx

host=$1
dataset=$2

basedir="/media/sds-wd-1gb/sds/"
pathsdir=$basedir/paths/$dataset/
bgpdir=$basedir/archive.routeviews.org/${dataset}/bgpdata/
subdir="RIBS"

# Catch the unusual cases; really just 'oix-route-views'
# (routeviews1), and 'bgpdata' (routeviews2).
case "$dataset" in
	"oix-route-views" )
		pathsdir=$basedir/paths/route-views1
		bgpdir=$basedir/archive.routeviews.org/$dataset
		subdir=""
		;;
	"bgpdata" )
		pathsdir=$basedir/paths/route-views2
		bgpdir=$basedir/archive.routeviews.org/$dataset
		subdir=""
		;;
	* )
		echo "Unknown dataset!"
		exit
		;;
esac

for year in `seq 2008 2009` ; do
	for file in *${year}*bz2 ; do
		echo ${file}
		scp $file ${host}:/tmp/${file} &> /dev/null
		ssh ${host} 'cat /tmp/'${file}' |
		bunzip2 | 
		bgpdump -m - | 
		cut -d "|" -f 7 | 
		scala -cp ~/PhD/build/ com.sdstrowes.util.Uniq | 
		bzip2 |
		ssh carney "cat > /media/sds-wd-1gb/sds/paths/'${dataset}'.routeviews.org/'${year}'/`basename '${file}' .bz2`.paths.bz2"
		rm /tmp/'${file}' '
	done
done
