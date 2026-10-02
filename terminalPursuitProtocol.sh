#!/bin/bash

#stty for configuring the terminal behavior
#-icanon to read input without the need of pressing Enter
#-echo for preventing the key presses to apear on screen
stty -icanon -echo

declare -A boardMatrix
numRows=5
numCols=40

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]='-'
        done
    done
    boardMatrix[0,0]='🛼'
    boardMatrix[$((numRows-1)),$((numCols-1))]='☠'
}

function printBoard {
    displayBoard='════════════════════════════════════════\n'
    for((i=0; i<numRows; i++)) do
        for((j=0; j<numCols; j++)) do
            displayBoard+=${boardMatrix[$i,$j]}
        done
        displayBoard+='\n'
    done
    displayBoard+='════════════════════════════════════════'
    echo -e $displayBoard
}

function moveBoardObjects {
    for((i=0; i<numRows; i++)) do
        for((j=0; j<numCols; j++)) do
            local char="${boardMatrix[$i,$j]}"
            if [[ "$char" == "☠" ]]; then
                boardMatrix[$i,$j]='-'
                if ((j-1 >0)); then
                    boardMatrix[$i,$((j-1))]=$char
                fi
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
    #read for reading keyboard input
    #-n 1 (Read only 1 character per press)
    #-t (Wait that time after input detected before closing the input read)
    if read -n 1 -t 0.001 key; then
        echo "Key pressed: $key"
        sleep 3000
    fi
    ((objectsMovementTimer++))
    if ((objectsMovementTimer==10)); then
        moveBoardObjects
        objectsMovementTimer=0
    fi
    printBoard
    #Every 16.67ms (60fps)
    sleep 0.0166666666667
    clear
done