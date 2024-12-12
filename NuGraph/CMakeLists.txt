# Data files.

FILE(GLOB data *.xml *.pt )

install(FILES ${data} DESTINATION NuGraph)
