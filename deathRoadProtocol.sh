#!/bin/bash

#stty for configuring the terminal behavior
#-icanon to read input without the need of pressing Enter
#-echo for preventing the key presses to apear on screen
stty -icanon -echo

## GLOBAL VARIABLES ##
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

#Colors
red=$'\e[31m'
green=$'\e[32m'
blue=$'\e[34m'
yellow=$'\e[33m'
defaultColor=$'\e[0m'

#Char types
emptyRoadChar='⠀'
playerDefaultChar="${blue}●${defaultColor}"
playerInvincibleChar="${yellow}●${defaultColor}"
playerChar="$playerDefaultChar"
wheelChar='◎'
heartChar="${green}❤${defaultColor}"
starChar="${yellow}★${defaultColor}"
treeChar='ψ'
enemyCarChar="${red}◄${defaultColor}"
enemyBombChar="${red}☢${defaultColor}"


## MENUS ##
function gameMenu {
    local optionSelected
    while true; do
        clear
        echo "
_____________________________________  __   ______________________________ 
___  __ \__  ____/__    |__  __/__  / / /   ___  __ \_  __ \__    |__  __ \ 
__  / / /_  __/  __  /| |_  /  __  /_/ /    __  /_/ /  / / /_  /| |_  / / /
_  /_/ /_  /___  _  ___ |  /   _  __  /     _  _, _// /_/ /_  ___ |  /_/ / 
/_____/ /_____/  /_/  |_/_/    /_/ /_/      /_/ |_| \____/ /_/  |_/_____/  

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   ___  ___  ____  __________  _________  __ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  / _ \/ _ \/ __ \/_  __/ __ \/ ___/ __ \/ / 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ / ___/ , _/ /_/ / / / / /_/ / /__/ /_/ / /__
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀/_/  /_/|_|\____/ /_/  \____/\___/\____/____/                                        

⠀→⠀Press a number to select an option⠀
┏━━━┓⠀┏━━━━━━━━━━━━━━┓
┃⠀1⠀┃⠀┃⠀NEW GAME⠀⠀⠀⠀⠀┃
┗━━━┛⠀┗━━━━━━━━━━━━━━┛
┏━━━┓⠀┏━━━━━━━━━━━━━━┓
┃⠀2⠀┃⠀┃⠀HOW TO PLAY⠀⠀┃
┗━━━┛⠀┗━━━━━━━━━━━━━━┛
┏━━━┓⠀┏━━━━━━━━━━━━━━┓
┃⠀3⠀┃⠀┃⠀EXIT⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
┗━━━┛⠀┗━━━━━━━━━━━━━━┛


⋄ GitHub: https://github.com/Guillermo-Mora/TerminalPursuitProtocol

⋄ Created by Guillermo Mora Mortes
"
        while true; do
            read -n 1 optionSelected
            case "$optionSelected" in
                1)
                    local continueGameOption
                    local continueGame=true
                    while [[ $continueGame == true ]]; do
                        setGameVariables
                        createBoard
                        newGame
                        gameOverScreen
                        while true; do
                            read -n 1 continueGameOption
                            case $continueGameOption in
                                1)
                                    continueGame=true
                                    break
                                    ;;
                                2)
                                    continueGame=false
                                    break
                                    ;;
                            esac
                        done
                    done
                    break
                    ;;
                2)
                    howToPlayMenu
                    break
                    ;;
                3)
                    #I restore the default terminal state before closing the game.
                    stty icanon echo
                    clear
                    exit 0
                    ;;
            esac
        done
    done
}

function howToPlayMenu {
    clear
    echo "
⋄⠀CONTROLS

⠀⠀⠀⠀⠀┏━━━┓
⠀⠀⠀⠀⠀┃⠀w⠀┃
⠀⠀⠀⠀⠀┗━━━┛
┏━━━┓┏━━━┓┏━━━┓
┃⠀A⠀┃┃⠀S⠀┃┃⠀D⠀┃
┗━━━┛┗━━━┛┗━━━┛

⋄⠀OBJECTS

$wheelChar [Wheel] It restores you a wheel
$heartChar [Heart] It restores you all missing wheels
$starChar [Star] Makes you invincible for 10 seconds
$enemyCarChar [Enemy car] Breaks you a wheel
$enemyBombChar [Bomb] Blows your car into a thousand pieces


⠀→⠀Press any key to return to main menu⠀
"
read -n 1
}

