# Data files.

FILE(GLOB data *.xml )

install(FILES ${data} DESTINATION ${product}/${version}/ppfx)
