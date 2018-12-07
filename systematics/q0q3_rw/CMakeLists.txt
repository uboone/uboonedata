# Data files.

FILE(GLOB data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/systematics/q0q3_rw)
