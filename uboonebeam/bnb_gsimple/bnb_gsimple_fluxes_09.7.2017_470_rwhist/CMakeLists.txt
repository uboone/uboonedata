# Data files.

FILE(GLOB data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/uboonebeam/bnb_gsimple/bnb_gsimple_fluxes_09.7.2017_470_rwhist)
