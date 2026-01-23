--[[pod_format="raw",created="2024-01-23 00:00:00",modified="2024-01-23 00:00:00",revision=0]]
-- k-razy shoot-out for picotron
-- main entry point

-- This is the main cartridge file for Picotron
-- It loads all the game modules and starts the game

-- Load all modules
include("utils.lua")
include("sprites.lua")
include("collision.lua")
include("arena.lua")
include("entities.lua")
include("hud.lua")
include("main.lua")

-- The game will start via _init() in main.lua
