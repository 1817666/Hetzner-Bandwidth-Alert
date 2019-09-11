#!/bin/bash

# HETNER
API_TOKEN="HETZNER_API_TOKEN"
PROJECT="HETZNER_PREJECT_ID"
BWALERT="BANDWIDTH_USAGE_ALERT" # Like 18 (TB)

# PUSHOVER
TOKEN="PUSHOVER_TOKEN" #API TOKEN/KEY
USER="PUSHOVER_USER_KEY"

FILE="/tmp/serverlist"
TMP="/tmp/curltmp"

# Get Server List
curl -H "Authorization: Bearer $API_TOKEN" 'https://api.hetzner.cloud/v1/servers' 2>/dev/null | grep -Pzo '(?<=\n\s{6}"id": )(.*)(?=,)' > $FILE

# Get Server Info
while read line
do
  curl -H "Authorization: Bearer $API_TOKEN" https://api.hetzner.cloud/v1/servers/$line 2>/dev/null > $TMP
  BW=`bc <<< "$(cat $TMP | grep -Pzo '(?<="outgoing_traffic": )(.*)(?=,)')/1024^4"`
  SERVER=$(cat $TMP | grep -Pzo '(?<=\n\s{4}"name": ")(.*)(?=",)')
  IP=$(cat $TMP | grep -Pzo '(?<=\"ipv4\"\:\s\{\n\s{8}"ip": ")(.*)(?=",)')
  if [ "$BW" -ge $BWALERT ]
  then
    # Pushover Notification
	curl -s \
	  --form-string "token=$TOKEN" \
	  --form-string "user=$USER" \
	  --form-string "title=Bandwidth Usage Alert!" \
	  --form-string "message=Server $SERVER ($IP) using $BW TB Outgouing Traffic!" \
	  --form-string "url=https://console.hetzner.cloud/projects/$PROJECT/servers/$SERVER/overview" \
	  https://api.pushover.net/1/messages.json &> /dev/null
  fi
done < $FILE

rm -rf $TMP
rm -rf $FILE
