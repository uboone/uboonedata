# SinglePhotonAnalysis Data files, required at runtime.

FILE(GLOB data *.root )
LIST(APPEND data *.txt )


message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION ${product}/${version}/SinglePhotonAnalysis)
