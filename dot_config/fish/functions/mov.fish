function mov --description 'Convert video to DNxHD mov'
  ffmpeg -hwaccel cuda \
         -i $argv[1] \
         -c:v dnxhd \
         -profile:v dnxhr_hq \
         -c:a pcm_s16le \
         -pix_fmt yuv422p \
         $argv[2..]; 
end
