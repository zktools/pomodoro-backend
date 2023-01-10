project('crow',
    'cpp',
    version : '3.0.0',
    license : 'MIT'
)

install_subdir('include', install_dir : '/usr/include/crow', strip_directory : true)

pkgc = import('pkgconfig')
pkgc.generate(name: 'crow',
    version: meson.project_version(),
    description: 'Crow is a C++ framework for creating HTTP or Websocket web services'
)

crow_dep = declare_dependency(
    include_directories : include_directories('include')
)
