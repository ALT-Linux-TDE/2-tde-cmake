#################################################
#
#  (C) 2021 Slávek Banko
#  slavek.banko (at) axis.cz
#
#  Improvements and feedback are welcome
#
#  This file is released under GPL >= 2
#
#################################################

## Process only if it is built as a standalone package
if( "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}" )

##### general package setup #####################

  # building tde-cmake requires reading the minimum required version
  # from the source files, because there may be a different version
  # of tde-cmake already installed in the system. Trying to build
  # tde-cmake with a lower minimum version would not be allowed then.

  include( ${CMAKE_SOURCE_DIR}/modules/TDEVersion.cmake )
  cmake_minimum_required( VERSION ${TDE_CMAKE_MINIMUM_VERSION} )
  project( tde-cmake-rules )


##### install TDE CMake files ###################

  file( GLOB_RECURSE _modules
        RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/modules/* )
  install( FILES ${_modules} DESTINATION ${CMAKE_ROOT}/Modules )

  file( GLOB_RECURSE _templates
        RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/templates/* )
  install( FILES ${_templates} DESTINATION ${CMAKE_ROOT}/Templates )

endif()
