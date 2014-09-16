
INCLUDE( CMakeParseArguments )
INCLUDE( cmake_lib_utils )

FUNCTION( USE_CPP11 )
  SET( OPTIONS  )
  SET( ONE_VALUE_ARG MODE )
  SET( MULTI_VALUE_ARGS )
  CMAKE_PARSE_ARGUMENTS( _CPP11 "${OPTIONS}" "${ONE_VALUE_ARG}" "${MULTI_VALUE_ARGS}" ${ARGN} )
  SET( _CPP11_TARGET ${_CPP11_UNPARSED_ARGUMENTS} )

  IF( CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" )
    IF( MSVC_VERSION LESS 1700 )
      MESSAGE( SEND_ERROR "Visual Studio version is too low to use C++11 standard" )
    ENDIF(  )
  ELSEIF( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
    # ref: http://clang.llvm.org/cxx_status.html
    IF( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 2.9.0 )
      MESSAGE( SEND_ERROR "Clang version is too low to use C++11 standard features : Clang(${CMAKE_CXX_COMPILER_VERSION})" )
    ENDIF(  )

    IF( APPLE )
      IF( _CPP11_MODE STREQUAL "TARGET" )
        IF( XCODE_VERSION )
          SET_XCODE_PROPERTY( ${_CPP11_TARGET} CLANG_CXX_LANGUAGE_STANDARD "c++11" )
	  SET_XCODE_PROPERTY( ${_CPP11_TARGET} CLANG_CXX_LIBRARY "libc++" )
	ENDIF(  )
        SET_PROPERTY( ${_CPP11_MODE} ${_CPP11_Target} APPEND_STRING PROPERTY LINK_FLAGS " -stdlib=libc++" )
      ENDIF(  )
      SET_PROPERTY( ${_CPP11_MODE} ${_CPP11_Target} APPEND_STRING PROPERTY COMPILE_FLAGS " -std=c++11 -stdlib=libc++" )
    ELSE(  )
      SET_PROPERTY( ${_CPP11_MODE} ${_CPP11_Target} APPEND_STRING PROPERTY COMPILE_FLAGS " -std=c++11" )
    ENDIF(  )
  ELSEIF( CMAKE_CXX_COMPILER_ID STREQUAL "GNU" )
    GET_GCC_VERSION(  )
    
    IF( GCC_VERSION VERSION_LESS 4.3 )
      MESSAGE( SEND_ERROR "GCC version is too low to use C++11 standard features" )
    ELSEIF( GCC_VERSION VERSION_GREATER 4.7 )
      SET( _CPP11_CODE "c++11" )
    ELSE(  )
      SET( _CPP11_CODE "c++0x" )
    ENDIF(  )
    SET_PROPERTY( ${_CPP11_MODE} ${_CPP11_Target} APPEND_STRING PROPERTY COMPILE_FLAGS " -std=${_CPP11_CODE}" )
  ENDIF(  )
ENDFUNCTION( USE_CPP11 )
