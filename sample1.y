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
#include <cmath>
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

%token TK_OPENPAR "("
%token TK_CLOSEPAR ")"
%token TK_ASSIGN "="
%token TK_COMMA ","
%token TK_EOL "EOL"
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
%token<std::string> TK_LITERAL "literal"
%token OP_SEMICOLON ";"
%token TK_ERROR "unknown token"
%type<int> expr
%type<int> term
%type<int> factor
%type<int> asgn
%type<std::string> print printArgs optl_print_args optl_print_argsP

%%

expr: EOLP exprP expr2 { }
;

exprP: asgn | print
;

expr2: EOLP exprP expr2 | EOLP expr2 | %empty
;

expr: expr "+" term { $$ = $1 + $3; }
     | expr OP_SUB term { $$ = $1 - $3; }
     | term { $$ = $1; }
;


asgn: TK_IDENT "=" expr { vars.emplace($1, $3); }
;

print: KW_PRINT printArgs { std::cout << $2 << '\n'; }
;

printArgs: TK_LITERAL optl_print_args { $$ = $1 + $2; }
;

optl_print_args: "," term optl_print_argsP { $$ = std::to_string($2) + $3; }
                | %empty { $$ = ""; }
;

optl_print_argsP: "," printArgs { $$ = $2; }
                | %empty { $$ = ""; }
;

term: factor "+" term { $$ = $1 + $3; }
     |  factor "-" term { $$ = $1 - $3; }
     |  factor "*" term { $$ = $1 * $3; }
     |  factor "/" term { $$ = $1 / $3; }
     |  factor "**" term { $$ = pow($1, $3); }
     |  factor "%" term { $$ = $1 % $3; }
     |  factor "==" term { $$ = $1 == $3; }
     |  factor "!=" term { $$ = $1 != $3; }
     |  factor "<=" term { $$ = $1 <= $3; }
     |  factor ">=" term { $$ = $1 >= $3; }
     |  factor ">" term { $$ = $1 > $3; }
     |  factor "<" term { $$ = $1 < $3; }
     | factor   { $$ = $1; }
;

factor: TK_NUMBER { $$ = $1; }
        | TK_IDENT factorP {$$ = vars[$1]; }
/*         | TK_LITERAL */
;

factorP: "(" args_list ")"
        | "(" ")"
        | "[" args_list "]"
        | %empty
;

args_list: term args_listP
;

args_listP: "," term args_listP
           | %empty
;

EOLP: TK_EOL EOLP
        | %empty
;