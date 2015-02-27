#!/bin/bash

LIPO="xcrun lipo"
AR="xcrun ar"
RM="rm"

extract_architectures() {
    $LIPO -info "$1" | sed -nE '/in the fat file/ {s/^.*are: (.+)[[:space:]]+$/\1/; p;}' | tr ' ' '\n'
}

IN_FAT_LIBRARY="WeMoLocalControl.a"
IN_FAT_ARCHS=$( extract_architectures $IN_FAT_LIBRARY )
OBJECT_FILE="ConnectionCheck.o"

[[ -z "$IN_FAT_ARCHS" ]] && {
    echo "File $IN_FAT_LIBRARY is not a fat library";
    exit 1;
}
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

