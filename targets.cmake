
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

# Prints essential compilation / linking options of the specified target.
function( show_target_details TargetName )
    get_target_property( TARG_COMPILE_FLAGS "${TargetName}" COMPILE_FLAGS )
    get_target_property( TARG_LINK_FLAGS "${TargetName}" LINK_FLAGS )
    get_target_property( TARG_COMPILE_DEFINITIONS "${TargetName}" COMPILE_DEFINITIONS )
    get_target_property( TARG_INCLUDE_DIRECTORIES "${TargetName}" INCLUDE_DIRECTORIES )

    show_separator()
    message( STATUS "Target ${TargetName} (${PROJECT_NAME})" )

    if( TARG_COMPILE_FLAGS )
        message( STATUS "    Compile flags = ${TARG_COMPILE_FLAGS}" )
    else()
        message( STATUS "    Compile flags = n/a" )
    endif()

    if( TARG_COMPILE_DEFINITIONS )
        message( STATUS "    Compile definitions = ${TARG_COMPILE_DEFINITIONS}" )
    else()
        message( STATUS "    Compile definitions = n/a" )
    endif()

    if( TARG_INCLUDE_DIRECTORIES )
        message( STATUS "    Include directories = ${TARG_INCLUDE_DIRECTORIES}" )
    else()
        message( STATUS "    Include directories = n/a" )
    endif()

    if( TARG_LINK_FLAGS )
        message( STATUS "    Link flags = ${TARG_LINK_FLAGS}" )
    else()
        message( STATUS "    Link flags = n/a" )
    endif()
endfunction()

# Adds one or more include directories to the target.
# Synopsis: fn( TargetName IncludeDir [IncludeDir ...] )
function( target_add_include_directory TargetName IncludeDir )
    get_target_property( TARG_INCLUDE_DIRECTORIES "${TargetName}" INCLUDE_DIRECTORIES )

    if( NOT TARG_INCLUDE_DIRECTORIES )
        set( TARG_INCLUDE_DIRECTORIES "" )
    endif()

    foreach( INCLUDE_NR RANGE 2 ${ARGC} )
        math( EXPR ARG_INDEX "${INCLUDE_NR} - 1" )
        list( APPEND TARG_INCLUDE_DIRECTORIES "${ARGV${ARG_INDEX}}" )
    endforeach()

    set_target_properties( "${TargetName}" PROPERTIES INCLUDE_DIRECTORIES "${TARG_INCLUDE_DIRECTORIES}" )
endfunction()

# Adds one or more preprocessor constants to the target.
# Definition format for constants with no value: <CONSTANT_NAME>.
# Definition format for constants with a value: <CONSTANT_NAME>=<VALUE>.
# synopsis: fn( TargetName Definition [Definition...] )
function( target_add_compile_definition TargetName Definition )
    get_target_property( TARG_COMPILE_DEFINITIONS "${TargetName}" COMPILE_DEFINITIONS )

    if( NOT TARG_COMPILE_DEFINITIONS )
        set( TARG_COMPILE_DEFINITIONS "" )
    endif()

    foreach( DEF_NR RANGE 2 ${ARGC} )
        math( EXPR ARG_INDEX "${DEF_NR} - 1" )
        list( APPEND TARG_COMPILE_DEFINITIONS "${ARGV${ARG_INDEX}}" )
    endforeach()

    set_target_properties( "${TargetName}" PROPERTIES COMPILE_DEFINITIONS "${TARG_COMPILE_DEFINITIONS}" )
endfunction()

