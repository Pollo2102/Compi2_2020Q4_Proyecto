
%option noyywrap
%option yylineno
%option reentrant
%option nounistd
%option never-interactive

%{
#include <cstdio>
#include <stack>
#include "expr_lexer.h"

#define YY_EXTRA_TYPE std::istream*
#define YY_DECL int ExprLexer::_getNextToken(ExprLexer::semantic_type& yylval, yyscan_t yyscanner)
#define YY_INPUT(buf, result, max_size) \
        do { \
            std::istream *in = yyget_extra(yyscanner); \
            in->read(buf, max_size); \
            result = in->gcount(); \
        } while (0)

static std::stack<int> indentation_stack;

%}

DIGIT [0-9]
LETTER [a-zA-Z]

%%

\#[^\n]* {  }
[\t]+\n { return makeToken(yytext, yyleng, token::TK_EOL); }
^[\t]+/[^\n]  { 
                int ind_token = handleIndent(yyleng);
                if (ind_token == token::TK_INDENT) {
                    /* std::cout << "Indent\n"; */
                    return makeToken(yytext, yyleng, token::TK_INDENT); 
                }
                else if (ind_token == token::TK_DEDENT) {
                    /* std::cout << "tab dedent\n"; */
                    return makeToken(yytext, yyleng, token::TK_DEDENT); 
                }
            }
^[ ]+/[^\n]   { 
                int ind_token = handleIndent(yyleng);
                if (ind_token == token::TK_INDENT) {
                    /* std::cout << "Indent\n"; */
                    return makeToken(yytext, yyleng, token::TK_INDENT); 
                }
                else if (ind_token == token::TK_DEDENT) {
                    /* std::cout << "space dedent\n"; */
                    return makeToken(yytext, yyleng, token::TK_DEDENT);  
                }
            }
\n/\n   {
    return makeToken(yytext, yyleng, token::TK_EOL);
}            
\n/[^\n\t\ ]  {
                int ind_token = handleIndent(0); 
                if (!is_balanced(0)) {
                    std::cout << "Balance\n";
                    unput('\n');
                }
                if (ind_token == token::TK_INDENT) {
                    /* std::cout << "Indent\n"; */
                    return makeToken(yytext, yyleng, token::TK_INDENT); 
                }
                else if (ind_token == token::TK_DEDENT) {
                    /* std::cout << "Dedent\n"; */
                    return makeToken(yytext, yyleng, token::TK_DEDENT); 
                }
}
\n\t+   { return makeToken(yytext, yyleng - 1, token::TK_INDENT); }
\n      { return makeToken(yytext, yyleng, token::TK_EOL); }
[ ]     { }
"print" { return makeToken(yytext, yyleng, token::KW_PRINT); }
"input" { return makeToken(yytext, yyleng, token::KW_INPUT); }
"if"    { return makeToken(yytext, yyleng, token::KW_IF); }
"elif"  { return makeToken(yytext, yyleng, token::KW_ELIF); }
"else"  { return makeToken(yytext, yyleng, token::KW_ELSE); }
"while" { return makeToken(yytext, yyleng, token::KW_WHILE); }
"for"   { return makeToken(yytext, yyleng, token::KW_FOR); }
"in"    { return makeToken(yytext, yyleng, token::KW_IN); }
"def"   { return makeToken(yytext, yyleng, token::KW_DEF); }
"return" { return makeToken(yytext, yyleng, token::KW_RETURN); }
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
"["     { return makeToken(yytext, yyleng, token::TK_OPENBRK); }
"]"     { return makeToken(yytext, yyleng, token::TK_CLOSEBRK); }
"="     { return makeToken(yytext, yyleng, token::OP_ASSIGN); }
","     { return makeToken(yytext, yyleng, token::TK_COMMA); }
":"     { return makeToken(yytext, yyleng, token::TK_COLON); }
"\""[^"]*"\"" {
    std::string txt(&yytext[1], &yytext[yyleng - 1]);
    yylval.emplace<std::string>(txt.c_str(), txt.size());
    return makeToken(txt.c_str(), txt.size(), token::TK_LITERAL);
}
"\'"[^\']*"\'" {
    std::string txt(&yytext[1], &yytext[yyleng - 1]);
    yylval.emplace<std::string>(txt.c_str(), txt.size());
    return makeToken(txt.c_str(), txt.size(), token::TK_LITERAL);
}
{DIGIT}+    {
    yylval.emplace<int>(std::strtol(yytext, nullptr, 10));
    return makeToken(yytext, yyleng, token::TK_NUMBER);
}
({LETTER}|_)({LETTER}|_|{DIGIT})* {
    std::cout << yytext << '\n';
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

bool ExprLexer::is_balanced(int wsp)
{
    if (indent_stack.top() != wsp) {
        return false;
    }
    return true;
}

int ExprLexer::handleIndent(int indentAmount)
{
    int cur_indent = indent_stack.top();
    if (indentAmount == cur_indent) return -1;
    else if (indentAmount < cur_indent) {
        indent_stack.pop();
        return Expr::Parser::token::TK_DEDENT;
    }
    else {
        indent_stack.push(indentAmount);
        return Expr::Parser::token::TK_INDENT;
    }
}

int ExprLexer::getLineNo() {
    return yyget_lineno(scanner);
}