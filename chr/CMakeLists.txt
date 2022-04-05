#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the Apache License, Version 2.0.
#
#  Copyright:
#     2021, Vincent Barichard <Vincent.Barichard@univ-angers.fr>
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)
# If the user specifies -DCMAKE_BUILD_TYPE on the command line, take their definition
# and dump it in the cache along with proper documentation, otherwise set CMAKE_BUILD_TYPE
# to Release prior to calling PROJECT()
#
IF(NOT DEFINED CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
ENDIF()

PROJECT(CHR_EDT VERSION 0.1)

SET(CMAKE_VERBOSE_MAKEFILE TRUE)

# Reserved call stack for examples and tests
SET(RESERVED_CALL_STACK "10000000" CACHE STRING "Reserved call stack")

# Include Cotire for compilation speedup
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
INCLUDE(cotire)

IF(UNIX)
  # determine, whether we want a static binary
  SET(STATIC_LINKING FALSE CACHE BOOL "Build a static binary?")
  # do we want static libraries?
  IF(STATIC_LINKING)
    # When STATIC_LINKING is TRUE, than cmake looks for libraries ending
    # with .a. This is for linux only!
    SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    SET(CMAKE_EXE_LINKER_FLAGS "-static")
    # Remove flags to get rid off all the -Wl,Bydnamic
    SET(CMAKE_EXE_LINK_DYNAMIC_C_FLAGS)
    SET(CMAKE_EXE_LINK_DYNAMIC_CXX_FLAGS)
  ENDIF(STATIC_LINKING)
ENDIF(UNIX)

# Check if C++ compiler support specific options
INCLUDE(CheckCXXCompilerFlag)
SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)
SET(CMAKE_CXX_EXTENSIONS OFF)

IF (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  ADD_COMPILE_OPTIONS(-Wall -Wextra -Wno-unused-local-typedefs -pipe)
  SET(CMAKE_CXX_FLAGS_DEBUG "-ggdb -fno-inline-functions -fPIC")
  # To make MinGW able to compile big files
  IF (MINGW)
	ADD_COMPILE_OPTIONS(-Wa,-mbig-obj)
  ENDIF(MINGW)
  # Compiler compatibility
  IF (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6)
      ADD_COMPILE_OPTIONS(-DUSE_DEPRECATED_GCC_CONSTRUCT)
  ENDIF() 

ELSEIF (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  ADD_COMPILE_OPTIONS(-Wall -Wextra -Wno-unused-local-typedefs -pipe)
  SET(CMAKE_CXX_FLAGS_DEBUG "-g")
ELSEIF (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  ADD_COMPILE_OPTIONS(/bigobj)
ENDIF()

SET(CMAKE_CODELITE_USE_TARGETS ON)

IF (${CMAKE_CXX_COMPILER_ID} STREQUAL MSVC)
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /STACK:${RESERVED_CALL_STACK}")
ELSEIF (MINGW)
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--stack,${RESERVED_CALL_STACK}")
ELSEIF (WIN32 AND (${CMAKE_CXX_COMPILER_ID} STREQUAL Clang))
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--stack,${RESERVED_CALL_STACK}")
ENDIF()

SET(HEADER_FILES
  nlohmann-json/json.hpp
  cp_int.h
  debug.h
  instanceparser.h
)

SET(INLINED_SRC_FILES
)

SET(SOURCE_FILES
    main.cpp
    cp_int.cpp
    instanceparser.cpp
)

SET(CHRPP_SOURCE_FILES
	timetabling.chrpp
)

SET(CHR_CLASS_timetabling.chrpp TIMETABLING)

SOURCE_GROUP("Hpp Files" REGULAR_EXPRESSION ".hpp")
SOURCE_GROUP("Chrpp Files" REGULAR_EXPRESSION ".chrpp")

SET(chrppc_parameters "")

SET(CHRPP_BINARY_DIR "/usr/local/include/chrpp" CACHE STRING "Path to chrpp binary files.")
SET(CHRPP_SOURCE_DIR "/usr/local/include/chrpp" CACHE STRING "Path to chrpp source files.")
SET(CHRPPC_BINARY "/usr/local/bin/chrppc" CACHE STRING "Link to chrppc program.")

SET(ENABLE_TRACE OFF CACHE BOOL "Set to true to generate output with trace properties.")
IF (ENABLE_TRACE)
	ADD_DEFINITIONS(-DENABLE_TRACE)
	SET(chrppc_parameters ${chrppc_parameters} --trace)
ENDIF(ENABLE_TRACE)

SET(ENABLE_LINE_ERROR ON CACHE BOOL "Enable friendly line error in chrpp source file")
IF(ENABLE_LINE_ERROR)
	SET(chrppc_parameters ${chrppc_parameters} --enable-line_error)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-line_error)
ENDIF()

SET(ENABLE_CONSTRAINT_STORE_INDEX ON CACHE BOOL "Enable the use of an indexing data structure for managing constraint store")
IF(ENABLE_CONSTRAINT_STORE_INDEX)
	SET(chrppc_parameters ${chrppc_parameters} --enable-constraint_store_index)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-constraint_store_index)
ENDIF()

SET(ENABLE_WARNING_ASSIGN ON CACHE BOOL "Enable warning about assign operator on logical variable")
IF(ENABLE_WARNING_ASSIGN)
	SET(chrppc_parameters ${chrppc_parameters} --enable-warning_assign)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-warning_assign)
