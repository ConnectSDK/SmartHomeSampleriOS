#!/bin/bash

set -o errexit
set -o nounset

AR="xcrun ar"
GREP="grep"
LIPO="xcrun lipo"
NM="nm"
RM="rm"

extract_architectures() {
    $LIPO -info "$1" | sed -nE '/in the fat file/ {s/^.*are: (.+)[[:space:]]+$/\1/; p;}' | tr ' ' '\n'
}

# jump to the script's directory so that it can be run from any location
BASE_DIR="$( dirname $0 )"
pushd "$BASE_DIR" >/dev/null

IN_FAT_LIBRARY="WeMoLocalControl.a"
[[ -e "$IN_FAT_LIBRARY" ]] || {
    echo "File $PWD/$IN_FAT_LIBRARY not found!";
    exit 1;
}

IN_FAT_ARCHS=$( extract_architectures $IN_FAT_LIBRARY )
OBJECT_FILE="ConnectionCheck.o"

[[ -z "$IN_FAT_ARCHS" ]] && {
    echo "File $IN_FAT_LIBRARY is not a fat library!";
    exit 1;
}

if ! $NM "$IN_FAT_LIBRARY" | $GREP --fixed-strings "$OBJECT_FILE" >/dev/null; then
    echo "File $IN_FAT_LIBRARY is already patched!";
    exit 1;
fi

OUT_LIBRARIES=""
for arch in $IN_FAT_ARCHS; do
    # split the fat library into architectures
    OUT_LIBRARY=${IN_FAT_LIBRARY/.a/_${arch}.a}
    $LIPO $IN_FAT_LIBRARY -thin $arch -output $OUT_LIBRARY
    OUT_LIBRARIES="$OUT_LIBRARIES $OUT_LIBRARY"

    # remove the object file from the library
    $AR -d $OUT_LIBRARY $OBJECT_FILE
done

# reassemble the fat library
$LIPO $OUT_LIBRARIES -create -output $IN_FAT_LIBRARY

$RM $OUT_LIBRARIES

echo "File $IN_FAT_LIBRARY has been patched successfully!"
popd >/dev/null
