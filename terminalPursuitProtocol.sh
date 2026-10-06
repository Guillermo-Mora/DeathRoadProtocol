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
#Colors
red=$'\e[31m'
green=$'\e[32m'
blue=$'\e[34m'
yellow=$'\e[33m'
defaultColor=$'\e[0m'
##

##Score
score=0
scoreFillingZeros="000000"
scoreString="$scoreFillingZeros$score"
##

#Level
level=0
levelFillingSpaces="⠀⠀⠀⠀⠀⠀"
levelString="$levelFillingSpaces$level"

##Char types
emptyRoadChar='⠀'
playerChar="${blue}●${defaultColor}"
wheelChar='◎'
heartChar="${green}❤${defaultColor}"
starChar="${yellow}★${defaultColor}"
treeChar='ψ'
enemyCarChar="${red}◄${defaultColor}"
enemyBombChar="${red}☢${defaultColor}"
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

#Game state
gameOver=false
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

function levelUp {
    local currentLevelLenght="${#level}"
    ((level++))
    local newLevelLenght="${#level}"
    if ((newLevelLenght > currentLevelLenght)); then
        levelFillingSpaces="${levelFillingSpaces::-1}"
    fi
    levelString="$levelFillingSpaces$level"
    if ((triggerObjectsMovement > 1)); then
        ((triggerObjectsMovement--))
    fi
    if ((triggerSpawnObjects > 15)); then
        ((triggerSpawnObjects -= 5))
    fi
    if ((level % 2 == 0 && triggerBackgroundMovement > 2)); then
        ((triggerBackgroundMovement--))
    fi
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
    ((playerWheels-=$1))
    local emptyChars
    for ((i=0; i<$1; i++)); do
        emptyChars+="⠀⠀"
    done
    #I remove first two characters and add two filling spaces
    playerWheelsString="${playerWheelsString:${#emptyChars}}$emptyChars"
    if ((playerWheels <= 0)); then
        gameOver=true
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

function printFrame {
    local gameStatsRow=0
    local gameStats=(
        "┏━━━━━━━━━━━━━━━━━┓"
        "┃⠀WHEELS:⠀$playerWheelsString┃"
        "┗━━━━━━━━━━━━━━━━━┛"
        "┏━━━━━━━━━━━━━━━━━┓" 
        "┃⠀SCORE:⠀⠀$scoreString⠀┃" 
        "┗━━━━━━━━━━━━━━━━━┛" 
        "┏━━━━━━━━━━━━━━━━━┓" 
        "┃⠀LEVEL:⠀⠀$levelString⠀┃" 
        "┗━━━━━━━━━━━━━━━━━┛" 
    )
    local backgroundTreesString=''
    for i in "${backgroundTrees[@]}"
    do
        backgroundTreesString+="$i"
    done
    local displayBoard="
    \n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${gameStats[$((gameStatsRow++))]}
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃${gameStats[$((gameStatsRow++))]}
    \n┃$backgroundTreesString┃${gameStats[$((gameStatsRow++))]}
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃${gameStats[$((gameStatsRow++))]}
    \n┃════════════════════════════════════════┃${gameStats[$((gameStatsRow++))]}\n"
    for((i=0; i<numRows; i++)) do
        displayBoard+='┃'
        for((j=0; j<numCols; j++)) do
            displayBoard+=${boardMatrix[$i,$j]}
        done
        displayBoard+="┃${gameStats[$((gameStatsRow++))]}\n"
    done
    displayBoard+="┃════════════════════════════════════════┃
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┃$backgroundTreesString┃
    \n┃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
    \n┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    #I now do the clear of the screen here to reduce screen flickering as much as possible.
    #As converting the matrix to a string can also take some CPU time to display
    #Clear screen each frame after all the calculations have been performed
    #This is what causes flickering on some terminal emulators, as all the screen
    #is being cleared and generated again, and not the moving parts only. However, I still don't
    #know how to solve this.
    clear
    #Print the new frame on screen
    echo -e $displayBoard
}

function moveBoardObjects {
    for((i=0; i<numRows; i++)) do
        for((j=0; j<numCols; j++)) do
            local char="${boardMatrix[$i,$j]}"
            if [[ "$char" != "$emptyRoadChar" && "$char" != "$playerChar" ]]; then
                boardMatrix[$i,$j]=$emptyRoadChar
                if ((j-1 >= 0)); then
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
            looseWheel 1
            ;;
        $enemyBombChar)
            looseWheel $playerWheels
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
while [[ $gameOver == false ]]
do
    #read for reading keyboard input
    #-n 1 (Read only 1 character per press)
    #-t (Wait that for user input)
    if read -n 1 -t 0.001 key; then
        doKeyPressAction $key
    fi
    #Check timers and other things
    if ((objectsMovementTimer >= triggerObjectsMovement)); then
        moveBoardObjects
        objectsMovementTimer=0
    fi
    if ((spawnObjectsTimer >= triggerSpawnObjects)); then
        spawnObjects
        spawnObjectsTimer=0
    fi
    if ((backgroundMovementTimer >= triggerBackgroundMovement)); then
        moveBackground
        backgroundMovementTimer=0
    fi
    if ((scorePointsTimer == triggerScorePoint)); then
        scorePoints 1
        if ((score % 10 == 0)); then
            levelUp
        fi
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
    #Print current state of the screen (frame)
    printFrame
    #Every 16.67ms (60fps)
    sleep 0.0166666666667
done
clear
echo "GAME OVER ☠"
#I restore the default terminal state before closing the game.
stty icanon echo