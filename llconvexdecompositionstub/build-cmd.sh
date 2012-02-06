#!/bin/sh

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

top="$(pwd)"
pushd "Source"
    case "$AUTOBUILD_PLATFORM" in
        "windows")
			load_vsvars

            build_sln "LLConvexDecomposition.sln" "Debug|Win32"
            build_sln "LLConvexDecomposition.sln" "Release|Win32"
            mkdir -p ../stage/lib/{debug,release}
            cp "lib/debug/LLConvexDecompositionStub.lib" \
                "../stage/lib/debug/LLConvexDecompositionStub.lib"
            cp "lib/debug/LLConvexDecompositionStub.pdb" \
                "../stage/lib/debug/LLConvexDecompositionStub.pdb"
            cp "lib/release/LLConvexDecompositionStub.lib" \
                "../stage/lib/release/LLConvexDecompositionStub.lib"
        ;;
        "darwin")
			libdir="$top/stage/lib"
            mkdir -p "$libdir"/{debug,release}
			make -C lib -f Makefile_mac clean
			make -C lib -f Makefile_mac 
			cp "lib/debug_stub/libllconvexdecompositionstub.a" \
				"$libdir/debug/libllconvexdecompositionstub.a"
			cp "lib/release_stub/libllconvexdecompositionstub.a" \
				"$libdir/release/libllconvexdecompositionstub.a"
		;;
        "linux")
			libdir="$top/stage/lib"
            mkdir -p "$libdir"/{debug,release}
			make -C lib clean
			make -C lib
			cp "lib/debug_stub/libllconvexdecompositionstub.a" \
				"$libdir/debug/libllconvexdecompositionstub.a"
			cp "lib/release_stub/libllconvexdecompositionstub.a" \
				"$libdir/release/libllconvexdecompositionstub.a"
        ;;
    esac
    mkdir -p "../stage/include"
    cp "lib/LLConvexDecomposition.h" "../stage/include/llconvexdecomposition.h"
    mkdir -p ../stage/LICENSES
    cp LICENSE_STUB.txt ../stage/LICENSES/LLConvexDecompositionStubLicense.txt
popd

pass

