local os = os
local io = io
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
--local image = require("image")
module("mpc")

local modkey = "Mod4"
local icon
local tip
local mpcInfo = {}

local function readStatus()
    local n = os.tmpname()
    os.execute ("mpc -f '%title%\n%artist%\n%album%' > " .. n)
    local f = io.open(n)
    mpcInfo.status = f:read("*all")
    f:close()
    os.remove(n)
    -- update song info
    local c=0
    _,c,mpcInfo.title =  mpcInfo.status:find("^([^\n]*)\n")
    _,c,mpcInfo.artist = mpcInfo.status:find("\n([^\n]*)\n", c)
    _,_,mpcInfo.album = mpcInfo.status:find("\n([^\n]*)\n", c)
    _,_,mpcInfo.volume = mpcInfo.status:find("volume:(%d+)%%")
end

local function state()
    local _,_,s = mpcInfo.status:find("%[(%a+)%]")
    if (s == "playing") then
        return "play"
    elseif (s == "paused") then
        return "pause"
    else
        return "stop"
    end
end

function updateTooltip()
    if mpcInfo.album then
        tip:set_text("<big><b> " .. mpcInfo.title .. " </b></big>\n by " .. mpcInfo.artist .. " \n (" .. mpcInfo.album .. ")")
        return "<big><b> " .. mpcInfo.title .. " </b></big>\n by " .. mpcInfo.artist .. " \n (" .. mpcInfo.album .. ")"
    else
        tip:set_text("")
        return ""
    end
end

function setState(state)
    if (state == "stop") then
        icon:set_image(beautiful.media_stop)
    elseif (state == "play") then
        icon:set_image(beautiful.media_play)
    elseif (state == "pause") then
        icon:set_image(beautiful.media_pause)
    elseif (state == "newsong") then
        readStatus()
        updateTooltip()
    end
end

function getWidget()
    awful.util.spawn_with_shell("bash " .. awful.util.getdir("config") .. "/awesome-mpc.sh")
    icon = wibox.widget.imagebox()
    wibox.widget.base.buttons(icon, awful.util.table.join(
        awful.button({ }, 1, function() awful.util.spawn("mpc -q toggle") end),
        awful.button({ }, 2, function() awful.util.spawn("urxvtcd -e ncmpcpp") end),
        awful.button({ }, 3, function() awful.util.spawn("mpc -q stop") end),
        awful.button({ modkey }, 1, function() awful.util.spawn("mpc -q prev") end),
        awful.button({ modkey }, 3, function() awful.util.spawn("mpc -q next") end)
        ))
    readStatus()
    setState(state())
    tip = awful.tooltip({ objects = { icon }, })
    updateTooltip()
    return icon
end

