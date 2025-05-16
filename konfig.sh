#!/bin/bash
# shellcheck disable=SC1091 disable=SC2034

# This script contains variables, functions, and tests used by the other scripts.

# Colors and formatting.
green_bright="\e[1;38;5;118m"
magenta_bright="\e[1;38;5;201m"
orange_bright="\e[1;38;5;208m"
yellow_bright="\e[1;38;5;226m"
blue_bright="\e[1;38;5;74m"
red_bright="\e[1;38;5;1m"
green_dim="\e[2;38;5;118m"
magenta_dim="\e[2;38;5;201m"
orange_dim="\e[2;38;5;208m"
red_dim="\e[2;38;5;1m"
bold="\e[1m"
italic="\e[3m"
off="\e[0m"

# Path definitions and aliases.
dldir=$(xdg-user-dir DOWNLOAD)
docdir=$(xdg-user-dir DOCUMENTS)
scrfldr=$HOME/.equivoke
rebasef="git config pull.rebase false"
snin="sudo ninja -C build install"
distro=$(lsb_release -sc)

# Build dependencies, plus recommended and script-related packages.
deps=(
  arc-theme
  build-essential
  ccache
  check
  cmake
  cowsay
  ddcutil
  doxygen
  fonts-noto
  freeglut3-dev
  gettext
  graphviz
  gstreamer1.0-plugins-bad
  gstreamer1.0-plugins-ugly
  hwdata
  i2c-tools
  imagemagick
  libaom-dev
  libasound2-dev
  libavahi-client-dev
  libavif-dev
  libblkid-dev
  libbluetooth-dev
  libddcutil-dev
  libegl1-mesa-dev
  libexif-dev
  libfontconfig-dev
  libdrm-dev
  libfreetype-dev
  libfribidi-dev
  libgbm-dev
  libgeoclue-2-dev
  libgif-dev
  libgraphviz-dev
  libgstreamer1.0-dev
  libgstreamer-plugins-base1.0-dev
  libharfbuzz-dev
  libheif-dev
  libi2c-dev
  libibus-1.0-dev
  libinput-dev libinput-tools
  libjansson-dev
  libjpeg-dev
  libjson-c-dev
  libjxl-dev
  libkmod-dev
  liblua5.2-dev
  liblz4-dev
  libmenu-cache-dev
  libmount-dev
  libopenjp2-7-dev
  libosmesa6-dev
  libpam0g-dev
  libpoppler-cpp-dev
  libpoppler-dev
  libpoppler-private-dev
  libpulse-dev
  libqoi-dev
  libraw-dev
  librlottie-dev
  librsvg2-dev
  libsdl1.2-dev
  libscim-dev
  libsndfile1-dev
  libspectre-dev
  libssl-dev
  libsystemd-dev
  libtiff5-dev
  libtool
  libudev-dev
  libudisks2-dev
  libunibreak-dev
  libunwind-dev
  libusb-1.0-0-dev
  libwebp-dev
  libxcb-keysyms1-dev
  libxcursor-dev
  libxinerama-dev
  libxkbcommon-x11-dev
  libxkbfile-dev
  lxmenu-data
  libxrandr-dev
  libxss-dev
  libxtst-dev
  libyuv-dev
  lolcat
  manpages-dev
  manpages-posix-dev
  meson
  ninja-build
  papirus-icon-theme
  systemd-dev
  texlive-base
  texlive-font-utils
  unity-greeter-badges
  valgrind
  wayland-protocols
  wmctrl
  xdotool
)

