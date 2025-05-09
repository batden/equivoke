#!/bin/bash
#shellcheck disable=SC1091 disable=SC2154 disable=SC2164

# This script allows you to easily and securely install or update Enlightenment along with other
# applications based on the Enlightenment Foundation Libraries (EFL) on your Ubuntu desktop.
# Alternatively, because of the overall modular approach, it will help you to uninstall
# the Enlightenment ecosystem in a clean and safe way.

# Supported distribution: Ubuntu Plucky Puffin.

# EQUIVOKE.SH handles the download, configuration, and building of everything
# you need to enjoy the very latest version of the Enlightenment environment
# (DEB packages ——if they exist—— often lag far behind). Once installed,
# you can update your Enlightenment desktop whenever you like.

# Optional: Additional steps may be taken to achieve optimal results.
# Please refer to the comments of the build_plain() function.

# Tip: Set your terminal scrollback to unlimited, so you can always scroll up
# to see the previous output.

# See README.md for instructions on how to use this script.
# See also the repository's wiki for post-installation hints.

# Heads up!
# Enlightenment programs compiled from git source code will inevitably conflict
# with those installed from DEB packages. Therefore, remove all previous binary
# installations of EFL, Enlightenment, and related applications before running
# this script.

# Also note that EQUIVOKE.SH is not compatible with non-standard package managers like Nix.

# EQUIVOKE.SH is licensed under a Creative Commons Attribution 4.0 International License,
# in memory of Aaron Swartz.
# See https://creativecommons.org/licenses/by/4.0/

# If you find our scripts useful, please consider starring our repositories or
# donating with PayPal (see README.md) to show your support.
# Thank you!

# Source companion script.
source "$HOME"/.equivoke/konfig.sh

# Menu hints and prompts.
# 1: A no-frills, plain build.
# 2: A feature-rich, decently optimized build on Xorg; recommended for most users.
# 3: Similar to the above, but running Enlightenment as a Wayland compositor is still considered experimental.
# Avoid the third option with Nvidia drivers.
#
menu_slct() {
  is_einstl=$1

  echo
  if [ "$is_einstl" == false ]; then
    printf "1  $green_bright%s $off%s\n\n" "INSTALL the Enlightenment ecosystem now" | pv -qL 20
    printf "2  $magenta_dim%s $off%s\n\n" "(Update and rebuild the ecosystem in release mode)" | pv -qL 30
    printf "3  $orange_dim%s $off%s\n\n" "(Update and rebuild the ecosystem with Wayland support)" | pv -qL 30
    printf "4  $red_dim%s $off%s\n\n" "(Uninstall the Enlightenment ecosystem)" | pv -qL 30
  else
    printf "1  $green_dim%s $off%s\n\n" "(Install the Enlightenment ecosystem now)" | pv -qL 30
    printf "2  $magenta_bright%s $off%s\n\n" "Update and rebuild the ecosystem in RELEASE mode" | pv -qL 20
    printf "3  $orange_bright%s $off%s\n\n" "Update and rebuild the ecosystem with WAYLAND support" | pv -qL 24
    printf "4  $red_bright%s $off%s\n\n" "UNINSTALL the Enlightenment ecosystem" | pv -qL 24
  fi

  sleep 1 && printf "$italic%s $off%s\n\n" "Or press Ctrl+C to quit."
  read -r usr_input
}

# Check binary dependencies.
bin_dps() {
  if ! sudo apt install --no-install-recommends "${deps[@]}"; then
    printf "\n$red_bright%s %s\n" "CONFLICTING OR MISSING DEB PACKAGES"
    printf "$red_bright%s %s\n" "OR DPKG DATABASE IS LOCKED."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

# Check source dependencies.
cnt_dir() {
  count=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)

  if [ ! -d efl ] || [ ! -d enlightenment ]; then
    printf "\n$red_bright%s %s\n" "FAILED TO DOWNLOAD MAIN COMPONENT."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
  #
  # Tip: You can try to download the missing file(s) manually (see clonefl or clonenl), then
  # rerun the script and select option 1 again; or relaunch the script at a later time.
  # In both cases, be sure to enter the same path for the Enlightenment source folders
  # as you used before.

  case $count in
  15)
    printf "$green_bright%s $off%s\n\n" "All programs have been downloaded successfully."
    beep_complete
    sleep 2
    ;;
  0)
    printf "\n$red_bright%s %s\n" "OOPS! SOMETHING WENT WRONG."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
    ;;
  *)
    printf "\n$yellow_bright%s %s\n" "WARNING: ONLY $count OF 15 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$yellow_bright%s $off%s\n\n" "WAIT 12 SECONDS OR HIT CTRL+C TO EXIT NOW."
    beep_attention
    sleep 12
    ;;
  esac
}

