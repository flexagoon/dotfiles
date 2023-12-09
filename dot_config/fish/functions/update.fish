function update --description 'Interactive system update'
  read -n 1 -l dnf_a -P "Do you want to upgrade system packages? (Y/n)"
  switch $dnf_a
    case y Y ''
      set dnf true
    case '*'
      set dnf false
  end

  read -n 1 -l flatpak_a -P "Do you want to upgrade flatpak packages? (Y/n)"
  switch $flatpak_a
    case y Y ''
      set flatpak true
    case '*'
      set flatpak false
  end

  if $dnf
    set -l old_kernel (rpm -q --qf "%{VERSION}" kernel)

    echo "Running dnf upgrade..."
    sudo dnf upgrade --refresh

    set -l new_kernel (rpm -q --qf "%{VERSION}" kernel)
    if test "$old_kernel" != "$new_kernel"
      echo "Kernel version changed! Reboot and rebind tpm2."	
    else
      echo "Kernel not updated."
    end
  end

  if $flatpak
    echo "Updating flatpak packages..."
    flatpak update -y
  end

  read -n 1 -l firmware_a -P "Do you want to upgrade system firmware? (Y/n)"
  switch $firmware_a
    case y Y ''
      fwupdmgr update
    case '*'
      echo "Skipping firmware update"
  end
end
