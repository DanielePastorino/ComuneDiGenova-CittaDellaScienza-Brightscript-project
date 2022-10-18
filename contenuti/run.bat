rem ffmpeg -y -f lavfi -i color=c=black:s=600x3840:d=30 -vf "drawtext=verdana.ttf:fontsize=128:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text=''" loop.mp4 

ffmpeg -f concat -i list1.txt -c copy 01_120.mp4
ffmpeg -f concat -i list2.txt -c copy 02_120.mp4
ffmpeg -f concat -i list3.txt -c copy 03_120.mp4


ffmpeg -i 01_120.mp4 -vf "transpose=2" out/01.mp4
ffmpeg -i 02_120.mp4 -vf "transpose=2" out/02.mp4
ffmpeg -i 03_120.mp4 -vf "transpose=2" out/03.mp4
ffmpeg -i 04.mp4 -vf "transpose=2" out/04.mp4


