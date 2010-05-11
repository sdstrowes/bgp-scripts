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

# Example: ./pathsToLinks.sh bo720-5-01 route-views.linx

suffix=routeviews.org
#suffix=oregon-ix.net

host=$1
dataset=$2

cd /media/sds-wd-1gb/sds/paths/${dataset}.${suffix}/

startYear=`ls | sort -n | head -n 1`
endYear=`ls | sort -n | tail -n 1`

for year in `seq $startYear $endYear` ; do
	for file in /media/sds-wd-1gb/sds/paths/${dataset}.${suffix}/${year}/*bz2 ; do
		scp $file ${host}:/tmp/`basename ${file}` &> /dev/null

		file=`basename ${file}`

		echo $file; 

		ssh ${host} <<EOF
cat /tmp/${file} | 
bunzip2 | 
sed 's/[{}()]//g' | 
sed 's/[0-9],[0-9,]*//g' |
scala -cp ~/PhD/build com.sdstrowes.util.BGPPathsToLinks | 
bzip2 |
ssh $HOSTNAME "cat > /media/sds-wd-1gb/sds/links/${dataset}.${suffix}/${year}/`basename ${file} .paths.bz2`.links.bz2"
rm /tmp/${file}
EOF
	done
done
echo "--" ${file}

# /tmp/`basename ${file} .paths.bz2`.links.bz2
# grep -v "," | 
