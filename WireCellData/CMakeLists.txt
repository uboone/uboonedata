# Wire-Cell Data files, required at runtime.

FILE(GLOB data *.bz2 *.jsonnet )

message(STATUS "Data files ${data}")

#install(FILES ${data} DESTINATION ${product}/${version}/WireCellData)

install_wp(LIST ${data})

add_subdirectory(nfspl1)
add_subdirectory(simulation)
add_subdirectory(pgrapher)
