local FULL = 4 -- number of drops to fill a tube

local tubes = {}
local selectedDrop

local rng = require("colorsRGB")
local colors = {
    "snow", 
    "steelblue",
    "rosybrown",
    "orchid",
    "wheat",
    "thistle",
    "teal"
}

local moves 
local timeRemaining
local timeRemainingTimer
local levelOver = false

local function isEmpty(tube) 
    -- Empty tube = has no drops
end 

local function isFull(tube) 
    -- Full tube = has FULL drops
end

local function isSolved(tube)
    --- complete = is full AND all drops have the same color 
end

local function isAllSolved()
    -- Are all tubes complete (or empty)
end

local function addDrop(drop, tube, animate)
    -- place drop into tube. 

    -- change drop position so that it is 'inside tube' and 'on top' of other drops 
    -- append drop to tube drop collection
end


local function removeDrop(tube, animate) 
    -- remove and return the top drop from given tube or nil.

    -- if tube is empty then return nill

    -- take the top most drop and move it to top of test tube.
    -- remove drop from tube drop collection.
    -- return drop

end 


local function moveDrop(event) 
    -- Pick up/drop a drop from/to selected tube.

    -- we will come back to this later
end

local function startLevel(level)
    -- create level with given parameters

    -- number of colors, number of spare tubes, level difficulty and duration
    local nColors, nSwap, nDifficulty, duration = unpack(level)
    local nTubes = nColors + nSwap


    -- instantiate all of the tubes
        -- put in correct position
        -- table property drops to store drops
        -- add tap event listener to call moveDrop
        -- first nColors tubes start being full of drops of one color

    rng.randomseed(42)

    -- using nDifficulty randomise the starting position
       -- possible algorithm: 
          -- pick random source and destination tubes and move drop if allowed.
          -- repeat based on nDifficulty


    -- initialise game variables (moves, etc)

    -- start countdown clock 
       -- Use timer.performWithDelay with 1 second delay
       -- Need function updateClock to update timeRemaining and text label

end

startLevel({3,2,20, 90})

local function moveDrop( event ) 
    -- Pick up/drop a drop from/to selected tube.

    local tube = event.target

    -- if selectedDrop is nil then 
       -- remove drop from selected tube and save it to selectedDrop

       -- place selectedDrop to selected tube if allowed
       -- update moves count

    -- if game is solved
       -- stop countdown clock
end