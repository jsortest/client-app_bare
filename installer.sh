#!/bin/bash

command -v dotnet >/dev/null 2>&1 || { echo >&2 ".NET Core is not installed.  Aborting."; exit 1; }

command -v /usr/bin/dotnet >/dev/null 2>&1 || { echo >&2 "dotnet command must be located in path /usr/bin/. Please make a link for /usr/bin/dotnet. Aborting."; exit 1; }

command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is not installed.  Aborting."; exit 1; }

DIR=$(dirname "${1}")
TGT_DIR=/sorcerer/

if pidof systemd
then
systemctl stop sorcerer
else
service stop sorcerer
fi

#kill  $(ps aux | grep 'SorcererClient.dll' | awk '{print $2}')

mkdir -p "${TGT_DIR}"
unzip -o -u $1 -d "${TGT_DIR}"

# other lib for centos/redhat
if [ -f /etc/redhat-release ]; then
cp "${DIR}/centos-libgit2-15e1193.so" "${TGT_DIR}publish/lib/linux/x86_64/libgit2-15e1193.so"
fi

cp "${TGT_DIR}publish/lib/linux/x86_64/libgit2-15e1193.so" "${TGT_DIR}publish"


CFG_FILE="${TGT_DIR}publish/config.txt"
if [ ! -f "${CFG_FILE}" ]; then
  CLIENT_ID="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  siteId=$(cat "site.txt")
  echo id=$CLIENT_ID$siteId > "${CFG_FILE}" 

  echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  echo !!! Client ID is $CLIENT_ID$siteId !!!
  echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
fi

# install on systemd
if pidof systemd
then
  cp "${DIR}/sorcerer.service" /etc/systemd/system/
  
  systemctl enable sorcerer
  systemctl --no-block restart sorcerer
else
  # install for init.d
  cp "${DIR}/sorcerer" /etc/init.d/
  chmod +x /etc/init.d/sorcerer

  update-rc.d sorcerer defaults
  service restart sorcerer
fi





