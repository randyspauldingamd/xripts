#!/bin/bash
# ci version of cmake and make commands

CORES=$(expr $(nproc) / 2 - 4)
if [ $# -gt 1 ] ; then
  CORES=$1
fi
echo "$CORES"

exit 1
CXX=/opt/rocm/llvm/bin/clang++ CXXFLAGS='-Werror'  cmake -DMIOPEN_TEST_FLAGS=' --disable-verification-cache ' -DCMAKE_BUILD_TYPE=release -DBUILD_DEV=Off -DMIOPEN_TEST_DISCRETE=OFF  -DMIOPEN_USE_MLIR=ON -DMIOPEN_GPU_SYNC=Off  -DCMAKE_PREFIX_PATH=/opt/rocm    ..

LLVM_PATH=/opt/rocm/llvm CTEST_PARALLEL_LEVEL=4 MIOPEN_CONV_PRECISE_ROCBLAS_TIMING=0  dumb-init make -j$CORES miopen_gtest package