function gameOverScreen {
    clear
    echo "
 ▗▄▄▖ ▗▄▖ ▗▖  ▗▖▗▄▄▄▖     ▗▄▖ ▗▖  ▗▖▗▄▄▄▖▗▄▄▖ 
▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌       ▐▌ ▐▌▐▌  ▐▌▐▌   ▐▌ ▐▌
▐▌▝▜▌▐▛▀▜▌▐▌  ▐▌▐▛▀▀▘    ▐▌ ▐▌▐▌  ▐▌▐▛▀▀▘▐▛▀▚▖
▝▚▄▞▘▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖    ▝▚▄▞▘ ▝▚▞▘ ▐▙▄▄▖▐▌ ▐▌                

⋄⠀SCORE: $scoreString
⋄⠀LEVEL: $level

⠀→⠀Press a number to select an option⠀
┏━━━┓⠀┏━━━━━━━━━━━━━━━━━━━━━┓
┃⠀1⠀┃⠀┃⠀NEW GAME⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀┃
┗━━━┛⠀┗━━━━━━━━━━━━━━━━━━━━━┛
┏━━━┓⠀┏━━━━━━━━━━━━━━━━━━━━━┓
┃⠀2⠀┃⠀┃⠀RETURN TO MAIN MENU⠀┃
┗━━━┛⠀┗━━━━━━━━━━━━━━━━━━━━━┛
    "
}


## PREPARE NEW GAME ##
function setGameVariables {
    #Score
    score=0
    scoreFillingZeros="000000"
    scoreString="$scoreFillingZeros$score"
    
    #Level
    level=0
    levelFillingSpaces="⠀⠀⠀⠀⠀⠀"
    levelString="$levelFillingSpaces$level"

    #Wheels
    playerWheels=4
    playerWheelsString="$wheelChar⠀$wheelChar⠀$wheelChar⠀$wheelChar⠀"
    
    #Player
    playerChar="$playerDefaultChar"
    isPlayerInvincible=false
    
    #Player position
    playerRow=2
    playerCol=0
    previousPlayerRow=2
    previousPlayerCol=0
    
    #Timers
    objectsMovementTimer=0
    backgroundMovementTimer=0
    scorePointsTimer=0
    spawnObjectsTimer=0
    invincibilityTimer=0
    
    #Timers limits
    triggerEndInvincibility=500
    triggerBackgroundMovement=8
    triggerObjectsMovement=10
    triggerScorePoint=50
    triggerSpawnObjects=100
    
    #Game state
    isGameOver=false
}

function createBoard {
    for((i=0; i<numRows; i++)) do
        for((j=0; j <numCols; j++)) do
        boardMatrix[$i,$j]=$emptyRoadChar
        done
    done
    boardMatrix[2,0]=$playerChar
}


## NEW GAME LOOP FUNCTION ##
function newGame {
    clear
    while [[ $isGameOver == false ]]; do
        #read for reading keyboard input
        #-n 1 (Read only 1 character per press)
        #-t (Wait that for user input)
        if read -n 1 -t 0.001 key; then
            doKeyPressAction $key
        fi
        #Check timers
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
        #Blinking animation on the last 100 ticks of ivnincibility
        if [[ $isPlayerInvincible == true ]]; then
            if ((invincibilityTimer >= 400 && invincibilityTimer % 10 == 0)); then
                if [[ $playerChar == "$playerInvincibleChar" ]]; then
                    playerChar="$playerDefaultChar"
                else
                    playerChar="$playerInvincibleChar"
                fi
            fi
        fi
        #On each frame, I check for collisions with the player
        checkCollisions
        #This timer has to be checked after collisions. If not, the last frame a player
        #is invincible it could recieve damage, wihch shouldn't happen
        if [[ $isPlayerInvincible == true ]]; then
            if ((invincibilityTimer == triggerEndInvincibility)); then
                endInvincibility
            fi
        fi
        #Add 1 to timers in each frame
        ((
            objectsMovementTimer++,
            backgroundMovementTimer++,
            scorePointsTimer++,
            spawnObjectsTimer++
        ))
        if [[ $isPlayerInvincible == true ]]; then
            ((invincibilityTimer++))
        fi
        #Print current state of the screen (frame)
        printFrame
        #Every 16.67ms (60fps)
        sleep 0.0166666666667
    done
}


