#!/bin/sh

set -eu

. ./run_env.sh

IMAGE_TAG="${APP_NAME}-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"

usage()
{
	echo "Usage: ${0} [OPTIONS]"
	echo "Run the project."
	echo "The following environment variables can be set to pass additional parameters:"
	echo "    [TARGET_ARCH] override the default target architecture (default: ${TARGET_ARCH_DEF})"
	echo "    [ALPINE_VERSION] override the default Alpine version (default: ${ALPINE_VERSION_DEF})"
	echo "Available options:"
	echo "    -h   Print this help (usage)."
}

cleanup() {
	trap EXIT
}

main()
{
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

	if  ! docker image inspect "$IMAGE_TAG" > "/dev/null" 2>&1; then
		./run_build.sh
	fi

	docker run \
			-it \
			--rm \
			-p 18080:18080 \
			"$IMAGE_TAG" \
			"${@}"

	cleanup
}

main "${@}"

exit 0
