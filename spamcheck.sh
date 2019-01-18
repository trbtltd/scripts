#!/bin/bash
# Date: Apr 18,2017
# Author: TRBT Ltd
# https://www.fsolution.biz
# Check the IP Against Major SPAM Sources.
# For Debuging uncomment row below 
#set -x
# pipe delimited exclude list for remote lists
hosts=""
Exclude='^dnsbl.mailer.mobi$|^foo.bar$|^bar.baz$'
#WPurl="https://en.wikipedia.org/wiki/Comparison_of_DNS_blacklists"
BLIST="$(curl -s $WPurl | egrep "<td>([a-z]+\.){1,7}[a-z]+</td>" | sed -r 's|</?td>||g;/$Exclude/d')"
# Locally maintained list of DNSBLs to check
LocalList='
b.barracudacentral.org
dnsbl.sorbs.net
new.spam.dnsbl.sorbs.net
smtp.dnsbl.sorbs.net
spam.dnsbl.sorbs.net
zombie.dnsbl.sorbs.net
badconf.rhsbl.sorbs.net
old.spam.dnsbl.sorbs.net
sbl.spamhaus.org
xbl.spamhaus.org
pbl.spamhaus.org
sbl-xbl.spamhaus.org
zen.spamhaus.org
cbl.abuseat.org
dnsbl.cobion.com
babl.rbl.webiron.net
cabl.rbl.webiron.net
stabl.rbl.webiron.net
all.rbl.webiron.net
crawler.rbl.webiron.net
truncate.gbudb.net
dnsrbl.org
db.wpbl.info
bad.psky.me
bl.spamcop.net
noptr.spamrats.com
dyna.spamrats.com
spam.spamrats.com
auth.spamrats.com
ix.dnsbl.manitu.net
dnsbl.inps.de
bl.blocklist.de
srnblack.surgate.net
all.s5h.net
rbl.megarbl.net
rbl.realtimeblacklist.com
dnsbl.spfbl.net
ubl.unsubscore.com
0spam.fusionzero.com
'

# Variables
tmp_file='/tmp/blacklisted'

MAIL_ADMIN=""

> $tmp_file

HostToIP()
{
 if ( echo "$host" | egrep -q "[a-zA-Z]" ); then
   IP=$(host "$host" | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print$NF}')
 else
   IP="$host"
 fi
}

Repeat()
{
 printf "%${2}s\n" | sed "s/ /${1}/g"
}

Reverse()
{
 echo $1 | awk -F. '{print$4"."$3"."$2"."$1}'
}
Check()
{
 result=$(dig +short $rIP.$BL)
 if [ -n "$result" ]; then
   echo -e "\033[31m \033[1m MAY BE LISTED \t $BL (answer = $result) \033[0m \033[22m"  | tee -a "$tmp_file"
 else
   echo -e "NOT LISTED \t $BL :\033[32m \033[1m OK \033[22m \033[0m"  | tee -a "$tmp_file"
 fi
}

if [ -z "$hosts" ]; then
  hosts=$(netstat -tn | awk '$4 ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ && $4 !~ /127.0.0/ {gsub(/:[0-9]+/,"",$4);} END{print$4}')
fi

if [ -n "$1" ]; then
  hosts=$@
fi

for host in $hosts; do
  HostToIP
  rIP=$(Reverse $IP)
  # remote list
  echo "====================================================================================================" | tee -a "$tmp_file"
  echo; Repeat - 100
  echo " checking $IP against BLs from $WPurl" | tee -a "$tmp_file"
  echo "====================================================================================================" | tee -a "$tmp_file"
  Repeat - 100
  for BL in $BLIST; do
    Check
  done
  echo "====================================================================================================" |tee -a  "$tmp_file"
  # local list
  echo; Repeat - 100
  echo " checking $IP against BLs from a local list" | tee -a "$tmp_file"
  echo "====================================================================================================" | tee -a "$tmp_file"
  Repeat - 100
  for BL in $LocalList; do
    Check
  done

alert=`grep -i "MAY BE LISTED" $tmp_file |wc -l`;

	if [ $alert = 0 ]; then
		echo "Check for $IP completed succesfull "
		else
		cat $tmp_file |mail -s "DNSBL REPORT FOR $IP" $MAIL_ADMIN
	fi

done
