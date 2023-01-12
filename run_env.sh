#!/bin/sh

set -eu

APP_NAME="${CI_PROJECT_NAME:-$(basename "$PWD")}"
export APP_NAME

ALPINE_VERSION_DEF="3.17"
ALPINE_VERSION=${ALPINE_VERSION:-$ALPINE_VERSION_DEF}

TARGET_ARCH_DEF="amd64"
TARGET_ARCH=${TARGET_ARCH:-$TARGET_ARCH_DEF}

BUILDTYPE_DEF="debug"
BUILDTYPE=${BUILDTYPE:-$BUILDTYPE_DEF}

BUILDDIR_DEF=".build-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"
BUILDDIR=${BUILDDIR:-$BUILDDIR_DEF}

SRCDIR_DEF="src"
SRCDIR=${SRCDIR:-$SRCDIR_DEF}

# All source files of the project that lints run against
SRC_FILES="$(
			find \
				./src/ \
				-iname '*.h' -print \
				-o -iname '*.c' -print \
				-o -iname '*.cpp' -print \
				-o -iname '*.hpp' -print
		)"

export SRC_FILES

# this variable is set during CI pipeline execution
CI=${CI:-}
