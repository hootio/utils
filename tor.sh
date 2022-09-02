#!/usr/bin/env bash
set -eo pipefail

help()
{
    echo \
"
Usage: tor.sh
    [ interface ]   {'Wi-Fi'|'Ethernet'|'Display Ethernet'}
    [ --help ]      Prints this message
"
}

interface=""

# Check script is run on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script can only run on macOS"
    exit 1
fi

if [[ "$#" -gt 1 ]]; then
    help
    exit 1
fi

case "$1" in
"Wi-Fi")
    interface=Wi-Fi
    ;;
"Ethernet")
    interface=Ethernet
    ;;
"Display Ethernet")
    interface="Display Ethernet"
    ;;
--help)
    help
    exit 0
    ;;
*)
    echo "Using default interface=Wi-Fi"
    interface=Wi-Fi
esac

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# trap ctrl-c and call disable_proxy()
disable_proxy() {
    sudo networksetup -setsocksfirewallproxystate $interface off
    echo "$(tput setaf 1)" # red
    echo "SOCKS proxy disabled."
    echo "$(tput sgr0)" # color reset
}
trap disable_proxy INT

# Let's roll
sudo networksetup -setsocksfirewallproxy $interface 127.0.0.1 9050 off
sudo networksetup -setsocksfirewallproxystate $interface on

echo "$(tput setaf 64)" # green
echo "SOCKS proxy 127.0.0.1:9050 enabled."
echo "$(tput setaf 136)" # orange
echo "Starting Tor..."
echo "Visit https://check.torproject.org/ to confirm you've connected to Tor"
echo "$(tput sgr0)" # color reset

tor
