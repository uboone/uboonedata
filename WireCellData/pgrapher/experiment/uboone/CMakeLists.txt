# Wire-Cell Data files, required at runtime.

FILE(GLOB data *.jsonnet *.fcl )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/WireCellData/pgrapher/experiment/uboone)
