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

# ---------------------------------------------------------------------
# To get the RIBs for a collector
# From /media/sds-wd-1gb/sds/ run:
#wget --no-parent --accept html -e robots=off -r http://archive.routeviews.org/route-views.wide/

files=`find . -name "index.html"  | grep RIBS`
dates=`egrep -h -o "200[0-9][01][0-9][0-3][0-9]" $files | sort | uniq`

# Get the filenames to retreive
for i in ${dates[@]} ; do echo -n "http://archive.routeviews.org/route-views.eqix/bgpdata/${i:0:4}.${i:4:2}/RIBS/"; grep $i bgpdata/${i:0:4}.${i:4:2}/RIBS/index.html | cut -d "\"" -f 8 | head -n 1; done > urls

wget -e robots=off `cat urls `
