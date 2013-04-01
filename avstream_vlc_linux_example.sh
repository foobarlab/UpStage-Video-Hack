#!/bin/sh
# example script for RTMP streaming
# using VLC + video4linux (e.g. from your local webcam)
# change settings according to your needs

# ----------------------
# video capture settings
# ----------------------

# v4l capture device (internal most likely is "/dev/video0", external is "/dev/video1")
VIDEO_CAPTURE_DEVICE="/dev/video0"
VIDEO_CAPTURE_WIDTH=640
VIDEO_CAPTURE_HEIGHT=480
VIDEO_CAPTURE_FPS=30


# ----------------------
# audio capture settings
# ----------------------

# main audio device (probably not used) 
AUDIO_CAPTURE_DEVICE="/dev/pcm"
# actually the device you capture audio from (e.g. internal is "alsa://hw:0,0", external is "alsa://hw:1,0")
AUDIO_CAPTURE_DEVICE_SLAVE="alsa://hw:0,0"
AUDIO_CAPTURE_SAMPLERATE=48000


# --------------------------
# stream publishing settings
# --------------------------

# the URL where to publish the stream to (last part is the actual stream name)
STREAM_PUBLISH_URL="rtmp://localhost:1935/oflaDemo/mystream"
 
STREAM_VIDEO_FPS=30
STREAM_VIDEO_WIDTH=320
STREAM_VIDEO_HEIGHT=240
STREAM_VIDEO_SCALE=1
STREAM_VIDEO_BITRATE=128

STREAM_AUDIO_CHANNELS=2
STREAM_AUDIO_SAMPLERATE=22050
STREAM_AUDIO_BITRATE=64


# -----------
# transcoding
# -----------

# use vp6 and mp3:

STREAM_TRANSCODE="#transcode{vcodec=FLV1,vb=$STREAM_VIDEO_BITRATE,fps=$STREAM_VIDEO_FPS,width=$STREAM_VIDEO_WIDTH,height=$STREAM_VIDEO_HEIGHT,scale=$STREAM_VIDEO_SCALE,acodec=mp3,ab=$STREAM_AUDIO_BITRATE,channels=$STREAM_AUDIO_CHANNELS,samplerate=$STREAM_AUDIO_SAMPLERATE}:standard{access=rtmp,mux=ffmpeg{mux=flv},dst=$STREAM_PUBLISH_URL}"

# just uncomment the lines below to use h.264 and mp4a with different size and bitrate:

#STREAM_VIDEO_BITRATE=512
#STREAM_VIDEO_WIDTH=640
#STREAM_VIDEO_HEIGHT=480
#
#STREAM_ENCODER_OPTIONS="{profile=baseline,level=1.2}"
#STREAM_TRANSCODE="#transcode{vcodec=h264,venc=x264$STREAM_ENCODER_OPTIONS,vb=$STREAM_VIDEO_BITRATE,fps=$STREAM_VIDEO_FPS,width=$STREAM_VIDEO_WIDTH,height=$STREAM_VIDEO_HEIGHT,scale=$STREAM_VIDEO_SCALE,acodec=mp4a,ab=$STREAM_AUDIO_BITRATE,channels=$STREAM_AUDIO_CHANNELS,samplerate=$STREAM_AUDIO_SAMPLERATE}:standard{access=rtmp,mux=ffmpeg{mux=flv},dst=$STREAM_PUBLISH_URL}"


# -------------
# watch stream? 
# -------------

# uncomment to watch the published stream using MPlayer:
#rtmpdump -r "$STREAM_PUBLISH_URL" --live | mplayer - &


# ---------------
# start streaming
# ---------------

echo ----------------------------------------------------------------------------------------
echo Streaming to $STREAM_PUBLISH_URL ...
echo Video: $STREAM_VIDEO_WIDTH x $STREAM_VIDEO_HEIGHT, $STREAM_VIDEO_FPS fps, $STREAM_VIDEO_BITRATE kBit/s
echo Audio: $STREAM_AUDIO_CHANNELS channel, $STREAM_AUDIO_SAMPLERATE kHz, $STREAM_AUDIO_BITRATE kBit/s
echo ----------------------------------------------------------------------------------------

cvlc v4l2://$VIDEO_CAPTURE_DEVICE :v4l-vdev=$VIDEO_CAPTURE_DEVICE :v4l-adev=$AUDIO_CAPTURE_DEVICE :v4l-norm=3 :v4l-frequency=-1 :input-slave=$AUDIO_CAPTURE_DEVICE_SLAVE :v4l-caching=100 :v4l-chroma="" :v4l-fps=-1.000000 :v4l-samplerate=$AUDIO_CAPTURE_SAMPLERATE :v4l-audio=-1 :v4l-stereo :v4l-width=$VIDEO_CAPTURE_WIDTH :v4l-height=$VIDEO_CAPTURE_HEIGHT :v4l-brightness=-1 :v4l-colour=-1 :v4l-hue=-1 :v4l-contrast=-1 :no-v4l-mjpeg :v4l-decimation=1 :v4l-quality=100 --sout=$STREAM_TRANSCODE

