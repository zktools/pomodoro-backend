project(
    'pomodoro-backend',
    'cpp',
    version : '0.1.0',
    default_options: ['warning_level=3', 'werror=true', 'cpp_std=c++17', 'optimization=g'],
)


project_flags = [ ]

# project specific flags
project_flags += [
    # Crow expose virtual destructors
    '-Wno-non-virtual-dtor',
]

cxx = meson.get_compiler('cpp')

add_project_arguments(cxx.get_supported_arguments(project_flags), language : 'cpp')

# project include files are stored in separate folder structure
subdir('include')

# source files go here
subdir('src')

# test files go here
subdir('tests')
