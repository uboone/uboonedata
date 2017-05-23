# Data files.

FILE(GLOB data dQdx*.txt )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/Calibration)
