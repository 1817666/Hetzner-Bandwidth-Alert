#!/bin/bash

# Hetzner Outgouing Traffic Monitoring
# https://docs.hetzner.cloud
# https://pushover.net
# https://t.me/Nginx0

# HETNER
API_TOKEN="HETZNER_API_TOKEN"
PROJECT="HETZNER_PREJECT_ID"

# PUSHOVER
TOKEN="PUSHOVER_TOKEN" #API TOKEN/KEY
USER="PUSHOVER_USER_KEY"

FILE=/tmp/serverlist
curl -H "Authorization: Bearer $API_TOKEN" 'https://api.hetzner.cloud/v1/servers' 2>/dev/null | grep -Pzo '(?<=\n\s{6}"id": )(.*)(?=,)' > $FILE

while read line
do
  BW=$(curl -H "Authorization: Bearer $API_TOKEN" https://api.hetzner.cloud/v1/servers/$line 2>/dev/null | grep -Pzo '(?<="outgoing_traffic": )(.*)(?=,)')
  NEWBW=`bc <<< "$BW/1024^4"`
  SERVER=$(curl -H "Authorization: Bearer $API_TOKEN" https://api.hetzner.cloud/v1/servers/$line 2>/dev/null | grep -Pzo '(?<=\n\s{4}"name": ")(.*)(?=",)')
  if [ "$NEWBW" -ge 18 ]
  then
	curl -s \
	  --form-string "token=$TOKEN" \
	  --form-string "user=$USER" \
	  --form-string "title=Bandwidth Usage Alert!" \
	  --form-string "message=Server $SERVER using $NEWBW TB Outgouing Traffic! Check it quickly!!" \
	  --form-string "url=https://console.hetzner.cloud/projects/$PROJECT/servers/3060821/overview" \
	  https://api.pushover.net/1/messages.json &> /dev/null
  fi
done < $FILE

rm -rf $FILE