#!/bin/bash

# red = errors, cyan = warnings, green = confirmations, blue = informational
# plain for generic text, bold for titles, reset flag at each end of line
# plain blue should not be used for readability reasons - use plain cyan instead
CLR_RST=$(tput sgr0)                        ## reset flag
CLR_RED=$CLR_RST$(tput setaf 1)             #  red, plain
CLR_GRN=$CLR_RST$(tput setaf 2)             #  green, plain
CLR_BLU=$CLR_RST$(tput setaf 4)             #  blue, plain
CLR_CYA=$CLR_RST$(tput setaf 6)             #  cyan, plain
CLR_BLD=$(tput bold)                        ## bold flag
CLR_BLD_RED=$CLR_RST$CLR_BLD$(tput setaf 1) #  red, bold
CLR_BLD_GRN=$CLR_RST$CLR_BLD$(tput setaf 2) #  green, bold
CLR_BLD_BLU=$CLR_RST$CLR_BLD$(tput setaf 4) #  blue, bold
CLR_BLD_CYA=$CLR_RST$CLR_BLD$(tput setaf 6) #  cyan, bold

#  keygen
function keygen() {
    local certs_dir=~/.android-certs
    [ -z "$1" ] || certs_dir=$1
    rm -rf "$certs_dir"
    mkdir -p "$certs_dir"
    local subject
    echo "Sample subject: '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'"
    echo "Now enter subject details for your keys:"
    for entry in C ST L O OU CN emailAddress; do
        echo -n "$entry:"
        read -r val
        subject+="/$entry=$val"
    done
    for key in certs releasekey platform shared media networkstack testkey; do
        ./development/tools/make_key "$certs_dir"/$key "$subject"
    done
}

# generate executables
function cmd() {
m sign_target_files_apks && m ota_from_target_files
}

# sign the target files
function sign() {
croot
sign_target_files_apks -o -d ~/.android-certs \
    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
    signed-target_files.zip
}

# zip it up!
function zip() {
ota_from_target_files -k ~/.android-certs/releasekey \
    signed-target_files.zip \
    signed-ota_update.zip

}

# ok done
  read -rp "Would you like to generate target files [y|n]:" choice

  case ${choice} in
  Y | y) make target-files-package otatools  && echo "generating target files only" ;;
  N | n) echo "Ok, if you don't want ur wish :P";;
  esac
echo ""
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo ""
  read -rp "Would you like to generate keys [y|n]:" choice

  case ${choice} in
  Y | y) keygen  && echo "ok, generating keys" ;;
  N | n) echo "Ok, if you don't want ur wish :P";;
  esac

echo ""
  read -rp "Would you like to generate signing commands [y|n]:" choice

  case ${choice} in
  Y | y) cmd  && echo "ok, generating signing commads" ;;
  N | n) echo "Ok, if you don't want ur wish :P";;
  esac

echo ""
sign
echo ""
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo "                        build signing done"
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo ""
echo ""
zip
echo ""
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo "                        now flash this shit"
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo ""
echo "Although you may choose whatever zip name you want, for the sake of simplicity I've used **signed-ota_update.zip**"
echo "×××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××"
echo ""
echo ""
echo "                FOR FURTHER INFORMATION HEAD OVER TO"
echo "      https://source.android.com/devices/tech/ota/sign_builds"
echo "                               or                             "
echo "             https://wiki.lineageos.org/signing_builds"
