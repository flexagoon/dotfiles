function fish_prompt
    # Silverblue workaround
    set -l pwd (string replace /var/home /home $PWD)

    echo

    # Indicate if running inside of toolbx/distrobox
    if test -e /run/.toolboxenv
        echo -n "📦 "
    end

    echo -s (set_color -o cyan)(prompt_pwd -D 3 $pwd) (set_color magenta)(fish_vcs_prompt)
    echo -ns (set_color green) "❯" (set_color normal) " "
end
