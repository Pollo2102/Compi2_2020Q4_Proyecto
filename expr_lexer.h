#ifndef _EXPR_LEXER_H_
#define _EXPR_LEXER_H_

#include <iostream>
#include <fstream>
#include <string>
#include <stack>
#include "expr_tokens.h"

using yyscan_t = void*;

class ExprLexer {
public:
    using semantic_type = Expr::Parser::semantic_type;
    using token = Expr::Parser::token;

    ExprLexer(std::istream &in);
    ~ExprLexer();

    int getNextToken(semantic_type *yylval) 
    { 
        return _getNextToken(*yylval, scanner); 
    }
    std::string getText() { return text; }
    int handleIndent(int indentAmount);
    int getLineNo();
    bool is_balanced(int wsp);

private: 
    /* Flex will generate this function */
    int _getNextToken(semantic_type& yylval, yyscan_t yyscanner);

    int makeToken(const char *txt, int len, int tk) {
        std::string tt(txt, len);
        text = std::move(tt);
        return tk;
    }

private:
    std::istream &in;
    std::string text;
    yyscan_t scanner;
    std::stack<int> indent_stack;
};
#endif