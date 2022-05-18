rm -rf ./builds
mkdir -p ./builds/mytest-conan
pushd ./builds/mytest-conan
conan install -g CMakeDeps -pr:b default -pr:h ../../mytest.profile -s:h build_type=Debug -s:h arch=armv8 ../..
conan install -g CMakeDeps -pr:b default -pr:h ../../mytest.profile -s:h build_type=Debug -s:h arch=x86_64 ../..
conan install -g CMakeDeps -pr:b default -pr:h ../../mytest.profile -s:h build_type=Release -s:h arch=armv8 ../..
conan install -g CMakeDeps -pr:b default -pr:h ../../mytest.profile -s:h build_type=Release -s:h arch=x86_64 ../..

sed -i '' 's/_RELEASE/_RELEASE_X86_64/g' fmt-release-x86_64-data.cmake
sed -i '' 's/_RELEASE/_RELEASE_ARMV8/g' fmt-release-armv8-data.cmake
sed -i '' 's/_DEBUG/_DEBUG_X86_64/g' fmt-debug-x86_64-data.cmake
sed -i '' 's/_DEBUG/_DEBUG_ARMV8/g' fmt-debug-armv8-data.cmake

### HACK ####
# We know fmt headers are not different between arches (even build_types) so just pick one in fmt-Target-(debug/release).cmake
sed -i '' 's/fmt_INCLUDE_DIRS_RELEASE/fmt_INCLUDE_DIRS_RELEASE_X86_64/g' fmt-Target-release.cmake
sed -i '' 's/fmt_INCLUDE_DIRS_DEBUG/fmt_INCLUDE_DIRS_DEBUG_X86_64/g' fmt-Target-debug.cmake
#############

###HACK #####
# I don't know how the write the proper generator expression for selecting an arch. 
# I think what I want is 
# $<$<AND:$<CONFIG:Debug>,$<ARCH:arm64>>:{ARM64_LIBRARIES}>
# But $<ARCH:...> generator expression doesn't exist.
#
# Soooo,
# Just send the both intel and arm libraries to the linker. Let it choose the correct one.
# This generates warning during link though (as expected).
#
# following warning for arm64 build
# ld: warning: ignoring file /Users/obirsoy/.conan/data/fmt/6.1.2/_/_/package/b5855232fa6dee7d27d2005b789408c1c12da382/lib/libfmtd.a, building for macOS-arm64 but attempting to link with file built for macOS-x86_64
#
# following warning for x86_64 build
# ld: warning: ignoring file /Users/obirsoy/.conan/data/fmt/6.1.2/_/_/package/42a10e89ce278d2cf0fa1c09abdd40b137b6e79b/lib/libfmtd.a, building for macOS-x86_64 but attempting to link with file built for macOS-arm64
#
sed -i '' 's/$<$<CONFIG:Debug>:${fmt_LIBRARIES_TARGETS_DEBUG}/$<$<CONFIG:Debug>:${fmt_LIB_DIRS_DEBUG_X86_64}\/lib${fmt_LIBS_DEBUG_X86_64}.a ${fmt_LIB_DIRS_DEBUG_ARMV8}\/lib${fmt_LIBS_DEBUG_ARMV8}.a/g' fmt-Target-debug.cmake
sed -i '' 's/$<$<CONFIG:Release>:${fmt_LIBRARIES_TARGETS_RELEASE}/$<$<CONFIG:Release>:${fmt_LIB_DIRS_RELEASE_X86_64}\/lib${fmt_LIBS_RELEASE_X86_64}.a ${fmt_LIB_DIRS_RELEASE_ARMV8}\/lib${fmt_LIBS_RELEASE_ARMV8}.a/g' fmt-Target-release.cmake
###################
# NOTE: We got it easy with fmt, such that it doesn't have any dependency. We might need to 'duplicate' those as well....
##########################################################################################################################
popd

echo ============================================================================================================
cmake --list-presets
echo
echo
echo ============================================================================================================
cmake --preset xcode
echo
echo
echo ============================================================================================================
cmake --preset debug-ninja-clang
echo
echo
echo ============================================================================================================
cmake --preset release-ninja-clang
echo
echo
