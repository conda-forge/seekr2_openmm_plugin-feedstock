#!/bin/bash

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DSEEKR2_BUILD_OPENCL_LIB=OFF -DOPENMM_DIR=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX}"

if [[ "$target_platform" == linux* ]]; then
    # CFLAGS
    # JRG: Had to add -ldl to prevent linking errors (dlopen, etc)
    MINIMAL_CFLAGS+=" -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    #LDFLAGS+=" $LDPATHFLAGS"

    # Use GCC
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

    if [[ "$target_platform" == linux-64 || "$target_platform" == linux-ppc64le ]]; then
        # CUDA_HOME is defined by nvcc metapackage
        CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME:-$PREFIX}"
        
        # From: https://github.com/floydhub/dl-docker/issues/59
        #CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
        #CMAKE_FLAGS+=" -DCUDA_CUDA_LIBRARY=${CUDA_HOME}/lib64/stubs/libcuda.so"
        #CMAKE_FLAGS+=" -DSEEKR2_CUDA_BUILD_TESTS=OFF"
        CMAKE_FLAGS+=" -DSEEKR2_CUDA_BUILD_TESTS=OFF"
        
        # shadow some CMAKE_FLAGS bits that interfere with CUDA detection
        CMAKE_FLAGS+=" -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH"
    fi
    
    # Cuda tests won't build. Disable all tests for now
    
    CMAKE_FLAGS+=" -DSEEKR2_REFERENCE_BUILD_TESTS=OFF"
    CMAKE_FLAGS+=" -DSEEKR2_BUILD_SERIALIZATION_TESTS=OFF"
fi

mkdir build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}/seekr2plugin
make -j $CPU_COUNT
make install PythonInstall

for lib in ${PREFIX}/lib/plugins/*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done
