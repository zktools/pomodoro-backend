#!/bin/sh

set -eu

. ./run_env.sh

IMAGE_TAG="${APP_NAME}-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"

usage()
{
	echo "The following environment variables can be set to pass additional parameters:"
	echo "    [TARGET_ARCH] override the default target architecture (default: ${TARGET_ARCH_DEF})"
	echo "    [ALPINE_VERSION] override the default Alpine version (default: ${ALPINE_VERSION_DEF})"
}

cleanup() {
	trap EXIT
}

main()
{

	usage

	if  ! docker image inspect "$IMAGE_TAG" > "/dev/null" 2>&1; then
		./run_build.sh
	fi

	echo "==============================================================================="
	echo "Starting application ..."
	echo "==============================================================================="
	echo ""

	docker run \
			-it \
			--rm \
			-v "$(pwd)":"/app" \
			-p 18080:18080 \
			"$IMAGE_TAG" \
			"${@}"


	cleanup
}

main "${@}"

exit 0
