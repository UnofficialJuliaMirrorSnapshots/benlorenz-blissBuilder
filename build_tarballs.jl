# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "bliss"
version = v"0.73"

# Collection of sources required to build bliss 
sources = [
    "http://www.tcs.hut.fi/Software/bliss/bliss-0.73.zip" =>
    "f57bf32804140cad58b1240b804e0dbd68f7e6bf67eba8e0c0fa3a62fd7f0f84",
]

# Bash recipe for building across all platforms
script = raw"""
cd bliss-0.73
sed -i -e 's/^namespace bliss/#define BLISS_USE_GMP\n\nnamespace bliss/' defs.hh
make -j lib_gmp CFLAGS="-I$prefix/include -O3 -fPIC -I." LDFLAGS="$LDFLAGS -L$prefix/lib" CC="$CXX"
$CXX -shared -o libbliss.$dlext *.og $LDFLAGS -L$prefix/lib -lgmp
mkdir -p $prefix/include/bliss
mkdir -p $prefix/lib
install -p -m 0644 -t $prefix/include/bliss *.hh
install -p libbliss.$dlext $prefix/lib
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# no sys/times.h on windows
platforms = filter(x->!isa(x,Windows),supported_platforms())


# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libbliss", :libbliss)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
