# Data files.

FILE(GLOB data *.xml )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION genie)


# ExtGen (ubsim/ExtGen) total cross section splines and tables, one
# directory per external generator. Found by GENIEGen through the XSecTable
# fcl parameter, e.g. "genie/gibuu/<file>.xml" (uboonedata is on FW_SEARCH_PATH).
FILE(GLOB gibuu_data gibuu/*.xml gibuu/*.txt )
if( gibuu_data )
  install(FILES ${gibuu_data} DESTINATION ${product}/${version}/genie/gibuu)
endif()
FILE(GLOB nuwro_data nuwro/*.xml nuwro/*.txt )
if( nuwro_data )
  install(FILES ${nuwro_data} DESTINATION ${product}/${version}/genie/nuwro)
endif()
