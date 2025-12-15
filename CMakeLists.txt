cmake_minimum_required(VERSION 3.28)

project(plugintemplate-for-obs VERSION 1.0.0 LANGUAGES C CXX)

# Set C and C++ language standards to C17 and C++17
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Set symbols to be hidden by default for C and C++
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/common")
if(MSVC)
  list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows")
elseif(APPLE)
  list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/macos")
else()
  list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/linux")
endif()

include(compilerconfig)
include(defaults)

list(PREPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/.deps/Frameworks")
find_package(libobs REQUIRED)

set(PLUGIN_SOURCES src/plugin-main.cpp)
set(PLUGIN_LOCALE_RESOURCES data/locale/en-US.ini)

add_library(${CMAKE_PROJECT_NAME} MODULE ${PLUGIN_SOURCES})
target_link_libraries(${CMAKE_PROJECT_NAME} OBS::libobs)

if(APPLE)
  target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${PLUGIN_LOCALE_RESOURCES})
  set_source_files_properties(${PLUGIN_LOCALE_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/locale")

  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES
      BUNDLE ON
      BUNDLE_EXTENSION "plugin"
      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "-"
      XCODE_ATTRIBUTE_INSTALL_PATH "$(USER_LIBRARY_DIR)/Application Support/obs-studio/plugins"
      XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.example.plugintemplate-for-obs"
      XCODE_ATTRIBUTE_PRODUCT_NAME "${CMAKE_PROJECT_NAME}"
      XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@loader_path/../Frameworks"
  )
endif()