# Adds one or more compilation flags to the target.
# synopsis: fn( TargetName CompileFlag [CompileFlag...] )
function( target_add_compile_flag TargetName CompileFlag )
    get_target_property( TARG_COMPILE_FLAGS "${TargetName}" COMPILE_FLAGS )

    foreach( FLAG_NR RANGE 2 ${ARGC} )
        math( EXPR ARG_INDEX "${FLAG_NR} - 1" )
        set( CompileFlag "${ARGV${ARG_INDEX}}" )

        if( NOT TARG_COMPILE_FLAGS )
            set( TARG_COMPILE_FLAGS "${CompileFlag}" )
        else()
            set( TARG_COMPILE_FLAGS "${TARG_COMPILE_FLAGS} ${CompileFlag}" )
        endif()
    endforeach()

    set_target_properties( "${TargetName}" PROPERTIES COMPILE_FLAGS "${TARG_COMPILE_FLAGS}" )
endfunction()

# Adds one or more link flags to the target.
# synopsis: fn( TargetName LinkFlag [LinkFlag...] )
function( target_add_link_flag TargetName LinkFlag )
        get_target_property( TARG_LINK_FLAGS "${TargetName}" LINK_FLAGS )

        foreach( FLAG_NR RANGE 2 ${ARGC} )
                math( EXPR ARG_INDEX "${FLAG_NR} - 1" )
                set( LinkFlag "${ARGV${ARG_INDEX}}" )

                if( NOT TARG_LINK_FLAGS )
                        set( TARG_LINK_FLAGS "${LinkFlag}" )
                else()
                        set( TARG_LINK_FLAGS "${TARG_LINK_FLAGS} ${LinkFlag}" )
                endif()
        endforeach()

        set_target_properties( "${TargetName}" PROPERTIES LINK_FLAGS "${TARG_LINK_FLAGS}" )
endfunction()

