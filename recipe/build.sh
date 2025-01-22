#!/bin/bash
# This build script is based on the build script from the scipy feedstock. (Thank you!)
# https://github.com/conda-forge/scipy-feedstock/blob/main/recipe/build.sh
set -ex

export BUILD_DIR=build
mkdir $BUILD_DIR

# HACK: extend $CONDA_PREFIX/meson_cross_file that's created in
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/blob/main/recipe/activate-gcc.sh
# https://github.com/conda-forge/clang-compiler-activation-feedstock/blob/main/recipe/activate-clang.sh
# to use host python; requires that [binaries] section is last in meson_cross_file
echo "python = '${PREFIX}/bin/python'" >> ${CONDA_PREFIX}/meson_cross_file.txt

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x \
    -Cbuilddir=$BUILD_DIR \
    -Cinstall-args=--tags=runtime,python-runtime,devel \
    -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
    || (cat $BUILD_DIR/meson-logs/meson-log.txt && exit 1)

$PYTHON -m pip install dist/*.whl -vvv
