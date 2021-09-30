FROM alpine

RUN apk update && apk add inotify-tools ffmpeg

COPY overlay.png .

VOLUME ["/workdir"]
ENTRYPOINT ["/bin/sh", "-c", "inotifywait -m -q -e close_write /workdir --format '%w%f' --includei '\\.mp4$' | while read file; do echo $file; ffmpeg -y -i overlay.png -ss \"$(echo \"$(ffprobe -loglevel error -of csv=p=0 -show_entries format=duration \"$file\")*0.5\" | bc -l)\" -i \"$file\" -filter_complex \"scale2ref=iw*0.35:iw*0.35[logo][base];[base][logo]overlay=main_w/2-overlay_w/2:main_h/2-overlay_h/2\" -vframes 1 -q:v 3 \"$file.jpg\"; done"]