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

# Example: ./bgpToUniqPaths.sh oix-route-views

dataset=$1

startyear=2007
endyear=2009

basedir=/media/sds-wd-1gb/sds/

cd $basedir/archive.routeviews.org/${dataset}/

for year in `seq $startyear $endyear` ; do
	for file in *${year}*bz2 ; do
		echo ${file}

		file=`basename ${file}`
		cleanfile=$basedir/clean-tables/$dataset/$year/`basename ${file} .dat.bz2`.clean.bz2
		pathsfile=$basedir/paths/$dataset/$year/`basename ${file} .dat.bz2`.paths.bz2

		# Generate a clean table from the Cisco text output.
		cat ${file} |
		bunzip2 |
		grep -v "closed" |
		awk -f /users/sds/PhD/bin/munge-bgp-table.awk |
		bzip2 > $cleanfile

		# Generate uniq set of paths from cleaned-up BGP table
		cat ${cleanfile} |
		bunzip2 |
		cut -d " " -f 2- | 
		scala -cp ~/PhD/build/ com.sdstrowes.util.Uniq | 
		bzip2 > $pathsfile
	done
done
