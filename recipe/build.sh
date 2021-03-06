#!/bin/bash

CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DSEEKR2_BUILD_OPENCL_LIB=OFF -DOPENMM_DIR=$PREFIX"

if [[ "$target_platform" == linux* ]]; then
    # CFLAGS
    # JRG: Had to add -ldl to prevent linking errors (dlopen, etc)
    MINIMAL_CFLAGS+=" -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    LDFLAGS+=" $LDPATHFLAGS"

    # Use GCC
    CMAKE_ARGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

    # CUDA_HOME is defined by nvcc metapackage
    CMAKE_ARGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    # From: https://github.com/floydhub/dl-docker/issues/59
    CMAKE_ARGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    CMAKE_ARGS+=" -DCUDA_CUDA_LIBRARY=${CUDA_HOME}/lib64/stubs/libcuda.so"
    
    # Cuda tests won't build. Disable all tests for now
    CMAKE_ARGS+=" -DSEEKR2_CUDA_BUILD_TESTS=OFF"
    CMAKE_ARGS+=" -DSEEKR2_REFERENCE_BUILD_TESTS=OFF"
    CMAKE_ARGS+=" -DSEEKR2_BUILD_SERIALIZATION_TESTS=OFF"
fi

mkdir build
cd build
cmake ${CMAKE_ARGS} ${SRC_DIR}/seekr2plugin
make -j $CPU_COUNT
make install PythonInstall

for lib in ${PREFIX}/lib/plugins/*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done
