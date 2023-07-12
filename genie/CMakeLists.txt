# Data files.

FILE(GLOB data *.xml )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION genie)

