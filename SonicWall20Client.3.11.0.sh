#!/bin/sh

# SonicWall Capture Client for Linux Installer
# Copyright (c) 2025 SonicWall

S1_TOKEN=eyJ1cmwiOiAiaHR0cHM6Ly9zb25pY3dhbGwtbWRyLnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICIzYWY0ZjRmYzA1N2FiNmUyIn0=
DOWNLOAD_URL=https://software.sonicwall.com/CaptureClient/SentinelOne/SentinelOne_linux_v25_1_3_6
PACKAGE_TYPE=sh
VERSION=3.11.0
RELEASE_GUID=ad317fec-7114-4209-87e0-964aba4b7ef1


echo "SonicWall Capture Client for Linux Installer"
echo "Version ${VERSION}"
echo "Copyright (c) 2025 SonicWall"

show_help () {
  echo "Usage:" $0 "[-hp]"
  echo "  -h  Show this help message"
  echo "  -p  Set package type. Accepted values: rpm, deb"
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [ "${machine}" = "Mac" ]; then
  echo ""
  echo "This installer does not support macOS! Use the SonicWall Capture Client for macOS (.pkg) installer instead."
  exit 0
fi

if [ "${machine}" = "Cygwin" ]; then
  echo ""
  echo "This installer does not support Windows! Use the SonicWall Capture Client for Windows (.msi) installer instead."
  exit 0
fi

if [ "${machine}" = "MinGw" ]; then
  echo ""
  echo "This installer does not support Windows! Use the SonicWall Capture Client for Windows (.msi) installer instead."
  exit 0
fi

if [ -f /etc/debian_version ]
then
  PACKAGE_TYPE=deb
elif command -v dpkg > /dev/null
then
  PACKAGE_TYPE=deb
elif command -v rpm > /dev/null
then
  PACKAGE_TYPE=rpm
else
  echo "Package type could not be detected. Specified the package type (deb/rpm) with -p"
  exit 1
fi

while getopts "h?p:" opt; do
  case "$opt" in
    h|?)
        show_help
        exit 0
        ;;
    p)  PACKAGE_TYPE=$OPTARG
        ;;
  esac
done

echo "Package type:" ${PACKAGE_TYPE}
echo "Downloading SentinelOne agent ..."
wget -q ${DOWNLOAD_URL}.${PACKAGE_TYPE} -O /tmp/SonicWall.Capture.Client.${VERSION}.${RELEASE_GUID}.${PACKAGE_TYPE}
ret=$?
if [  $ret -ne "0" ]
then
  echo "Package download failed! Exiting ..."
  exit 1
fi

echo "Installing SentinelOne agent ..."
if [ $PACKAGE_TYPE = "deb" ]
then
  sudo dpkg -i /tmp/SonicWall.Capture.Client.${VERSION}.${RELEASE_GUID}.${PACKAGE_TYPE}
  ret=$?
elif [ $PACKAGE_TYPE = "rpm" ]
then
  sudo rpm -i --nodigest /tmp/SonicWall.Capture.Client.${VERSION}.${RELEASE_GUID}.${PACKAGE_TYPE}
  ret=$?
else
  echo "Package type not supported! Exiting ..."
  exit 1
fi

if [  $ret -ne "0" ]
then
  echo "Installation failed! Exiting ..."
  exit 1
fi

echo "Registering SentinelOne agent ..."
sudo /opt/sentinelone/bin/sentinelctl management token set ${S1_TOKEN}
ret=$?
if [  $ret -ne "0" ]
then
  echo "Registration failed! Exiting ..."
  exit 1
fi

echo "Activating agent ..."

sudo /opt/sentinelone/bin/sentinelctl control start

ret=$?
if [  $ret -ne "0" ]
then
  echo "Activation failed! Exiting ..."
  exit 1
else
  echo "Activation complete. Your device is now protected!"
fi