# Adds target that generates output. Target's associated commands are
# run only if output is not already present or a dependency is out of
# date. This is a hybrid add_custom_command() + add_custom_target()
# to workaround add_custom_command() conflicts for generated files in
# concurrent build environment.
# See http://www.cmake.org/pipermail/cmake/2008-October/024491.html for
# more details.
#
# Synopsis:
#   add_custom_output_command(
#     Name [ALL] 
#     OUTPUT output1 [output2 ...]
#     COMMAND command1 [args1...]
#     [COMMAND command2 [args2...] ...]
#     [MAIN_DEPENDENCY depend]
#     [DEPENDS [depends...]]
#     [IMPLICIT_DEPENDS <lang1> depend1
#                      [<lang2> depend2] ...]
#     [WORKING_DIRECTORY dir]
#     [COMMENT comment] [VERBATIM])
#
# For meaning of individual arguments refer to docs of add_custom_command()
# and add_custom_target().
#
# NOTE: Make sure all targets / custom commands that depend on OUTPUT or
# this target's Name list both OUTPUT and Name in DEPENDS. Listing Name
# fixes parallel build issues and listing OUTPUT makes targets re-generate
# only if dependent file changes.
function( add_custom_output_target )
        set( REV_ARGV ${ARGV} )
        list( REVERSE REV_ARGV )

        # VERBATIM
        list( GET REV_ARGV 0 ARG_VALUE )
        if( ARG_VALUE STREQUAL VERBATIM )
            set( IN_VERBATIM TRUE )
            list( REMOVE_AT REV_ARGV 0 )
        else()
            set( IN_VERBATIM FALSE )
        endif()

        # COMMENT
        set( IN_COMMENT "" )
        list( FIND REV_ARGV COMMENT COMMENT_START_INDEX )

        if( NOT COMMENT_START_INDEX EQUAL -1 )
            if( NOT COMMENT_START_INDEX EQUAL 1 )
                message( FATAL_ERROR "COMMENT must specify exactly one argument" )
            endif()

            list( GET REV_ARGV 0 IN_COMMENT )
            list( REMOVE_AT REV_ARGV 0 1 )
        endif()

        # WORKING_DIRECTORY
        set( IN_WORKING_DIRECTORY "" )
        list( FIND REV_ARGV WORKING_DIRECTORY WD_START_INDEX )

        if( NOT WD_START_INDEX EQUAL -1 )
            if( NOT WD_START_INDEX EQUAL 1 )
                message( FATAL_ERROR "WORKING_DIRECTORY must specify exactly one argument" )
            endif()

            list( GET REV_ARGV 0 IN_WORKING_DIRECTORY )
            list( REMOVE_AT REV_ARGV 0 1 )
        endif()

        # IMPLICIT_DEPENDS
        set( IN_IMPLICIT_DEPENDS "" )
        list( FIND REV_ARGV IMPLICIT_DEPENDS ID_START_INDEX )

        if( NOT ID_START_INDEX EQUAL -1 )
            if( ID_START_INDEX GREATER 0 )
                math( EXPR ID_COUNT "${ID_START_INDEX} - 1" )
                foreach( ID_NR RANGE ${ID_COUNT} )
                    list( GET REV_ARGV 0 IN_IMPLICIT_DEP )
                    list( REMOVE_AT REV_ARGV 0 )
                    list( APPEND IN_IMPLICIT_DEPENDS ${IN_IMPLICIT_DEP} )
                endforeach()

                list( REVERSE IN_IMPLICIT_DEPENDS )
            endif()

            list( REMOVE_AT REV_ARGV 0 )
        endif()

        # DEPENDS
        set( IN_DEPENDS "" )
        list( FIND REV_ARGV DEPENDS DEPS_START_INDEX )

        if( NOT DEPS_START_INDEX EQUAL -1 )
            if( DEPS_START_INDEX GREATER 0 )
                math( EXPR DEP_COUNT "${DEPS_START_INDEX} - 1" )
                foreach( DEP_NR RANGE ${DEP_COUNT} )
                    list( GET REV_ARGV 0 IN_DEP )
                    list( REMOVE_AT REV_ARGV 0 )
                    list( APPEND IN_DEPENDS ${IN_DEP} )
                endforeach()

                list( REVERSE IN_DEPENDS )
            endif()

            list( REMOVE_AT REV_ARGV 0 )
        endif()

        # MAIN_DEPENDENCY
        set( IN_MAIN_DEPENDENCY "" )
        list( FIND REV_ARGV MAIN_DEPENDENCY MD_START_INDEX )

        if( NOT MD_START_INDEX EQUAL -1 )
            if( NOT MD_START_INDEX EQUAL 1 )
                message( FATAL_ERROR "MAIN_DEPENDENCY must specify exactly one argument" )
            endif()

            list( GET REV_ARGV 0 IN_MAIN_DEPENDENCY )
            list( REMOVE_AT REV_ARGV 0 1 )
        endif()

        # COMMAND
        # Format: COMMAND ... [COMMAND ...]
        set( IN_COMMANDS "" )
        while( TRUE )
            list( FIND REV_ARGV COMMAND CMD_START_INDEX )

            if( NOT CMD_START_INDEX EQUAL -1 )
                if( CMD_START_INDEX GREATER 0 )
                    math( EXPR CMD_ARG_COUNT "${CMD_START_INDEX} - 1" )
                    foreach( CMD_ARG_NR RANGE ${CMD_ARG_COUNT} )
                        list( GET REV_ARGV 0 IN_COMMAND_ARG )
                        list( REMOVE_AT REV_ARGV 0 )
                        list( APPEND IN_COMMANDS ${IN_COMMAND_ARG} )
                    endforeach()
                endif()

                list( REMOVE_AT REV_ARGV 0 )
                list( APPEND IN_COMMANDS COMMAND )
            else()
                break()
            endif()
        endwhile()

        list( LENGTH IN_COMMANDS CMD_COUNT )
        if( CMD_COUNT GREATER 0 )
            list( REVERSE IN_COMMANDS )
        endif()

        # OUTPUT
        set( IN_OUTPUT "" )
        list( FIND REV_ARGV OUTPUT OUTPUT_START_INDEX )

        if( NOT OUTPUT_START_INDEX EQUAL -1 )
            if( OUTPUT_START_INDEX GREATER 0 )
                math( EXPR OUTPUT_COUNT "${OUTPUT_START_INDEX} - 1" )
                foreach( OUTPUT_NR RANGE ${OUTPUT_COUNT} )
                    list( GET REV_ARGV 0 IN_OUTPUT_FILE )
                    list( REMOVE_AT REV_ARGV 0 )
                    list( APPEND IN_OUTPUT ${IN_OUTPUT_FILE} )
                endforeach()

                list( REVERSE IN_OUTPUT )
            endif()

            list( REMOVE_AT REV_ARGV 0 )
        endif()

        # ALL
        list( GET REV_ARGV 0 ARG_VALUE )

        if( ARG_VALUE STREQUAL ALL )
            set( IN_ALL TRUE )
            list( REMOVE_AT REV_ARGV 0 )
            list( GET REV_ARGV 0 ARG_VALUE )
        else()
            set( IN_ALL FALSE )
        endif()

        # Name
        set( IN_NAME ${ARG_VALUE} )
        list( REMOVE_AT REV_ARGV 0 )

        # Extra front arguments?
        list( LENGTH REV_ARGV SPARE_ARG_COUNT )
        if( SPARE_ARG_COUNT GREATER 0 )
            message( FATAL_ERROR "Spare arguments found after parsing arguments in backwards order" )
        endif()

        # Check for mandatory arguments
        if( IN_NAME STREQUAL "" )
            message( FATAL_ERROR "Name not given" )
        endif()

        list( LENGTH IN_OUTPUT OUTPUT_COUNT )
        if( OUTPUT_COUNT LESS 1 )
            message( FATAL_ERROR "No OUTPUTs given" )
        endif()

        list( LENGTH IN_COMMANDS CMD_COUNT )
        if( CMD_COUNT LESS 1 )
            message( FATAL_ERROR "No COMMANDs given" )
        endif()

        # Assemble arguments for add_custom_command()
        set( CUSTOM_COMMAND_ARGS
            OUTPUT ${IN_OUTPUT}
            ${IN_COMMANDS}  )

        if( NOT IN_MAIN_DEPENDENCY STREQUAL "" )
            list( APPEND CUSTOM_COMMAND_ARGS MAIN_DEPENDENCY ${IN_MAIN_DEPENDENCY} )
        endif()

        list( LENGTH IN_DEPENDS DEP_COUNT )
        if( DEP_COUNT GREATER 0 )
            list( APPEND CUSTOM_COMMAND_ARGS DEPENDS ${IN_DEPENDS} )
        endif()

        list( LENGTH IN_IMPLICIT_DEPENDS ID_COUNT )
        if( ID_COUNT GREATER 0 )
            list( APPEND CUSTOM_COMMAND_ARGS IMPLICIT_DEPENDS ${IN_IMPLICIT_DEPENDS} )
        endif()

        if( NOT IN_WORKING_DIRECTORY STREQUAL "" )
            list( APPEND CUSTOM_COMMAND_ARGS WORKING_DIRECTORY ${IN_WORKING_DIRECTORY} )
        endif()

        if( NOT IN_COMMENT STREQUAL "" )
            list( APPEND CUSTOM_COMMAND_ARGS COMMENT ${IN_COMMENT} )
        endif()

        if( ${IN_VERBATIM} )
            list( APPEND CUSTOM_COMMAND_ARGS VERBATIM )
        endif()

        # Assemble arguments for add_custom_target()
        set( CUSTOM_TARGET_ARGS
            ${IN_NAME} )

        if( ${IN_ALL} )
            list( APPEND CUSTOM_TARGET_ARGS ALL )
        endif()

        list( APPEND CUSTOM_TARGET_ARGS DEPENDS ${IN_OUTPUT} )

        # Create custom command and target
        add_custom_command( ${CUSTOM_COMMAND_ARGS} )
        add_custom_target( ${CUSTOM_TARGET_ARGS} )
endfunction()

include( "${CMAKE_CURRENT_LIST_DIR}/targets/cxx.cmake" )


