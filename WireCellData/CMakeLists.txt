# Wire-Cell Data files, required at runtime.

FILE(GLOB data *.bz2 )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/WireCellData)

