#!/bin/sh
while true
do
  cd /data/00_hugo && git pull &>/dev/null
  killall -0 hugo || hugo server -b doc.zsjshao.cn --bind 0.0.0.0
  sleep 60
done
