#! /bin/bash
# Opalstack uwsgi installer.

# env for sqlite3
export PATH=/usr/sqlite330/bin:$PATH
export LD_LIBRARY_PATH=/usr/sqlite330/lib

CRED2='\033[1;91m'        # Red
CGREEN2='\033[1;92m'      # Green
CYELLOW2='\033[1;93m'     # Yellow
CBLUE2='\033[1;94m'       # Blue
CVIOLET2='\033[1;95m'     # Purple
CCYAN2='\033[1;96m'       # Cyan
CWHITE2='\033[1;97m'      # White
CEND='\033[0m'       # Text Reset

# i is for UUID, t is for user token, n is for app name
while getopts i:n: option
do
case "${option}"
in
i) UUID=${OPTARG};;
n) APPNAME=$OPTARG;;
esac
done

now=$(date)
echo "$now" >> /home/$USER/logs/apps/$APPNAME/install.log

if [ -z $UUID ] || [ -z $OPAL_TOKEN ] || [ -z $APPNAME ]
then
     printf $CRED2
     echo 'This command requires the following parameters to function,
     -i App UUID, used to make API calls to control panel.
     -t Control panel TOKEN, used to authenticate to the API.
     -n Application NAME, must match the name in the control panel
     '
     exit 1
else
    # Get the port and verify the app exists, and thus the file schema exists.
    if serverjson=`curl -s --fail --header "Content-Type:application/json" --header "Authorization: Token $OPAL_TOKEN"  $API_URL/api/v1/app/read/$UUID` ;then
         printf $CGREEN2
         echo 'UUID validation and server lookup OK.'
         printf $CEND
         PORT=`echo $serverjson | jq -r .port`
    else
         printf $CRED2
         echo 'UUID validation and server lookup failed.'
         exit 1
    fi;
fi;
echo $PORT

mkdir -p $HOME/apps/$APPNAME/tmp

# create a python 3.10 venv
/usr/local/bin/python3.10 -m venv /home/$USER/apps/$APPNAME/env
source /home/$USER/apps/$APPNAME/env/bin/activate
pip install -U pip

# install latest LTS release
scl enable devtoolset-11 -- pip install uwsgi
chmod +x /home/$USER/apps/$APPNAME/env/bin/uwsgi

