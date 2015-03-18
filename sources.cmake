
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

# Adds one or more preprocessor constants to the source file.
# Definition format for constants with no value: <CONSTANT_NAME>.
# Definition format for constants with a value: <CONSTANT_NAME>=<VALUE>.
# synopsis: fn( SourceFile Definition [Definition...] )
function( source_add_compile_definition SourceFile Definition )
    get_source_file_property( SOURCE_COMPILE_DEFINITIONS "${SourceFile}" COMPILE_DEFINITIONS )

    if( NOT SOURCE_COMPILE_DEFINITIONS )
        set( SOURCE_COMPILE_DEFINITIONS "" )
    endif()

    foreach( DEF_NR RANGE 2 ${ARGC} )
        math( EXPR ARG_INDEX "${DEF_NR} - 1" )
        list( APPEND SOURCE_COMPILE_DEFINITIONS "${ARGV${ARG_INDEX}}" )
    endforeach()

    set_source_files_properties( "${SourceFile}" PROPERTIES COMPILE_DEFINITIONS "${SOURCE_COMPILE_DEFINITIONS}" )
endfunction()

# Adds one or more compile flags to the source file.
# synopsis: fn( SourceFile CompileFlag [CompileFlag...] )
function( source_add_compile_flag SourceFile Flag )
    get_source_file_property( SOURCE_COMPILE_FLAGS "${SourceFile}" COMPILE_FLAGS )

    if( NOT SOURCE_COMPILE_FLAGS )
        set( SOURCE_COMPILE_FLAGS "" )
    endif()

    foreach( FLAG_NR RANGE 2 ${ARGC} )
        math( EXPR ARG_INDEX "${FLAG_NR} - 1" )
        list( APPEND SOURCE_COMPILE_FLAGS "${ARGV${ARG_INDEX}}" )
    endforeach()

    set_source_files_properties( "${SourceFile}" PROPERTIES COMPILE_FLAGS "${SOURCE_COMPILE_FLAGS}" )
endfunction()

