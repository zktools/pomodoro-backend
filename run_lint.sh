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
	echo "Available options:"
	echo "    -h   Print this help (usage)."
	echo "    -c   Format all project's source files."
	echo "    -f   Run clang-format on project's source files."
	echo "    -s   Run lint in shell scripts."
	echo "    -t   Run clang-tidy on project's source files."
	echo "    -d   Run hadolint check on Dockerfile"
}

cleanup() {
	trap EXIT
}

hadolint_check() {
	echo "Runnig hadolint check on Dockerfile ..."
	docker run --rm -i hadolint/hadolint < "Dockerfile"
	echo "Done!"
}

shell_check ()
{
	echo "Running shellcheck on project's *.sh files..."
	
	shell_lint_error=false
	tmp_dir=$(mktemp -d -p .)
	find ./ -type f -iname "*.sh" -print0 | xargs -0 cp -r -t "${tmp_dir}"
	shell_linter_image_tag="${horus-shell-linter}"
	
	docker build \
			--target shell_linter \
			-q \
			--build-arg "SHELL_SCRIPTS=${tmp_dir}" \
			-t "${shell_linter_image_tag}" \
			"./" > /dev/null
	
	rm -rf "${tmp_dir}" > /dev/null

	if ! docker run \
			--rm \
			"${shell_linter_image_tag}" \
			sh -c 'shellcheck --color=always --format=tty --shell=sh *.sh'; then
			shell_lint_error=true
	fi

	docker rmi "${shell_linter_image_tag}" > /dev/null

	echo "Done!"
	
	if [ "$shell_lint_error" = true ]; then
		exit 1
	fi
}


clang_format_check()
{
	echo "Checking if source code files are correctly formated..."
	docker run \
			--rm \
			"$IMAGE_TAG" \
			sh -c "clang-format --dry-run --Werror $SRC_FILES"
	
	echo "Source code files are correctly formated."
}

clang_format_apply()
{
	echo "Applying clang-format to project's source files..."

	docker run \
			--rm \
			"$IMAGE_TAG" \
			sh -c "clang-format style=file -i -fallback-style=none $SRC_FILES"

	echo "Project's source files formated."

}

clang_tidy_check()
{
	echo "Running clang-tidy on project's source files..."

	docker run \
			--rm \
			"$IMAGE_TAG" \
			sh -c "clang-tidy -header-filter=.* -p $BUILDDIR $SRC_FILES"

	echo "Project's source checked."

}


main()
{
	while getopts ":hcfstd" _options; do
		case "${_options}" in
		h)
			usage
			exit 0
			;;
		c)
			clang_format_apply
			exit 0
			;;
		f)
			clang_format_check
			exit 0
			;;
		s)
			shell_check
			exit 0
			;;
		t)
			clang_tidy_check
			exit 0
			;;
		d)
			hadolint_check
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
		 *)
		 	echo "Invalid option: -${OPTARG}"
			exit 1
			;;
		esac
	done
	shift "$((OPTIND - 1))"

	cleanup

}

main "${@}"

exit 0
