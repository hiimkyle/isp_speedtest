#!/usr/bin/env bash

# Character for separating values
# (commas are not safe, because some servers return speeds with commas)
sep=";"

# Temporary file holding speedtest-cli output
log=/var/log/speedtest/speedtest-splunk.tmp

# Local functions
function str_extract() {
 pattern=$1
 # Extract
 res=`grep "$pattern" $log | sed "s/$pattern//g"`
 # Drop trailing ...
 res=`echo $res | sed 's/[.][.][.]//g'`
 # Trim
 res=`echo $res | sed 's/^ *//g' | sed 's/ *$//g'`
 echo $res
}

# Display header?
if test "$1" = "--header"; then
  start="start"
  stop="stop"
  from="from"
  from_ip="from_ip"
  server="server"
  server_dist="server_dist"
  server_ping="server_ping"
  download="download"
  upload="upload"
  share_url="share_url"
else
  mkdir -p `dirname $log`

  start=`date +"%Y-%m-%d %H:%M:%S"`

  if test -n "$SPEEDTEST_CSV_SKIP" && test -f "$log"; then
    # Reuse existing results (useful for debugging)
    1>&2 echo "** Reusing existing results: $log"
  else
    # Query Speedtest
    /usr/local/bin/speedtest-cli --share > $log
  fi
  
  stop=`date +"%Y-%m-%d %H:%M:%S"`
  
  # Parse
  from=`str_extract "Testing from "`
  from_ip=`echo $from | sed 's/.*(//g' | sed 's/).*//g'`
  from=`echo $from | sed 's/ (.*//g'`
  
  server=`str_extract "Hosted by "`
  server_ping=`echo $server | sed 's/.*: //g'`
  server=`echo $server | sed 's/: .*//g'`
  server_dist=`echo $server | sed 's/.*\\[//g' | sed 's/\\].*//g'`
  server=`echo $server | sed 's/ \\[.*//g'`
  
  download=`str_extract "Download: "`
  upload=`str_extract "Upload: "`
  share_url=`str_extract "Share results: "`
fi

# Standardize units?
if test "$1" = "--standardize"; then
  download=`echo $download | sed 's/Mbits/Mbit/'`
  upload=`echo $upload | sed 's/Mbits/Mbit/'`
fi

#  KVP for Splunk
log_splunk=/var/log/speedtest/speedtest-splunk.log
value0=`echo $server`
value1=`echo $server_ping | cut -d" " -f1`
value2=`echo $server_dist | cut -d" " -f1`
value3=`echo $download | cut -d" " -f1`
value4=`echo $upload | cut -d" " -f1` 

# Write to Splunk log
echo time_start=$start >> $log_splunk
echo test_server=\"$value0\" >> $log_splunk
echo test_ping_ms=$value1 >> $log_splunk
echo test_dist_km=$value2 >> $log_splunk
echo down_speed_mbps=$value3 >> $log_splunk
echo up_speed_mbps=$value4 >> $log_splunk
echo "" >> $log_splunk

# Remove tmp files
rm $log
