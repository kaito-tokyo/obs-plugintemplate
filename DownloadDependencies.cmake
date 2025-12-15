# Plugin Name
# Copyright (C) <Year> <Developer> <Email Address>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; for more details see the file
# "LICENSE" in the distribution root.

cmake_minimum_required(VERSION 3.28)

set(BUILDSPEC_FILE "${CMAKE_CURRENT_SOURCE_DIR}/buildspec.json")
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.deps")

macro(get_dependency_info BUILDSPEC_CONTENT DEP_NAME PLATFORM_KEY HAS_DEBUG_SYMBOLS)
  string(JSON DEP_VERSION GET "${BUILDSPEC_CONTENT}" dependencies "${DEP_NAME}" version)
  string(JSON DEP_BASEURL GET "${BUILDSPEC_CONTENT}" dependencies "${DEP_NAME}" baseUrl)
  string(JSON DEP_HASH GET "${BUILDSPEC_CONTENT}" dependencies "${DEP_NAME}" hashes "${PLATFORM_KEY}")
  if(HAS_DEBUG_SYMBOLS)
    string(
      JSON
      DEP_DEBUG_SYMBOLS_HASH
      GET "${BUILDSPEC_CONTENT}"
      dependencies
      "${DEP_NAME}"
      debugSymbols
      "${PLATFORM_KEY}"
    )
  endif()
endmacro()

function(download_dependency URL FILE EXPECTED_HASH)
  file(DOWNLOAD "${URL}" "${FILE}" EXPECTED_HASH "${EXPECTED_HASH}" STATUS DOWNLOAD_STATUS)
endfunction()

if(NOT EXISTS "${BUILDSPEC_FILE}")
  message(FATAL_ERROR "buildspec.json not found at ${BUILDSPEC_FILE}")
endif()
file(READ "${BUILDSPEC_FILE}" BUILDSPEC_CONTENT)

if(MSVC)
  get_dependency_info("${BUILDSPEC_CONTENT}" obs-studio windows-x64 OFF)
  get_dependency_info("${BUILDSPEC_CONTENT}" prebuilt windows-x64 OFF)
  get_dependency_info("${BUILDSPEC_CONTENT}" qt6 windows-x64 ON)
elseif(APPLE)
  get_dependency_info("${BUILDSPEC_CONTENT}" obs-studio macos OFF)
  set(FILENAME "${DEP_VERSION}.tar.gz")
  file(DOWNLOAD "${DEP_BASEURL}/${FILENAME}" "${DEPS_DIR}/${FILENAME}" EXPECTED_HASH "SHA256=${DEP_HASH}" STATUS DOWNLOAD_STATUS)
  file(ARCHIVE_EXTRACT INPUT "${DEPS_DIR}/${FILENAME}" DESTINATION "${DEPS_DIR}/obs-studio-${DEP_VERSION}")

  get_dependency_info("${BUILDSPEC_CONTENT}" prebuilt macos OFF)
  set(FILENAME "macos-deps-${DEP_VERSION}-universal.tar.xz")
  file(DOWNLOAD "${DEP_BASEURL}/${DEP_VERSION}/${FILENAME}" "${DEPS_DIR}/${FILENAME}" EXPECTED_HASH "SHA256=${DEP_HASH}" STATUS DOWNLOAD_STATUS)
  file(ARCHIVE_EXTRACT INPUT "${DEPS_DIR}/${FILENAME}" DESTINATION "${DEPS_DIR}/obs-deps-${DEP_VERSION}-universal")

  get_dependency_info("${BUILDSPEC_CONTENT}" qt6 macos ON)
  set(FILENAME "macos-deps-qt6-${DEP_VERSION}-universal.tar.xz")
  file(DOWNLOAD "${DEP_BASEURL}/${DEP_VERSION}/${FILENAME}" "${DEPS_DIR}/${FILENAME}" EXPECTED_HASH "SHA256=${DEP_HASH}" STATUS DOWNLOAD_STATUS)
  file(ARCHIVE_EXTRACT INPUT "${DEPS_DIR}/${FILENAME}" DESTINATION "${DEPS_DIR}/obs-deps-qt6-${DEP_VERSION}-universal")
else()
  message(FATAL_ERROR "This script must not be run on this platform.")
endif()

message(STATUS "All dependencies downloaded and extracted to ${DEPS_DIR}")
