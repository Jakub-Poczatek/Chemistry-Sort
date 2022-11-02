-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local FULL = 4  -- number of drops to full a tube
-- local level = {1,2,2,90}
-- local level = {2,2,3,90}
local level = {3,2,50,90}
local tubes = { }
local selectedDrop
local state -- playing

---@diagnostic disable-next-line: deprecated
if not table.unpack then table.unpack=unpack end

local rng = require("rng")

local colorsRGB = require("colorsRGB")
local colors = {
    "snow",
    "steelblue",
    "rosybrown",
    "orchid",
    "wheat",
    "thistle",
    "teal"
}

local moves = {}
local solution = {}

local timeRemaining
local timeRemainingTimer
local levelOver = false
local movesText
local timeText
local scoreText

local printState

local function quit()
    print("Not implemented - quit")
end

local startLevel


local function reset()
    -- remove existing display objects
    for t = #tubes, 1, -1 do
        local tube = tubes[t]
        for d = #tube.drops, 1, -1 do
            local drop = tube.drops[d]
            display.remove(drop)
            table.remove(tube.drops)
        end
        display.remove(tube)
        table.remove(tubes)
    end
    if selectedDrop~=nil then
        display.remove(selectedDrop)
        selectedDrop = nil
    end
    timer.cancel(timeRemainingTimer)

    startLevel(level)
end

local removeDrop
local addDrop
local function undo()
    if #moves==0 then return end
    local move = table.remove(moves)
    local drop = removeDrop(tubes[move.to], true)
    addDrop(drop, tubes[move.from], true)
    movesText.text = "Moves: "..#moves
    printState()
end

local function hint()
    print("Not implemented - hint")    
end

local printSolution
local search
local function solve()
    print("Not implemented - solve")
    search()
    printSolution()
end

local menu = {
    {name="Quit", onClick=quit},
    {name="Reset", onClick=reset},
    {name="Undo", onClick=undo},
    {name="Hint", onClick=hint},
    {name="Solve", onClick=solve}
}

local menuTextColor = {
    highlight = {r=1, g=1, b=1},
    shadow = {r=0.2, g=0.7, b=0.7}
}

local function myNewLabel(display, text, x, y, scale)
    local obj = display.newEmbossedText(text, x, y, native.systemFont, scale)
    obj.anchorX = 0
    obj.anchorY = 1

    obj:setFillColor( 0.5 )
    obj:setEmbossColor( menuTextColor )

    return obj
end


movesText = myNewLabel(display, "Moves: 0", 20, 50, 20)
timeText = myNewLabel(display, "Time: 0", display.contentWidth-60, movesText.y, 20)

local x = display.contentCenterX - 100
for _,v in ipairs(menu) do
    v.button = myNewLabel(display, v.name, x, movesText.y, 20)
    x = x + v.button.width + 10
    v.button:addEventListener("tap", v.onClick)
end

local function updateClock()
    timeRemaining = timeRemaining - 1
    local seconds = timeRemaining % 60
    local minutes = math.floor(timeRemaining/60)
    local s = string.format("%02d:%02d", minutes, seconds)
    timeText.text = "Time: "..s
end

local function update()

end

local function isEmpty(tube)
    -- Empty tube = has no drops
    return #tube.drops==0
end

local function isFull(tube)
    -- Full tube = has FULL drops
    return #tube.drops==FULL
end

local function isSolved(tube)
    --- complete = is full AND all drops have the same color 

    if isEmpty(tube) or not isFull(tube) then return false end

    -- not empty => must have at least one drop 
    local color = tube.drops[1].color
    for k = 2, #tube.drops do
        if tube.drops[k].color~=color then return false end
    end
    return true
end

local function isAllSolved()
    -- Are all tubes complete (or empty)
    for k,tube in ipairs(tubes) do
        if not isEmpty(tube) and not isSolved(tube) then return false end
    end

    return true
end

local function endLevel()

end


local function computeScore()
    local total = 0
    local score = 0
    for _,tube in ipairs(tubes) do
        score = 0
        if not isEmpty(tube) then
            local drops = tube.drops
            local solvedColor = drops[1].color
            for k, drop in ipairs(drops) do
                if drop.color~=solvedColor then break end 
                score = score + k
            end
        end

        tube.label.text = tube.k .. " (" .. score .. ")"
        total = total + score
    end

    scoreText.text = total
    return total
end


printSolution = function()
    print("Solution\n\tFrom\tTo\t\tScore")
    for _,move in ipairs(solution) do
        print(move.from, move.to, move.score)
    end
end


