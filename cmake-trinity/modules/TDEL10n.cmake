#################################################
#
#  (C) 2018-2020 Slávek Banko
#  slavek (DOT) banko (AT) axis.cz
#
#  Improvements and feedback are welcome
#
#  This file is released under GPL >= 2
#
#################################################


##### include essential TDE macros ##############

set( MASTER_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
include( TDEMacros )


##### verify required programs ##################

if( NOT DEFINED TDE_PREFIX AND IS_DIRECTORY /opt/trinity )
  set( TDE_PREFIX "/opt/trinity" )
else( )
  set( TDE_PREFIX "/usr" )
endif( )

if( NOT DEFINED KDE_XGETTEXT_EXECUTABLE )
  find_program( KDE_XGETTEXT_EXECUTABLE
    NAMES kde-xgettext
    HINTS "${TDE_PREFIX}/bin"
  )
  if( "${KDE_XGETTEXT_EXECUTABLE}" STREQUAL "KDE_XGETTEXT_EXECUTABLE-NOTFOUND" )
    tde_message_fatal( "kde-xgettext is required but not found" )
  endif( )
endif( )

if( NOT DEFINED XGETTEXT_EXECUTABLE )
  find_program( XGETTEXT_EXECUTABLE
    NAMES xgettext
    HINTS "${TDE_PREFIX}/bin"
  )
  if( "${XGETTEXT_EXECUTABLE}" STREQUAL "XGETTEXT_EXECUTABLE-NOTFOUND" )
    tde_message_fatal( "xgettext is required but not found" )
  endif( )
endif( )

if( NOT DEFINED MSGUNIQ_EXECUTABLE )
  find_program( MSGUNIQ_EXECUTABLE
    NAMES msguniq
    HINTS "${TDE_PREFIX}/bin"
  )
  if( "${MSGUNIQ_EXECUTABLE}" STREQUAL "MSGUNIQ_EXECUTABLE-NOTFOUND" )
    tde_message_fatal( "msguniq is required but not found" )
  endif( )
endif( )

if( NOT DEFINED PO4A_GETTEXTIZE_EXECUTABLE )
  find_program( PO4A_GETTEXTIZE_EXECUTABLE
    NAMES po4a-gettextize
    HINTS "${TDE_PREFIX}/bin"
  )
  if( "${PO4A_GETTEXTIZE_EXECUTABLE}" STREQUAL "PO4A_GETTEXTIZE_EXECUTABLE-NOTFOUND" )
    tde_message_fatal( "po4a-gettextize is required but not found" )
  endif( )
  execute_process(
    COMMAND ${PO4A_GETTEXTIZE_EXECUTABLE} --version
    OUTPUT_VARIABLE _po4a_version
    ERROR_VARIABLE _po4a_version
  )
  string( REGEX REPLACE "^po4a-gettextize[^\n]* ([^ ]*)\n.*" "\\1" _po4a_version ${_po4a_version} )
  if( "${_po4a_version}" VERSION_LESS "0.45" )
    tde_message_fatal( "po4a version >= 0.45 is required but found only ${_po4_version}" )
  endif( )
endif( )

if( NOT DEFINED TDE_COMMON_TEXTS_POT )
  get_filename_component( TDE_SOURCE_BASE "${CMAKE_CURRENT_SOURCE_DIR}" ABSOLUTE )
  while( (NOT EXISTS "${TDE_SOURCE_BASE}/core/tdelibs"
          OR NOT IS_DIRECTORY "${TDE_SOURCE_BASE}/core/tdelibs" )
         AND NOT "${TDE_SOURCE_BASE}" STREQUAL "/" )
    get_filename_component( TDE_SOURCE_BASE "${TDE_SOURCE_BASE}" PATH )
  endwhile( )
  find_file( TDE_COMMON_TEXTS_POT
    NAMES tde.pot
    HINTS "${TDE_SOURCE_BASE}/core/tdelibs" "${TDE_PREFIX}/include" "${TDE_PREFIX}/include/tde"
  )
  if( "${TDE_COMMON_TEXTS_POT}" STREQUAL "TDE_COMMON_TEXTS_POT-NOTFOUND" )
    tde_message_fatal( "translation template with common texts not found" )
  endif( )
endif( )


#################################################
#####
##### tde_l10n_add_subdirectory
#####
##### The function simulates the add_subdirectory() behavior, but
##### the CMakeL10n.txt file is used instead of CMakeLists.txt.
#####

function( tde_l10n_add_subdirectory _dir )
  set( CMAKE_CURRENT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}" )
  set( CMAKE_CURRENT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/${_dir}" )
  include( ${CMAKE_CURRENT_SOURCE_DIR}/CMakeL10n.txt )
endfunction( )


#################################################
#####
##### tde_l10n_auto_add_subdirectories
#####
##### The function is equivalent to tde_auto_add_subdirectories, but
##### the CMakeL10n.txt file is used instead of CMakeLists.txt.
#####

function( tde_l10n_auto_add_subdirectories )
  file( GLOB _dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/*" )
  foreach( _dir ${_dirs} )
    if( IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_dir}
        AND NOT ${_dir} STREQUAL ".svn"
        AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_dir}/CMakeL10n.txt )
      tde_l10n_add_subdirectory( ${_dir} )
    endif( )
  endforeach( )
endfunction( )


#################################################
#####
##### tde_l10n_create_template
#####
##### Macro is used to generate a translation template - POT file.
#####
##### Syntax:
#####   tde_l10n_create_template(
#####     [CATALOG] file_name
#####     [SOURCES source_spec [source_spec]]
#####     [COMMENT tag]
#####     [EXCLUDES regex [regex]]
#####     [KEYWORDS keyword [keyword]]
#####     [ATTRIBUTES attrib_spec [attrib_spec]]
#####     [X-POT common_texts.pot]
#####     [DESTINATION directory]
#####   )
#####
##### Where:
#####   CATALOG determines the target file name (without pot suffix).
#####     If the name ends with '/', a catalog of the same name
#####     will be created in the specified directory.
#####   SOURCES can be specified by several options:
#####     a) Do not specify anything
#####      - all usual source files will be automatically searched.
#####     b) Enter the directory name - for example, '.' or 'src'
#####      - all the usual source files in the specified directory
#####        and subdirectories will be searched.
#####     c) Enter the mask - for example '*.cpp'
#####      - all files with the specified mask will be searched.
#####     d) Specify the name of the individual file.
#####     The methods from b) to d) can be combined.
#####   EXCLUDES determines which files are to be excluded from processing
#####   COMMENT determines additional comment to extract by xgettext.
#####   KEYWORDS determines additional keywords for xgettext.
#####     Use "-" if is needed to disable default keywords.
#####   ATTRIBUTES determines files and specification for extractattr:
#####     source_spec:element,attribute[,context][[:element,attribute[,context]]...]
#####   X-POT entries from common_texts.pot are not extracted
#####     By default, "tde.pot" is searched for and used.
#####     Use "-" to skip this.
#####   DESTINATION determines directory to save translation template.
#####     The destination directory is determined as follows:
#####     a) Directory is specified as an argument.
#####     b) The variable POT_SOURCE_DIR is set.
#####     c) There is a 'translations' directory.
#####     d) There is a 'po' directory.
#####
##### Note:
#####    Editing the _files list inside foreach( ${_files} ) below in the
#####    code is safe, because in CMake foreach parameters are evaluated
#####    before the loop starts. Therefore, the changes in the list inside
#####    the loop do not have an unwanted impact on the loop processing.
#####

macro( tde_l10n_create_template )

  unset( _catalog )
  unset( _sources )
  unset( _excludes )
  unset( _files )
  unset( _desktops )
  unset( _pots )
  unset( _dest )
  unset( _keywords_add )
  unset( _comment )
  unset( _attributes )
  unset( _exclude_pots )
  unset( _pot )
  unset( _directive )
  set( _var _catalog )
  set( _keywords_c_default "i18n" "i18n:1,2" "tr2i18n" "tr2i18n:1,2" "I18N_NOOP" "I18N_NOOP2" )
  set( _keywords_desktop_default
       "-" "Name" "GenericName" "Comment" "Keywords"
       "Description" "ExtraNames" "X-TDE-Submenu" )

  foreach( _arg ${ARGN} )

    # found directive "CATALOG"
    if( "+${_arg}" STREQUAL "+CATALOG" )
      unset( _catalog )
      set( _var _catalog )
      set( _directive 1 )
    endif( )

    # found directive "SOURCES"
    if( "+${_arg}" STREQUAL "+SOURCES" )
      unset( _sources )
      set( _var _sources )
      set( _directive 1 )
    endif( )

    # found directive "SOURCES_DESKTOP"
    if( "+${_arg}" STREQUAL "+SOURCES_DESKTOP" )
      unset( _desktops )
      set( _var _desktops )
      set( _directive 1 )
    endif( )

    # found directive "EXCLUDES"
    if( "+${_arg}" STREQUAL "+EXCLUDES" )
      unset( _excludes )
      set( _var _excludes )
      set( _directive 1 )
    endif( )

    # found directive "DESTINATION"
    if( "+${_arg}" STREQUAL "+DESTINATION" )
      unset( _dest )
      set( _var _dest )
      set( _directive 1 )
    endif( )

    # found directive "COMMENT"
    if( "+${_arg}" STREQUAL "+COMMENT" )
      unset( _comment )
      set( _var _comment )
      set( _directive 1 )
    endif( )

    # found directive "KEYWORDS"
    if( "+${_arg}" STREQUAL "+KEYWORDS" )
      unset( _keywords_add )
      set( _var _keywords_add )
      set( _directive 1 )
    endif( )

    # found directive "ATTRIBUTES"
    if( "+${_arg}" STREQUAL "+ATTRIBUTES" )
      unset( _attributes )
      set( _var _attributes )
      set( _directive 1 )
    endif( )

    # found directive "X-POT"
    if( "+${_arg}" STREQUAL "+X-POT" )
      unset( _exclude_pots )
      set( _var _exclude_pots )
      set( _directive 1 )
    endif( )

    # collect data
    if( _directive )
      unset( _directive )
    elseif( _var )
      list( APPEND ${_var} ${_arg} )
    endif( )

  endforeach( )

  # verify catalog
  if( NOT _catalog )
    tde_message_fatal( "the name of the translation catalog is not defined" )
  endif( )

  # determine the destination directory
  if( NOT _dest )
    if( POT_SOURCE_DIR )
      set( _dest ${POT_SOURCE_DIR} )
    elseif( EXISTS "${MASTER_SOURCE_DIR}/translations" )
      set( _dest "${MASTER_SOURCE_DIR}/translations/" )
    elseif( EXISTS "${MASTER_SOURCE_DIR}/po" )
      set( _dest "${MASTER_SOURCE_DIR}/po/" )
    else( )
      tde_message_fatal( "cannot determine destination directory" )
    endif( )
  endif( )
  if( ${_dest} MATCHES "[^/]$" )
    set( _dest "${_dest}/" )
  endif( )
  if( NOT IS_ABSOLUTE ${_dest} )
    set( _dest "${CMAKE_CURRENT_SOURCE_DIR}/${_dest}" )
  endif( )

  if( ${_catalog} MATCHES "/$" )
    string( REGEX REPLACE "/$" "" _catalog "${_catalog}" )
    get_filename_component( _catalog_base "${_catalog}" NAME )
    set( _catalog "${_catalog}/${_catalog_base}" )
  endif( )
  get_filename_component( _potFilename "${_dest}${_catalog}.pot" ABSOLUTE )
  file( RELATIVE_PATH _potFilename ${CMAKE_SOURCE_DIR} ${_potFilename} )
  message( STATUS "Create translation template ${_potFilename}" )

  # verify sources
  if( NOT _sources AND NOT _attributes AND NOT _desktops )
    # add current directory
    list( APPEND _sources "." )
  endif( )
  foreach( _src ${_sources} )

    # add all source files from directory
    if( IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_src} )
      if( ${_src} STREQUAL "." )
        set( _dir "${CMAKE_CURRENT_SOURCE_DIR}" )
      else( )
        set( _dir "${CMAKE_CURRENT_SOURCE_DIR}/${_src}" )
      endif( )
      file( GLOB_RECURSE _add_files
            RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
            ${_dir}/*.c
            ${_dir}/*.cc
            ${_dir}/*.cpp
            ${_dir}/*.cxx
            ${_dir}/*.h
            ${_dir}/*.hh
            ${_dir}/*.hpp
            ${_dir}/*.hxx
            ${_dir}/*.kcfg
            ${_dir}/*.rc
            ${_dir}/*.ui
      )
      list( SORT _add_files )
      list( APPEND _files ${_add_files} )

    # add files by the specified mask
    elseif( ${_src} MATCHES "(\\*|\\?)" )
      file( GLOB_RECURSE _add_files
            RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}/${_src}
      )
      list( SORT _add_files )
      list( APPEND _files ${_add_files} )

    # add a individual file
    elseif( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_src} )
      list( APPEND _files ${_src} )
    endif( )

  endforeach( )

  # filter files by excludes
  if( _excludes )
    foreach( _src ${_files} )
      foreach( _exclude ${_excludes} )
        if( ${_src} MATCHES ${_exclude} )
          list( REMOVE_ITEM _files ${_src} )
        endif( )
      endforeach( )
    endforeach( )
  endif( )
  if( NOT _files AND NOT _attributes AND NOT _desktops )
    tde_message_fatal( "no source files found" )
  endif( )

  # prepare x-pot
  foreach( _exclude_pot_file ${TDE_COMMON_TEXTS_POT} ${_exclude_pots} )
    if( "${_exclude_pot_file}" STREQUAL "-" )
      unset( _exclude_pot )
    else()
      if( NOT IS_ABSOLUTE "${_exclude_pot_file}" )
        set( _exclude_pot_file "${CMAKE_CURRENT_SOURCE_DIR}/${_exclude_pot_file}" )
      endif()
      list( APPEND _exclude_pot "-x${_exclude_pot_file}" )
    endif( )
  endforeach( )

  # prepare comment
  if( NOT "${_comment}" STREQUAL "" )
    if( "${_comment}" STREQUAL "-" OR "${_comment}" STREQUAL "all" )
      set( _comment "-c" )
    else( )
      set( _comment "-c${_comment}" )
    endif( )
  endif( )

  # prepare keywords
  unset( _keywords_c )
  unset( _keywords_desktop )
  foreach( _keyword ${_keywords_c_default} ${_keywords_add} )
    if( "${_keyword}" STREQUAL "-" )
      unset( _keywords_c )
      unset( _keyword )
    endif( )
    list( APPEND _keywords_c "-k${_keyword}" )
  endforeach( )
  foreach( _keyword ${_keywords_desktop_default} ${_keywords_add} )
    if( "${_keyword}" STREQUAL "-" )
      unset( _keywords_desktop )
      unset( _keyword )
    endif( )
    if( _keyword )
      list( APPEND _keywords_desktop "${_keyword}" )
    endif( )
  endforeach( )

  # prepare resource files *.kcfg, *.rc and *.ui
  foreach( _src ${_files} )
    if( ${_src} MATCHES "\\.(kcfg|rc|ui)(\\.cmake)?$" )
      set( _src_index 0 )
      set( _src_l10n "${_src}.tde_l10n" )
      list( FIND _files "${_src_l10n}" _src_file_index )
      while( "${_src_file_index}" GREATER -1 )
        set( _src_l10n "${_src}.tde_l10n${_src_index}" )
        list( FIND _files "${_src_l10n}" _src_file_index )
        math( EXPR _src_index "${_src_index}+1" )
      endwhile( )
      tde_l10n_prepare_xml( SOURCE ${_src} TARGET ${_src_l10n} )
      list( REMOVE_ITEM _files ${_src} )
      list( APPEND _files "${_src_l10n}" )
    endif( )
  endforeach( )

  # prepare attributes
  if( _attributes )
    foreach( _attrib ${_attributes} )
      if( ${_attrib} MATCHES "^([^:]+):(.+)$" )
        string( REGEX REPLACE "^([^:]+):(.+)$" "\\1" _attrib_glob ${_attrib} )
        string( REGEX REPLACE "^([^:]+):(.+)$" "\\2" _attrib_spec ${_attrib} )
        file( GLOB_RECURSE _attrib_files
              RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
              ${CMAKE_CURRENT_SOURCE_DIR}/${_attrib_glob}
        )
        if( _excludes )
          foreach( _src ${_attrib_files} )
            foreach( _exclude ${_excludes} )
              if( ${_src} MATCHES ${_exclude} )
                list( REMOVE_ITEM _attrib_files ${_src} )
              endif( )
            endforeach( )
          endforeach( )
        endif( )
        if( _attrib_files )
          list( SORT _attrib_files )
          string( REGEX MATCHALL "[^:]+" _attrib_spec "${_attrib_spec}" )
          foreach( _src ${_attrib_files} )
            set( _src_index 0 )
            set( _src_l10n "${_src}.tde_l10n" )
            list( FIND _files "${_src_l10n}" _src_file_index )
            while( "${_src_file_index}" GREATER -1 )
              set( _src_l10n "${_src}.tde_l10n${_src_index}" )
              list( FIND _files "${_src_l10n}" _src_file_index )
              math( EXPR _src_index "${_src_index}+1" )
            endwhile( )
            tde_l10n_prepare_xmlattr(
              SOURCE ${_src}
              TARGET ${_src_l10n}
              ATTRIBUTES ${_attrib_spec}
            )
            list( APPEND _files "${_src_l10n}" )
          endforeach( )
        endif( )
      endif( )
    endforeach( )
  endif( )

  # prepare tips
  foreach( _src ${_files} )
    if( ${_src} MATCHES "(^|/)tips$" )
      tde_l10n_preparetips( ${_src} )
      list( REMOVE_ITEM _files ${_src} )
      list( APPEND _files "${_src}.tde_l10n" )
    endif( )
  endforeach( )

  # prepare documentation
  foreach( _src ${_files} )
    if( ${_src} MATCHES "\\.(ad|adoc|docbook|[1-8])(\\.cmake)?$" )
      if( ${_src} MATCHES "\\.(ad|adoc)(\\.cmake)?$" )
        set( _doc_format "asciidoc" )
      elseif( ${_src} MATCHES "\\.(docbook)(\\.cmake)?$"  )
        set( _doc_format "docbook" )
      elseif( ${_src} MATCHES "\\.([1-8])(\\.cmake)?$"  )
        set( _doc_format "man" )
      else( )
        set( _doc_format "text" )
      endif( )
      execute_process(
        COMMAND ${PO4A_GETTEXTIZE_EXECUTABLE}
          -f ${_doc_format} -m ${_src}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE _potDoc
      )
      if( _potDoc )
        string( REPLACE "Content-Type: text/plain; charset=CHARSET" "Content-Type: text/plain; charset=UTF-8" _potDoc "${_potDoc}" )
        string( REPLACE "Content-Transfer-Encoding: ENCODING" "Content-Transfer-Encoding: 8bit" _potDoc "${_potDoc}" )
        file( WRITE ${CMAKE_CURRENT_SOURCE_DIR}/${_src}.tde_l10n "${_potDoc}" )
        list( APPEND _pots ${_src}.tde_l10n )
      endif( )
      list( REMOVE_ITEM _files ${_src} )
    endif( )
  endforeach( )

  # pick desktop files - *.desktop, *.directory, *.kcsrc, *.protocol, *.theme, *.themerc and eventsrc
  foreach( _src ${_files} )
    if( ${_src} MATCHES "\\.(desktop|directory|kcsrc|protocol|theme|themerc)(\\.cmake)?$"
        OR ${_src} MATCHES "(^|/)eventsrc(\\.cmake)?$" )
      list( APPEND _desktops ${_src} )
      list( REMOVE_ITEM _files ${_src} )
    endif( )
  endforeach( )

  # pick pot files *.pot
  foreach( _src ${_files} )
    if( ${_src} MATCHES "\\.pot(\\.cmake)?(\\.tde_l10n)?$" )
      list( APPEND _pots ${_src} )
      list( REMOVE_ITEM _files ${_src} )
    endif( )
  endforeach( )

  # add common translator info
  unset( _tranlatorinfo_pot )
  if( _files )
    list( FIND _excludes "_translatorinfo" _translatorinfo_index )
    if( "${_translatorinfo_index}" LESS 0 )
      set( _translatorinfo
        "i18n(\"NAME OF TRANSLATORS\", \"Your names\")\n"
        "i18n(\"EMAIL OF TRANSLATORS\", \"Your emails\")\n"
      )
      file( WRITE ${CMAKE_CURRENT_SOURCE_DIR}/_translatorinfo.tde_l10n ${_translatorinfo} )
      execute_process(
        COMMAND ${KDE_XGETTEXT_EXECUTABLE} --foreign-user -C
          ${_keywords_c} -o - _translatorinfo.tde_l10n
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE _translatorinfo_pot
      )
      file( REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/_translatorinfo.tde_l10n )
    endif( )
  endif( )

  # create translation template
  if( _files )
    execute_process(
      COMMAND ${KDE_XGETTEXT_EXECUTABLE} --foreign-user -C
        ${_comment} ${_keywords_c} ${_exclude_pot} -o - ${_files}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE _pot
    )
    if( _translatorinfo_pot )
      if( _pot )
        set( _pot "${_translatorinfo_pot}\n${_pot}" )
      else( )
        set( _pot "${_translatorinfo_pot}" )
      endif( )
    endif( )
  endif( )

  # process desktop files
  if( _desktops )
    # prepare desktop files
    foreach( _src ${_desktops} )
      tde_l10n_prepare_desktop( ${_src} KEYWORDS ${_keywords_desktop} )
      list( REMOVE_ITEM _desktops ${_src} )
      list( APPEND _desktops "${_src}.tde_l10n" )
    endforeach( )

    # create translation template for desktop files
    execute_process(
      COMMAND ${XGETTEXT_EXECUTABLE} --foreign-user
        --from-code=UTF-8 -C -c -ki18n -o - ${_desktops}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE _potDesktop
    )

    # merge translation templates
    if( _potDesktop )
      if( _pot )
        set( _pot "${_pot}\n${_potDesktop}" )
      else( )
        set( _pot "${_potDesktop}" )
      endif( )
    endif( )
  endif( )

  # join additional pot files
  if( _pots )
    foreach( _extra_pot IN LISTS _pots )
      file( READ ${CMAKE_CURRENT_SOURCE_DIR}/${_extra_pot} _extra_pot )
      if( _extra_pot )
        if( _pot )
          set( _pot "${_pot}\n${_extra_pot}" )
        else( )
          set( _pot "${_extra_pot}" )
        endif( )
      endif( )
    endforeach( )
  endif( )

  # finalize translation template
  if( _pot )

    # set charset and encoding headers
    string( REPLACE "Content-Type: text/plain; charset=CHARSET" "Content-Type: text/plain; charset=UTF-8" _pot "${_pot}" )
    string( REPLACE "Content-Transfer-Encoding: ENCODING" "Content-Transfer-Encoding: 8bit" _pot "${_pot}" )

    # update references for resources to original files and line numbers
    list( FIND _files "extracted-rc.tde_l10n" _extractedRC_index )
    if( "${_extractedRC_index}" GREATER -1
        AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/extracted-rc.tde_l10n )
      file( READ "${CMAKE_CURRENT_SOURCE_DIR}/extracted-rc.tde_l10n" _extractedRC )
      string( REGEX REPLACE "[^\n]" "" _extractedRC_len "${_extractedRC}" )
      string( LENGTH "+${_extractedRC_len}" _extractedRC_len )
      set( _rcPos 0 )
      while( _rcPos LESS ${_extractedRC_len} )
        string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\1" _rcLine "${_extractedRC}" )
        string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\2" _extractedRC "${_extractedRC}" )
        math( EXPR _rcPos "${_rcPos}+1" )
        if( "${_rcLine}" MATCHES "^//i18n: file .* line [0-9]*$" )
          string( REGEX REPLACE "^//i18n: file (.*) line ([0-9]*)$" "\\1:\\2" _rcOrig ${_rcLine} )
        endif( )
        if( "${_rcLine}" MATCHES "^i18n\\(" AND _rcOrig )
          string( REGEX REPLACE "(^|\n)(#:.*) extracted-rc.tde_l10n:${_rcPos}( |\n)" "\\1\\2 ${_rcOrig}\\3" _pot "${_pot}" )
          unset( _rcOrig )
        endif( )
      endwhile( )
    endif( )

    # update references for modified source files (".tde_l10n" extension)
    string( REGEX REPLACE "\\.tde_l10n[0-9]*(:[0-9]+)" "\\1" _pot "${_pot}" )

    # merge unique strings
    string( REGEX REPLACE "\n\n(#[^\n]*\n)*msgid \"\"\nmsgstr \"\"\n(\"[^\n]*\n)*\n" "\n\n" _pot "${_pot}" )
    file( WRITE ${CMAKE_CURRENT_SOURCE_DIR}/extracted-pot.tmp "${_pot}" )
    execute_process(
      COMMAND ${MSGUNIQ_EXECUTABLE}
      INPUT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/extracted-pot.tmp
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE _pot
    )
    file( REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/extracted-pot.tmp )
    string( REGEX REPLACE "(^|\n)#.? #-#-#-#-# [^\n]* #-#-#-#-#\n" "\\1" _pot "${_pot}" )

    # replace the references for _translatorinfo with instructions in the comment
    string( REGEX REPLACE
      "(^|\n)(#:[^\n]*) _translatorinfo:1($|[^\n]*)"
      "\\1#. Instead of a literal translation, add your name to the end of the list (separated by a comma).\n\\2\\3\n#, ignore-inconsistent"
      _pot "${_pot}"
    )
    string( REGEX REPLACE
      "(^|\n)(#:[^\n]*) _translatorinfo:2($|[^\n]*)"
      "\\1#. Instead of a literal translation, add your email to the end of the list (separated by a comma).\n\\2\\3\n#, ignore-inconsistent"
      _pot "${_pot}"
    )
    string( REGEX REPLACE "(^|\n)#:($|\n)" "\\1" _pot "${_pot}" )

    # save translation template
    if( EXISTS "${_dest}${_catalog}.pot" )
      file( READ "${_dest}${_catalog}.pot" _potOrig )
    else( )
      unset( _potOrig )
    endif( )
    if( _potOrig )
      string( REGEX REPLACE "\n\"POT-Creation-Date: [^\"]*\"\n" "" _potOrig "${_potOrig}" )
      string( REGEX REPLACE "\n\"POT-Creation-Date: [^\"]*\"\n" "" _potNew "${_pot}" )
    endif( )
    if( NOT _potOrig OR NOT "${_potNew}" STREQUAL "${_potOrig}" )
      file( WRITE "${_dest}${_catalog}.pot" "${_pot}" )
    endif( )

  endif( _pot )

  # cleanup
  foreach( _file ${_files} ${_desktops} ${_pots} )
    if( "${_file}" MATCHES "\\.tde_l10n[0-9]*$" )
      file( REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/${_file} )
    endif( )
  endforeach( )

endmacro( )


#################################################
#####
##### tde_l10n_preparetips
#####
##### Macro is used to prepare tips file for xgettext
#####

macro( tde_l10n_preparetips _tips )

  tde_l10n_prepare_xml(
    SOURCE ${_tips}
    TAGS html
    C_FORMAT
    PRESERVE entities line-wrap spaces-leading spaces-trailing spaces-multi
  )

endmacro( )


#################################################
#####
##### tde_l10n_prepare_xml
#####
##### The function is used to prepare XML file for xgettext.
##### The default settings are identical to extractrc.
#####

function( tde_l10n_prepare_xml )

  unset( _source )
  unset( _target )
  unset( _context )
  set( _skip_properties "database|associations|populationText" )
  set( _tags "[tT][eE][xX][tT]|title|string|whatsthis|tooltip|label" )
  set( _preserve "line-wrap" "lines-leading" "lines-multi" "spaces-leading" "spaces-trailing" "spaces-multi" )
  set( _no_c_format 1 )
  unset( _directive )
  set( _var _source )

  foreach( _arg ${ARGN} )

    # found directive "SOURCE"
    if( "+${_arg}" STREQUAL "+SOURCE" )
      unset( _source )
      set( _var _source )
      set( _directive 1 )
    endif( )

    # found directive "TARGET"
    if( "+${_arg}" STREQUAL "+TARGET" )
      unset( _target )
      set( _var _target )
      set( _directive 1 )
    endif( )

    # found directive "CONTEXT"
    if( "+${_arg}" STREQUAL "+CONTEXT" )
      unset( _context )
      set( _var _context )
      set( _directive 1 )
    endif( )

    # found directive "SKIP-PROPERTIES"
    if( "+${_arg}" STREQUAL "+SKIP-PROPERTIES" )
      unset( _skip_properties )
      set( _var _skip_properties )
      set( _directive 1 )
    endif( )

    # found directive "TAGS"
    if( "+${_arg}" STREQUAL "+TAGS" )
      unset( _tags )
      set( _var _tags )
      set( _directive 1 )
    endif( )

    # found directive "PRESERVE"
    if( "+${_arg}" STREQUAL "+PRESERVE" )
      unset( _preserve )
      set( _var _preserve )
      set( _directive 1 )
    endif( )

    # found directive "C_FORMAT"
    if( "+${_arg}" STREQUAL "+C_FORMAT" )
      unset( _no_c_format )
      set( _directive 1 )
    endif( )

    # found directive "NO_C_FORMAT"
    if( "+${_arg}" STREQUAL "+NO_C_FORMAT" )
      set( _no_c_format 1 )
      set( _directive 1 )
    endif( )

    # collect data
    if( _directive )
      unset( _directive )
    elseif( _var )
      list( APPEND ${_var} ${_arg} )
    endif( )

  endforeach( )

  # verify source
  if( NOT _source )
    tde_message_fatal( "no source XML file" )
  endif( )
  if( NOT IS_ABSOLUTE "${_source}" )
    set( _source "${CMAKE_CURRENT_SOURCE_DIR}/${_source}" )
  endif( )
  if( NOT _target )
    set( _target "${_source}.tde_l10n" )
  endif( )
  if( NOT IS_ABSOLUTE "${_target}" )
    set( _target "${CMAKE_CURRENT_SOURCE_DIR}/${_target}" )
  endif( )

  # prepare tags to regexp
  string( REPLACE ";" "|" _tags "${_tags}" )
  if( "${_skip_properties}" STREQUAL "-" )
    unset( _skip_properties )
  endif( )
  if( DEFINED _skip_properties )
    string( REPLACE ";" "|" _skip_properties "${_skip_properties}" )
    set( _tags "property|${_tags}" )
  endif( )

  # read file
  file( READ ${_source} _xml_data )
  string( REGEX REPLACE "[^\n]" "" _xml_len ${_xml_data} )
  string( LENGTH "+${_xml_len}" _xml_len )

  # process lines
  set( _xml_pos 0 )
  unset( _xml_l10n )
  unset( _xml_inside )
  unset( _xml_tag_empty )
  unset( _xml_skipped_prop )
  while( _xml_pos LESS ${_xml_len} )
    # pick line
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\1" _xml_line "${_xml_data}" )
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\2" _xml_data "${_xml_data}" )
    math( EXPR _xml_pos "${_xml_pos}+1" )
    set( _xml_newline 1 )

    # process tags on line
    while( _xml_newline OR NOT "${_xml_line}" STREQUAL "" )
      unset( _xml_newline )
      unset( _xml_line_prefix )
      unset( _xml_line_suffix )
      unset( _xml_line_rest )
      if( NOT _xml_inside )
        if( _xml_skipped_prop AND "${_xml_line}" MATCHES "</property>" )
          unset( _xml_skipped_prop )
          string( REGEX MATCH "</property>(.*)" _xml_line "${_xml_line}" )
          string( REGEX REPLACE "^</property>(.*)" "\\1" _xml_line "${_xml_line}" )
        endif( )
        if( NOT _xml_skipped_prop AND "${_xml_line}" MATCHES "<(${_tags})([ \t][^>]*)*>" )
          string( REGEX MATCH "<(${_tags})([ \t][^>]*)*>(.*)" _xml_line "${_xml_line}" )
          string( REGEX MATCH "^<(${_tags})([ \t][^>]*)*>" _xml_attr "${_xml_line}" )
          string( REGEX REPLACE "^<(${_tags})([ \t][^>]*)*>(.*)" "\\3" _xml_line "${_xml_line}" )
          if( "${_xml_attr}" MATCHES "^<property([ \t][^>]*)*>" AND DEFINED _skip_properties )
            if( "${_xml_attr}" MATCHES "[ \t]name=\"(${_skip_properties})\"" )
              set( _xml_skipped_prop 1 )
            endif( )
            set( _xml_line_rest "${_xml_line}" )
            set( _xml_line "" )
          else( )
            set( _xml_inside 1 )
            set( _xml_context "${_context}" )
            if( "${_xml_attr}" MATCHES "[ \t]context=\"([^\"]*)\"" )
              string( REGEX REPLACE ".* context=\"([^\"]*)\".*" "\\1" _xml_context "${_xml_attr}" )
            endif( )
            set( _xml_line_prefix "i18n(" )
            if( _no_c_format )
              set( _xml_line_prefix "${_xml_line_prefix}/* xgettext: no-c-format */" )
            endif( )
            if( _xml_context )
              set( _xml_line_prefix "${_xml_line_prefix}\"${_xml_context}\", " )
            endif( )
            set( _xml_tag_empty 1 )
          endif( )
        else( )
          set( _xml_line "" )
        endif( )
      endif( )

      if( _xml_inside )
        if( "${_xml_line}" MATCHES "</(${_tags})>" )
          unset( _xml_inside )
          string( REGEX REPLACE "</(${_tags})>(.*)" "\\2" _xml_line_rest "${_xml_line}" )
          string( REGEX REPLACE "</(${_tags})>(.*)" "" _xml_line "${_xml_line}" )
          set( _xml_line_suffix ");" )
        endif( )

        string( REGEX REPLACE "\\\\" "\\\\\\\\" _xml_line "${_xml_line}" )
        string( REGEX REPLACE "\\\"" "\\\\\"" _xml_line "${_xml_line}" )
        string( REGEX REPLACE "\t" "\\\\t" _xml_line "${_xml_line}" )
        if( NOT ";${_preserve};" MATCHES ";entities;" )
          string( REGEX REPLACE "&lt;" "<" _xml_line "${_xml_line}" )
          string( REGEX REPLACE "&gt;" ">" _xml_line "${_xml_line}" )
          string( REGEX REPLACE "&amp;" "&" _xml_line "${_xml_line}" )
        endif( )
        if( NOT ";${_preserve};" MATCHES ";spaces-leading;" )
          string( REGEX REPLACE "^ +" "" _xml_line "${_xml_line}" )
        endif( )
        if( NOT ";${_preserve};" MATCHES ";spaces-trailing;" )
          string( REGEX REPLACE " +$" "" _xml_line "${_xml_line}" )
        endif( )
        if( NOT ";${_preserve};" MATCHES ";spaces-multi;" )
          string( REGEX REPLACE "  +" " " _xml_line "${_xml_line}" )
        endif( )

        if( _xml_inside )
          if( ";${_preserve};" MATCHES ";line-wrap;" )
            if( NOT "${_xml_line}" STREQUAL ""
                OR ( ";${_preserve};" MATCHES ";lines-leading;" AND _xml_tag_empty )
                OR ( ";${_preserve};" MATCHES ";lines-multi;" AND NOT _xml_tag_empty ) )
              set( _xml_line "${_xml_line}\\n" )
            endif( )
          elseif( NOT "${_xml_line}" STREQUAL "" AND NOT _xml_tag_empty )
            set( _xml_line " ${_xml_line}" )
          endif( )
        endif( )
        if( NOT "${_xml_line}" STREQUAL "" )
          unset( _xml_tag_empty )
        endif( )
      endif( )

      # drop empty tag on single line
      if( _xml_line_prefix AND _xml_line_suffix AND _xml_tag_empty )
        # skip empty string for translation

      # add current tag to output
      else( )
        set( _xml_l10n "${_xml_l10n}${_xml_line_prefix}" )
        if( NOT "${_xml_line}" STREQUAL "" OR ( _xml_line_suffix AND _xml_tag_empty ) )
          set( _xml_l10n "${_xml_l10n}\"${_xml_line}\"" )
        endif( )
        set( _xml_l10n "${_xml_l10n}${_xml_line_suffix}" )
      endif( )

      # take the rest of the line for processing
      set( _xml_line "${_xml_line_rest}" )
    endwhile( )
    set( _xml_l10n "${_xml_l10n}\n" )
  endwhile( )

  # write file
  file( WRITE ${_target} "${_xml_l10n}" )

endfunction( )


#################################################
#####
##### tde_l10n_prepare_xmlattr
#####
##### The function is used to prepare attributes in XML file
##### for xgettext, comparable to extractattr.
#####

function( tde_l10n_prepare_xmlattr )

  unset( _source )
  unset( _target )
  unset( _context )
  unset( _attribs )
  unset( _directive )
  set( _preserve "line-wrap" "lines-leading" "spaces-leading" "spaces-trailing" "spaces-multi" )
  set( _var _source )

  foreach( _arg ${ARGN} )

    # found directive "SOURCE"
    if( "+${_arg}" STREQUAL "+SOURCE" )
      unset( _source )
      set( _var _source )
      set( _directive 1 )
    endif( )

    # found directive "TARGET"
    if( "+${_arg}" STREQUAL "+TARGET" )
      unset( _target )
      set( _var _target )
      set( _directive 1 )
    endif( )

    # found directive "CONTEXT"
    if( "+${_arg}" STREQUAL "+CONTEXT" )
      unset( _context )
      set( _var _context )
      set( _directive 1 )
    endif( )

    # found directive "ATTRIBUTES"
    if( "+${_arg}" STREQUAL "+ATTRIBUTES" )
      unset( _attribs )
      set( _var _attribs )
      set( _directive 1 )
    endif( )

    # found directive "PRESERVE"
    if( "+${_arg}" STREQUAL "+PRESERVE" )
      unset( _preserve )
      set( _var _preserve )
      set( _directive 1 )
    endif( )

    # collect data
    if( _directive )
      unset( _directive )
    elseif( _var )
      list( APPEND ${_var} ${_arg} )
    endif( )

  endforeach( )

  # verify source
  if( NOT _source )
    tde_message_fatal( "no source XML file" )
  endif( )
  if( NOT IS_ABSOLUTE "${_source}" )
    set( _source "${CMAKE_CURRENT_SOURCE_DIR}/${_source}" )
  endif( )
  if( NOT _target )
    set( _target "${_source}.tde_l10n" )
  endif( )
  if( NOT IS_ABSOLUTE "${_target}" )
    set( _target "${CMAKE_CURRENT_SOURCE_DIR}/${_target}" )
  endif( )

  # prepare tags to regexp
  if( NOT _attribs )
    tde_message_fatal( "no attributes specified" )
  endif( )
  unset( _tags )
  foreach( _attrib ${_attribs} )
    string( REGEX REPLACE "^([^,]+),.*" "\\1" _tag "${_attrib}" )
    list( APPEND _tags "${_tag}" )
  endforeach( )
  list( REMOVE_DUPLICATES _tags )
  string( REPLACE ";" "|" _tags "${_tags}" )

  # read file
  file( READ ${_source} _xml_data )
  string( REGEX REPLACE "[^\n]" "" _xml_len ${_xml_data} )
  string( LENGTH "+${_xml_len}" _xml_len )

  # process lines
  set( _xml_pos 0 )
  unset( _xml_l10n )
  unset( _xml_inside_tag )
  unset( _xml_inside_attrib )
  unset( _xml_attrib_empty )
  while( _xml_pos LESS ${_xml_len} )
    # pick line
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\1" _xml_line "${_xml_data}" )
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\2" _xml_data "${_xml_data}" )
    math( EXPR _xml_pos "${_xml_pos}+1" )
    set( _xml_newline 1 )

    # process tags on line
    while( _xml_newline OR NOT "${_xml_line}" STREQUAL "" )
      unset( _xml_line_rest )
      if( NOT _xml_inside_tag )
        if( "${_xml_line}" MATCHES "<(${_tags})([ \t\n][^>]*|$)" )
          set( _xml_inside_tag 1 )
          string( REGEX MATCH "<(${_tags})([ \t\n][^>]*|$)(.*)" _xml_line "${_xml_line}" )
          string( REGEX REPLACE "^<(${_tags})[ \t\n]*.*" "\\1" _xml_tag "${_xml_line}" )
          string( REGEX REPLACE "^<(${_tags})[ \t\n]*" "" _xml_line "${_xml_line}" )
          unset( _tag_attribs )
          foreach( _attrib ${_attribs} )
            if( "${_attrib}" MATCHES "^${_xml_tag}," )
              string( REGEX REPLACE "^([^,]+),([^,]+),?(.*)" "\\2" _attrib "${_attrib}" )
              list( APPEND _tag_attribs "${_attrib}" )
            endif( )
          endforeach( )
          string( REPLACE ";" "|" _tag_attribs "${_tag_attribs}" )
          unset( _xml_inside_attrib )
        else( )
          set( _xml_line "" )
        endif( )
      endif( )

      if( _xml_inside_tag )
        if( "${_xml_line}" MATCHES "^(([ \t]*[^>=]+=\"[^\"]*\")*)[ \t]*/?>" )
          unset( _xml_inside_tag )
          string( REGEX REPLACE "^(([ \t]*[^>=]+=\"[^\"]*\")*)[ \t]*/?>(.*)" "\\3" _xml_line_rest "${_xml_line}" )
          string( REGEX REPLACE "^(([ \t]*[^>=]+=\"[^\"]*\")*)[ \t]*/?>(.*)" "\\1" _xml_line "${_xml_line}" )
        endif( )

        # process attribs on line
        set( _xml_attrib_line "${_xml_line}" )
        while( _xml_newline OR NOT "${_xml_attrib_line}" STREQUAL "" )
          unset( _xml_newline )
          unset( _xml_line_prefix )
          unset( _xml_line_suffix )
          unset( _xml_attrib_line_rest )

          if( NOT _xml_inside_attrib )
            if( "${_xml_attrib_line}" MATCHES "(^|[ \t]+)(${_tag_attribs})=\"" )
              set( _xml_inside_attrib 1 )
              string( REGEX MATCH "(^|[ \t]+)(${_tag_attribs})=\"(.*)" _xml_attrib_line "${_xml_attrib_line}" )
              string( REGEX REPLACE "^[ \t]*(${_tag_attribs})=\".*" "\\1" _xml_attrib "${_xml_attrib_line}" )
              string( REGEX REPLACE "^[ \t]*(${_tag_attribs})=\"" "" _xml_attrib_line "${_xml_attrib_line}" )
              set( _xml_context "${_context}" )
              foreach( _attrib ${_attribs} )
                if( "${_attrib}" MATCHES "^${_xml_tag},${_xml_attrib}," )
                  string( REGEX REPLACE "^([^,]+),([^,]+),?(.*)" "\\3" _xml_context "${_attrib}" )
                endif( )
              endforeach( )
              set( _xml_line_prefix "i18n(" )
              if( _xml_context )
                set( _xml_line_prefix "${_xml_line_prefix}\"${_xml_context}\", " )
              endif( )
              set( _xml_attrib_empty 1 )
            else( )
              set( _xml_attrib_line "" )
            endif( )
          endif( )

          if( _xml_inside_attrib )
            if( "${_xml_attrib_line}" MATCHES "\"" )
              unset( _xml_inside_attrib )
              string( REGEX REPLACE "\"(.*)" "\\1" _xml_attrib_line_rest "${_xml_attrib_line}" )
              string( REGEX REPLACE "\"(.*)" "" _xml_attrib_line "${_xml_attrib_line}" )
              set( _xml_line_suffix ");" )
            endif( )

            string( REGEX REPLACE "\\\\" "\\\\\\\\" _xml_attrib_line "${_xml_attrib_line}" )
            string( REGEX REPLACE "\\\"" "\\\\\"" _xml_attrib_line "${_xml_attrib_line}" )
            string( REGEX REPLACE "\t" "\\\\t" _xml_attrib_line "${_xml_attrib_line}" )
            if( NOT ";${_preserve};" MATCHES ";entities;" )
              string( REGEX REPLACE "&lt;" "<" _xml_attrib_line "${_xml_attrib_line}" )
              string( REGEX REPLACE "&gt;" ">" _xml_attrib_line "${_xml_attrib_line}" )
              string( REGEX REPLACE "&amp;" "&" _xml_attrib_line "${_xml_attrib_line}" )
            endif( )
            if( NOT ";${_preserve};" MATCHES ";spaces-leading;" )
              string( REGEX REPLACE "^ +" "" _xml_attrib_line "${_xml_attrib_line}" )
            endif( )
            if( NOT ";${_preserve};" MATCHES ";spaces-trailing;" )
              string( REGEX REPLACE " +$" "" _xml_attrib_line "${_xml_attrib_line}" )
            endif( )
            if( NOT ";${_preserve};" MATCHES ";spaces-multi;" )
              string( REGEX REPLACE "  +" " " _xml_attrib_line "${_xml_attrib_line}" )
            endif( )

            if( NOT "${_xml_inside_attrib}" STREQUAL "" )
              if( ";${_preserve};" MATCHES ";line-wrap;" )
                if( ";${_preserve};" MATCHES ";lines-leading;"
                    OR NOT "${_xml_attrib_line}" STREQUAL "" OR NOT _xml_attrib_empty )
                  set( _xml_attrib_line "${_xml_attrib_line}\\n" )
                endif( )
              elseif( NOT "${_xml_attrib_line}" STREQUAL "" AND NOT _xml_attrib_empty )
                set( _xml_attrib_line " ${_xml_attrib_line}" )
              endif( )
            endif( )
            if( NOT "${_xml_attrib_line}" STREQUAL "" )
              unset( _xml_attrib_empty )
            endif( )
          endif( )

          # drop empty attrib on single line
          if( _xml_line_prefix AND _xml_line_suffix AND _xml_attrib_empty )
            # skip empty translation

          # add current attrib to output
          else( )
            set( _xml_l10n "${_xml_l10n}${_xml_line_prefix}" )
            if( NOT "${_xml_attrib_line}" STREQUAL "" OR ( _xml_line_suffix AND _xml_attrib_empty ) )
              set( _xml_l10n "${_xml_l10n}\"${_xml_attrib_line}\"" )
            endif( )
            set( _xml_l10n "${_xml_l10n}${_xml_line_suffix}" )
          endif( )

          # take the rest of the line for processing
          set( _xml_attrib_line "${_xml_attrib_line_rest}" )
        endwhile( )
      endif( )

      # take the rest of the line for processing
      unset( _xml_newline )
      set( _xml_line "${_xml_line_rest}" )
    endwhile( )
    set( _xml_l10n "${_xml_l10n}\n" )
  endwhile( )

  # write file
  file( WRITE ${_target} "${_xml_l10n}" )

endfunction( )


#################################################
#####
##### tde_l10n_prepare_desktop
#####
##### The function is used to prepare desktop style file
##### for xgettext.
#####
##### Note: gettext >= 0.19 includes support for extracting
##### strings from desktop files, but there are some drawbacks.
#####

function( tde_l10n_prepare_desktop )

  unset( _source )
  unset( _target )
  unset( _keywords )
  unset( _directive )
  set( _var _source )

  foreach( _arg ${ARGN} )

    # found directive "SOURCE"
    if( "+${_arg}" STREQUAL "+SOURCE" )
      unset( _source )
      set( _var _source )
      set( _directive 1 )
    endif( )

    # found directive "TARGET"
    if( "+${_arg}" STREQUAL "+TARGET" )
      unset( _target )
      set( _var _target )
      set( _directive 1 )
    endif( )

    # found directive "KEYWORDS"
    if( "+${_arg}" STREQUAL "+KEYWORDS" )
      unset( _keywords )
      set( _var _keywords )
      set( _directive 1 )
    endif( )

    # collect data
    if( _directive )
      unset( _directive )
    elseif( _var )
      list( APPEND ${_var} ${_arg} )
    endif( )

  endforeach( )

  # verify source
  if( NOT _source )
    tde_message_fatal( "no source desktop file" )
  endif( )
  if( NOT IS_ABSOLUTE "${_source}" )
    set( _source "${CMAKE_CURRENT_SOURCE_DIR}/${_source}" )
  endif( )
  if( NOT _target )
    set( _target "${_source}.tde_l10n" )
  endif( )
  if( NOT IS_ABSOLUTE "${_target}" )
    set( _target "${CMAKE_CURRENT_SOURCE_DIR}/${_target}" )
  endif( )

  # prepare keywords
  if( NOT _keywords )
    tde_message_fatal( "the keywords whose strings are to be extracted are not specified" )
  endif( )
  string( REPLACE ";" "|" _keywords_match "(${_keywords})" )

  # read file
  file( READ ${_source} _desktop_data )
  string( REGEX REPLACE "[^\n]" "" _desktop_len ${_desktop_data} )
  string( LENGTH "+${_desktop_len}" _desktop_len )

  # process lines
  set( _desktop_pos 0 )
  unset( _desktop_l10n )
  while( _desktop_pos LESS ${_desktop_len} )
    # pick line
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\1" _desktop_line "${_desktop_data}" )
    string( REGEX REPLACE "^([^\n]*)\n(.*)" "\\2" _desktop_data "${_desktop_data}" )
    math( EXPR _desktop_pos "${_desktop_pos}+1" )

    # process line
    if( "${_desktop_line}" MATCHES "^${_keywords_match}[ ]*=" )
      string( REGEX REPLACE "\\\"" "\\\\\"" _desktop_line "${_desktop_line}" )
      string( REGEX REPLACE "^${_keywords_match}[ ]*=[ ]*([^\n]*)" "/*\\1*/i18n(\"\\2\");" _desktop_line "${_desktop_line}" )
    else( )
      set( _desktop_line "" )
    endif( )
    set( _desktop_l10n "${_desktop_l10n}${_desktop_line}\n" )
  endwhile( )

  # write file
  file( WRITE ${_target} "${_desktop_l10n}" )

endfunction( )
