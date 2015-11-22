local table = table
local pairs = pairs
local ipairs = ipairs
local print = print
local string = require("string")
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local capi = { wibox = wibox,
               keygrabber = keygrabber,
               screen = screen }
module("modal")

local font = "Sans 10"
local data = { actions={}, current=nil, box=nil }

local function centerWibox(box, w, h)
    local g = capi.screen[1].geometry
    box:geometry({ x=(g.width-w)/2, y=g.height-h, width=w, height=h })
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

local function draw(box, current)
    local vertical = wibox.layout.flex.vertical()
    local width = 0
    local height = 0
    local spacer = wibox.widget.textbox()
    spacer.fit = function(_, w, h) return 20, h end
    for k,v in pairsByKeys(current) do
        local key = wibox.widget.textbox()
        key.fit = function(_, w, h) return 80, h end
        key:set_markup("<b>"..k.."</b>")
        --key:set_text(k)
        local exp = wibox.widget.textbox()
        exp:set_markup(v[2] or " . . . ")
        if font then
            key:set_font(font)
            exp:set_font(font)
        end
        local hor = wibox.layout.fixed.horizontal()
        hor:add(spacer)
        hor:add(key)
        hor:add(exp)
        hor:add(spacer)
        vertical:add(hor)
        local w,_ = exp:fit(-1, -1)
        w = w + 80 + 2*20
        if w > width then width = w end
        --local _,h = key:fit(-1, -1)
        local h = 15
        height = height + h
    end
    box:set_widget(vertical)
    centerWibox(box, width, height)
end

local function check(mod, key, event)
    if event == "release" then return true end
    if key == "Escape" then  releaseKeyboard() end
    if data.current then
        local cur = nil
        if key == "Space" or key == "Enter" then
            cur = data.current[" "]
        else
            data.current = data.current[key]
            cur = data.current
        end
        -- action
        if data.current then
            local action = cur[1]
            if action then
                releaseKeyboard()
                action()
            else
                draw(data.box, data.current)
            end
        end
    end
    if not data.current then releaseKeyboard() end
end

function createWibox()
    local beautiful = bt.get()
    local box = capi.wibox({ fg = beautiful.fg_normal,
                       bg = beautiful.bg_normal,
                       border_color = beautiful.border_normal,
                       border_width = beautiful.border_width,
                       font = fnt or beautiful.font })
    box.ontop = true
    box.opacity = 1
    box.screen = 1
    return box
end

function grabKeyboard()
    data.current = data.actions
    if not data.box then data.box = createWibox() end
    data.box.visible = true
    draw(data.box, data.current)
    capi.keygrabber.run(check)
end

function releaseKeyboard()
    data.box.visible = false
    capi.keygrabber.stop()
end

function add(key, func, exp)
    local a = data.actions
    -- match multibyte keys
    for c in key:gmatch"([%z\1-\127\194-\244][\128-\191]*)" do
        if not a[c] then a[c] = {} end
        a = a[c]
    end
    table.insert(a, func)
    table.insert(a, exp)
end

function remove(key)
    local great1 = function(t)
        local count = 0
        for k,v in pairs(t) do
            count = count + 1
            if count > 1 then return true end
        end
        return false
    end
    local removeSub = function(key, k, force)
        local a = data.actions
        for c in key:gmatch"." do
            a = a[c]
            if not a then return false end
        end
        if force or not great1(a) then
            a[k] = nil
            return true
        end
        return false
    end
    local k = string.sub(key, -1)
    local key = string.sub(key, 1, -2)
    if not removeSub(key, k, true) then return end
    while not (key == "") do
        local k = string.sub(key, -1)
        local key = string.sub(key, 1, -2)
        if not removeSub(key, k) then return end
    end
end
