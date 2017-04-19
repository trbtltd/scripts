# Date: Apr 18,2017
# Author: TRBT Ltd.
# https://www.fsolution.biz
# Check the IP/Domain name Against Major SPAM Sources.


spamcheck.sh

Shell script that perform manual or scheduled checks in spam/blacklist for defined IP/domain name

Usage: ./spamcheck.sh IP/domain name or defined in variable hosts=""

There the DNSBL are fetched from https://en.wikipedia.org/wiki/Comparison_of_DNS_blacklists or can be defined in LocalList=''.
To be able to get notifications via e-mail you have to define valid e-mail account notification is sent only if the IP/Domain name is blacklisted.
