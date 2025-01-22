#################################################
#
#  (C) 2022 Slávek Banko
#  slavek (DOT) banko (AT) axis.cz
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


get_filename_component( _src_file "${SRC_FILE}" ABSOLUTE )
set( _meta_includes ${META_INCLUES} )
unset( _moc_headers )

if( EXISTS "${_src_file}" )

  # read source file and check if have moc include
  file( READ "${_src_file}" _src_content )
  string( REGEX MATCHALL "#include +[^ ]+\\.moc[\">]" _moc_includes "${_src_content}" )

  # found included moc(s)?
  if( _moc_includes )
    foreach( _moc_file ${_moc_includes} )

      # extracting moc filename
      string( REGEX MATCH "[^ <\"]+\\.moc" _moc_file "${_moc_file}" )
      set( _moc_file "${CMAKE_CURRENT_BINARY_DIR}/${_moc_file}" )

      # create header filename
      get_filename_component( _src_path "${_src_file}" ABSOLUTE )
      get_filename_component( _src_path "${_src_path}" PATH )
      get_filename_component( _src_header "${_moc_file}" NAME_WE )
      set( _header_file "${_src_path}/${_src_header}.h" )

      # if header doesn't exists, check in META_INCLUDES
      if( NOT EXISTS "${_header_file}" )
        unset( _found )
        foreach( _src_path ${_meta_includes} )
          set( _header_file "${_src_path}/${_src_header}.h" )
          if( EXISTS "${_header_file}" )
            set( _found 1 )
            break( )
          endif( )
        endforeach( )
        if( NOT _found )
          get_filename_component( _moc_file "${_moc_file}" NAME )
          tde_message_fatal( "AUTOMOC error: '${_moc_file}' cannot be generated.\n Reason: '${_src_header}.h' not found." )
        endif( )
      endif( )

      # moc-ing header
      execute_process( COMMAND ${TMOC_EXECUTABLE} ${_header_file} -o ${_moc_file} )
      list( APPEND _moc_headers "${_src_header}.h" )

    endforeach( _moc_file )

  endif( _moc_includes )

else()
  tde_message_fatal( "AUTOMOC error: '${_src_file}' not found!" )
endif( EXISTS "${_src_file}" )

get_filename_component( _automoc_file "${_src_file}+automoc" NAME )
if( DEFINED _moc_headers )
  string( REPLACE ";" "\n * " _moc_headers "${_moc_headers}" )
  file( WRITE "${_automoc_file}" "/*\n * processed:\n * ${_moc_headers}\n */" )
else()
  file( WRITE "${_automoc_file}" "/* processed - no moc files */" )
endif()
