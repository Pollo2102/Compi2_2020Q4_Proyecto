#!/bin/bash


TEST_FILES_PATH="../TinyPythonEjemplos"
EXE_PATH="./build/TinyPython"

SUCCESSFUL=0
FAILED=0

cd ./build && make && cd ..

echo "=============================="
echo "      Tiny Python Tests"
echo "=============================="
echo ""


echo -e "\e[45m\e[33mHello World Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/HelloWorld.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[44m\e[31mFailed.\e[32m\e[49m"
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mInput World Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/input.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mArithmetic Operators Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/ArithOperators.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mRelational Operators Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/RelOperators.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mIf Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/IfTest.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mWhile Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/WhileTest.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mFor Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/ForTest.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mGCD Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/gcd.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo -e "\e[45m\e[33mSelection Sort Test\e[32m\e[49m"
if $EXE_PATH $TEST_FILES_PATH/SelectionSort.py
then 
    echo -e "\e[44m\e[32mSuccesful\e[32m\e[49m"
    SUCCESSFUL=$((SUCCESSFUL+1))
else 
    echo -e "\e[31mFailed."
    FAILED=$((FAILED+1))
fi

echo "FAILED: $FAILED  SUCCESSFUL: $SUCCESSFUL"
