function dl-mp3 --description 'Download MP3 from YouTube'
  yt-dlp -f 140 $argv[1] -o - | ffmpeg -i pipe: $argv[2];
end
