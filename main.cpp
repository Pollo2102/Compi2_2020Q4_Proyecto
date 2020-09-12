#include <iostream>
#include <unordered_map>
#include <string>
#include "expr_tokens.h"
#include "expr_lexer.h"
#include "expr_ast.h"


std::string removeExt(std::string fileName);
std::string removePrefix(std::string filename);

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

    Ast::AstNode *root;
    ExprLexer lexer(in);
    Expr::Parser p(vars, lexer, root);
    try {
        p.parse();
    } catch (std::string& err) {
        std::cerr << err << '\n';
    }
    Ast::SymbolTable symb_tbl;
    std::string data;
    data += ".data\n\n";
    root->eval(vars, data);

    std::ofstream newFile;
    std::string newFileName = removePrefix(filename);
    newFileName = "../files/" + removeExt(newFileName) + ".asm";

    newFile.open(newFileName);
    newFile << ".global main\n\n" << data << "\n.text\n\nmain:\n";
    if (!vars.empty()) {
        newFile <<  "addi $sp, $sp, -4\n" <<
                        "sw $fp, 0($sp)\n" <<
                        "move $fp, $sp\n\n";
    }

    newFile << root->code;

    if (!vars.empty()) {
        newFile << "\nmove $sp, $fp\n" <<
                     "sw $fp, 0($sp)\n" <<
                     "addi $sp, $sp, 4\n";
    }

    newFile.close();
}

std::string removeExt(std::string fileName) {
    std::string newString;
    for (size_t i = 0; i < fileName.size(); i++)
    {
        if (fileName[i] == '.') break;
        else newString += fileName[i];
    }
    return newString;
}

std::string removePrefix(std::string filename) {
    std::string tmp;
    for (size_t i = 0; i < filename.size(); i++)
    {
        if (filename[i] == '/') tmp.clear();
        else tmp += filename[i];
    }
    return tmp;
}