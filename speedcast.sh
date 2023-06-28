#!/bin/bash

function Speedcast (){
    	ffmpeg -stream_loop 100 -re -i speedcast.mp4 -c:v libx264 -c:a aac -f flv rtmp://127.0.0.1:1935/live/speedcast?pkt_size=1316
}
Speedcast
