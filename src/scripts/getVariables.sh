export BASE64ID='MjUwMDBiMWNmM2U5NGEwZTkzODY3N2IxYjQxNjkzZTY6ZmYwNmVhMDBmYmY3NDQwYjgyYzBiM2ZlNTQ2ZWFiOTI='



printf "%s\n" "########## Authentication section"
printf "Set AuthorizationID (i)\n"
printf "Get token (t)\n"
printf "Print token (p)\n"
printf "%s\n" "########## Get URIs"
printf "Get artist URI (a)\n"
printf "Get album URI (l)\n"
printf "Get track URI (r)\n"
printf "%s\n" "########## Play/Stop/Pause URIs"
printf "Open Spotify (O)\n"
printf "Play URI (P)\n"
printf "Pause/Play (A)\n"
printf "Next Track (N)\n"
printf "Previous Track (R)\n"
printf "Stop URI (S)\n"
printf "%s\n" "#################################"

printf "Exit (Ret)\n"

while read -p "Select one of the actions: " SELECTION; do
  if [ -w $SELECTION ]; then
    printf "Exit: \n"
    exit;

  elif [ $SELECTION = "i" ]; then
    read -t 5 -p "--Write the Authorization base64ID: " input64ID
    BASE64ID=${input64ID:-$BASE64ID}
    printf "\n%sBASE64ID: %s\n" "----" $BASE64ID
  elif [ $SELECTION = "t" ]; then
     
    export TOKEN=$(curl -X "POST" -H "Authorization: Basic $BASE64ID" -d grant_type=client_credentials https://accounts.spotify.com/api/token 2>/dev/null|jq -r '.access_token')
    
    printf "%sToken: %s\n" "----" $TOKEN
  elif [ $SELECTION = "p" ]; then
    if [ -z $TOKEN ]; then
      printf "%sYou have first to get one token\n" "--"
      continue
    else
      printf "%sToken: %s\n" "----" $TOKEN
    fi
  elif [ $SELECTION = "a" ]; then
    read -p "--Write the artist name: " ARTIST
    if [ -z "$ARTIST" ]; then
      printf "%sYou have to insert a name\n" "--"
      continue
    else
      echo "Artist: $ARTIST"
      ARTIST=$(echo $ARTIST|sed 's/ /%20/g')
      if [ -z $TOKEN ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/search?q=$ARTIST&type=artist" 2>/dev/null | jq -r ".artists.items[]|.name,.uri"|\
                sed '$!N;s/\n/\t/'
      fi
    fi
  elif [ $SELECTION = "l" ]; then
    read -p "--Write the artist ID: " ARTIST_ID
    if [ -z "$ARTIST_ID" ]; then
      printf "%sYou have to insert an artistID\n" "--"
      continue
    else
      echo "ArtistID: $ARTIST_ID"
      if [ -z $TOKEN ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/artists/$ARTIST_ID/albums" 2> /dev/null | jq -r ".items[]|.name,.uri" |\
                sed '$!N;s/\n/ \t/'
      fi
    fi 
  elif [ $SELECTION = "r" ]; then
    read -p "--Write the album ID: " ALBUM_ID
    if [ -z "$ALBUM_ID" ]; then
      printf "%sYou have to insert an album ID\n" "--"
      continue
    else
      echo "AlbumID: $ALBUM_ID"
      if [ -z $TOKEN ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/albums/$ALBUM_ID/tracks" 2> /dev/null | jq -r ".items[]|.name,.uri" |\
                sed '$!N;s/\n/ \t/'
      fi
    fi 
  elif [ $SELECTION = "O" ]; then
    spotify 1>/dev/null 2>&1 &
    if [ $? -ne 0 ]; then
	printf "%sImpossible to launch Spotify\n" "--"
    fi
  elif [ $SELECTION = "P" ]; then
    read -p "--Write the string to play: " STRING_ID
    if [ -z "$STRING_ID" ]; then
      printf "%sYou have to insert a valid string\n" "--"
      continue
    else
      echo "Sting: $String_ID"
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause\
        && dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri "string:$STRING_ID"
      if [ $? -ne 0 ]; then
	printf "%sImpossible to Play $STRING_ID\n" "--"
      fi
    fi 
  elif [ $SELECTION = "A" ]; then
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
      if [ $? -ne 0 ]; then
	printf "%sImpossible to Pause/Play\n" "--"
      fi
  elif [ $SELECTION = "S" ]; then
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
      if [ $? -ne 0 ]; then
	printf "%sImpossible to Stop $STRING_ID\n" "--"
      fi
  elif [ $SELECTION = "N" ]; then
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next
      if [ $? -ne 0 ]; then
	printf "%sImpossible to open the Next track $STRING_ID\n" "--"
      fi
  elif [ $SELECTION = "R" ]; then
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous
      if [ $? -ne 0 ]; then
	printf "%sImpossible to open the Previous track $STRING_ID\n" "--"
      fi
  elif [ $SELECTION = "S" ]; then
      dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
      if [ $? -ne 0 ]; then
	printf "%sImpossible to Stop $STRING_ID\n" "--"
      fi
  else
    printf "Wrong selection\n"
    echo $SELECTION
  fi
done
exit (0)
#base64ID=$1
token=$1
artist=$2
selection=$3

echo "Token: $token"
#curl -H "Authorization: Bearer $token" -X GET "https://api.spotify.com/v1/search?q=$artist&type=artist"|jq ".$selection"
curl -H "Authorization: Bearer $token" -X GET "https://api.spotify.com/v1/search?q=$artist&type=artist"|jq -r ".artists.items[]|.name,.uri"

token=$1
artistID=$2


curl -H "Authorization: Bearer $token" -X GET "https://api.spotify.com/v1/artists/$artistID/albums?include_groups=album"|jq -r ".items[]|.name"
