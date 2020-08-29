cmake_minimum_required(VERSION 3.0)
project(TinyPython)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -std=c++14")

set (LEXER_SRC "${PROJECT_SOURCE_DIR}/sample1.l")
set (PARSER_SRC "${PROJECT_SOURCE_DIR}/sample1.y")

find_package(FLEX REQUIRED)
find_package(TREECC REQUIRED)

# Run flex to generate the lexer
add_custom_command(
    OUTPUT expr_lexer.cpp
    COMMAND flex -o expr_lexer.cpp ${LEXER_SRC}
    MAIN_DEPENDENCY ${LEXER_SRC}
)

#FLEX_TARGET(sample1 sample1.l  ${CMAKE_CURRENT_BINARY_DIR}/sample1.cpp)

# Run bison to generate the parser
add_custom_command(
    OUTPUT expr_tokens.h expr_parser.cpp
    COMMAND bison --defines=expr_tokens.h -rall -o expr_parser.cpp ${PARSER_SRC}
    MAIN_DEPENDENCY ${PARSER_SRC}
)

add_custom_command(
    OUTPUT expr_ast.cpp
    COMMAND ${TREECC} -o expr_ast.cpp -h expr_ast.h ${PROJECT_SOURCE_DIR}/expr_ast.tc
    MAIN_DEPENDENCY ${PROJECT_SOURCE_DIR}/expr_ast.tc
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${PROJECT_NAME}  expr_ast.cpp
                                expr_lexer.cpp
                                expr_parser.cpp
                                main.cpp)