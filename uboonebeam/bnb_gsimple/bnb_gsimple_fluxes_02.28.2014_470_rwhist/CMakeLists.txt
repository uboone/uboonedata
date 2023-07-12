# Data files.

FILE(GLOB data *.root )

message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION uboonebeam/bnb_gsimple/bnb_gsimple_fluxes_02.28.2014_470_rwhist)
