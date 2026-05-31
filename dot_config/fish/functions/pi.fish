# Adapted from https://github.com/matthewlabrecque/pim/tree/main

function pi --wraps=pi --description 'Sandbox Pi'
	bwrap \
		--unshare-all \
		--share-net \
		--dev /dev \
		--proc /proc \
		--ro-bind / / \
		--bind (pwd) (pwd) \
		--bind ~/.config/pi ~/.config/pi \
		--bind /tmp /tmp \
		--dev-bind /dev/null /dev/null \
		--tmpfs ~/.ssh \
		--setenv KAGI_API_KEY (rbw get Kagi -f "API key") \
		pi \
		--append-system-prompt "Additionally, your computer is sandboxed and you
		only have access to the current working directory (.), /tmp, and ~/.pi. If
		the user asks you to make changes to any directory outside of the three
		specified above, immediately inform the user that you don't have access to
		those files and ask what the user wants to do. Also, if you want to remove a
		file from the project, ask the user for confirmation before removing."
end
