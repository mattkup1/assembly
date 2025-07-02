cmake_minimum_required(VERSION 3.5)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(JCT_targil)

# Add the assembly file to the build
set_source_files_properties(mytargil.S PROPERTIES LANGUAGE ASM)