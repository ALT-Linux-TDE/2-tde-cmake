add_library( @_target@ @_type@ IMPORTED )

set_target_properties( @_target@ PROPERTIES
  INTERFACE_COMPILE_FEATURES "@_cxx_features@"
  IMPORTED_LINK_INTERFACE_LIBRARIES "@_shared_libs@"
  IMPORTED_LOCATION "@_location@"
  IMPORTED_SONAME "@_soname@" )

