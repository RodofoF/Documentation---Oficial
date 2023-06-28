#!/bin/bash

function Video (){
    	ffmpeg -stream_loop 100 -re -i speedcast.mp4 -c:v libx264 -c:a aac -f flv rtmp://10.0.19.93:1935/live/woohoo?pkt_size=1316
	#ffmpeg -stream_loop 50 -i RecordTV.ts -c:v copy -b:v 4000 -minrate 2000 -maxrate 3900 -bufsize 500k -level 4.0 -c:a aac -rematrix_maxval 1.0 -ac 2 -b:a 128k -f flv "rtmp://10.0.19.93:1935/live/woohoo?pkt_size=1316"

}
Video