# Source repositories of programs. Latest source code available:
clonefl="git clone https://git.enlightenment.org/enlightenment/efl.git"
clonety="git clone https://git.enlightenment.org/enlightenment/terminology.git"
clonenl="git clone https://git.enlightenment.org/enlightenment/enlightenment.git"
cloneph="git clone https://git.enlightenment.org/enlightenment/ephoto.git"
clonerg="git clone https://git.enlightenment.org/enlightenment/rage.git"
clonevi="git clone https://git.enlightenment.org/enlightenment/evisum.git"
clonexp="git clone https://git.enlightenment.org/enlightenment/express.git"
clonecr="git clone https://git.enlightenment.org/enlightenment/ecrire.git"
cloneve="git clone https://git.enlightenment.org/enlightenment/enventor.git"
clonedi="git clone https://git.enlightenment.org/enlightenment/edi.git"
clonent="git clone https://git.enlightenment.org/vtorri/entice.git"
cloneft="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts.git"
clonepn="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-penguins.git"
clonepl="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-places.git"
clonete="git clone https://github.com/dimmus/eflete.git"

# “mbs” stands for Meson Build System.
prog_mbs=(
  efl
  terminology
  enlightenment
  ephoto
  rage
  evisum
  express
  ecrire
  enventor
  edi
  entice
  enlightenment-module-forecasts
  enlightenment-module-penguins
  enlightenment-module-places
  eflete
)

# Audible feedback (event, sudo prompt...) on most systems.
beep_complete() {
  aplay --quiet /usr/share/sounds/sound-icons/glass-water-1.wav 2>/dev/null
}

beep_attention() {
  aplay --quiet /usr/share/sounds/sound-icons/percussion-50.wav 2>/dev/null
}

beep_question() {
  aplay --quiet /usr/share/sounds/sound-icons/guitar-13.wav 2>/dev/null
}

beep_exit() {
  aplay --quiet /usr/share/sounds/sound-icons/pipe.wav 2>/dev/null
}

beep_ok() {
  aplay --quiet /usr/share/sounds/sound-icons/trumpet-12.wav 2>/dev/null
}

do_tests() {
  free_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ "$free_space" -lt 2 ]; then
    printf "\n$red_bright%s %s\n" "INSUFFICIENT DISK SPACE. AT LEAST 2 GB REQUIRED."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi

  if [ -x /usr/bin/wmctrl ]; then
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
      wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    fi
  fi

  printf "\n\n$bold%s $off%s\n" "System check..."

  if systemd-detect-virt -q --container; then
    printf "\n$red_bright%s %s\n" "EQUIVOKE IS NOT INTENDED FOR USE INSIDE CONTAINERS."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi

  if [ "$distro" == plucky ]; then
    printf "\n$green_bright%s $off%s\n\n" "Ubuntu ${distro^}... OK"
    sleep 1
  else
    printf "\n$red_bright%s $off%s\n\n" "UNSUPPORTED OPERATING SYSTEM [ $(lsb_release -d | cut -f2) ]."
    beep_exit
    exit 1
  fi

  if ! git ls-remote https://git.enlightenment.org/enlightenment/efl.git HEAD &>/dev/null; then
    printf "\n$red_bright%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$red_bright%s $off%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    beep_exit
    exit 1
  fi

  if [[ ! -d "$HOME/.local/bin" ]]; then
    mkdir -p "$HOME/.local/bin"
  fi

  if [[ ! -d "$HOME/.cache/ebuilds" ]]; then
    mkdir -p "$HOME/.cache/ebuilds"
  fi
}

do_bsh_alias() {
  if [ -f "$HOME/.bash_aliases" ]; then
    mv -vb "$HOME/.bash_aliases" "$HOME/.bash_aliases_bak"
    echo
    touch "$HOME/.bash_aliases"
  else
    touch "$HOME/.bash_aliases"
  fi

  cat >"$HOME/.bash_aliases" <<EOF
    # ---------------------
    # Environment variables
    # ---------------------
    # (These variables can be accessed from any shell session.)

    # Compiler and linker flags added by KONFIG.SH.
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=9
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig

    # Keyring service workaround for Enlightenment.
    # You also need to autostart some additional services at startup for this to work:
    # See the repository's wiki (Startup Applications) for more info.
    #
    if printenv | grep -q 'XDG_CURRENT_DESKTOP=Enlightenment'; then
      export SSH_AUTH_SOCK=/run/user/${UID}/keyring/ssh
    fi
EOF

  . "$HOME/.bash_aliases"
}
