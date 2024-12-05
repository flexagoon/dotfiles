function mov --description 'Convert video to DNxHD mov'
  ffmpeg -hwaccel cuda \
         -c:v dnxhd \
         -profile:v dnxhr_hq \
         -c:a pcm_s16le \
         -pix_fmt yuv422p \
         -i $argv[1] $argv[2..]; 
end