ENDIF()

SET(ENABLE_WARNING_UNUSED_RULE ON CACHE BOOL "Enable warning about unused ruled detection")
IF(ENABLE_WARNING_UNUSED_RULE)
	SET(chrppc_parameters ${chrppc_parameters} --enable-warning_unused_rule)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-warning_unused_rule)
ENDIF()

SET(ENABLE_NEVER_STORED ON CACHE BOOL "Enable never stored optimization")
IF(ENABLE_NEVER_STORED)
	SET(chrppc_parameters ${chrppc_parameters} --enable-never_stored)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-never_stored)
ENDIF()

SET(ENABLE_LATE_STORAGE ON CACHE BOOL "Enable late storage optimization")
IF(ENABLE_LATE_STORAGE)
	SET(chrppc_parameters ${chrppc_parameters} --enable-late_storage)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-late_storage)
ENDIF()

SET(ENABLE_HEAD_REORDER ON CACHE BOOL "Enable head reorder optimization")
IF(ENABLE_HEAD_REORDER)
	SET(chrppc_parameters ${chrppc_parameters} --enable-head_reorder)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-head_reorder)
ENDIF()

SET(ENABLE_GUARD_REORDER ON CACHE BOOL "Enable guard reorder optimization")
IF(ENABLE_GUARD_REORDER)
	SET(chrppc_parameters ${chrppc_parameters} --enable-guard_reorder)
ELSE()
	SET(chrppc_parameters ${chrppc_parameters} --disable-guard_reorder)
ENDIF()

SET(ENABLE_STATISTICS ON CACHE BOOL "Enable runtime statistics")
IF(ENABLE_STATISTICS)
	ADD_DEFINITIONS(-DENABLE_STATISTICS)
ENDIF()

SET(ENABLE_MEMORY_STATISTICS OFF CACHE BOOL "Enable runtime memory statistics")
IF(ENABLE_MEMORY_STATISTICS)
	ADD_DEFINITIONS(-DENABLE_MEMORY_STATISTICS)
ENDIF()

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})
INCLUDE_DIRECTORIES(${CHRPP_BINARY_DIR})
INCLUDE_DIRECTORIES(${CHRPP_SOURCE_DIR})

FOREACH (chrpp_file ${CHRPP_SOURCE_FILES})
	GET_FILENAME_COMPONENT(chrpp_file_name ${chrpp_file} NAME_WE)
	SET(CHR_AUTO_GEN_FILES)
	# NOT NEEDED LIST(APPEND CHR_AUTO_GEN_FILES ${chrpp_file_name}_chr_main.cpp)
	LIST(APPEND CHR_AUTO_GEN_FILES ${chrpp_file_name}_chr_header.hpp)
	FOREACH (CHR_CLASS ${CHR_CLASS_${chrpp_file}})
		LIST(APPEND CHR_AUTO_GEN_FILES ${chrpp_file_name}_chr_${CHR_CLASS}.cpp)
	ENDFOREACH (CHR_CLASS ${CHR_CLASS_${chrpp_file}})

	ADD_CUSTOM_COMMAND(OUTPUT ${CHR_AUTO_GEN_FILES}
		COMMAND ${CHRPPC_BINARY} ${chrppc_parameters} --output_dir ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/${chrpp_file}
		DEPENDS ${CHRPPC_BINARY} ${chrpp_file}
	)

	ADD_EXECUTABLE(${chrpp_file_name} ${CHR_AUTO_GEN_FILES} ${chrpp_file} ${HEADER_FILES} ${INLINED_SRC_FILES} ${SOURCE_FILES})
	COTIRE(${chrpp_file_name})
	# Add install target
	INSTALL(TARGETS ${chrpp_file_name} RUNTIME DESTINATION bin)
ENDFOREACH ()
