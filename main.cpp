#include <iostream>
#include <unordered_map>
#include <string>
#include "expr_tokens.h"
#include "expr_lexer.h"

int main(int argc, char const *argv[])
{
    if (argc != 2)
    {
        std::cerr << "Correct usage: " << argv[0] << " <file path>\n";
        return 1;
    }

    std::unordered_map<std::string, int> vars;
    std::string filename(argv[1]);

    std::ifstream in(filename.c_str(), std::ios::in);

    if (!in.is_open()) {
        fprintf(stderr, "Cannot open file %s\n", argv[1]);
        return 1;
    }

    ExprLexer lexer(in);
    Expr::Parser p(vars, lexer);
    try {
        p.parse();
        // yyparse(vars);
    } catch (std::string& err) {
        std::cerr << err << '\n';
    }
}