local function topColor(tube) 
    if isEmpty(tube) then return nil end
    return tube.drops[#tube.drops].color
end

search = function()
    solution = {}
    state = 'search'

    -- define and call recursive search 
    local function rsearch(depth, maxDepth, debug)

        local indent = "" 
        for k = 1, depth do indent = indent .. "\t" end
        local total = computeScore()
        if depth>maxDepth then return total end
        if isAllSolved() then return (maxDepth+1-depth)*total end
        local bestMove = { from=0, to=0, score=-1 }
        for _,fromTube in ipairs(tubes) do
            if not isSolved(fromTube) and not isEmpty(fromTube) then
                local drop = fromTube.drops[#fromTube.drops]
                if debug then print(indent, "from", fromTube.k, drop.color) end
                for __,toTube in ipairs(tubes) do
                   if fromTube.k~=toTube.k and not isFull(toTube) and (isEmpty(toTube) or topColor(toTube)==drop.color) then
                    if debug then print(indent, "to", toTube.k) end
                        addDrop(removeDrop(fromTube), toTube)
                        local score = rsearch(depth+1, maxDepth)
                        if debug then print(indent, "score", score) end
                        addDrop(removeDrop(toTube), fromTube)
                        if score > bestMove.score then
                            bestMove = {from=fromTube.k, to=toTube.k, score=score}
                        end
                   end
                end
                --table.insert(fromTube.drops, drop)
            end
        end
        print(indent, "Best Score", bestMove.score)
        if depth==1 then
            table.insert(solution, bestMove) 
        end

        return bestMove.score
    end
    rsearch(1, 1)

    state = 'playing'

    print("Solution")
    for _,move in ipairs(solution) do
        print(move.from, move.to, move.score)
    end
end

addDrop = function(drop, tube, animate)
    -- place drop into tube 

    -- change drop position so that it is 'inside tube' and 'on top' of other drops 
    local x = tube.x 
    local y = tube.y + 69 - (#tube.drops)*42
    if animate then 
        transition.moveTo(drop, {x=x,y=y, time=150, 
        onComplete=function()
            if isAllSolved() and state=="playing" then endLevel() end
        end
        })
    else     
        drop.x = x
        drop.y = y
    end
    -- append drop to tube drop collection
    table.insert(tube.drops, drop)
end


removeDrop = function(tube, animate)
    -- remove and returns the top drop from given tube or nil.

    -- if tube is empty then return nill
    if isEmpty(tube) then return nil end

    -- remove the top most drop from tube drop collection.
    local drop = table.remove(tube.drops)
    -- move drop to top of test tube.
    local y = tube.y - 120
    if animate then 
        transition.moveTo(drop, {y=y, time=150})
    else
        drop.y = y
    end
    -- return drop
    return drop 
end


local function moveDrop(event)

    local tube = event.target
 
    print("tube:moveDrop", tube.k)

    -- Pick up/drop a drop from/to selected tube.
    if selectedDrop==nil then -- pickup
        selectedDrop = removeDrop(tube, true)
        selectedDrop.k = tube.k
    elseif tube.k == selectedDrop.k then -- canceling a move
        addDrop(selectedDrop, tube, true)
        selectedDrop = nil
    else -- dropping  
        local colorMatch = (not isEmpty(tube) and selectedDrop.color==tube.drops[#tube.drops].color)   
        if (not isFull(tube) and colorMatch) or isEmpty(tube) then
            addDrop(selectedDrop, tube, true)
            table.insert(moves, {from=selectedDrop.k, to=tube.k})
            selectedDrop = nil
            movesText.text = "Moves: "..#moves
            computeScore()
        end
    end
    printState()
end


printState = function() 
    -- devel helper function that outputs game state and info
    print("\nGame State")

    print("\ntube", "num drops", "isEmpty", "isFull", "isSolved")
    print("t\tn")
    for k,tube in ipairs(tubes) do
        print(k, #tube.drops, isEmpty(tube), isFull(tube), isSolved(tube))
    end
    print ("isAllSolved = ", isAllSolved())

    print ("Move list:")
    for k,move in ipairs(moves) do
        print(k, move.from, move.to )
    end

end


startLevel = function(level)
    -- create level with given parameters

    -- number of colors, number of spare tubes, level difficulty and duration
    local nColors, nSwap, nDifficulty, duration = table.unpack(level)
    local nTubes = nColors + nSwap

    scoreText = display.newText("score", display.contentCenterX, 60, native.systemfont, 15)

    -- instantiate all of the tubes
    for k = 1, nTubes do
        local tube = display.newImageRect("assets/tube.png", 70, 197)
        table.insert(tubes,tube)

        -- put in correct position
        tube.y = display.contentCenterY + 40
        tube.x = display.contentCenterX - (nTubes/2-k+0.5)*80

        tube.k = k
        tube.label = display.newText(k, tube.x, tube.y+tube.height/2+10, native.systemfont, 15)

        -- table property drops to store drops
        tube.drops = {}

        -- add tap event listener to call moveDrop
        tube:addEventListener("tap", moveDrop)

        -- first nColors tubes start being full of drops of one color
        if k<=nColors then
            for d = 1, FULL do 

                local y = tube.y + 69 - (#tube.drops)*42        
                local drop = display.newCircle(tube.x, y, 20)
                table.insert(tube.drops, drop)
                drop.color = colors[k]
                drop:setFillColor(table.unpack(colorsRGB[drop.color]))
            end
        end
    end

    rng.randomseed(42)

    -- using nDifficulty randomise the starting position
       -- possible algorithm: 
          -- pick random source and destination tubes and move drop if allowed.
          -- repeat based on nDifficulty
    for n = 1, 5*nDifficulty do
        local src = tubes[rng.random(#tubes)]
        local dest = tubes[rng.random(#tubes)]
        if src~=dest and not isEmpty(src) and not isFull(dest) then
            addDrop(removeDrop(src), dest)
        end
    end

    -- initialise game variables (moves, etc)

    -- start countdown clock 
       -- Use timer.performWithDelay with 1 second delay
       -- Need function updateClock to update timeRemaining and text label

    printState()

    state = "playing"
    moves = {}
    movesText.text = "Moves: "..#moves
    timeRemaining = duration + 1
    updateClock()
    timeRemainingTimer = timer.performWithDelay(1000, updateClock, timeRemaining)
    selectedDrop = nil
    computeScore()
end


startLevel(level)