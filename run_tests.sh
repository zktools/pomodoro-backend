#!/bin/sh

set -eu

. ./run_env.sh

IMAGE_TAG="${APP_NAME}-build-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"

usage()
{
	echo "Usage: ${0} [OPTIONS]"
	echo "Run project tests."
	echo "The following environment variables can be set to pass additional parameters:"
	echo "    [TARGET_ARCH] override the default target architecture (default: ${TARGET_ARCH_DEF})"
    echo "    [ALPINE_VERSION] override the default Alpine version (default: ${ALPINE_VERSION_DEF})"
    echo "    [USE_VALGRIND] run tests under valgring wrapper."
	echo "        Enable it to detect possible memory leaks. ( true or false, default: true)"
	echo "Available options:"
	echo "    -h   Print this help (usage)."
	echo "    -t <test_name>  Run test specified by <test_name>. (default: run all tests)"
}

cleanup() {
	trap EXIT
}

run_tests() {

	if  ! docker image inspect "$IMAGE_TAG" > "/dev/null" 2>&1; then
		./run_build.sh
	fi

	# use "USE_VALGRIND=false ./run_tests.sh"
	USE_VALGRIND="${USE_VALGRIND:-true}"
	if [ "${USE_VALGRIND}" = true ]; then
		VALGRIND_WRAPPER="
			valgrind
				--leak-check=full
				--show-leak-kinds=all
				--errors-for-leak-kinds=all
				--keep-stacktraces=alloc-and-free
				--read-var-info=yes
				--track-origins=yes
				--errors-for-leak-kinds=definite,possible
				--leak-resolution=high
				--num-callers=40
				--expensive-definedness-checks=yes
				--show-mismatched-frees=yes
				--xtree-memory=full
				--xtree-leak=yes
				--xtree-leak-file=xtleak.kcg.%p
				--error-exitcode=1
			"
	fi

	docker run \
			--rm \
			"$IMAGE_TAG" \
			sh -c "meson \
						test \
						-v \
						--wrap='${VALGRIND_WRAPPER:-}' \
						-C ./${BUILDDIR} ${TEST_NAME:-}"
}

main()
{
	while getopts ":ht:" _options; do
		case "${_options}" in
		h)
			usage
			exit 0
			;;
		t)
			TEST_NAME="${OPTARG:-}"
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

	run_tests

	cleanup
}

main "${@}"

exit 0
