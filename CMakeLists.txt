cmake_minimum_required(VERSION 3.28)

project(plugintemplate-for-obs VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(PLUGIN_SOURCES src/plugin-main.cpp)
set(PLUGIN_LOCALE_RESOURCES data/locale/en-US.ini)

add_library(${CMAKE_PROJECT_NAME} MODULE ${PLUGIN_SOURCES})

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
  )
endif()
