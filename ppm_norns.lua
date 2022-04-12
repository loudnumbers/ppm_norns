-- ppm_norns
-- v1.00 @duncangeere
-- https://llllllll.co/t/XXXX
--
-- a single tone that reflects the 
-- concentration of CO2 in the atmosphere.
--
-- when it reaches C4, we will have likely
-- reached 1.5C of warming, the threshold 
-- for severe climate impacts on people,
-- wildlife and ecosystems.
--
-- you can also plug in a crow to get a cv
-- output in the 0-10v range.
--
-- to change the output, change your habits
-- and elect politicians who support strong
-- and immediate climate action.
--
local musicutil = require("musicutil")

local json = include("lib/json")
-- https://github.com/rxi/json.lua

local threshold = 507
local api = "https://global-warming.org/api/co2-api"

local dl = util.os_capture("curl -m 30 -k " .. api)

process(dl)

function process(download) print(json.decode(download)) end
