#!/bin/bash

commad=$1
song=$2

#spotify 1>/dev/null 2>&1 &

#sleep 5

#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause

#dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:org.mpris.MediaPlayer2.Player string:Volume variant:double:0.1
#dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:org.mpris.MediaPlayer2.Player string:Rate variant:double:5.0
#dbus-send --print-reply --type=method_call  --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Rate
#dbus-send --print-reply --type=method_call  --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:MinimumRate
#dbus-send --print-reply --type=method_call  --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:PlaybackStatus

#qdbus org.mpris.MediaPlayer2.spotify / org.freedesktop.MediaPlayer2.OpenUri spotify:album:4m2880jivSbbyEGAKfITCa

#dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause
#sleep3
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri "string:https://open.spotify.com/track/7EavTa2ie6Ynz7tX8uTeTt?si=hZXF9X_ZT1Wsq8Rissao6A"
#sleep 3
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play


uri=spotify:album:0XiL5uT7v5QLW8LU5Mx7qW # We are going to use this variable to access the metadata for the album.
song=$(curl -G "http://ws.spotify.com/lookup/1/?uri=$uri&extras=track" | grep -E -o "spotify:track:[a-zA-Z0-9]+" -m 1) # Get the first track of the Album. We are going to use this variable in next line.
echo $song
#dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause && dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri "string:$song" # Pause the player and the play the first song of the album
