# CMakeLists.txt file for uboonedata

#  This simply copies files into an install directory - there is no build

CMAKE_MINIMUM_REQUIRED (VERSION 3.19)

project(uboonedata VERSION 09.31.00 LANGUAGES NONE)

# cetbuildtools contains our cmake modules
find_package(cetbuildtools REQUIRED)

include(CetCMakeEnv)

# uboonedata has no architecture dependence
cet_cmake_env( noarch )

# source code
add_subdirectory(scripts)
add_subdirectory(CRT)
add_subdirectory(Calibration)
add_subdirectory(PandoraData)
add_subdirectory(WireCellData)
add_subdirectory(Response)
add_subdirectory(SpaceCharge)
add_subdirectory(beamData)
add_subdirectory(uboonebeam)
add_subdirectory(systematics)
add_subdirectory(ups)

# packaging utility
include(UseCPack)


