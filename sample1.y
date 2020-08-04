%require "3.0"
%language "c++"

%parse-param { std::unordered_map<std::string, int>& vars}
%parse-param { ExprLexer& lexer }

%define parse.error verbose
%define api.value.type variant
%define api.parser.class { Parser }
/* %define parser_class_name { Parser } */
%define api.namespace { Expr }

%code requires {
#include <unordered_map>
#include <string>

class ExprLexer;
}

%{
#include <iostream>
#include <cstdio>
#include <string>
#include <unordered_map>
// #include "expr_parser.h"
#include "expr_lexer.h"
#include "expr_tokens.h"

#define yylex(arg) lexer.getNextToken(arg)

namespace Expr
{
        void Parser::error (const std::string& msg)
        {
                std::cerr << msg << '\n';
        }
}

%}

%token OP_ADD "+"
%token OP_SUB "-"
%token OP_MUL "*"
%token OP_DIV "/"
%token OP_POW "**"
%token OP_MOD "%"

%token REL_EQ "=="
%token REL_NEQ "!="
%token REL_LEQ "<="
%token REL_GTE ">="
%token REL_GT ">"
%token REL_LT "<"

%token OP_OPENPAR "("
%token OP_CLOSEPAR ")"
%token TK_ASSIGN "="
%token TK_COMMA ","
%token TK_INDENT
%token TK_DEDENT

%token KW_PRINT "print"
%token KW_IF    "if"
%token KW_ELIF  "elif"
%token KW_WHILE "while"
%token KW_ELSE  "else"
%token KW_RETURN "return"
%token KW_DEF   "def"
%token KW_FOR   "for"
%token KW_IN    "in"

%token<int> TK_NUMBER "number"
%token<std::string> TK_IDENT "identifier"
%token OP_SEMICOLON ";"
%token TK_ERROR "unknown token"
%type<int> expr
%type<int> term
%type<int> factor

%%

input: statement_list opt_semicolon 
;

opt_semicolon: OP_SEMICOLON
                | %empty
                ;

statement_list: statement_list OP_SEMICOLON statement_list
                | statement
;

statement: expr { std::cout << $1 << '\n'; }
;

expr: expr "+" term { $$ = $1 + $3; }
     | expr OP_SUB term { $$ = $1 - $3; }
     | term { $$ = $1; }
;

term: term OP_MUL factor { $$ = $1 * $3; }
      | term OP_DIV factor {
              if ($3 == 0) {
                      error("Division by zero");
              }
              $$ = $1 / $3;
        }
      | factor { $$ = $1; }
;

factor: TK_NUMBER { $$ = $1; }
        | TK_IDENT {$$ = vars[$1]; }
        | OP_OPENPAR expr OP_CLOSEPAR { $$ = $2; }
;