mng_err() {
  printf "\n$red_bright%s $off%s\n\n" "BUILD ERROR——TRY AGAIN LATER."
  beep_exit
  exit 1
}

e_bkp() {
  tstamp=$(date +%s)

  if [ -d "$docdir/ebackups" ]; then
    rm -rf "$docdir/ebackups"

    mkdir -p "$docdir/ebackups/e_$tstamp" "$docdir/ebackups/eterm_$tstamp"

    cp -aR "$HOME/.elementary" "$HOME/.e" "$docdir/ebackups/e_$tstamp" &>/dev/null
    cp -aR "$HOME/.config/terminology" "$docdir/ebackups/eterm_$tstamp" &>/dev/null

    sleep 2
  fi
  #
  # Timestamp: See the date man page to convert epoch to human-readable date
  # or visit https://www.epochconverter.com/
  #
  # To restore a backup, use the same commands that were executed, but with the source
  # and destination reversed, similar to this:
  # cp -aR /home/riley/Documents/ebackups/e_1743247879/.elementary/ /home/riley/
  # cp -aR /home/riley/Documents/ebackups/e_1743247879/.e/ /home/riley/
  # cp -aR /home/riley/Documents/ebackups/eterm_1743247879/terminology/config/ /home/riley/.config/terminology/
  # cp -aR /home/riley/Documents/ebackups/eterm_1743247879/terminology/themes/ /home/riley/.config/terminology/
  #
  # Then close the terminal and press Ctrl+Alt+End to restart Enlightenment if you are logged in.
}

e_tokens() {
  printf '%(%s)T\n' -1 >>"$HOME/.cache/ebuilds/etokens"
  mapfile -t lines <"$HOME/.cache/ebuilds/etokens"
  token=${#lines[@]}

  if [[ "$token" -eq 10 ]]; then
    printf "\n$blue_bright%s %s" "Thank you $LOGNAME, for your trust and fidelity!"
    printf "\n$blue_bright%s $off%s\n\n" "Looks like you're on the right track..."
    sleep 2
    sl | lolcat
    sleep 2
  elif [[ "$token" -gt 4 ]]; then
    echo
    # Questions: Enter either y or n, or press Enter to accept the default value (capital letter).
    beep_question
    read -r -t 12 -p "Do you want to back up your Enlightenment and Terminology settings now? [y/N] " answer
    case $answer in
    y | Y)
      e_bkp
      printf "\n$italic%s $off%s\n\n" "(Done... OK)"
      ;;
    n | N)
      printf "\n$italic%s $off%s\n\n" "(No backup made... OK)"
      ;;
    *)
      printf "\n$italic%s $off%s\n\n" "(No backup made... OK)"
      ;;
    esac
  fi
}

# Fetch EDI's additional dependencies before executing the script?
# If you want edi to compile, you will also need to install the
# packages listed in the link below:
# https://gist.github.com/batden/99a7ebdd5ba9d9e83b2446ab5f05f3dc
#
build_plain() {
  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for i in "${prog_mbs[@]}"; do
    cd "$esrcdir/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Building $i..."

    case $i in
    efl)
      meson setup build -Dbuildtype=plain \
        -Dfb=true \
        -Dbuild-tests=false \
        -Dlua-interpreter=lua \
        -Devas-loaders-disabler= \
        -Dglib=true \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson setup build -Dbuildtype=plain
      ninja -C build || mng_err
      ;;
    edi)
      meson setup build -Dbuildtype=plain \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    *)
      meson setup build -Dbuildtype=plain
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

