#!/bin/sh
set -eu
trap 'echo "EXIT detected with exit status $?"' EXIT

check_command() {
    if ! command -v ${1} >/dev/null 2>&1; then
        echo "This script requires ${1}"
        exit 1
    fi
}

# Requires curl, 7z, unzip and fontforge
check_command 7z
check_command curl
check_command unzip
check_command fontforge

# OS temp dir & script working dir
TEMPDIR=$(mktemp -u)
BASEDIR=$(cd "$(dirname "$0")" ; pwd -P)

# Reset build dir
mkdir -p ${BASEDIR}/build

echo "Using ${TEMPDIR}"
mkdir -p ${TEMPDIR}
cd ${TEMPDIR}

# Download and extract nerd-fonts-patcher
curl --silent -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip"
unzip -qq FontPatcher.zip

# Download and extract SFMono
curl --silent -LO "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg"
7z x "SF-Mono.dmg" >/dev/null
7z x "SFMonoFonts/SF Mono Fonts.pkg" >/dev/null
7z x "Payload~" >/dev/null

# Build the fonts
for font in Library/Fonts/*; do
    echo "Patching ${font}"
    if [ -n ${1+x} ] && [ ${1:-} = "mono" ]; then
        ./font-patcher --complete --use-single-width-glyphs ${font}
    else
        ./font-patcher --complete ${font}
    fi
done

# Copy the fonts to build dir
chmod a-x *.otf
cp -f *.otf ${BASEDIR}/build

# Cleanup
rm -rf ${TEMPDIR}
echo "\nDone."
