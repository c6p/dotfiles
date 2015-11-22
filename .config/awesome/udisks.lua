local table = table
local pairs = pairs
local print = print
local string = require("string")
local io = require("io")
local awful = require("awful")
local naughty = require("naughty")
local modal = require("modal")
module("udisks")

local devices = {}
local chars = {"j","f","h","g","k","d","s","ş","a","u","r","m","v","ı","e","ö","c","o","w","ç","x","p","q",".","z","1","2","3","4","5","6","7","8","9","0"}
local function generateModalMenu()
    modal.remove("m")   -- mount submenu
    local m_count = 0
    for k,v in pairs(devices) do
        m_count = m_count + 1
        modal.add("m"..chars[m_count], v.func, v.text)
    end
end

function remove(device, notNotify)
    if not notNotify then naughty.notify({ title = "Removed", text = device }) end
    devices[device] = nil
    generateModalMenu()
end

function unmount(device, devtype, notNotify)
    if not notNotify then naughty.notify({ title = "UnMounted", text = "["..devtype.."]   "..device }) end
    if not devices[device] then devices[device] = {} end
    devices[device].mounted = false
    devices[device].func = function() awful.util.spawn("udisks --mount "..device) end
    devices[device].text = "<span color='#161'>mount</span>   "..device.."   ["..devtype.."]"
    generateModalMenu()
end

function mount(device, devtype, mountpoint, notNotify)
    if not notNotify then naughty.notify({ title = "Mounted", text = "["..devtype.."]   "..device.."   on   "..mountpoint }) end
    if not devices[device] then devices[device] = {} end
    devices[device].mounted = true
    devices[device].func = function() awful.util.spawn("udisks --unmount "..device) end
    devices[device].text = "<span color='#a23'>unmount</span>   "..device.."   ("..mountpoint..")   ["..devtype.."]"
    generateModalMenu()
end

function init()
    local f = io.popen("python2 /home/can/.config/awesome/removable.py")
    for dev in f:lines() do
        --local a,b,state,device,devtype,mountpoint = string.find(dev, "(%a+)%s+(/[^ ]+)%s+(%a+)%s+(.*).*$")
        local _,_,state,device,devtype,mountpoint = string.find(dev, "(%a+)%s+(/[^ ]+)%s+(%a+)%s*(.*)$")
        --print(dev,state,device,devtype,mountpoint)
        if state == "mount" then mount(device, devtype, mountpoint, true)
        else unmount(device, devtype, true)
        end
    end
    f:close()
end
