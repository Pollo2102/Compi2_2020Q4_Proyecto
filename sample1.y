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
                throw 1;
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
%token TK_OPENBRK "["
%token TK_CLOSEBRK "]"
%token OP_ASSIGN "="
%token TK_COMMA ","
%token TK_COLON ":"
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
%token KW_INPUT "input"

%token<int> TK_NUMBER "number"
%token<std::string> TK_IDENT "identifier"
%token<std::string> TK_LITERAL "literal"
%token OP_SEMICOLON ";"
%token END 0 "EOF"
%token TK_ERROR "unknown token"
%type<int> expr
%type<int> term
%type<int> factor
%type<int> asgn asgnP
%type<int> input
%type<std::string> print printArgs optl_print_args optl_print_argsP

%%

expr: expr2 EOLP { }
;

exprP:  asgn 
        | print 
        | input 
        | cond_stmt 
        | while_stmt 
        | for_stmt 
        | func_def 
        | return_stmt
        | func_call
;

expr2: expr2 EOLP exprP | %empty
;



input: "input" "(" TK_LITERAL ")" { 
        std::string number;
        std::cout << $3 << '\n';
        std::cin >>  number;
        $$ = atoi(number.c_str());
 }
;

asgn: TK_IDENT "=" asgnP { vars.emplace($1, $3); }
;

asgnP:  term { $$ = $1; }
        | input { $$ = $1; }
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

cond_stmt: "if" term ":" func_code cond_stmtP
;

cond_stmtP: "elif" term ":" func_code cond_stmtP
           | "else" ":" func_code 
           | %empty
;

while_stmt: "while" term ":" func_code
;

for_stmt: "for" TK_IDENT "in" TK_IDENT "(" term "," term ")" ":" func_code
;

func_code: TK_EOL TK_INDENT exprP EOLP func_codeP dedent_prod
;

func_codeP: func_codeP exprP TK_EOL
            | %empty
;

func_def: "def" TK_IDENT "(" opt_args_list ")" ":" func_code
;

func_call: TK_IDENT "(" opt_args_list ")"
;

return_stmt: "return" term
;



term: term "+" factor { $$ = $1 + $3; }
     |  term "-" factor { $$ = $1 - $3; }
     |  term "*" factor { $$ = $1 * $3; }
     |  term "/" factor { $$ = $1 / $3; }
     |  term "**" factor { $$ = pow($1, $3); }
     |  term "%" factor { $$ = $1 % $3; }
     |  term "==" factor { $$ = $1 == $3; }
     |  term "!=" factor { $$ = $1 != $3; }
     |  term "<=" factor { $$ = $1 <= $3; }
     |  term ">=" factor { $$ = $1 >= $3; }
     |  term ">" factor { $$ = $1 > $3; }
     |  term "<" factor { $$ = $1 < $3; }
     | factor   { $$ = $1; }
;

factor: TK_NUMBER { $$ = $1; }
        | TK_IDENT factorP { $$ = 1; }
;

factorP: "(" opt_args_list ")"
        | "[" args_list "]"
        | %empty
;

opt_args_list: args_list | %empty
;

args_list: term args_listP
;

args_listP: "," term args_listP
           | %empty
;

EOLP: EOLP TK_EOL
        | %empty
;

dedent_prod: TK_DEDENT
             | END
;