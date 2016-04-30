#!/bin/bash
cd ~/youtube #Change this to your youtube-dl directory.
mapfile -t videos < <(find . | grep -v -e "part$" -e "\.$")
for i in "${videos[@]}"
do
   mpv --speed=1.33 "$i" &
   mplayerpid=$!
   until wmctrl -l -p | grep -i "$mplayerpid" &>/dev/null
   do
      echo "Waiting for player"
      sleep .5
   done
   wid=$(wmctrl -l -p | grep -i "$mplayerpid" | sed -e 's/\ .*//g')
   wmctrl -r "$wid" -i -b toggle,sticky,above
   mapfile -t geo < <(wmctrl -l -G -p | grep -i "$mplayerpid" )
   let dim1=$(echo ${geo[0]} | sed -e 's/ /,/g' | cut -d , -f6)/2
   let dim2=$(echo ${geo[0]} | sed -e 's/ /,/g' | cut -d , -f7)/2
   let x=$(xdpyinfo | grep 'dimensions:' | cut -f 2 -d ':' | cut -c5-8)-${dim1}
   wmctrl -r "$wid" -i -e "0,$x,0,${dim1},${dim2}"
   echo "mpv made above and sticky"
   while ps "$mplayerpid" &>/dev/null
   do
      sleep 5
   done
   rm "$i"
done
