ARG APP_NAME="pomodoro-backend"
ARG ALPINE_VERSION="3.16"
ARG TARGET_ARCH="amd64"
ARG BUILDTYPE="debug"
ARG BUILDDIR=".build-${TARGET_ARCH}-alpine-${ALPINE_VERSION}"

FROM koalaman/shellcheck-alpine:stable as shell_linter
ARG APP_NAME
WORKDIR /"${APP_NAME}"
ARG SHELL_SCRIPTS
COPY "${SHELL_SCRIPTS}" ./

FROM index.docker.io/${TARGET_ARCH}/alpine:${ALPINE_VERSION} AS runtime-dependencies
# hadolint ignore=DL3018
RUN \
    apk add --no-cache \
        libstdc++

FROM runtime-dependencies AS builder
ARG APP_NAME
WORKDIR /${APP_NAME}
# hadolint ignore=DL3018
RUN \
    apk add --no-cache \
        boost-dev \
        clang-extra-tools \
        g++ \
        git \
        gtest \
        gtest-dev \
        meson \
        valgrind

FROM builder AS build
ARG BUILDDIR
ARG BUILDTYPE
COPY meson.build .
COPY subprojects/ subprojects/
COPY tests/ tests/
COPY include/ include/
COPY src/ src/
RUN \
    meson setup --buildtype "${BUILDTYPE}" "${BUILDDIR}" \
    && meson compile -C "${BUILDDIR}"
COPY .clang-tidy ./
COPY .clang-format ./

FROM runtime-dependencies AS production
ARG APP_NAME
ARG BUILDDIR
EXPOSE 18080
COPY --from=build /${APP_NAME}/${BUILDDIR}/src/pomodoro-backend /usr/bin/
COPY ./dockerfiles/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["pomodoro-backend"]
