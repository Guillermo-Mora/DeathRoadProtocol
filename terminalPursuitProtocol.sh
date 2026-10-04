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

##Constants
scoreLenght=12
#Colors
red=$'\e[31m'
green=$'\e[32m'
blue=$'\e[34m'
reset=$'\e[0m'
##

##Score
score=0
scoreFillingZeros="000000"
scoreString="$scoreFillingZeros$score"
##

##Char types
emptyRoadChar='⠀'
playerChar="${blue}●${reset}"
wheelChar='◎'
treeChar='ψ'
enemyCarChar="${red}◄${reset}"
enemyBombChar="${red}☢${reset}"
##

##Player
playerWheels=4
playerWheelsString="$wheelChar⠀$wheelChar⠀$wheelChar⠀$wheelChar⠀"
#Player position
playerRow=0
playerCol=0
previousPlayerRow=0
previousPlayerCol=0
##

##Timers
objectsMovementTimer=0
backgroundMovementTimer=0
scorePointsTimer=0
spawnObjectsTimer=0
##

##Timers limits
triggerBackgroundMovement=8
triggerObjectsMovement=10
triggerScorePoint=50
triggerSpawnObjects=100
##

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]=$emptyRoadChar
        done
    done
    boardMatrix[0,0]=$playerChar
    boardMatrix[$((numRows-1)),$((numCols-1))]="$enemyCarChar"
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

function scorePoints {
    local currentScoreLenght="${#score}"
    ((score+=$1))
    local newScoreLenght="${#score}"
    if ((newScoreLenght > currentScoreLenght)); then
        #I remove last character from the filling zeros
        scoreFillingZeros="${scoreFillingZeros::-1}"
    fi
    scoreString="$scoreFillingZeros$score"
}

function getWheel {
    if ((playerWheels < 4)); then
        ((playerWheels++))
        #I remove last two characters and add a wheel with space at the start
        playerWheelsString="$wheelChar⠀${playerWheelsString::-2}"
    fi
}

function looseWheel {
    ((playerWheels--))
    #I remove first two characters and add two filling spaces
    playerWheelsString="${playerWheelsString:2}⠀⠀"
    if ((playerWheels == 0)); then
        echo "The player dies"
    fi
}

function spawnObjects {
    local generatesWheel=false
    local generatesEnemies=false
    if (((1 + RANDOM % 100) <= 3)); then
        generatesWheel=true
    fi
    if (((1 + RANDOM % 100) <= 95)); then
        generatesEnemies=true
    fi
    if $generatesEnemies; then
        local enemiesQuantity
        local enemiesQuantityRandom=$((1 + RANDOM % 100))
        if ((enemiesQuantityRandom <= 5)); then
            enemiesQuantity=4
        elif ((enemiesQuantityRandom <= 25)); then
            enemiesQuantity=3
        elif ((enemiesQuantityRandom <= 80)); then
            enemiesQuantity=2
        else
            enemiesQuantity=1
        fi
    fi
    if $generatesWheel; then
        local wheelPosition=$((RANDOM % $numRows))
        boardMatrix[$wheelPosition,$((numCols-1))]="$wheelChar"
    fi
    if $generatesEnemies; then
        local enmeyRandomPosition
        local randomPositionCurrentChar
        for ((i=0; i<enemiesQuantity; i++))
        do
            enmeyRandomPosition=$((RANDOM % $numRows))
            randomPositionCurrentChar="${boardMatrix[$enmeyRandomPosition,$((numCols-1))]}"
            while [[ "$randomPositionCurrentChar" != "$emptyRoadChar" ]]
            do
                if ((enmeyRandomPosition <= 3)); then
                    ((enmeyRandomPosition++))
                else
                    enmeyRandomPosition=0
                fi
                randomPositionCurrentChar="${boardMatrix[$enmeyRandomPosition,$((numCols-1))]}"
            done
            local enemyRandomType=$((1 + RANDOM % 100))
            local enemy
            if ((enemyRandomType <= 15)); then
                enemy="$enemyBombChar" 
            else
                enemy="$enemyCarChar"
            fi
            boardMatrix[$enmeyRandomPosition,$((numCols-1))]="$enemy"
        done
    fi
}

function printBoard {
    local backgroundTreesString=''
    for i in "${backgroundTrees[@]}"
    do
        backgroundTreesString+="$i"
    done
    local displayBoard="┏━━━━━━━━━━━━━━━━┓⠀⠀⠀⠀⠀┏━━━━━━━━━━━━━━━━━┓
    \n┃⠀SCORE:⠀$scoreString⠀┃⠀⠀⠀⠀⠀┃⠀WHEELS:⠀$playerWheelsString┃
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
            if [[ "$char" != "$emptyRoadChar" && "$char" != "$playerChar" ]]; then
                boardMatrix[$i,$j]=$emptyRoadChar
                if ((j-1 >0)); then
                    boardMatrix[$i,$((j-1))]=$char
                fi
            fi
        done
    done
}

function checkCollisions {
    local newPlayerPositionChar="${boardMatrix[$playerRow,$playerCol]}"
    case $newPlayerPositionChar in
        $enemyCarChar)
            looseWheel
            ;;
        $enemyBombChar)
            looseWheel
            ;;
        $wheelChar)
            getWheel
            ;;
    esac
    if ((playerRow != previousPlayerRow || playerCol != previousPlayerCol)); then
        #The player previous position may now be occuped by an object
        #So I check it before setting it empty
        local previousPositionChar="${boardMatrix[$previousPlayerRow,$previousPlayerCol]}"
        if [[ "$previousPositionChar" == "$playerChar" ]]; then
            boardMatrix[$previousPlayerRow,$previousPlayerCol]=$emptyRoadChar
        fi
    fi
    boardMatrix[$playerRow,$playerCol]=$playerChar
}

function doKeyPressAction {
    previousPlayerCol=$playerCol
    previousPlayerRow=$playerRow
    case $1 in
        w)
            if ((playerRow - 1 >= 0)); then
                ((playerRow--))
            fi
            ;;
        a)
            if ((playerCol - 1 >= 0)); then
                ((playerCol--))
            fi
            ;;
        s)
            if ((playerRow + 1 < numRows)); then
                ((playerRow++))
            fi
            ;;
        d)
            #I prevent the player to position in the last column, as
            #it's where the random objects generate.
            if ((playerCol + 1 < numCols-1)); then
                ((playerCol++))
            fi
            ;;
    esac
}

clear
createBoard
#Game loop
while true
do
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
    if ((spawnObjectsTimer == triggerSpawnObjects)); then
        spawnObjects
        spawnObjectsTimer=0
    fi
    if ((backgroundMovementTimer == triggerBackgroundMovement)); then
        moveBackground
        backgroundMovementTimer=0
    fi
    if ((scorePointsTimer == triggerScorePoint)); then
        scorePoints 1
        scorePointsTimer=0
    fi
    #On each frame, I check for collisions with the player
    checkCollisions
    #Add 1 to timers in each frame
    ((
        objectsMovementTimer++,
        backgroundMovementTimer++,
        scorePointsTimer++,
        spawnObjectsTimer++
    ))
    #Print current state of the board (frame)
    printBoard
    #Every 16.67ms (60fps)
    sleep 0.0166666666667
    #Clear screen after each frame
    clear
done