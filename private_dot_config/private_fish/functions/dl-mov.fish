function dl-mov --description 'Download DNxHD MOV from YouTube'
  yt-dlp $argv[1] -o - | mov pipe: $argv[2];
end
