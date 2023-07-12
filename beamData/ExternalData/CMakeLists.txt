# Data files.

FILE(GLOB data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION beamData/ExternalData)
