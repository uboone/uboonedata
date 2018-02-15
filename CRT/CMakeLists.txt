# Data files.

FILE(GLOB data *.txt )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/Calibration)
