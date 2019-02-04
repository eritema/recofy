#! /bin/bash
#
# recofy
#
# Raffaele Fronza
# git: https://github.com/eritema/recofy

shopt -s -o nounset


#### The client and secret ID of the app TestDbus 
##   https://developer.spotify.com/dashboard/applications/25000b1cf3e94a0e938677b1b41693e6
export BASE64ID='MjUwMDBiMWNmM2U5NGEwZTkzODY3N2IxYjQxNjkzZTY6ZmYwNmVhMDBmYmY3NDQwYjgyYzBiM2ZlNTQ2ZWFiOTI='

TOKEN=0
MODE="web"
PLAY="1"
tracks="0"


function menu {
  printf "%s\n" "########## Authentication section"
  printf "Set AuthorizationID (i)\n"
  printf "Get token (t)\n"
  printf "Load token (T)\n"
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
  printf "%s\n" "########## Parameters"
  printf "Use DBUS to play(d)\n"
  printf "Use web api to play (w)\n"
  printf "Get play interface (pi)\n"
  printf "%s\n" "#################################"
  printf "Print Menu (m)\n"
  printf "Exit (Ret)\n"
  return 0
}



declare -t menu

menu

while read -p "Select one of the actions: " SELECTION; do
  if [ -w $SELECTION ]; then
    printf "Exit: \n"
    exit;
  elif [ $SELECTION = "m" ]; then
    menu
  elif [ $SELECTION = "i" ]; then
    read -t 5 -p "--Write the Authorization base64ID: " input64ID
    BASE64ID=${input64ID:-$BASE64ID}
    printf "\n%sBASE64ID: %s\n" "----" $BASE64ID
  elif [ $SELECTION = "t" ]; then
     
    export TOKEN=$(curl -X "POST" -H "Authorization: Basic $BASE64ID" -d grant_type=client_credentials https://accounts.spotify.com/api/token 2>/dev/null|jq -r '.access_token')    
    printf "%sToken: %s\n" "----" $TOKEN
    echo $TOKEN > token.txt
  elif [ $SELECTION = "T" ]; then
    if test ! -f ./token.txt; then
      printf "%stoken.txt is not existing. Use get option to have one\n" "----" 
    else  
      token=(`cat token.txt`)  
      TOKEN=${token[0]}
      printf "%sLoaded Token: %s\n" "----" $TOKEN
    fi 
  elif [ $SELECTION = "p" ]; then
    if [ $TOKEN = "0" ]; then
      printf "%sYou have first to get or load an access token\n" "--"
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
      if [ $TOKEN = "0" ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/search?q=$ARTIST&type=artist&limit=50" 2>/dev/null | jq -r ".artists.items[]|.name,.uri"|\
                sed '$!N;s/\n/	/' |sed 's/ /_/g' |sed 's/spotify:artist://'> $ARTIST.txt
        cat $ARTIST.txt
        artist=(`cat $ARTIST.txt`)
        len=${#artist[*]}
	let i=0 counter=1
        printf "Length: %s\n" $len
        while ((i<$len)); do
          printf "%s) %s\n" $counter ${artist[$i]}
          let i=i+2 counter++
        done
      fi
    fi
  elif [ $SELECTION = "l" ]; then
    read -p "--Write the  ID: " ARTIST_ID
    if [ -z "$ARTIST_ID" ]; then
      printf "%sYou have to insert an artistID\n" "--"
      continue
    else
      let ARTIST_ID=ARTIST_ID*2-1
      echo "ArtistID: ${artist[$ARTIST_ID]}"
      if [ -z $TOKEN ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        echo "curl -H \"Authorization: Bearer $TOKEN\" -X GET \"https://api.spotify.com/v1/artists/${artist[$ARTIST_ID]}/albums?limit=50\" 2> /dev/null"
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/artists/${artist[$ARTIST_ID]}/albums?limit=50" 2> /dev/null | jq -r ".items[]|.name,.uri" |\
                sed '$!N;s/\n/	/' |sed 's/ /_/g'|sed 's/spotify:album://' > $ARTIST.Albums.txt
        albums=(`cat $ARTIST.Albums.txt`)
        len=${#albums[*]}
	let i=0 counter=1
        printf "Length: %s\n" $len
        while ((i<$len)); do
          printf "%s) %s\n" $counter ${albums[$i]}
          let i=i+2 counter++
        done
      fi
    fi 
  elif [ $SELECTION = "r" ]; then
    read -p "--Write the album ID: " ALBUM_ID
    if [ -z "$ALBUM_ID" ]; then
      printf "%sYou have to insert an album ID\n" "--"
      continue
    else
      let ALBUM_ID=ALBUM_ID*2-1
      let ALBUM_NAME=ALBUM_ID-1
      echo "AlbumID: ${albums[$ALBUM_ID]}"
      if [ -z $TOKEN ]; then
        printf "%sYou have first to get one token\n" "--"
        continue
      else
        echo "curl -H \"Authorization: Bearer $TOKEN\" -X GET \"https://api.spotify.com/v1/albums/${albums[$ALBUM_ID]}/tracks?limit=50\" 2> /dev/null"
        curl -H "Authorization: Bearer $TOKEN" -X GET "https://api.spotify.com/v1/albums/${albums[$ALBUM_ID]}/tracks?limit=50" 2> /dev/null | jq -r ".items[]|.name,.uri" |\
                sed '$!N;s/\n/	/'|sed 's/ /_/g'|sed 's/spotify:track://' > $ARTIST.${albums[$ALBUM_NAME]}.tracks.txt
	tracks=(`cat $ARTIST.${albums[$ALBUM_NAME]}.tracks.txt`)
        len=${#tracks[*]}
        let i=0 counter=1
        printf "Number of tracks: %s\n" $len
        while ((i<$len)); do
          printf "%s) %s\n" $counter ${tracks[$i]}
          let i=i+2 counter++
        done
      fi
    fi 

#### PLAY section
  elif [ $SELECTION = "O" ]; then
    spotify 1>/dev/null 2>&1 &
    if [ $? -ne 0 ]; then
	printf "%sImpossible to launch Spotify\n" "--"
    fi
  elif [ $SELECTION = "P" ]; then
    if [ $tracks = "0" ]; then
      printf "%sNo tracks are loaded\n" "--"
      continue
    fi
    len=${#tracks[*]}
    let i=0 counter=1
    while ((i<$len)); do
      printf "%s) %s\n" $counter ${tracks[$i]}
      let i=i+2 counter++
    done
    read -p "Select the track you would like to play:" STRING_ID
    let STRING_ID=STRING_ID*2-1
    let STRING_NAME=STRING_ID-1
    # read -p "--Write the string to play: " STRING_ID
    if [ -z "$STRING_ID" ]; then
      printf "%sYou have to insert a valid string\n" "--"
      continue
    else
      echo "Sting: $STRING_NAME"
      #if [ $MODE = "web" ]; do
               
      #else
        dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause\
        && dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri "string:spotify:track:${tracks[$STRING_ID]}"
      #fi
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
      if [ $MODE = "web" ]; then
        if [ $PLAY = "0" ]; then
           curl -X PUT "https://api.spotify.com/v1/me/player/pause" -H "Authorization: Bearer $TOKEN"
	   PLAY=1
        else
           curl -X PUT "https://api.spotify.com/v1/me/player/play" -H "Authorization: Bearer $TOKEN"
           PLAY=0
        fi 		
      else
        dbus-send  --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
      fi
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
