# SinglePhotonAnalysis Data files, required at runtime.

FILE(GLOB data *.root )
LIST(APPEND data MCC9_channel_list.txt )


message(STATUS "Data files ${data}")

install(FILES ${data} DESTINATION SinglePhotonAnalysis)
