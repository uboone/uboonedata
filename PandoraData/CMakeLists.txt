# Pandora Data files, required at runtime.

FILE(GLOB data *.xml )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION PandoraData)

