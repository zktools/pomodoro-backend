gtest_main = dependency('gtest_main', main : true,  method: 'pkg-config', fallback : ['gtest', 'gtest_main_dep'], required : true)

test_example = \
    executable(
        'test_example',
        sources: ['test_example.cpp', src_files],
        dependencies: [ gtest_main],
        include_directories : [include_dirs ]
    )

test('test_example', test_example, suite: 'unit_tests')