## GAME FUNCTIONS ##
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
    if ((triggerSpawnObjects > 10)); then
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
        local zerosToRemove=$((newScoreLenght-currentScoreLenght))
        scoreFillingZeros="${scoreFillingZeros::-zerosToRemove}"
    fi
    scoreString="$scoreFillingZeros$score"
}

function getWheel {
    if ((playerWheels < 4)); then
        ((playerWheels+=$1))
        local wheelChars
        for ((i=0; i<$1; i++)); do
            wheelChars+="$wheelChar⠀"
        done
        playerWheelsString="$wheelChars${playerWheelsString::$((-$1*2))}"
    fi
}

function looseWheel {
    ((playerWheels-=$1))
    local emptyChars
    for ((i=0; i<$1; i++)); do
        emptyChars+="⠀⠀"
    done
    playerWheelsString="${playerWheelsString:$(($1*2))}$emptyChars"
    if ((playerWheels <= 0)); then
        isGameOver=true
    fi
}

function becomeInvincible {
    isPlayerInvincible=true
    playerChar="$playerInvincibleChar"
    invincibilityTimer=0
}

function endInvincibility {
    isPlayerInvincible=false
    playerChar="$playerDefaultChar"
}

function spawnObjects {
    local generatesPowerUp=false
    local generatesEnemies=false
    if ((RANDOM % 100 + 1 <= 12)); then
        generatesPowerUp=true
    fi
    if ((RANDOM % 100 + 1 <= 95)); then
        generatesEnemies=true
    fi
    if $generatesEnemies; then
        local enemiesQuantity
        local enemiesQuantityRandom=$((RANDOM % 100 + 1))
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
    if $generatesPowerUp; then
        local powerUpChar
        local powerUpRandom=$((RANDOM % 100 + 1))
        if ((powerUpRandom <= 10)); then
            powerUpChar="$heartChar"
        elif ((powerUpRandom <= 30)); then
            powerUpChar="$starChar"
        else
            powerUpChar="$wheelChar"
        fi
        local powerUpPosition=$((RANDOM % $numRows))
        boardMatrix[$powerUpPosition,$((numCols-1))]="$powerUpChar"
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
            local enemyRandomType=$((RANDOM % 100 + 1))
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
            if [[ $isPlayerInvincible == false ]]; then
                looseWheel 1
            else
                scorePoints 10
            fi
            ;;
        $enemyBombChar)
            if [[ $isPlayerInvincible == false ]]; then
                looseWheel $playerWheels
            else
                scorePoints 20
            fi
            ;;
        $wheelChar)
            getWheel 1
            scorePoints 10
            ;;
        $heartChar)
            getWheel $((4 - playerWheels))
            scorePoints 100
            ;;
        $starChar)
            becomeInvincible
            scorePoints 50
            ;;
    esac
    if ((playerRow != previousPlayerRow || playerCol != previousPlayerCol)); then
        #The player previous position may now be occuped by an object
        #So I check it before setting it empty
        local previousPositionChar="${boardMatrix[$previousPlayerRow,$previousPlayerCol]}"
        if [[ "$previousPositionChar" == "$playerDefaultChar" || "$previousPositionChar" == "$playerInvincibleChar" ]]; then
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

## GAME ENTRY POINT ##
gameMenu