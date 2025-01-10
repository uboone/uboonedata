# CMakeLists.txt file for uboonedata

#  This simply copies files into an install directory - there is no build

CMAKE_MINIMUM_REQUIRED (VERSION 3.20 FATAL_ERROR)

find_package(cetmodules REQUIRED)
project(uboonedata VERSION 10.02.02.01 LANGUAGES NONE)

include(CetCMakeEnv)
cet_cmake_env()

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
add_subdirectory(searchingfornues)
add_subdirectory(systematics)
add_subdirectory(genie)
add_subdirectory(ParticleID)
add_subdirectory(ppfx)
add_subdirectory(SinglePhotonAnalysis)
add_subdirectory(NuGraph)

# packaging utility

cet_cmake_config()
