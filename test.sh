#!/bin/bash

MAX_WORKERS=8
STOP=false

trap 'echo "Stopping..."; STOP=true' SIGINT

run_job() {
  http_code=$(curl -s -w "%{http_code}" -X POST http://192.168.0.101:3002/decode \
    -H "Content-Type: application/json" \
    -d "{\"videoPath\": \"$1\", \"seekTime\": $2}" -o /tmp/resp_$$.dat 2>/dev/null)
  if [ "$http_code" != "200" ]; then
    STOP=true
    rm -f /tmp/resp_$$.dat
    return 1
  fi
  size=$(($(wc -c < /tmp/resp_$$.dat) / 1024))
  printf "%5d KB: %s\n" "$size" "$1"
  rm -f /tmp/resp_$$.dat
}

while true; do
  for file in drvs/drive_5/messed/*.mp4; do

    SEEK_TIME=$((60 + RANDOM % 60))

    run_job "$file" "$SEEK_TIME" &

    while true; do
      count=$(jobs -r 2>/dev/null | wc -l | tr -d ' ')
      [ -z "$count" ] && count=0
      [ "$count" -lt "$MAX_WORKERS" ] && break
      sleep 0.1
    done

    [ "$STOP" = true ] && break
  done

  [ "$STOP" = true ] && break
done

wait
echo "Terminted"

