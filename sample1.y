%require "3.0"
%language "c++"

%parse-param { std::unordered_map<std::string, int>& vars}
%parse-param { ExprLexer& lexer }
%parse-param { Ast::AstNode *&root }

%define parse.error verbose
%define api.value.type variant
%define api.parser.class { Parser }
/* %define parser_class_name { Parser } */
%define api.namespace { Expr }

%code requires {
#include <unordered_map>
#include <string>
#include "expr_ast.h"

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

Ast::NodeVector stmts;

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

%type<Ast::BlockStmt *> expr2
%type<int> expr
%type<Ast::Stmt *> exprP
%type<Ast::Expr *> term
%type<Ast::Expr *> factor
%type<Ast::AssignStmt *> asgn
%type<Ast::Expr *> asgnP
%type<Ast::Input *> input
%type<Ast::PrintStmt *> print
%type<Ast::PrintArgs *> printArgs
%type<Ast::Optl_Print_Args *> optl_print_args
%type<Ast::Optl_Print_ArgsP *> optl_print_argsP

%%

expr: expr2 EOLP { root = new Ast::BlockStmt(stmts); }
;

exprP:  asgn { $$ = $1; }
        | print { $$ = $1; }
        | cond_stmt {  }
        | while_stmt {  }
        | for_stmt {  }
        | func_def {  }
        | return_stmt {  }
        | func_call {  }
;

expr2: expr2 EOLP exprP { stmts.push_back($3); }
       | %empty  {  }
;



input: "input" "(" TK_LITERAL ")" { 
        $$ = new Ast::Input($3);
 }
;

asgn: TK_IDENT "=" asgnP { $$ = new Ast::AssignStmt($1, $3); }
;

asgnP:  term { $$ = $1; }
        | input { $$ = $1; }
;

print: KW_PRINT printArgs { $$ = new Ast::PrintStmt($2); }
;

printArgs: TK_LITERAL optl_print_args { $$ = new Ast::PrintArgs($1, $2); }
;

optl_print_args: "," term optl_print_argsP { $$ = new Ast::Optl_Print_Args($2, $3); }
                | %empty { $$ = nullptr; }
;

optl_print_argsP: "," printArgs { $$ = new Ast::Optl_Print_ArgsP($2); }
                | %empty { $$ = nullptr; }
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



term: term "+" factor { $$ = new Ast::AddExpr($1, $3); }
     |  term "-" factor { $$ = new Ast::SubExpr($1, $3); }
     |  term "*" factor { $$ = new Ast::MulExpr($1, $3); }
     |  term "/" factor { $$ = new Ast::DivExpr($1, $3); }
     |  term "**" factor { $$ = new Ast::PowExpr($1, $3); }
     |  term "%" factor { $$ = new Ast::ModExpr($1, $3); }
     |  term "==" factor { $$ = new Ast::EqExpr($1, $3); }
     |  term "!=" factor { $$ = new Ast::NotExpr($1, $3); }
     |  term "<=" factor { $$ = new Ast::LEExpr($1, $3); }
     |  term ">=" factor { $$ = new Ast::GEExpr($1, $3); }
     |  term ">" factor { $$ = new Ast::GTExpr($1, $3); }
     |  term "<" factor { $$ = new Ast::LTExpr($1, $3); }
     | factor   { $$ = $1; }
;

factor: TK_NUMBER { $$ = new Ast::NumExpr($1); }
        | TK_IDENT factorP { $$ = new Ast::IdExpr($1); }
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