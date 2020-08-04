#include <iostream>
#include <unordered_map>
#include <string>
#include "expr_tokens.h"
#include "expr_lexer.h"

int main(int argc, char const *argv[])
{
    const char *prg = argv[0];
    std::unordered_map<std::string, int> vars;
    std::string filename;

    if (argc > 1) {
        --argc;
        argv++;
        for (int i = 0; i < argc; i++)
        {
            std::string arg = argv[i];
            if (arg.compare(0, 2, "-D") == 0) {
                int p = arg.find('=');
                if (p == std::string::npos) {
                    std::cerr << "Argument errors.\n";
                    return 1;
                }
                std::string name = arg.substr(2, p - 2);
                std::string sval = arg.substr(p+1);
                vars[name] = std::stol(sval);
                std::cout << name << "=" << sval << '\n';
            } else if (arg.compare(0, 2, "-f") == 0) {
                filename = arg.substr(2);
            } else {
                std::cerr << "Argument error.\n";
                return 1;
            }
        }
        
    }

    if (filename.empty()) {
        std::cerr << "Error opening file.\n";
        return 1;
    }

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