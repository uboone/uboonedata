# Data files.

FILE(GLOB data *.root )
LIST(APPEND data quietWires.txt )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/Response)
