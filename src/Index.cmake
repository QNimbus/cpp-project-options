cmake_minimum_required(VERSION 3.16)

set(ProjectOptions_SRC_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE FILEPATH "")

# Include utilities and enforce for out-of-source build
include("${ProjectOptions_SRC_DIR}/Utilities.cmake")
include("${ProjectOptions_SRC_DIR}/PreventInSourceBuilds.cmake")

#
# Params:
# - WARNINGS_AS_ERRORS: Treat compiler warnings as errors
# - ENABLE_CLANG_TIDY: Enable static analysis with clang-tidy
# - ENABLE_PCH: Enable Precompiled Headers
# - PCH_HEADERS: the list of the headers to precompile
# - ENABLE_CONAN: Use Conan for dependency management
# - CONAN_OPTIONS: Extra Conan options
#
# NOTE: cmake-lint [C0103] Invalid macro name "project_options" doesn't match `[0-9A-Z_]+`
macro(project_options)
  set(options
      WARNINGS_AS_ERRORS
      ENABLE_CLANG_TIDY
      ENABLE_PCH
      ENABLE_CONAN)
  # set(oneValueArgs MSVC_WARNINGS CLANG_WARNINGS GCC_WARNINGS)
  set(multiValueArgs PCH_HEADERS CONAN_OPTIONS)

  # See: https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html
  cmake_parse_arguments(
    ProjectOptions
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  # Set warning message level
  if(${ProjectOptions_WARNINGS_AS_ERRORS})
    set(WARNINGS_AS_ERRORS ${ProjectOptions_WARNINGS_AS_ERRORS})
    
    # CMake error level
    set(WARNING_MESSAGE SEND_ERROR)
  else()
    # CMake error level
    set(WARNING_MESSAGE WARNING)
  endif()

  # Link this 'library' to set the C++ standard / compile-time options requested
  add_library(project_options INTERFACE)

  include("${ProjectOptions_SRC_DIR}/StandardProjectSettings.cmake")

  # allow for static analysis options
  include("${ProjectOptions_SRC_DIR}/StaticAnalyzers.cmake")

  if(${ProjectOptions_ENABLE_CLANG_TIDY})
    enable_clang_tidy()
  endif()

  # Very basic PCH implementation
  if(${ProjectOptions_ENABLE_PCH})
    # This sets a global PCH parameter, each project will build its own PCH, which is a good idea
    # if any #define's change consider breaking this out per project as necessary
    if(NOT ProjectOptions_PCH_HEADERS)
      set(ProjectOptions_PCH_HEADERS
          <vector>
          <string>
          <map>
          <utility>)
    endif()

    # See: https://cmake.org/cmake/help/latest/command/target_precompile_headers.html
    target_precompile_headers(project_options INTERFACE ${ProjectOptions_PCH_HEADERS})
  endif()

  if(${ProjectOptions_ENABLE_CONAN})
    include("${ProjectOptions_SRC_DIR}/Conan.cmake")
    run_conan()
  endif()

endmacro()
