# Data files.

FILE(GLOB data dQdx*.txt )
LIST(APPEND data calibration_mcc8.4_v1.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/Calibration)
