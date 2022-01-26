# Function to dump all CMake variables
function(dump_cmake_variables)
  get_cmake_property(_variableNames VARIABLES)
  list (SORT _variableNames)
  foreach (_variableName ${_variableNames})
    if (ARGV0)
      unset(MATCHED)
      string(REGEX MATCH ${ARGV0} MATCHED ${_variableName})
      if (NOT MATCHED)
        continue()
      endif()
    endif()
    message(STATUS "${_variableName}=${${_variableName}}")
  endforeach()
endfunction()

# Function to dump all CMake environment variables
function(dump_cmake_env_variables)
  execute_process(COMMAND "${CMAKE_COMMAND}" "-E" "environment" OUTPUT_VARIABLE _envVariables)
  
  set(envvar_regex "^([^=]*)=.*$")

  string (REPLACE ";" "\\\;" _envVariables "${_envVariables}")
  string (REPLACE "\n" ";"   _envVariables "${_envVariables}")

  list (SORT _envVariables)

  foreach (_envVariable ${_envVariables})
    unset(_variableName)
    unset(MATCHED)
    
    string(REGEX MATCH "${envvar_regex}" MATCHED "${_envVariable}")
    if(MATCHED)
      string(REGEX REPLACE "${envvar_regex}" "\\1" _variableName "${MATCHED}")

      if (ARGV0)
        unset(MATCHED)
        string(REGEX MATCH ${ARGV0} MATCHED ${_variableName})
        if (NOT MATCHED)
          continue()
        endif()
      endif()

    endif()

    message(STATUS "${_variableName}=$ENV{${_variableName}}")
  endforeach()
endfunction()

# find a subtring from a string by a given prefix such as VCVARSALL_ENV_START
function(
  find_substring_by_prefix
  output
  prefix
  input)
  # find the prefix
  string(FIND "${input}" "${prefix}" prefix_index)
  if("${prefix_index}" STREQUAL "-1")
    message(SEND_ERROR "Could not find ${prefix} in ${input}")
  endif()
  # find the start index
  string(LENGTH "${prefix}" prefix_length)
  math(EXPR start_index "${prefix_index} + ${prefix_length}")

  string(
    SUBSTRING "${input}"
              "${start_index}"
              "-1"
              _output)
  set("${output}"
      "${_output}"
      PARENT_SCOPE)
endfunction()

# A function to set environment variables of CMake from the output of `cmd /c set`
function(set_env_from_string env_string)
  # replace ; in paths with __sep__ so we can split on ;
  string(
    REGEX
    REPLACE ";"
            "__sep__"
            env_string_sep_added
            "${env_string}")

  # the variables are separated by \r?\n
  string(
    REGEX
    REPLACE "\r?\n"
            ";"
            env_list
            "${env_string_sep_added}")

  foreach(env_var ${env_list})
    # split by =
    string(
      REGEX
      REPLACE "="
              ";"
              env_parts
              "${env_var}")

    list(LENGTH env_parts env_parts_length)
    if("${env_parts_length}" EQUAL "2")
      # get the variable name and value
      list(
        GET
        env_parts
        0
        env_name)
      list(
        GET
        env_parts
        1
        env_value)

      # recover ; in paths
      string(
        REGEX
        REPLACE "__sep__"
                ";"
                env_value
                "${env_value}")

      # set env_name to env_value
      set(ENV{${env_name}} "${env_value}")

      # update cmake program path
      if("${env_name}" EQUAL "PATH")
        list(APPEND CMAKE_PROGRAM_PATH ${env_value})
      endif()
    endif()
  endforeach()
endfunction()
