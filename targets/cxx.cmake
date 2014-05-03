
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

