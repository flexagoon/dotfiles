function base64 --description 'Decode base64 string'
	echo $argv[1] | command base64 -d
end
