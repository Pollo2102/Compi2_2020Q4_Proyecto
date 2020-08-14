
%option noyywrap
%option yylineno
%option reentrant
%option nounistd
%option never-interactive

%{
#include <cstdio>
#include "expr_lexer.h"

#define YY_EXTRA_TYPE std::istream*
#define YY_DECL int ExprLexer::_getNextToken(ExprLexer::semantic_type& yylval, yyscan_t yyscanner)
#define YY_INPUT(buf, result, max_size) \
        do { \
            std::istream *in = yyget_extra(yyscanner); \
            in->read(buf, max_size); \
            result = in->gcount(); \
        } while (0)


%}

DIGIT [0-9]
LETTER [a-zA-Z]

%%

\#[^\n]* {  }
\n\t+   { return makeToken(yytext, yyleng - 1, token::TK_INDENT); }
\n      { return makeToken(yytext, yyleng, token::TK_EOL); }
[ ]     { }
"print" { return makeToken(yytext, yyleng, token::KW_PRINT); }
"input" { return makeToken(yytext, yyleng, token::KW_INPUT); }
"+"     { return makeToken(yytext, yyleng, token::OP_ADD); }
"-"     { return makeToken(yytext, yyleng, token::OP_SUB); }
"**"    { return makeToken(yytext, yyleng, token::OP_POW); }
"*"     { return makeToken(yytext, yyleng, token::OP_MUL); }
"/"     { return makeToken(yytext, yyleng, token::OP_DIV); }
"%"     { return makeToken(yytext, yyleng, token::OP_MOD); }

"=="    { return makeToken(yytext, yyleng, token::REL_EQ); }
"<="    { return makeToken(yytext, yyleng, token::REL_LEQ); }
">="    { return makeToken(yytext, yyleng, token::REL_GTE); }
"!="    { return makeToken(yytext, yyleng, token::REL_NEQ); }
"<"     { return makeToken(yytext, yyleng, token::REL_LT); }
">"     { return makeToken(yytext, yyleng, token::REL_GT); }

"("     { return makeToken(yytext, yyleng, token::TK_OPENPAR); }
")"     { return makeToken(yytext, yyleng, token::TK_CLOSEPAR); }
"="     { return makeToken(yytext, yyleng, token::OP_ASSIGN); }
","     { return makeToken(yytext, yyleng, token::TK_COMMA); }
"\""[^"]*"\"" {
    std::string txt(&yytext[1], &yytext[yyleng - 1]);
    yylval.emplace<std::string>(txt.c_str(), txt.size());
    return makeToken(txt.c_str(), txt.size(), token::TK_LITERAL);
}
{DIGIT}+    {
    yylval.emplace<int>(std::strtol(yytext, nullptr, 10));
    return makeToken(yytext, yyleng, token::TK_NUMBER);
}
({LETTER}|_)({LETTER}|_|{DIGIT})* {
    yylval.emplace<std::string>(yytext, yyleng);
    return makeToken(yytext, yyleng, token::TK_IDENT);
}
.       { std::cout << yytext << "\n"; return makeToken(yytext, yyleng, token::TK_ERROR); }

%%

ExprLexer::ExprLexer(std::istream &in) 
: in(in) 
{
    indent_stack.push(0);
    yylex_init_extra(&in, &scanner);
}

ExprLexer::~ExprLexer() {
    yylex_destroy(scanner);
}

int ExprLexer::handleIndent(int indentAmount) // -1 = dedent, 0 = no indent, 1 = indent
{
    // Finish function
    return 0;
}

int ExprLexer::getLineNo() {
    return yyget_lineno(scanner);
}