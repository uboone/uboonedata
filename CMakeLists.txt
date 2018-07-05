# CMakeLists.txt file for uboonedata

#  This simply copies files into an install directory - there is no build

CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

project(uboonedata NONE)

# cetbuildtools contains our cmake modules
set( CETBUILDTOOLS_VERSION $ENV{CETBUILDTOOLS_VERSION} )
if( NOT CETBUILDTOOLS_VERSION )
  message( FATAL_ERROR "ERROR: setup cetbuildtools to get the cmake modules" )
endif()
set( CMAKE_MODULE_PATH $ENV{CETBUILDTOOLS_DIR}/Modules ${CMAKE_MODULE_PATH} )

# Add any modules from this source necessary for building
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Modules ${CMAKE_MODULE_PATH} )

include(CetCMakeEnv)

# uboonedata has no architecture dependence
cet_cmake_env( noarch )

# Make sure cetbuildtools is set up (version is minimum)
find_ups_product(cetbuildtools v4_14_01)

# source code
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


