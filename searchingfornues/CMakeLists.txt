# searchingfornues Data files, required at runtime.

FILE(GLOB data *.model )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION searchingfornues)
