# Run once flag
if(NOT SET_UP_CONFIGURATIONS_DONE)
  set(SET_UP_CONFIGURATIONS_DONE TRUE)
  
  # Define available build types
  if (NOT BUILD_TYPES_AVAILABLE)
    set(BUILD_TYPES_AVAILABLE "Debug;Release")
  endif()

  # Set a default build type if none was specified
  if (NOT default_build_type) 
    if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
      # If inside cloned git repo make this a 'Debug' build type by default
      set(default_build_type "Debug")
    else()
      # Otherwise default to 'Release'
      set(default_build_type "Release")
    endif()

    # See: https://cmake.org/cmake/help/latest/command/message.html
    message(STATUS "Setting actual build type to '${default_build_type}' as none was specified.")
  endif()

  # See: https://cmake.org/cmake/help/latest/command/message.html
  message(DEBUG "Default build type set to '${default_build_type}'")

  # No reason to set CMAKE_CONFIGURATION_TYPES if it's not a multiconfig generator
  # Also no reason mess with CMAKE_BUILD_TYPE if it's a multiconfig generator.
  get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(isMultiConfig)
      set(CMAKE_CONFIGURATION_TYPES ${BUILD_TYPES_AVAILABLE} CACHE STRING "" FORCE)
  else()
      if(NOT CMAKE_BUILD_TYPE)
          message("Defaulting to '${default_build_type}' build.")
          set(CMAKE_BUILD_TYPE ${default_build_type} CACHE STRING "" FORCE)
      endif()
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY HELPSTRING "Choose the type of build.")
      # set the valid options for cmake-gui drop-down list
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${BUILD_TYPES_AVAILABLE})
  endif()
  # now set up the Profile configuration
  # set(CMAKE_C_FLAGS_PROFILE "...")
  # set(CMAKE_CXX_FLAGS_PROFILE "...")
  # set(CMAKE_EXE_LINKER_FLAGS_PROFILE "...")

  # Determine architecture string (e.g 'x86_64')
  if(DEFINED ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID})
    set(PlatformArchitecture "${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}")
  else()
    math(EXPR PlatformArchitecture "8 * ${CMAKE_SIZEOF_VOID_P}")
    set(PlatformArchitecture "x${PlatformArchitecture}")
  endif()
  
  # Directories for output files
  if(isMultiConfig)
    foreach( OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES} )
      string( TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG_UC )
      set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UC} "${CMAKE_SOURCE_DIR}/lib/${OUTPUTCONFIG}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}" CACHE PATH "" FORCE)
      set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UC} "${CMAKE_SOURCE_DIR}/lib/${OUTPUTCONFIG}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}" CACHE PATH "" FORCE)
      set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UC} "${CMAKE_SOURCE_DIR}/bin/${OUTPUTCONFIG}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}" CACHE PATH "" FORCE)
    endforeach()
  else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}"
      CACHE PATH "Output directory for static libraries.")

    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}"
      CACHE PATH "Output directory for shared libraries.")

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE}-${CMAKE_SYSTEM_NAME}-${PlatformArchitecture}"
      CACHE PATH "Output directory for executables and DLL's.")
  endif()

endif()
