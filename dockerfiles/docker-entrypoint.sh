#!/bin/sh
set -e

if [ "$1" = 'c_cpp_project_template' ]; then
   c_cpp_project_template "$@"
else
    exec "$@"
fi
