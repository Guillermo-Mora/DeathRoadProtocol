#!/bin/bash

#stty for configuring the terminal behavior
#-icanon to read input without the need of pressing Enter
#-echo for preventing the key presses to apear on screen
stty -icanon -echo

##Board
#Game matrix
declare -A boardMatrix
#Game matriz size
numRows=5
numCols=40
#Background array
backgroundTrees=(
    '⠀' '⠀' '⠀' '⠀' 'ψ'
    '⠀' '⠀' '⠀' '⠀' '⠀'
    '⠀' '⠀' '⠀' '⠀' 'ψ'
    '⠀' '⠀' '⠀' '⠀' '⠀'
    '⠀' '⠀' '⠀' '⠀' 'ψ'
    '⠀' '⠀' '⠀' '⠀' '⠀'
    '⠀' '⠀' '⠀' '⠀' 'ψ'
    '⠀' '⠀' '⠀' '⠀' '⠀'
)
##

##Score
score=0
scoreFillingZeros="000000"
scoreString="$scoreFillingZeros$score"
##

##Player
playerWheels=4
#Player position
playerRow=0
playerCol=0
##

##Char types
emptyRoadChar='-'
playerChar='🛼'
treeChar='ψ'
##

##Timers
objectsMovementTimer=0
backgroundMovementTimer=0
scorePointsTimer=0
##

##Timers limits
triggerBackgroundMovement=8
triggerObjectsMovement=10
triggerScorePoint=50
##

##Constants
scoreLenght=12
##

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]=$emptyRoadChar
        done
    done
    boardMatrix[0,0]=$playerChar
    boardMatrix[$((numRows-1)),$((numCols-1))]='☠'
}

function moveBackground {
    for((i=0; i<numCols; i++)) do
        local currentChar="${backgroundTrees[$i]}"
        if [[ "$currentChar" == "$treeChar" ]]; then
            backgroundTrees[$i]='⠀'
            if (($i-1 >= 0)); then
                backgroundTrees[$((i-1))]=$treeChar
            else
                backgroundTrees[$((numCols-1))]=$treeChar
            fi
        fi
    done
}

function scorePoint {
    local currentScoreLenght="${#score}"
    ((score++))
    local newScoreLenght="${#score}"
    if ((newScoreLenght > currentScoreLenght)); then
        #I remove last character from the filling zeros
        scoreFillingZeros="${scoreFillingZeros::-1}"
    fi
    scoreString="$scoreFillingZeros$score"
}

function printBoard {
    local backgroundTreesString=''
    for i in "${backgroundTrees[@]}"
    do
        backgroundTreesString+="$i"
    done
    local displayBoard="┏━━━━━━━━━━━━━━━━┓⠀⠀⠀⠀⠀┏━━━━━━━━━━━━━━━━━┓
    \n┃⠀SCORE:⠀$scoreString⠀┃⠀⠀⠀⠀⠀┃⠀WHEELS:⠀⊙⠀⊙⠀⊙⠀⊙⠀┃
    \n┗━━━━━━━━━━━━━━━━┛⠀⠀⠀⠀⠀┗━━━━━━━━━━━━━━━━━┛
    \n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┃$backgroundTreesString┃
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┃════════════════════════════════════════┃\n"
    for((i=0; i<numRows; i++)) do
        displayBoard+='┃'
        for((j=0; j<numCols; j++)) do
            displayBoard+=${boardMatrix[$i,$j]}
        done
        displayBoard+='┃\n'
    done
    displayBoard+="┃════════════════════════════════════════┃
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┃$backgroundTreesString┃
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
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
#Game loop
while true
do
    printBoard
    #read for reading keyboard input
    #-n 1 (Read only 1 character per press)
    #-t (Wait that for user input)
    if read -n 1 -t 0.001 key; then
        doKeyPressAction $key
    fi
    #Check timers
    if ((objectsMovementTimer == triggerObjectsMovement)); then
        moveBoardObjects
        objectsMovementTimer=0
    fi
    if ((backgroundMovementTimer == triggerBackgroundMovement)); then
        moveBackground
        backgroundMovementTimer=0
    fi
    if ((scorePointsTimer == triggerScorePoint)); then
        scorePoint
        scorePointsTimer=0
    fi
    #Add 1 to timers in each frame
    ((objectsMovementTimer++))
    ((backgroundMovementTimer++))
    ((scorePointsTimer++))
    #Every 16.67ms (60fps)
    sleep 0.0166666666667
    #Clear screen after each frame
    clear
done