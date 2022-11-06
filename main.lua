local composer = require("composer")

-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- Set the highscore to impossible number
composer.setVariable("score", 0)

-- Go to the menu screen
composer.gotoScene("menu")