rebuild_optim() {
  esrcdir=$(cat "$HOME/.cache/ebuilds/storepath")

  bin_dps
  e_tokens

  for i in "${prog_mbs[@]}"; do
    cd "$esrcdir/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Updating $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

    case $i in
    efl)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dnative-arch-optimization=true \
        -Dfb=true \
        -Dharfbuzz=true \
        -Dlua-interpreter=lua \
        -Delua=true \
        -Dbindings=lua,cxx \
        -Devas-loaders-disabler= \
        -Dglib=true \
        -Dopengl=full \
        -Ddrm=false \
        -Dwl=false \
        -Dbuild-tests=false \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=false
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    *)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

rebuild_wayld() {
  esrcdir=$(cat "$HOME/.cache/ebuilds/storepath")

  if [ "$XDG_SESSION_TYPE" == "tty" ] && [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$red_bright%s $off%s\n\n" "PLEASE LOG IN TO THE DEFAULT DESKTOP ENVIRONMENT TO EXECUTE THIS SCRIPT."
    beep_exit
    exit 1
  fi

  bin_dps
  e_tokens

  for i in "${prog_mbs[@]}"; do
    cd "$esrcdir/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Updating $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

    case $i in
    efl)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dnative-arch-optimization=true \
        -Dfb=true \
        -Dharfbuzz=true \
        -Dlua-interpreter=lua \
        -Delua=true \
        -Dbindings=lua,cxx \
        -Devas-loaders-disabler= \
        -Dglib=true \
        -Ddrm=true \
        -Dwl=true \
        -Dopengl=es-egl \
        -Dbuild-tests=false \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=true
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    *)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

set_p_src() {
  echo
  beep_attention

  # Do not append a trailing slash (/) to the end of the path prefix.
  #
  read -r -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/$LOGNAME/Documents or /home/$LOGNAME/testing): " mypath

  if [[ ! "$mypath" =~ ^/home/$LOGNAME.* ]]; then
    printf "\n$red_bright%s $off%s\n" "PATH MUST BE WITHIN YOUR HOME DIRECTORY (/home/$LOGNAME)."
    beep_exit
    exit 1
  fi

  echo
  read -r -p "Create directory $mypath/sources? [Y/n] " confirm

  if [[ $confirm =~ ^[Nn]$ ]]; then
    beep_exit
    exit 1
  fi

  mkdir -p "$mypath/sources"
  p_srcdir="$mypath/sources"
  echo "$p_srcdir" >"$HOME/.cache/ebuilds/storepath"
  printf "\n$green_bright%s $off%s\n\n" "You have chosen: $p_srcdir"
  sleep 1
}

mv_sysfiles() {
  sudo mkdir -p /etc/enlightenment
  sudo mv -f /usr/local/etc/enlightenment/sysactions.conf /etc/enlightenment/sysactions.conf
  sudo mv -f /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
  sudo mv -f /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop
}

chk_pv() {
  if [ ! -x /usr/bin/pv ]; then
    printf "\n$bold%s $off%s\n\n" "Installing the pv command for menu animation..."
    sudo apt install -y pv
  fi
}

chk_sl() {
  if [ ! -x /usr/games/sl ]; then
    printf "\n$bold%s $off%s\n\n" "Installing the sl command for special animation..."
    sudo apt install -y sl
  fi
}

rstrt_e() {
  if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    enlightenment_remote -restart
    if [ -x /usr/bin/spd-say ]; then
      spd-say --language Rob 'enlightenment is awesome'
    fi
  fi
}

