-- ppm_norns
-- v1.00 @duncangeere
-- https://llllllll.co/t/XXXX
--
-- a single sine tone that 
-- reflects the concentration
-- of CO2 in the atmosphere.
--
-- there are no controls. 
-- 
-- to change the output, change 
-- your habits and elect 
-- politicians who support 
-- strong and immediate climate 
-- action.
--
-- when the tone reaches C4, 
-- we will have likely reached
-- 1.5c of warming, the threshold 
-- for severe climate impacts on 
-- people, wildlife and
-- ecosystems.
--
-- you can also plug in crow to 
-- get a cv output in the 0-10v 
-- range on all four channels.
--
engine.name = "TestSine"
local Graph = include("lib/lightergraph")
local json = include("lib/json")
-- https://github.com/rxi/json.lua

-- Constants
local preindustrial = 278
local threshold = 507
local C0 = 16.35
local C4 = 261.63
local api = "https://global-warming.org/api/co2-api"
local backup = "data.json"

-- Variables
local data
local dataset = {}

-- On startup
function init()
    engine.amp(0)
    local dl = util.os_capture("curl -s -m 30 -k " .. api)
    if (#dl > 0) then
        local File = io.open(_path.code .. "ppm_norns/" .. backup, 'w')
        File:write(dl)
        print("New backup saved")
        File:close()
    else
        io.input(_path.code .. "ppm_norns/" .. backup)
        dl = io.read("*all")
    end
    process(dl)
end

-- Visuals
function redraw()
    -- clear the screen
    screen.clear()

    -- drawing time
    screen.aa(1)
    chart:redraw()

    -- ppm
    screen.font_size(35)
    screen.font_face(19)
    screen.level(11)

    screen.move(0, 38)
    screen.text(string.format("%.0f", data.cycle) .. "ppm")

    -- date
    screen.font_size(8)
    screen.font_face(4)
    screen.level(4)

    screen.move(124, 60)
    screen.text_right(data.year .. "-" .. data.month .. "-" .. data.day)

    -- trigger a screen update
    screen.update()
end

-- Function to run after data is downloaded
function process(download)

    local everything = json.decode(download).co2

    -- Fill out the dataset
    for i = 1, #everything do
        table.insert(dataset, tonumber(everything[i].cycle))
    end

    -- Make the graph
    screen.level(3)
    chart = Graph.new(1, #dataset, "lin", preindustrial, threshold, "lin",
                      "spline", false, false)
    chart:set_position_and_size(0, 0, 128, 64)
    for i = 1, #dataset do chart:add_point(i, dataset[i]) end

    -- Latest datapoint
    data = everything[#everything]
    print(
        "The data " .. data.cycle .. " was gathered on " .. data.year .. "-" ..
            data.month .. "-" .. data.day)

    -- Use the data
    engine.hz(map(data.cycle, preindustrial, threshold, C0, C4))
    local volts = map(data.cycle, preindustrial, threshold, 0, 10)
    for i = 1, 4 do crow.output[i].volts = volts end
    engine.amp(0.5)
    redraw()
end

-- Function to map values from one range to another
function map(n, start, stop, newStart, newStop, withinBounds)
    local value = ((n - start) / (stop - start)) * (newStop - newStart) +
                      newStart

    -- // Returns basic value
    if not withinBounds then return value end

    -- // Returns values constrained to exact range
    if newStart < newStop then
        return math.max(math.min(value, newStop), newStart)
    else
        return math.max(math.min(value, newStart), newStop)
    end
end

-- Runs when script is stopped
function cleanup() engine.amp(0) end
