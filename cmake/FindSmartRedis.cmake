# - Find the SmartRedis library
find_path(SMARTREDIS_INCLUDE_DIR NAMES smartredis.hpp
          PATHS ${CMAKE_SOURCE_DIR}/smartredis/build/install/include)

find_library(SMARTREDIS_LIBRARY NAMES smartredis
             PATHS ${CMAKE_SOURCE_DIR}/smartredis/build/install/lib)

find_library(SMARTREDIS_FORTRAN_LIBRARY NAMES smartredis-fortran
             PATHS ${CMAKE_SOURCE_DIR}/smartredis/build/install/lib)

if (SMARTREDIS_INCLUDE_DIR AND SMARTREDIS_LIBRARY AND SMARTREDIS_FORTRAN_LIBRARY)
  set(SMARTREDIS_FOUND TRUE)
  set(SMARTREDIS_INCLUDE_DIRS ${SMARTREDIS_INCLUDE_DIR})
  set(SMARTREDIS_LIBRARIES ${SMARTREDIS_LIBRARY} ${SMARTREDIS_FORTRAN_LIBRARY})
  set(SMARTREDIS_LIBRARY_DIR ${CMAKE_SOURCE_DIR}/smartredis/build/install/lib)
else()
  message(STATUS "SmartRedis not found, attempting to download and build...")

  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build)

  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis)
    execute_process(
      COMMAND git clone https://github.com/CrayLabs/SmartRedis.git smartredis
      RESULT_VARIABLE result
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build
    )
    if(result)
      message(FATAL_ERROR "Git clone for SmartRedis failed: ${result}")
    else()
      message(STATUS "Git clone for SmartRedis completed (${result}).")
    endif()
  endif()

  execute_process(
    COMMAND make lib-with-fortran
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis
  )
  if(result)
    message(FATAL_ERROR "Build step for SmartRedis failed: ${result}")
  else()
    message(STATUS "Build step for SmartRedis completed (${result}).")
  endif()

  set(SMARTREDIS_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/install/include)
  set(SMARTREDIS_LIBRARY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/install/lib/libsmartredis.so)
  set(SMARTREDIS_FORTRAN_LIBRARY ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/install/lib/libsmartredis-fortran.so)
  set(SMARTREDIS_FOUND TRUE)
  set(SMARTREDIS_INCLUDE_DIRS ${SMARTREDIS_INCLUDE_DIR})
  set(SMARTREDIS_LIBRARIES ${SMARTREDIS_LIBRARY} ${SMARTREDIS_FORTRAN_LIBRARY})
  set(SMARTREDIS_LIBRARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/smartredis-build/smartredis/install/lib)

  include_directories(${SMARTREDIS_INCLUDE_DIR})

  message(STATUS "SmartRedis include directory: ${SMARTREDIS_INCLUDE_DIR}")
  message(STATUS "SmartRedis library directory: ${SMARTREDIS_LIBRARY_DIR}")
endif()

mark_as_advanced(SMARTREDIS_INCLUDE_DIR SMARTREDIS_LIBRARY SMARTREDIS_FORTRAN_LIBRARY)