install_now() {
  esrcdir=$(cat "$HOME/.cache/ebuilds/storepath")

  clear
  printf "\n$green_bright%s $off%s\n\n" "* INSTALLING ENLIGHTENMENT DESKTOP ENVIRONMENT: PLAIN BUILD ON XORG SERVER *"
  do_bsh_alias
  beep_attention
  bin_dps
  set_p_src

  cd "$HOME"
  mkdir -p "$esrcdir"/enlighten
  cd "$esrcdir"/enlighten

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  echo
  $clonety
  echo
  $clonenl
  echo
  $cloneph
  echo
  $clonerg
  echo
  $clonevi
  echo
  $clonexp
  echo
  $clonecr
  echo
  $cloneve
  echo
  $clonedi
  echo
  $clonent
  echo
  $cloneft
  echo
  $clonepn
  echo
  $clonepl
  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from Dimmus' git repository..."
  $clonete
  echo

  cnt_dir
  build_plain
  mv_sysfiles

  if [ -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/local/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  if [ -f /usr/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  # Doxygen outputs HTML-based (as well as LaTeX-formatted) documentation. Click on enlighten/efl/build/html/index.html
  # to open the HTML documentation in your browser.
  # This takes a while to build, but it's a one-time thing.
  #
  printf "\n\n$bold%s $off%s\n\n" "Generating the documentation for EFL..."
  sleep 1
  cd "$esrcdir/enlighten/efl/build/doc"
  doxygen

  # This will protect the file from accidental deletion.
  sudo chattr +i "$HOME/.cache/ebuilds/storepath"

  printf "\n%s\n\n" "All done!"
  beep_ok

  printf "\n\n$blue_bright%s %s" "INITIAL SETUP WIZARD TIPS:"
  printf "\n$blue_bright%s %s" '“Update checking” —— You can disable this feature as it is not helpful for this type of installation.'
  printf "\n$blue_bright%s $off%s\n\n" '“Network management support” —— Connman is not required. You can ignore the message that appears.'

  # Note: Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Gnome Desktop, you can safely delete them if it bothers you.

  echo
  cowsay "Now log out of your existing session, then select Enlightenment on the login screen... \
  That's All Folks!" | lolcat -a
  echo

  cp -f "$dldir/equivoke.sh" "$HOME/.local/bin"

  exit 0
}

release_go() {
  clear
  printf "\n$magenta_bright%s $off%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON XORG SERVER *"

  # Checks for available updates of the script folder first.
  cd "$scrfldr" && git pull &>/dev/null
  cp -f equivoke.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/equivoke.sh"
  sleep 1

  rebuild_optim

  sudo mv -f /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop &>/dev/null

  if [ -f /usr/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  if [ -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/local/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo

  exit 0
}

wayld_go() {
  clear
  printf "\n$orange_bright%s $off%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON WAYLAND *"

  # Checks for available updates of the script folder first.
  cd "$scrfldr" && git pull &>/dev/null
  cp -f equivoke.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/equivoke.sh"

  sleep 1

  rebuild_wayld

  sudo mkdir -p /usr/share/wayland-sessions
  sudo mv -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop \
    /usr/share/wayland-sessions/enlightenment-wayland.desktop &>/dev/null

  beep_ok

  if [ "$XDG_SESSION_TYPE" == "x11" ] || [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo
    cowsay -f www "Now log out of your existing session and press Ctrl+Alt+F3 to switch to tty3, \
        then enter your credentials and type: enlightenment_start" | lolcat -a
    echo
    # Wait a few seconds for the Wayland session to start.
    # When you're done, type exit
    # Pressing Ctrl+Alt+F1 will bring you back to the login screen.
  else
    echo
    cowsay -f www "That's it. Now type: enlightenment_start"
    echo
    # If Enlightenment fails to start, relaunch the script and select option 2.
    # After the build is complete, type exit, then go back to the login screen.
  fi

  exit 0
}

# Lo and behold (“bhd”)!
#
# First, display the selection menu...
#
lo() {
  trap '{ printf "\n$red_bright%s $off%s\n\n" "KEYBOARD INTERRUPT."; exit 130; }' SIGINT

  usr_input=0
  printf "\n$bold%s $off%s\n" "Please enter the number of your choice:"

  if [ ! -x /usr/local/bin/enlightenment_start ]; then
    menu_slct false
  else
    menu_slct true
  fi
}

# Then get the user's choice.
bhd() {
  case "$usr_input" in
  1)
    do_tests
    chk_pv
    chk_sl
    install_now
    ;;
  2)
    do_tests
    chk_pv
    chk_sl
    release_go
    ;;
  3)
    do_tests
    chk_pv
    chk_sl
    wayld_go
    ;;
  4)
    source "$HOME"/.equivoke/evakuate.sh
    uninstall_enlighten
    printf "\n\n$red_bright%s %s\n" "Done."
    printf "$red_bright%s $off%s\n\n" 'Candidates for further deletion: Search for "evakuate" and "ebackups" in your home folder.'
    ;;
  *)
    beep_exit
    exit 1
    ;;
  esac
}

lo
bhd
