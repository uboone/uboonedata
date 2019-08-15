# Data files.

LIST(APPEND data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/DiffusionData)
