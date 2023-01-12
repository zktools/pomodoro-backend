project(
    'pomodoro-backend',
    'cpp',
    version : '0.1.0',
    default_options: ['warning_level=3', 'werror=true', 'cpp_std=c++17', 'optimization=g'],
)


project_flags = [ ]

# Crow project specific flags
# TODO : Find a way to only disable flag below for the CROW project
project_flags += [
    '-Wno-non-virtual-dtor',
    '-Wno-address',
]

cxx = meson.get_compiler('cpp')

add_project_arguments(cxx.get_supported_arguments(project_flags), language : 'cpp')

# project include files are stored in separate folder structure
subdir('include')

# source files go here
subdir('src')

# test files go here
subdir('tests')
