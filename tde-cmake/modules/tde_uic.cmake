#################################################
#
#  (C) 2010-2011 Serghei Amelian
#  serghei (DOT) amelian (AT) gmail.com
#
#  Improvements and feedback are welcome
#
#  This file is released under GPL >= 2
#
#################################################

if( NOT ${CMAKE_CURRENT_LIST_DIR} STREQUAL ${CMAKE_ROOT}/Modules )
  set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}" )
endif()
include( TDEMacros )

get_filename_component( _ui_basename ${UI_FILE} NAME_WE )

# FIXME this will working only on out-of-source mode
set( local_ui_file ${_ui_basename}.ui )
configure_file( ${UI_FILE} ${local_ui_file} COPYONLY )
tde_execute_process( COMMAND ${TQT_REPLACE_SCRIPT} ${local_ui_file} )

# ui.h extension file, if exists
if( EXISTS "${UI_FILE}.h" )
  configure_file( ${UI_FILE}.h ${local_ui_file}.h COPYONLY )
  tde_execute_process( COMMAND ${TQT_REPLACE_SCRIPT} ${local_ui_file}.h )
endif( )

if( TDE_TQTPLUGINS_DIR )
  set( L -L ${TDE_TQTPLUGINS_DIR} )
endif( )

# Choose translation function, different for TQt and TDE
if ( TDE_FOUND AND NOT TQT_ONLY )
  set( TR_FUNC "tr2i18n" )
else( TDE_FOUND AND NOT TQT_ONLY )
  set( TR_FUNC "tr" )
endif( TDE_FOUND AND NOT TQT_ONLY )

# Generate ui .h file
tde_execute_process( COMMAND ${UIC_EXECUTABLE}
  -nounload -tr ${TR_FUNC}
  ${L}
  ${local_ui_file}
  OUTPUT_VARIABLE _ui_h_content )

if( _ui_h_content )
  string( REGEX REPLACE "#ifndef " "#ifndef UI_" _ui_h_content "${_ui_h_content}" )
  string( REGEX REPLACE "#define " "#define UI_" _ui_h_content "${_ui_h_content}" )
  if ( TDE_FOUND AND NOT TQT_ONLY )
    string( REGEX REPLACE "public T?QWizard" "public KWizard" _ui_h_content "${_ui_h_content}" )
    string( REGEX REPLACE "#include <(n?t)?qwizard.h>" "#include <kwizard.h>" _ui_h_content "${_ui_h_content}" )
  endif( TDE_FOUND AND NOT TQT_ONLY )
  file( WRITE ${_ui_basename}.h "${_ui_h_content}" )
endif( )

# Generate ui .cpp file
tde_execute_process( COMMAND ${UIC_EXECUTABLE}
  -nounload -tr ${TR_FUNC}
  ${L}
  -impl ${_ui_basename}.h
  ${local_ui_file}
  OUTPUT_VARIABLE _ui_cpp_content )

if( _ui_cpp_content )
  string( REGEX REPLACE "${TR_FUNC}\\(\"\"\\)" "TQString::null" _ui_cpp_content "${_ui_cpp_content}" )
  string( REGEX REPLACE "${TR_FUNC}\\(\"\", \"\"\\)" "TQString::null" _ui_cpp_content "${_ui_cpp_content}" )
  if ( TDE_FOUND AND NOT TQT_ONLY )
    string( REGEX REPLACE ": T?QWizard\\(" ": KWizard(" _ui_cpp_content "${_ui_cpp_content}" )
    set( _ui_cpp_content "#include <kdialog.h>\n#include <tdelocale.h>\n\n${_ui_cpp_content}" )
  endif( TDE_FOUND AND NOT TQT_ONLY )
  file( WRITE ${_ui_basename}.cpp "${_ui_cpp_content}" )

  tde_execute_process( COMMAND ${MOC_EXECUTABLE}
    ${_ui_basename}.h
    OUTPUT_VARIABLE _ui_h_moc_content )
  file( APPEND ${_ui_basename}.cpp "${_ui_h_moc_content}" )
endif( _ui_cpp_content )
