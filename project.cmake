
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

# Adds GNU-specific compile flags that enable essential warnings and
# turn them into errors
function( target_add_cxx_gnu_warnings TargetName )
	target_add_compile_flag( "${TargetName}"
                -Wall -Wextra -Werror -Wformat -Wswitch-default -Wswitch-enum
                -Wcast-qual -Wcast-align -Wlogical-op -Wredundant-decls
                -Winline -Wstack-protector
        )
endfunction()

# Adds GNU-specific compile flags that enable C++11 support
function( target_add_cxx_gnu_11 TargetName )
	target_add_compile_flag( "${TargetName}"
                -std=c++11
        )
endfunction()

# Adds Clang-specific compile flags that enable essential warnings and
# turn them into errors
function( target_add_cxx_clang_warnings TargetName )
	target_add_compile_flag( "${TargetName}"
		-Weverything -Werror -Wno-padded
		-Wno-global-constructors -Wno-exit-time-destructors -Wno-shadow
		-Wno-unreachable-code -Wno-covered-switch-default
		# Don't warn about C++11 extension use
		-Wno-c++11-extensions 
		# Don't warn about incompatibility with C++98
		-Wno-c++98-compat -Wno-c++98-compat-pedantic
		# Don't warn about weak virtual tables (will be generated
		# in every translation unit)
		-Wno-weak-vtables
        # Don't warn about noreturn attribute missing on potential candidates
        -Wno-missing-noreturn
        -Wno-documentation-unknown-command
        -Wno-unused-macros
	)
endfunction()

# Adds Clang-specific compile flags that enable C++11 support
function( target_add_cxx_clang_11 TargetName )
	target_add_compile_flag( "${TargetName}"
		-std=c++11
	)
endfunction()

# Adds Clang-specific compile flags that use libc++ instead of libstdc++
function( target_add_cxx_clang_libcxx TargetName )
    target_add_compile_flag( "${TargetName}"
        -stdlib=libc++
    )

    target_add_link_flag( "${TargetName}"
        -lc++
    )
endfunction()

# Adds Clang-specific compile flags that enable all sorts of sanitizers
# to check for bugs in software
function( target_add_cxx_clang_sanitizers TargetName )
    target_add_compile_flag( "${TargetName}"
        -fsanitize=address-full
        -fsanitize=undefined
        -fsanitize=use-after-return
        -fsanitize=use-after-scope
        -fno-omit-frame-pointer
        -fno-optimize-sibling-calls
        -fno-sanitize-recover
    )
    target_add_link_flag( "${TargetName}"
        -fsanitize=address-full
        -fsanitize=undefined
        -fsanitize=use-after-return
        -fsanitize=use-after-scope
    )
endfunction()

# Adds GCC-specific compile flags that enable all sorts of sanitizers
# to check for bugs in software
function( target_add_cxx_gcc_sanitizers TargetName )
    target_add_compile_flag( "${TargetName}"
        -fsanitize=address -fno-omit-frame-pointer
    )
    target_add_link_flag( "${TargetName}"
        -fsanitize=address
    )
endfunction()

# Automatically configures C++ compiler for the specified target
function( target_auto_configure_cxx_compiler TargetName )

	if( BUILD_CXX_COMPILER_GNU )
		# enable all warnings
		target_add_cxx_gnu_warnings( "${TargetName}" )
		# compile for C++11
		target_add_cxx_gnu_11( "${TargetName}" )

	elseif( BUILD_CXX_COMPILER_CLANG )
		# enable all warnings
		target_add_cxx_clang_warnings( "${TargetName}" )
		# compile for C++11
		target_add_cxx_clang_11( "${TargetName}" )

	else()
		message( FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}. Please configure." )
	endif()

endfunction()

# Include maximum debug information when building the specified target
function( target_auto_configure_cxx_max_debug_info TargetName )

	if( BUILD_CXX_COMPILER_GNU )
		target_add_compile_flag( "${TargetName}" -ggdb3 )

	elseif( BUILD_CXX_COMPILER_CLANG )
		target_add_compile_flag( "${TargetName}" -ggdb3 )

	else()
		message( FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}. Please configure." )
	endif()

endfunction()

# Enable maximum sanitizers when building the specified target
function( target_auto_configure_cxx_max_sanitizers TargetName )

    if( BUILD_CXX_COMPILER_GNU )
        target_add_cxx_gcc_sanitizers( "${TargetName}" )

    elseif( BUILD_CXX_COMPILER_CLANG )
        target_add_cxx_clang_sanitizers( "${TargetName}" )

    else()
        message( FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}. Please configure." )
    endif()

endfunction()

# Perform no optimizations when building the specified target
function( target_auto_configure_cxx_no_optimization TargetName )

        if( BUILD_CXX_COMPILER_GNU )
                target_add_compile_flag( "${TargetName}" -O0 )

        elseif( BUILD_CXX_COMPILER_CLANG )
                target_add_compile_flag( "${TargetName}" -O0 )

        else()
                message( FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}. Please configure." )
        endif()

endfunction()

# Perform maximum optimizations when building the specified target
function( target_auto_configure_cxx_max_optimization TargetName )

        if( BUILD_CXX_COMPILER_GNU )
                target_add_compile_flag( "${TargetName}" -Os )

        elseif( BUILD_CXX_COMPILER_CLANG )
                target_add_compile_flag( "${TargetName}" -Os )

        else()
                message( FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}. Please configure." )
        endif()

endfunction()

