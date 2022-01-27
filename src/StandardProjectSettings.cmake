# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE
      Debug
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(
    CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS
             "Debug"
             "Release"
             "MinSizeRel"
             "RelWithDebInfo")
endif()

# Generate compile_commands.json to make it easier to work with clang based tools
# See: https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Enhance error reporting and compiler messages
# See: https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  add_compile_options(-fcolor-diagnostics)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  add_compile_options(-fdiagnostics-color=always)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION GREATER 1900)
  add_compile_options(/diagnostics:column)
else()
  message(STATUS "No colored compiler diagnostic set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
endif()

# If the default CMAKE_CXX_STANDARD is not set detect the latest CXX standard supported by the compiler and use it.
# This is needed for the tools like clang-tidy, cppcheck, etc.
if(NOT "${CMAKE_CXX_STANDARD}")
  if(DEFINED CMAKE_CXX20_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX20_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 20)
  elseif(DEFINED CMAKE_CXX17_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX17_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 17)
  elseif(DEFINED CMAKE_CXX14_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX14_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 14)
  else()
    set(CXX_LATEST_STANDARD 11)
  endif()
  message(
    STATUS
    "The default CMAKE_CXX_STANDARD used by external targets and tools is not set yet. Using the latest supported C++ standard that is C++${CXX_LATEST_STANDARD}"
  )
  set(CMAKE_CXX_STANDARD ${CXX_LATEST_STANDARD})
endif()

# Organize default targets into subfolder for better organization in IDE's (e.g. MSVC)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)                    # See: https://cmake.org/cmake/help/latest/prop_gbl/USE_FOLDERS.html
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMake") # See: https://cmake.org/cmake/help/latest/prop_gbl/PREDEFINED_TARGETS_FOLDER.html

# Run vcvarsall.bat
# See: https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line#developer_command_file_locations
include("${ProjectOptions_SRC_DIR}/VCEnvironment.cmake")
run_vcvarsall()
