# Data files.

FILE(GLOB data *.model )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/ProtonID)
