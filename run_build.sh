#!/bin/sh

set -eu

. ./run_env.sh

usage()
{
	echo "Usage: ${0} [OPTIONS]"
	echo "Build and compile whole project."
	echo "The following environment variables can be set to pass additional parameters:"
	echo "    [TARGET_ARCH] override the default target architecture (default: ${TARGET_ARCH_DEF})"
	echo "    [ALPINE_VERSION] override the default Alpine version (default: ${ALPINE_VERSION_DEF})"
	echo "    [BUILDTYPE] override the default build type.(release, debug. Default: ${BUILDTYPE_DEF})"
	echo "    [BUILDDIR] override the default build directory (default: ${BUILDDIR_DEF})"
	echo "Available options:"
	echo "    -h   Print this help (usage)."
}

cleanup() {
	trap EXIT
}

build() {

	build_image_tag="${APP_NAME}-build-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"
	docker build \
			--target build \
			--build-arg "APP_NAME=${APP_NAME}" \
			--build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
			--build-arg "TARGET_ARCH=${TARGET_ARCH}" \
			--build-arg "BUILDTYPE=${BUILDTYPE}" \
			--build-arg "BUILDDIR=${BUILDDIR}" \
			-t "${build_image_tag}" \
			"./"

	# Only copy build artifacts and subprojects to local development environment
	if [ -z "${CI}" ]; then
		build_container=$(docker run -it -d "${build_image_tag}")
		docker cp "${build_container}:/${APP_NAME}/${BUILDDIR}" ./
		docker cp "${build_container}:/${APP_NAME}/subprojects" ./
		docker rm -f "$build_container" > /dev/null
	fi
}

build_production() {
		docker build \
			--target production \
			--build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
			--build-arg "TARGET_ARCH=${TARGET_ARCH}" \
			--build-arg "BUILDTYPE=${BUILDTYPE}" \
			--build-arg "BUILDDIR=${BUILDDIR}" \
			-t "${APP_NAME}-${TARGET_ARCH}-alpine-${ALPINE_VERSION}" \
			"./"
}

main()
{
	_start_time="$(date "+%s")"

	while getopts ":h" _options; do
		case "${_options}" in
		h)
			usage
			exit 0
			;;
		:)
			echo "Option -${OPTARG} requires an argument."
			exit 1
			;;
		?)
			echo "Invalid option: -${OPTARG}"
			exit 1
			;;
		esac
	done

	build
	build_production

	cleanup

	echo "==============================================================================="
	echo "Ran build and compile processes in $(($(date "+%s") - _start_time)) seconds"
	echo "==============================================================================="
}

main "${@}"

exit 0
