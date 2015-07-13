
cmake_minimum_required (VERSION 2.6) 
project (vectoradd)

add_definitions(-Wall -std=c++11)
add_definitions(-O3)

set( DEVICE "cpu"  CACHE STRING "Options: [ cpu | phi | gpu ]")
set( TYPE "float"  CACHE STRING "Options: [ float | int ]")
set( AUTOVEC "yes"  CACHE STRING "Options: [ yes | no ]")

#############################Selecting Device###############################
if(DEVICE STREQUAL "gpu")
    message("Device: gpu")
    add_definitions(-D__GPU__)
elseif(DEVICE STREQUAL "phi")
    message("Device: phi")
    add_definitions(-D__PHI__)
elseif(DEVICE STREQUAL "cpu")
    message("Default device: cpu")
    add_definitions(-D__CPU__)
elseif(DEVICE STREQUAL "fpga")
    message("Default device: fpga")
    add_definitions(-D__FPGA__)
else(DEVICE STREQUAL "cpu")
    message("Default device: cpu")
    add_definitions(-D__CPU__)
endif(DEVICE STREQUAL "gpu")
###########################################################

#############################Enabling Auto vectorisation###############################
if(AUTOVEC STREQUAL "yes")
    message("Autovec: yes")
    add_definitions()
elseif(AUTOVEC STREQUAL "no")
    message("Autovec: no")
    add_definitions(-D__NO_VEC__)
else(AUTOVEC STREQUAL "yes")
    message("Autovec: yes")
    add_definitions()
endif(AUTOVEC STREQUAL "yes")
###########################################################

#############################Selecting Type###############################
if(TYPE STREQUAL "float")
    message("Type: float")
    add_definitions(-D__FLOAT__)
elseif(TYPE STREQUAL "int")
    message("Type: int")
    add_definitions(-D__INT__)
else(TYPE STREQUAL "float")
    message("Type: float")
    add_definitions(-D__FLOAT__)
endif(TYPE STREQUAL "float")
###########################################################

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Setting build type to Release")
    set(CMAKE_BUILD_TYPE "Release")
endif()

# Determine machine bitness
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BITNESS 64)
else()
    set(BITNESS 32)
endif()

# Find OpenCL include directories
find_path( OPENCL_INCLUDES
        NAMES CL/cl.h OpenCL/cl.h
    HINTS
        $ENV{AMDAPPSDKROOT}/include
        $ENV{INTELOCLSDKROOT}/include
        $ENV{CUDA_PATH}/include
        $ENV{OPENCL_ROOT}/include
        PATHS
        /usr/include
        /usr/local/include
    )

# Find OpenCL libraries
if(BITNESS EQUAL 64)
    find_library( OPENCL_LIBS
        NAMES OpenCL
        HINTS
            $ENV{AMDAPPSDKROOT}/lib
            $ENV{INTELOCLSDKROOT}/lib
            $ENV{CUDA_PATH}/lib
            $ENV{OPENCL_ROOT}/lib
        PATH_SUFFIXES x86_64 x64
        PATHS
            /usr/lib64
            /usr/lib
            /usr/local/lib
    )
elseif(BITNESS EQUAL 32)
    find_library( OPENCL_LIBS
        NAMES OpenCL
        HINTS
            $ENV{AMDAPPSDKROOT}/lib
            $ENV{INTELOCLSDKROOT}/lib
            $ENV{CUDA_PATH}/lib
            $ENV{OPENCL_ROOT}/lib
        PATH_SUFFIXES x86 Win32
        PATHS
            /usr/lib32
            /usr/lib
            /usr/local/lib
    )
endif()

if( (NOT OPENCL_INCLUDES) OR (NOT OPENCL_LIBS) )
    message( FATAL_ERROR "Could not find OpenCL include/libs. Set OPENCL_ROOT to your OpenCL SDK. Download AMD APP SDK "
            "http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/ for x86/x64 "
            "or pocl http://pocl.sourceforge.net/ for ARM systems" )
else()
    message(STATUS "Selected OpenCL includes from ${OPENCL_INCLUDES}")
    message(STATUS "Selected OpenCL lib ${OPENCL_LIBS}")
endif()


include_directories(.)
include_directories(CL/)

add_executable(vectoradd
            host.cpp)

#target_link_libraries(smallBench ${OPENCL_LIBS})


if(CMAKE_SYSTEM_NAME MATCHES "Linux")
    target_link_libraries(vectoradd OpenCL)
endif(CMAKE_SYSTEM_NAME MATCHES "Linux")

