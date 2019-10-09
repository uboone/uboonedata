# Data files.

FILE(GLOB data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/ParticleID)
