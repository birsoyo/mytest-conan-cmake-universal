This is a test console application using conan and cmake creating a universal app for macOS.

In order to generate the ninja and xcode builds:
1. Need cmake >= 3.21 due to cmake-presets usage.
1. Need ninja
1. Need Xcode (I used 13.2.1)
1. run `./init.sh`. This will
    - delete the `builds` folder
    - generate conan files using `CMakeDeps` generator in `mytest-conan` folder
    - modify some of the conan generated files to make universal apps possible
    - generate Ninja and Xcode build _scripts_ for the main app.
2. Try opening Xcode project in builds/mytest-xcode
3. Try building debug ninja build in builds/mytest-debug-ninja-clang
4. Try building release ninja build in builds/mytest-release-ninja-clang


The main issue is conan doesn't generate usable cmake files so that we can just create an universal app using cmake xcode or cmake ninja generators.

The `CMakeDeps` generator comes really close but it still requires modifications to be usable.

For example:

The conan generated files (in mytest-conan folder), uses the same named variables between arches (like `fmt_PACKAGE_FOLDER_DEBUG` in `fmt-debug-armv8-data.cmake` and in `fmt-debug-x86_64.cmake`).

There are more comments in the `init.sh`.
