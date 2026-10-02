#!/bin/bash


varExample=2
varTest=4

function f1 {
    echo "Inside first function $varExample"
}

function f2 {
    echo "Inside second function $varTest"
}

function drawBoard {
    boardLineJump=10
    board=(
        '◼' '◼' '◼' '◼' '◼' '◼' '◼' '◼' '◼' '◼'
    )
    for i in ${!board[@]}
    do
        echo ${board[$i]}
        if (( ($i + 1) % 10 == 0 ))
            then echo '\n'
        fi
    done
}

function bidimensionalBoard {
    declare -a boardMatrix
    numRows=9
    numCols=9
    for((i=0;i<=numRows;i++)) do
        for((j=0;j<=numCols;j++)) do
        boardMatrix[$i,$j]='0'
        done
    done

    displayBoard=''
    for i in ${!boardMatrix[@]}
    do
        for j in {0..9}
        do
            displayBoard+=${boardMatrix[$i,$j]}
        done
        displayBoard+='\n'
    done
    echo -e $displayBoard
}

function printBoard {
    displayBoard=''
    for i in ${board[@]}
    do
        displayBoard+=$i'\n'
    done
    echo -e $displayBoard
}

declare -a board
playerPosition=(1 1)
board[0]='◼◼◼◼◼◼◼◼◼◼'
board[1]='◼🚓.......◼'
board[2]='◼........◼'
board[3]='◼........◼'
board[4]='◼◼◼◼◼◼◼◼◼◼'


#Videogame loop
clear
while true
do
    printBoard
    #Cada 100 ms (10fps)
    sleep 0.1
    clear
done