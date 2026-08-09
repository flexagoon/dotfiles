# Adapted from https://github.com/matthewlabrecque/pim/tree/main

function pi --wraps=pi --description 'Sandbox Pi'
	set -l bwrap_args \
		--unshare-all \
		--share-net \
		--dev /dev \
		--proc /proc \
		--ro-bind / / \
		--dev-bind /dev/null /dev/null \
		--dev-bind /dev/urandom /dev/urandom \
		--tmpfs ~/.ssh \
		--setenv KAGI_API_KEY (rbw get Kagi -f "API key") \
	
	set -l allowed_paths \
		(pwd) \
		~/.config/pi \
		/tmp \
		~/.cache

	# pnpm
	set -a allowed_paths ~/.local/share/pnpm/store

	# uv tools
	set -a allowed_paths ~/.local/share/uv/tools

	# android
	set -a allowed_paths \
		~/.local/share/gradle \
		~/.local/share/android/.android

	# git
	set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
	if test -n "$git_root"
		set -a allowed_paths $git_root/.git
	end

	for path in $allowed_paths
		set -a bwrap_args \
			--bind $path $path
	end
	

	bwrap $bwrap_args \
		pi \
		--append-system-prompt "Additionally, your computer is sandboxed and you
		only have write access to the current working directory (.), /tmp, and
		~/.config/pi. If the user asks you to make changes to any directory outside
		of the three specified above, immediately inform the user that you don't
		have access to those files and ask what the user wants to do. Also inform
		the user when you need acces to directories outside the sandbox for any
		other reason (eg. a command tries to write files to some cache location and
		fails)."\
		$argv
end
