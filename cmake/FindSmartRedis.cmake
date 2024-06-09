# - Find the smartredis library
find_package(smartredis
             PATHS ${CMAKE_SOURCE_DIR}/smartredis/build)

if (smartredis_FOUND)
  message(STATUS "smartredis FOUND")
else()
  message(STATUS "smartredis PATH not available, we'll try to download and install")

  # Ensure the download directory exists
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build)

  # Clone the SmartRedis repository if it doesn't exist
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis)
    execute_process(
      COMMAND git clone https://github.com/CrayLabs/SmartRedis.git smartredis
      RESULT_VARIABLE result
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build
    )
    if(result)
      message(FATAL_ERROR "Git clone for smartredis failed: ${result}")
    else()
      message("Git clone for smartredis completed (${result}).")
    endif()
  endif()

  # Build the SmartRedis library with Fortran bindings
  execute_process(
    COMMAND make lib-with-fortran
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis
  )
  if(result)
    message(FATAL_ERROR "Build step for smartredis failed: ${result}")
  else()
    message("Build step for smartredis completed (${result}).")
  endif()

  set(smartredis_LIBRARIES ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/build/Release)
  # Set the directory containing libsmartredis.so to the library search path
  list(APPEND CMAKE_LIBRARY_PATH ${smartredis_LIBRARIES})

  # Manually include the package definitions file
  set(smartredis_defs_DIR ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis)
  include(${smartredis_defs_DIR}/smartredis_defs.cmake)

  # Manually set any required variables
  set(smartredis_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/install/include)
  set(smartredis_FOUND TRUE)
  include_directories(${smartredis_INCLUDE_DIR})

  # Add this line to set the library directory
  set(smartredis_LIBRARY_DIR ${smartredis_LIBRARIES})

  # Print debug information
  message(STATUS "SmartRedis include directory: ${smartredis_INCLUDE_DIR}")
  message(STATUS "SmartRedis library directory: ${smartredis_LIBRARY_DIR}")

endif()
