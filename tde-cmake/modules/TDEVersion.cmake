#################################################
#
#  (C) 2022 Michele Calgaro
#  michele (DOT) calgaro (AT) yahoo (DOT) it
#
#  Improvements and feedback are welcome
#
#  This file is released under GPL >= 2
#
#################################################

# Centralized place where to set the minimum cmake version required in TDE

set( TDE_CMAKE_MINIMUM_VERSION 3.5 )


#################################################
#####
##### tde_set_project_version

macro( tde_set_project_version )

  set( DEFAULT_VERSION "R14.1.3" )

  unset( VERSION )

  if( EXISTS ${CMAKE_SOURCE_DIR}/.tdescminfo )
    file( STRINGS ${CMAKE_SOURCE_DIR}/.tdescminfo VERSION_STRING REGEX "^Version:.+$" )
    string( REGEX REPLACE "^Version: (R[0-9]+\\.[0-9]+\\.[0-9]+.*)$" "\\1" VERSION "${VERSION_STRING}" )
  endif()

  if( NOT VERSION )
    set( VERSION "${DEFAULT_VERSION}" )
  endif()

endmacro( )

