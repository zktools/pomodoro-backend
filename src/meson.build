executable_name = meson.project_name()

cxxopts_dep = dependency('', fallback : ['cxxopts', 'cxxopts_dep'], required: true)
crow_dep = dependency('crow', fallback : ['crow', 'crow_dep'], required: true)

dependencies = [cxxopts_dep, crow_dep]

src_files = []

executable(executable_name,
    sources:[ 'App.cpp', src_files],
    include_directories : [include_dirs],
    dependencies: dependencies,
    install: true)
