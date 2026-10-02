#!/bin/bash

declare -A boardMatrix
numRows=5
numCols=40

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]='.'
        done
    done
    boardMatrix[0,0]='🛼'
    boardMatrix[$((numRows-1)),$((numCols-1))]='🚗'
}

function printBoard {
    displayBoard=''
    for((i=0; i<numRows; i++)) do
        for((j=0; j<numCols; j++)) do
            displayBoard+=${boardMatrix[$i,$j]}
        done
        displayBoard+='\n'
    done
    echo -e $displayBoard
}

function moveBoardObjects {
    for((i=0; i<numRows; i++)) do
        for((j=0; j<numCols; j++)) do
            local char="${boardMatrix[$i,$j]}"
            if [[ "$char" == "🚗" ]]; then
                boardMatrix[$i,$j]='.'
                boardMatrix[$i,$((j-1))]=$char
            fi
        done
    done
}

clear
createBoard
objectsMovementTimer=0
#Game loop
while true
do
    ((objectsMovementTimer++))
    if ((objectsMovementTimer==3)); then
        moveBoardObjects
        objectsMovementTimer=0
    fi
    printBoard
    #Every 100 ms (10fps)
    sleep 0.1
    clear
done