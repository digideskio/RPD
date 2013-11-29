#! /bin/sh

### Douban details
DOUBAN_EMAIL='doubantucao@gmail.com'
DOUBAN_PASS='doubantucao'

### Jing details
JING_EMAIL=''
JING_PASS=''

douban_res="`curl -sG -d"email=$DOUBAN_EMAIL" -d"password=$DOUBAN_PASS" -d"app_name=radio_desktop_win" -d"version=100" "http://www.douban.com/j/app/login" | python -mjson.tool`"

echo "[Radio]
channel = 0

[DoubanFM]"
echo "$douban_res" | grep user_id | awk '{print $2}' | awk -F'"' '{print "uid = "$2}'
echo "$douban_res" | grep user_name | awk '{print $2}' | awk -F'"' '{print "uname = "$2}'
echo "$douban_res" | grep token | awk '{print $2}' | awk -F'"' '{print "token = "$2}'
echo "$douban_res" | grep expire | awk '{print $2}' | awk -F'"' '{print "expire = "$2}'
echo "kbps ="

echo "
[JingFM]"
jing_res="`curl -si -d"email=$JING_EMAIL" -d"pwd=$JING_PASS" 'http://jing.fm/api/v1/sessions/create'`"
echo "$jing_res" | tail -n 1 | python -mjson.tool | grep -m1 uid | awk '{print "uid = "$2}'
echo "$jing_res" | grep "Jing-A-Token-Header" | awk '{print "atoken = "$2}'
echo "$jing_res" | grep "Jing-R-Token-Header" | awk '{print "rtoken = "$2}'

echo "
[Output]
driver = alsa
device = default
rate = 44100

[Server]
address = 0.0.0.0
port = 10098
"
