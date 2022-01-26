cmake_minimum_required(VERSION 3.16)

set(ProjectOptions_SRC_DIR
    ${CMAKE_CURRENT_LIST_DIR}
    CACHE FILEPATH "")

include("${ProjectOptions_SRC_DIR}/PreventInSourceBuilds.cmake")

#
# Params:
# - ENABLE_CONAN: Use Conan for dependency management
# - CONAN_OPTIONS: Extra Conan options
#
# NOTE: cmake-lint [C0103] Invalid macro name "project_options" doesn't match `[0-9A-Z_]+`
macro(project_options)
  set(options ENABLE_CONAN)
  # set(oneValueArgs MSVC_WARNINGS CLANG_WARNINGS GCC_WARNINGS)
  set(multiValueArgs CONAN_OPTIONS)
  cmake_parse_arguments(
    ProjectOptions
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  include("${ProjectOptions_SRC_DIR}/StandardProjectSettings.cmake")

  if(${ProjectOptions_ENABLE_CONAN})
    include("${ProjectOptions_SRC_DIR}/Conan.cmake")
    run_conan()
  endif()

endmacro()
