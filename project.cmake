
# Copyright (C) 2014 Dmitry Stepanov <dmitry@stepanov.lv>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA

# Set BUILD_CROSS_COMPILE variable if we're cross-compiling
if( NOT CMAKE_HOST_SYSTEM STREQUAL CMAKE_SYSTEM )
        set( BUILD_CROSS_COMPILE ON )
endif()

# Set compiler trait variable (BUILD_CXX_COMPILER_*).
# Learned from http://stackoverflow.com/questions/10046114/in-cmake-how-can-i-test-if-the-compiler-is-clang
if( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
        set( BUILD_CXX_COMPILER_CLANG ON )
elseif( CMAKE_CXX_COMPILER_ID STREQUAL "GNU" )
        set( BUILD_CXX_COMPILER_GNU ON )
elseif( CMAKE_CXX_COMPILER_ID STREQUAL "Intel" )
        SET( BUILD_CXX_COMPILER_INTEL ON )
elseif( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" )
        SET( BUILD_CXX_COMPILER_MSVC ON )
endif()

# We should use macro() here so that variable scope is not
# affected. Otherwise, project() command stores PROJECT_*
# variables into function's scope.
macro( project_cxx Name )
        project( "${Name}" CXX )
endmacro()

# Prints information about current project. Should be the last
# macro invoked in the lists file which defines the project.
function( project_end )
	show_separator()
	message( STATUS "Project ${PROJECT_NAME} (${PROJECT_SOURCE_DIR})" )
        message( STATUS "    Build configuration = ${CMAKE_BUILD_TYPE}" )
        message( STATUS "    Target system = ${CMAKE_SYSTEM}" )
        message( STATUS "    Target system name = ${CMAKE_SYSTEM_NAME}" )
        message( STATUS "    Target system version = ${CMAKE_SYSTEM_VERSION}" )
        message( STATUS "    Target system processor = ${CMAKE_SYSTEM_PROCESSOR}" )
endfunction()

function( show_separator )
	message( STATUS "=====================================" )
endfunction()

include( "${CMAKE_CURRENT_LIST_DIR}/targets.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/sources.cmake" )

