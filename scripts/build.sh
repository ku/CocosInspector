#!/bin/sh

# https://github.com/jverkoey/iOS-Framework/blob/master/scripts/build_framework.sh
BUILDCONFIGURATION=Release
while getopts ":nc:" OPTNAME
do
  case "$OPTNAME" in
    "c")
      BUILDCONFIGURATION=$OPTARG
      ;;
    "n")
      NOEXTRAS=1
      ;;
    "?")
      echo "$0 -c [Debug|Release] -n"
      echo "       -c sets configuration"
      echo "       -n no test run"
      die
      ;;
    ":")
      echo "Missing argument value for option $OPTARG"
      die
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options"
      die
      ;;
  esac
done

# http://www.blackjaguarstudios.com/blog/programming/2012/11/22/xcode-45-creating-ios-framework-and-hold-my-hand-im-3-years-old
# Sets the target folders and the final framework product.
FMK_NAME=CocosInspector
FMK_VERSION=A

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
if [ -z "$SRCROOT" ]; then
    SRCROOT=`dirname $0`/..
fi

INSTALL_DIR=${SRCROOT}/bin/${FMK_NAME}.framework

# Cleaning the oldest.
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi

# Working dir will be deleted after the framework creation.
WRK_DIR=$SRCROOT/build

DEVICE_DIR="${WRK_DIR}/$BUILDCONFIGURATION-iphoneos/${FMK_NAME}.framework"
SIMULATOR_DIR="${WRK_DIR}/$BUILDCONFIGURATION-iphonesimulator/${FMK_NAME}.framework"


# Building both architectures.
xcodebuild -configuration "$BUILDCONFIGURATION" -target "${FMK_NAME}" -sdk iphoneos          #clean build
xcodebuild -configuration "$BUILDCONFIGURATION" -target "${FMK_NAME}" -sdk iphonesimulator   #clean build

# Creates and renews the final product folder.
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/Versions"
mkdir -p "${INSTALL_DIR}/Versions/${FMK_VERSION}"
mkdir -p "${INSTALL_DIR}/Versions/${FMK_VERSION}/Resources"
mkdir -p "${INSTALL_DIR}/Versions/${FMK_VERSION}/Headers"

# Creates the internal links.
# It MUST uses relative path, otherwise will not work when the folder is copied/moved.
ln -s "${FMK_VERSION}" "${INSTALL_DIR}/Versions/Current"
ln -s "Versions/Current/Headers" "${INSTALL_DIR}/Headers"
ln -s "Versions/Current/Resources" "${INSTALL_DIR}/Resources"
ln -s "Versions/Current/${FMK_NAME}" "${INSTALL_DIR}/${FMK_NAME}"

# Copies the headers and resources files to the final product folder.
cp -R "${DEVICE_DIR}/Headers/" "${INSTALL_DIR}/Versions/${FMK_VERSION}/Headers/"
cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/Versions/${FMK_VERSION}/Resources/"

# Removes the binary and header from the resources folder.
rm -r "${INSTALL_DIR}/Versions/${FMK_VERSION}/Resources/Headers" "${INSTALL_DIR}/Versions/${FMK_VERSION}/Resources/${FMK_NAME}"

# Uses the Lipo Tool to merge both binary files (i386 + armv6/armv7) into one Universal final product.
lipo -create "${DEVICE_DIR}/${FMK_NAME}" "${SIMULATOR_DIR}/${FMK_NAME}" -output "${INSTALL_DIR}/Versions/${FMK_VERSION}/${FMK_NAME}"

