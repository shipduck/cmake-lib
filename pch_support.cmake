INCLUDE( CMakeParseArguments )
INCLUDE( cmake_lib_utils )

# PrecompiledHeader
FUNCTION( SET_PCH )
  SET( OPTIONS CXX CXX11 )
  SET( ONE_VALUE_ARG TARGET HEADER SOURCE )
  SET( MULTI_VALUE_ARGS )
  CMAKE_PARSE_ARGUMENTS( _PCH "${OPTIONS}" "${ONE_VALUE_ARG}" "${MULTI_VALUE_ARGS}" ${ARGN} )

  GET_GCC_VERSION(  )
  IF( NOT _PCH_CXX )
    SET( COMPILER ${CMAKE_C_COMPILER} )
  ELSE(  )
    SET( COMPILER ${CMAKE_CXX_COMPILER} )
  ENDIF(  )

  IF( MSVC )
    SET( PrecompiledBinary "\$(IntDir)\$(TargetName).pch" )
    SET( Sources ${${SourcesVar}} )
    STRING( REGEX REPLACE "/Zm[0-9]+ *" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} )
    SET( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zm500" CACHE STRING "" FORCE )
    GET_FILENAME_COMPONENT( PrecompiledBasename ${_PCH_HEADER} NAME )
    GET_SOURCE_FILE_PROPERTY( OLD_COMPILE_FLAGS ${_PCH_SOURCE} COMPILE_FLAGS )

    SET_PROPERTY( SOURCE ${_PCH_SOURCE}
      APPEND
      PROPERTY
        COMPILE_FLAGS
          "/Yc\"${PrecompiledBasename}\" /Fp\"${PrecompiledBinary}\"" )
    SET_PROPERTY( SOURCE ${_PCH_SOURCE}
      APPEND
      PROPERTY
        OBJECT_OUTPUTS "${PrecompiledBinary}" )
    SET_PROPERTY( TARGET ${_PCH_TARGET}
      APPEND
      PROPERTY
        COMPILE_FLAGS
          "/Yu\"${PrecompiledBasename}\"" )
  ELSEIF( XCODE_VERSION )
    # ref some .xcodeproj/project.pbxproj file

    SET_XCODE_PROPERTY( ${_PCH_TARGET} GCC_PRECOMPILE_PREFIX_HEADER YES )
    SET_XCODE_PROPERTY( ${_PCH_TARGET} GCC_PREFIX_HEADER ${_PCH_HEADER} )
  ELSEIF( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
    # http://clang.llvm.org/docs/PCHInternals.html
    # http://clang.llvm.org/docs/UsersManual.html#usersmanual-precompiled-headers

    IF( NOT _PCH_CXX )
      SET( COMPILER_OPTION  )
    ELSE(  )
      SET( COMPILER_OPTION -x c++-header )
    ENDIF(  )

    IF( _PCH_CXX11 )
      LIST( APPEND COMPILER_OPTION -std=c++11 )
    ENDIF(  )

    GET_TARGET_PROPERTY(TARGET_INCLUDES ${_PCH_TARGET} INCLUDE_DIRECTORIES)
    FOREACH( INCLUDE_PATH IN LISTS TARGET_INCLUDES )
      LIST( APPEND INCLUDE_PATHS "-I${INCLUDE_PATH}" )
    ENDFOREACH( INCLUDE_PATH )

    ADD_CUSTOM_COMMAND(
      OUTPUT "${_PCH_HEADER}.pch"
      COMMAND ${COMPILER} ${COMPILER_OPTION} ${_PCH_HEADER} -o ${_PCH_HEADER}.pch ${INCLUDE_PATHS}
      DEPENDS ${_PCH_HEADER} )
    SET_PROPERTY( TARGET ${_PCH_TARGET} APPEND_STRING PROPERTY COMPILE_FLAGS " -include ${_PCH_HEADER}" )
    ADD_CUSTOM_TARGET(
      "${_PCH_TARGET}_pch"
      DEPENDS "${_PCH_HEADER}.pch" )
    ADD_DEPENDENCIES( ${_PCH_TARGET} "${_PCH_TARGET}_pch" )
  ELSEIF( GCC_VERSION )
    # https://gcc.gnu.org/onlinedocs/gcc/Precompiled-Headers.html
    # http://stackoverflow.com/questions/58841/precompiled-headers-with-gcc

    IF( NOT _PCH_CXX )
      SET( COMPILER_OPTION  )
    ELSE(  )
      SET( COMPILER_OPTION -x c++-header )
    ENDIF(  )

    IF( _PCH_CXX11 )
      LIST( APPEND COMPILER_OPTION -std=c++11 )
    ENDIF(  )

    ADD_CUSTOM_COMMAND(
      OUTPUT "${_PCH_HEADER}.gch"
      COMMAND ${COMPILER} ${COMPILER_OPTION} ${_PCH_HEADER}
      DEPENDS ${_PCH_HEADER} )
    ADD_CUSTOM_TARGET(
      "${_PCH_TARGET}_pch"
      DEPENDS "${_PCH_HEADER}.gch" )
    ADD_DEPENDENCIES( ${_PCH_TARGET} "${_PCH_TARGET}_pch" )
  ENDIF( )
ENDFUNCTION( SET_PCH )
