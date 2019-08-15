# Data files.

LIST(APPEND data 2019_08_15_sigma_map.root)

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/DiffusionData)