export PORT
export APPNAME
# generator.py - installs keepalive, kill, myapp.wsgi
echo "aW1wb3J0IG9zCnVzZXIgPSBvcy5nZXRlbnYoJ1VTRVInKQpuYW1lID0gb3MuZ2V0ZW52KCdBUFBO
QU1FJykKcG9ydCA9IG9zLmdldGVudignUE9SVCcpCmtlZXBhbGl2ZV9wYXRoID0gZicvaG9tZS97
dXNlcn0vYXBwcy97bmFtZX0vc3RhcnQnCmtlZXBhbGl2ZSA9IGYnJycjIS9iaW4vYmFzaApQSURG
SUxFPSIkSE9NRS9hcHBzL3tuYW1lfS90bXAve25hbWV9LnBpZCIKaWYgWyAtZSAiJHt7UElERklM
RX19IiBdICYmIChwcyAtdSAkKHdob2FtaSkgLW9waWQ9IHwKICAgICAgICAgICAgICAgICAgICAg
ICAgICAgZ3JlcCAtUCAiXlxzKiQoY2F0ICR7e1BJREZJTEV9fSkkIiAmPiAvZGV2L251bGwpOyB0
aGVuCiAgZWNobyAiQWxyZWFkeSBydW5uaW5nLiIKICBleGl0IDk5CmZpCmVjaG8gLW4gJ1N0YXJ0
ZWQgYXQgJwpkYXRlICIrJVktJW0tJWQgJUg6JU06JVMiCi9ob21lL3t1c2VyfS9hcHBzL3tuYW1l
fS9lbnYvYmluL3V3c2dpIC0taW5pIC9ob21lL3t1c2VyfS9hcHBzL3tuYW1lfS91d3NnaS5pbmkK
JycnCmYgPSBvcGVuKGtlZXBhbGl2ZV9wYXRoLCAndysnKQpmLndyaXRlKGtlZXBhbGl2ZSkKZi5j
bG9zZQpwcmludChmJ1dyb3RlIHtrZWVwYWxpdmVfcGF0aH0nKQoKa2lsbF9wYXRoID0gZicvaG9t
ZS97dXNlcn0vYXBwcy97bmFtZX0va2lsbCcKa2lsbCA9IGYnJycjIS9iaW4vYmFzaApraWxsIC05
IGBjYXQgJEhPTUUvYXBwcy97bmFtZX0vdG1wL3tuYW1lfS5waWRgCicnJwoKZiA9IG9wZW4oa2ls
bF9wYXRoLCAndysnKQpmLndyaXRlKGtpbGwpCmYuY2xvc2UKcHJpbnQoZidXcm90ZSB7a2lsbF9w
YXRofScpCgpzdG9wX3BhdGggPSBmJy9ob21lL3t1c2VyfS9hcHBzL3tuYW1lfS9zdG9wJwpzdG9w
ID0gZicnJyMhL2Jpbi9iYXNoCgpQSURGSUxFPSIkSE9NRS9hcHBzL3tuYW1lfS90bXAve25hbWV9
LnBpZCIKaWYgWyAtZSAiJHt7UElERklMRX19IiBdICYmIChwcyAtdSAkKHdob2FtaSkgLW9waWQ9
IHwKICAgICAgICAgICAgICAgICAgICAgICAgICAgZ3JlcCAtUCAiXlxzKiQoY2F0ICR7e1BJREZJ
TEV9fSkkIiAmPiAvZGV2L251bGwpOyB0aGVuCi9ob21lL3t1c2VyfS9hcHBzL3tuYW1lfS9lbnYv
YmluL3V3c2dpIC0tc3RvcCAvaG9tZS97dXNlcn0vYXBwcy97bmFtZX0vdG1wL3tuYW1lfS5waWQK
cm0gIC9ob21lL3t1c2VyfS9hcHBzL3tuYW1lfS90bXAve25hbWV9LnBpZAogIGV4aXQgOTkKZmkK
ZWNobyAiTm8gUElEIGZpbGUiCicnJwoKZiA9IG9wZW4oc3RvcF9wYXRoLCAndysnKQpmLndyaXRl
KHN0b3ApCmYuY2xvc2UKcHJpbnQoZidXcm90ZSB7c3RvcF9wYXRofScpCgp1d3NnaV9pbmlfcGF0
aCA9IGYnL2hvbWUve3VzZXJ9L2FwcHMve25hbWV9L3V3c2dpLmluaScKdXdzZ2lfaW5pID0gZicn
J1t1d3NnaV0KbWFzdGVyID0gVHJ1ZQpodHRwLXNvY2tldCA9IDEyNy4wLjAuMTp7cG9ydH0Kdmly
dHVhbGVudiA9IC9ob21lL3t1c2VyfS9hcHBzL3tuYW1lfS9lbnYvCmRhZW1vbml6ZSA9IC9ob21l
L3t1c2VyfS9sb2dzL2FwcHMve25hbWV9L3V3c2dpLmxvZwpwaWRmaWxlID0gL2hvbWUve3VzZXJ9
L2FwcHMve25hbWV9L3RtcC97bmFtZX0ucGlkCndvcmtlcnMgPSAyCnRocmVhZHMgPSAyCgojIGFk
anVzdCB0aGUgZm9sbG93aW5nIHRvIHBvaW50IHRvIHlvdXIgcHJvamVjdAp3c2dpLWZpbGUgPSAv
aG9tZS97dXNlcn0vYXBwcy97bmFtZX0vbXlhcHAvd3NnaS5weQp0b3VjaC1yZWxvYWQgPSAvaG9t
ZS97dXNlcn0vYXBwcy97bmFtZX0vbXlhcHAvd3NnaS5weQonJycKZiA9IG9wZW4odXdzZ2lfaW5p
X3BhdGgsICd3KycpCmYud3JpdGUodXdzZ2lfaW5pKQpmLmNsb3NlCnByaW50KGYnV3JvdGUge3V3
c2dpX2luaV9wYXRofScpCgpteWFwcF93c2dpX3BhdGggPSBmJy9ob21lL3t1c2VyfS9hcHBzL3tu
YW1lfS9teWFwcC93c2dpLnB5JwpteWFwcF93c2dpID0gZicnJ2RlZiBhcHBsaWNhdGlvbihlbnYs
IHN0YXJ0X3Jlc3BvbnNlKToKICAgIHN0YXJ0X3Jlc3BvbnNlKCcyMDAgT0snLCBbKCdDb250ZW50
LVR5cGUnLCd0ZXh0L2h0bWwnKV0pCiAgICByZXR1cm4gW2InSGVsbG8gV29ybGQhJ10KJycnCm9z
Lm1rZGlyKGYnL2hvbWUve3VzZXJ9L2FwcHMve25hbWV9L215YXBwJywgbW9kZT0wbzcwMCkKZiA9
IG9wZW4obXlhcHBfd3NnaV9wYXRoLCAndysnKQpmLndyaXRlKG15YXBwX3dzZ2kpCmYuY2xvc2UK
cHJpbnQoZidXcm90ZSB7bXlhcHBfd3NnaV9wYXRofScpCg==" | base64 --decode > /home/$USER/apps/$APPNAME/tmp/$APPNAME-generator.py
/usr/local/bin/python3.10 /home/$USER/apps/$APPNAME/tmp/$APPNAME-generator.py
rm -f /home/$USER/apps/$APPNAME/tmp/$APPNAME-generator.py

chmod +x /home/$USER/apps/$APPNAME/start
chmod +x /home/$USER/apps/$APPNAME/kill
chmod +x /home/$USER/apps/$APPNAME/stop

cline="*/10 * * * * /home/$USER/apps/$APPNAME/start"
(crontab -l; echo "$cline" ) | crontab -

# add installed OK
/usr/bin/curl -s -X POST --header "Content-Type:application/json" --header "Authorization: Token $OPAL_TOKEN" -d'[{"id": "'$UUID'"}]' $API_URL/api/v1/app/installed/
