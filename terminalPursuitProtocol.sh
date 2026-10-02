#!/bin/bash

#stty for configuring the terminal behavior
#-icanon to read input without the need of pressing Enter
#-echo for preventing the key presses to apear on screen
stty -icanon -echo

declare -A boardMatrix

numRows=5
numCols=40

playerRow=0
playerCol=0

emptyRoadChar='-'
playerChar='🛼'

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]=$emptyRoadChar
        done
    done
    boardMatrix[0,0]=$playerChar
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
                boardMatrix[$i,$j]=$emptyRoadChar
                if ((j-1 >0)); then
                    boardMatrix[$i,$((j-1))]=$char
                fi
            fi
        done
    done
}

function doKeyPressAction {
    case $1 in
            w)
                if ((playerRow - 1 >= 0)); then
                    boardMatrix[$playerRow,$playerCol]=$emptyRoadChar
                    ((playerRow--))
                    boardMatrix[$playerRow,$playerCol]=$playerChar
                fi
                ;;
            a)
                if ((playerCol - 1 >= 0)); then
                    boardMatrix[$playerRow,$playerCol]=$emptyRoadChar
                    ((playerCol--))
                    boardMatrix[$playerRow,$playerCol]=$playerChar
                fi
                ;;
            s)
                if ((playerRow + 1 < numRows)); then
                    boardMatrix[$playerRow,$playerCol]=$emptyRoadChar
                    ((playerRow++))
                    boardMatrix[$playerRow,$playerCol]=$playerChar
                fi
                ;;
            d)
                if ((playerCol + 1 < numCols)); then
                    boardMatrix[$playerRow,$playerCol]=$emptyRoadChar
                    ((playerCol++))
                    boardMatrix[$playerRow,$playerCol]=$playerChar
                fi
                ;;
        esac
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
        doKeyPressAction $key
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