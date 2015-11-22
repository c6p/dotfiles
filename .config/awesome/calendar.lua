-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable
-- modified by Can Altıparmak (gulaghad) under the same licence,

local string = string
--local print = print
local tostring = tostring
local os = os
local io = io
local print = print
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
module("calendar")

local calendar = {}
local id = nil
local current_day_format = "<u>%s</u>"
local cmd = 'str=$(wget -qO- https://www.google.com/calendar/ical/can6parmak%40gmail.com/private-59a3d4dc22f9db6261d1347179c21ead/basic.ics | ical.awk); echo "calendar.parseEvents("\\""$str"\\"")" | awesome-client'
local events = {}


function readEvents()
    --awful.util.spawn_with_shell(cmd)
end

function parseEvents(text)
    events = {}
    text:gsub("(.) (%d%d%d%d%-%d%d)%-(%d%d) (.-)::",
    function(deadline,m,d,summary)
        if (not events[m]) then events[m] = {} end
        events[m][d+0] = deadline
        events[m]["text"] = (events[m]["text"] or "") ..
        "\n  <span color='#" ..  (deadline == 's' and "339" or "933") ..
        "'><u>" .. d .. "</u></span> " .. summary .. "  "
        return nil;
    end)
end


function displayMonth(month,year,weekStart)
    local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
    local d=os.date("*t",t)
    local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

    --print(mthDays .."\n" .. stDay)
    local lines = "    "

    for x=0,6 do
        lines = lines .. os.date("<span color='#777'>%a </span>",os.time{year=2006,month=1,day=x+wkSt})
    end

    lines = lines .. "\n" .. os.date("<span color='#777'> %V</span>",os.time{year=year,month=month,day=1})

    local writeLine = 1
    while writeLine < (stDay + 1) do
        lines = lines .. "    "
        writeLine = writeLine + 1
    end

    local header = os.date(" %B %Y",os.time{year=year,month=month,day=1})
    local monthIndex = os.date("%Y-%m",os.time{year=year,month=month,day=1})
    local days = events[monthIndex] or {}
    for d=1,mthDays do
        local x = d
        local t = os.time{year=year,month=month,day=d}
        if writeLine == 8 then
            writeLine = 1
            lines = lines .. "\n" .. os.date("<span color='#777'> %V</span>",t)
        end
        if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
            x = string.format(current_day_format, d)
        end
        if days[d] then
            x = "<span foreground='#" ..
                (days[d] == 's' and "339" or "933") .. "'><u>"
                .. x .. "</u></span>"
        end
        if (#(tostring(d)) == 1) then
            x = " " .. x
        end
        lines = lines .. "  " .. x
        writeLine = writeLine + 1
    end

    return header .."\n" .. lines ..'\n'..
        (days["text"] and days["text"] .. '\n'  or "")
end

function switchMonth(switchMonths)
    if (#calendar < 3) then return end
    local swMonths = switchMonths or 1
    calendar[1] = calendar[1] + swMonths
    showMonth(calendar[1], calendar[2])
end

function showMonth(month, year, textbox)
    calendar[1] = month
    calendar[2] = year
    if (textbox) then
        textbox:set_markup(string.format('<span font_desc="%s">%s</span>', "monospace", displayMonth(month, year, 2)))
    else
        calendar[3]:set_markup(string.format('<span font_desc="%s">%s</span>', "monospace", displayMonth(month, year, 2)))
    end
end

function addCalendarToWidget(mywidget, custom_current_day_format)
    if custom_current_day_format then current_day_format = custom_current_day_format end

    calendar = { os.date('%m'), os.date('%Y'), awful.tooltip({ objects ={ mywidget } }) }
    mywidget:connect_signal('mouse::enter', function () showMonth(os.date('%m'), os.date('%Y')) end)

    mywidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function() switchMonth(-12) end),
    awful.button({ }, 2, function() showMonth(os.date('%m'), os.date('%Y')) end),
    awful.button({ "Mod4", }, 2, readEvents),
    awful.button({ }, 3, function() switchMonth(12) end),
    awful.button({ }, 4, function() switchMonth(-1) end),
    awful.button({ }, 5, function() switchMonth(1) end)
    ))
    readEvents()
    showMonth(os.date('%m'), os.date('%Y'))
end

function visible(v)
    calendar[3].visible = v
end

