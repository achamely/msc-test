#!/bin/bash

# Script to query the four major implementations and request balance for address supplied as $1
# Zathras Feb/2014

# Logic is rinse repeat, so drop in a function to filter down to just balance
function getbal {
# Note workaround the fact some implementations add whitespace into json output by replacing ": " with ":"
temp=`echo $json | sed "s/},/\n/g" | grep "$add" | sed "s/: /:/g" | sed 's/.*"balance":"\([^"]*\)".*/\1/'`
echo ${temp##*|}
}

# Grab parameter and throw into $add var
add=$1

# Grab verification API json from each implementation and then filter with above function to get balance
# Store balance in vars $bal1 to $bal4 so we can compare for consensus
echo Requesting balance for address $add...
echo
echo Checking masterchest.info...
json=`curl -s -X GET https://masterchest.info/mastercoin_verify/addresses.aspx`
bal1=`getbal`
echo Balance returned from masterchest.info is $bal1
echo Checking mastercoin-explorer.com...
json=`curl -s -X GET http://mastercoin-explorer.com/mastercoin_verify/addresses?currency_id=1`
bal2=`getbal`
echo Balance returned from mastercoin-explorer.com is $bal2
echo Checking masterchain.info...
json=`curl -s -X GET https://masterchain.info/mastercoin_verify/addresses/0`
bal3=`getbal`
echo Balance returned from masterchain.info is $bal3
echo Checking mymastercoins.com...
json=`curl -s -X GET http://www.mymastercoins.com/jaddress.aspx`
bal4=`getbal`
echo Balance returned from mymastercoins.com is $bal4
echo

# Check consensus
if [ "$bal1" == "$bal2" ] && [ "$bal1" == "$bal3" ] && [ "$bal1" == "$bal4" ] && [ "$bal2" == "$bal3" ] && [ "$bal2" == "$bal4" ] && [ "$bal3" == "$bal4" ]
then
echo "Consensus check: Balances match :)"
echo "Consensus balance: "$bal1
else
echo "Consensus check: BALANCES DO NOT MATCH!!! :("
fi
