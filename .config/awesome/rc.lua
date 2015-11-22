-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
--require("menubar")
-- My libs
local calendar = require("calendar")
--local mpc = require("mpc")
local modal = require("modal")
--local udisks = require("udisks")

naughty.config.defaults.icon_size = 96

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

function quit()
--    awful.util.spawn_with_shell("emacsclient -e '(server-shutdown t)'")
    awesome.quit()
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
config = awful.util.getdir("config")
beautiful.init(config .. "/theme.lua")
beautiful.wallpaper = "/home/can/data/images/wallpaper/space_shuttle_discovery_launch-wide.jpg"
--beautiful.wallpaper = "/home/can/data/images/WP/big_7a06ce07461f758a2aeaf19db433183d4634b1ee.png"
--beautiful.wallpaper = "/home/can/data/images/WP/ch.jpg"
for s = 1, screen.count() do
	--gears.wallpaper.centered(beautiful.wallpaper, s)
	gears.wallpaper.maximized(beautiful.wallpaper, s)
end

-- This is used later as the default terminal and editor to run.
terminal = "urxvtcd"
filemanager = terminal .. " -e ranger"
editor = "gvim"
editor_cmd = editor

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.max,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = { "f", "t", "m", "t1", "t2", "t3", "F", "T", "M" },
    layout = { layouts[1], layouts[2], layouts[3],
               layouts[2], layouts[2], layouts[2],
               layouts[1], layouts[2], layouts[3] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}


-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M", 30)
mytextclock.fit = function(_, w, h) return 45, h end
mytextclock:set_align("center")
mytextclock:set_font("Sans Mono Bold 10")
calendar.addCalendarToWidget(mytextclock, "<b><span background='white'>%s</span></b>")

-- Create a audio volume widget
function updateVolume(widget, vol)
    local cmd = "amixer -M sget Master"
    if vol then
        cmd = "amixer -M sset Master " .. vol
    end
    local fd = io.popen(cmd)
    local status = fd:read("*all")
    fd:close()
    local volume = string.match(status, "(%d?%d?%d)%%")
    volume = string.format("%3d", volume)
    status = string.match(status, "%[(o[^%]]*)%]")
    if string.find(status, "on", 1, true) then
    	volume = volume .. "<b><big> </big></b>"
    else
    	volume = volume .. "<b><big>M</big></b>"
    	--volume = "<span strikethrough='true'>" .. volume .. "</span>"
    end
	widget:set_markup("<span font='BitstreamVeraSansMono 7.5' color='white'>" .. volume .. "</span>")
end

myvol = wibox.widget.textbox()
volbg = wibox.widget.background()
volbg:set_bgimage(beautiful.audio)
volbg:set_widget(myvol)
myvol:buttons(awful.util.table.join(
    awful.button({ }, 4, function() updateVolume(myvol, "5%+") end),
 	awful.button({ }, 5, function() updateVolume(myvol, "5%-") end),
 	awful.button({ }, 3, function() updateVolume(myvol, "100%") end),
 	awful.button({ }, 2, function() updateVolume(myvol, "35%") end),
 	awful.button({ }, 1, function() updateVolume(myvol, "toggle") end)
))
updateVolume(myvol)

-- Battery widget
function hsv2html(H, S, V)
    local S, V = S/100, V/100;
    local Hi = math.floor(H/60);
    local C = V * S;
    local X = C * (1- math.abs((H/60)%2 -1));
    local m = V - C;
    C = math.floor( (C+m) * 255);
    X = math.floor( (X+m) * 255);
    m = math.floor(m * 255);
    if Hi == 0 then
        return string.format("#%x%x%x", C, X ,m);
    elseif Hi == 1 then
        return string.format("#%x%x%x", X ,C, m);
    elseif Hi == 2 then
        return string.format("#%x%x%x", m, C, X);
    elseif Hi == 3 then
        return string.format("#%x%x%x", m, X, C);
    elseif Hi == 4 then
        return string.format("#%x%x%x", X, m ,C);
    elseif Hi == 5 then
        return string.format("#%x%x%x", C, m ,X);
    end
end


function updateBattery(widget, bg)
    local fd = io.popen("bin/poll_battery")
    local text = fd:read("*all")
    fd:close()
    local ac, status, percent = string.match(text, "(%d)%s+(%a+)%s+(%w+)")
    --percent = string.format("%3d", percent)
    if (status == "Discharging") then
        status = "-"
    elseif (status == "Charging") then
        status = "+"
    else
        status = ""
    end
    text = percent .. status
    if (ac == "1") then
    	text = "<span underline='double'>" .. text .. "</span>"
    end
    bg:set_bg(hsv2html(tonumber(percent), 20, 90))
	--widget:set_text(text)
	widget:set_markup("<span font='BitstreamVeraSansMono 7.5'>" .. text .. "</span>")
    --bat_t = awful.tooltip({ objects = { widget},})
    --bat_t:set_text(status)
end

mybat = wibox.widget.textbox()
batbg = wibox.widget.background()
batbg:set_widget(mybat)
--batbg:set_bg("linear : 0,0,30,0 : 0,#85dd85, 0.2,#85dd85, 0.8,#b1ddb1, 1,#b1ddb1")
updateBattery(mybat, batbg)
battimer = timer({ timeout = 60 })
battimer:connect_signal("timeout", function() updateBattery(mybat, batbg) end)
battimer:start()

-- Create a Suspended Naughty Notifications widget --
local mynot = wibox.widget.textbox()
mynot:set_markup("<span color='#c33'><s>N</s></span>")
local notbg = wibox.widget.background()
local naughysuspended = false

function naughty_toggle(toggle)
    naughtysuspended = toggle~=nill and toggle or not naughtysuspended
    if naughtysuspended then
        naughty.resume()
        notbg:set_widget(nil)
    else
        naughty.suspend()
        notbg:set_widget(mynot)
    end
end

function naughty_clear()
    local screen = 1;
    local nn = naughty.notifications[screen]
    for k, v in pairs(nn.top_right) do
        if nn.timer then
            v.timer:stop()
        end
        v.box.visible = false;
    end
    nn.top_right = {}
end


-- Show Home --
local showhome = false
local box = nil
function home_toggle()
    showhome = not showhome
    naughty_toggle(not showhome)
    if showhome then
        if not box then
            box = modal.createWibox()
            cal = wibox.widget.textbox()
            box:set_widget(cal)
        end
        calendar.showMonth(os.date('%m'), os.date('%Y'), cal)
        local w, h = cal:fit(-1, -1)
        box:geometry({x=100, y=100, width=w, height=h})
        box.visible = true
    else
        box.visible = false
    end
end

-- Create a MPD widget
--mympc = mpc.getWidget()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ "Mod1" }, 2, function (c) c:kill() end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ modkey }, 1, function (c)
                         if not (c.maximized_horizontal and c.maximized_vertical)
                             and (c.maximized_horizontal or c.maximized_vertical) then
                            c.maximized_horizontal = true
                            c.maximized_vertical   = true
                        else
                            c.maximized_horizontal = not c.maximized_horizontal
                            c.maximized_vertical   = not c.maximized_vertical
                        end
                                          end),
                     awful.button({ modkey }, 2, function (c)
                        c.maximized_vertical   = not c.maximized_vertical
                        c.maximized_horizontal = false
                                          end),
                     awful.button({ modkey }, 3, function (c)
                        c.maximized_horizontal = not c.maximized_horizontal
                        c.maximized_vertical   = false
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(mympc)
    right_layout:add(notbg)
    right_layout:add(volbg)
    right_layout:add(batbg)
    right_layout:add(mytextclock)
    --right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey, }, "e", function () awful.util.spawn("skippy-xd --activate-window-picker") end),
    awful.key({}, "XF86TouchpadToggle", function () awful.util.spawn("toggle_touchpad") end),
    awful.key({}, "XF86AudioLowerVolume", function() updateVolume(myvol, "5%-") end),
    awful.key({}, "XF86AudioRaiseVolume", function() updateVolume(myvol, "5%+") end),
    awful.key({}, "XF86AudioMute", function() updateVolume(myvol, "toggle") end),
    awful.key({ modkey, }, "Home", home_toggle),
    awful.key({ modkey, }, "Delete", naughty_clear),
    awful.key({ modkey, }, "Left", awful.tag.viewprev),
    awful.key({ modkey, }, "Right", awful.tag.viewnext),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),

    --awful.key({ modkey,           }, "j", function ()
    --    for c in awful.client.iterate(function(c) return true end) do
    --        client.focus = c;
    --        c:raise();
    --    end
    --end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,             }, "w",         function () awful.util.spawn("dfiles.sh") end),
    awful.key({ modkey,             }, "o",         function () awful.util.spawn_with_shell("OPEN='emacsclient -c' EXT='org' dfiles.sh /home/can/data/_org/") end),
    awful.key({ modkey,             }, "s",         function () awful.util.spawn_with_shell("s `xsel -o`") end),
    awful.key({ modkey,             }, "g",         function() awful.util.spawn( "bash /home/can/bin/playGame.sh" ) end),
    awful.key({ modkey,             }, "z",         function() awful.util.spawn( "xcmenuctrl" ) end),
    awful.key({ modkey,             }, "space",     modal.grabKeyboard),
    awful.key({ modkey,             }, "0xff61",    nil ,function () awful.util.spawn("scrot -s -e 'mv $f ~/data/images/screenshot'") end),
    awful.key({                     }, "0xff61",    function () awful.util.spawn("scrot -e 'mv $f ~/data/images/screenshot'") end),
    awful.key({ modkey,             }, "Return",    function () awful.util.spawn(terminal) end),
    awful.key({ modkey,             }, ",",         function () awful.util.spawn(filemanager) end),
    awful.key({ modkey, "Control"   }, "r",         awesome.restart),
    awful.key({ modkey, "Shift"     }, "q",         quit),

    awful.key({ modkey,             }, "l",         function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,             }, "h",         function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"     }, "h",         function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"     }, "l",         function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control"   }, "h",         function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control"   }, "l",         function () awful.tag.incncol(-1)         end),

    awful.key({ modkey, "Control"   }, "n",         awful.client.restore),

    -- Prompt
    awful.key({ modkey              }, "r",         function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey              }, "x",
    function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end),
    awful.key({modkey,              }, "p",         function() awful.util.spawn( 'dmenu_run -y 18 -fn BitstreamVeraSans-8 -nb "#fff" -nf "#333" -sb "#cef" -sf "#000"' ) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,             }, "f",         function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"     }, "c",         function (c) c:kill() end),
    awful.key({ modkey, "Control"   }, "space",     awful.client.floating.toggle),
    awful.key({ modkey, "Control"   }, "Return",    function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,             }, "t",         function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,             }, "n",         function (c) c.minimized = true end),
    awful.key({ modkey,             }, "m",
    function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),
    awful.key({ modkey,             }, "v",
    function (c)
        c.maximized_vertical   = not c.maximized_vertical
        c.maximized_horizontal = false
    end),
    awful.key({ modkey,             }, "h",
    function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = false
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
end

clientbuttons = awful.util.table.join(
    awful.button({          }, 1, function (c) client.focus = c; c:raise(); end),
    awful.button({ modkey   }, 1, awful.mouse.client.move),
    awful.button({ modkey   }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons },
      --callback = function(c) naughty.notify({text=c.name, title=c.class, timeout = 0}) end
    },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Gifview" },
      properties = { floating = true },
      callback = awful.placement.centered },
    { rule = { class = "Spotify" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][3] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when window class changes.
client.connect_signal("property::class", function(c)
    -- HACK!, spotify class is empty in the beginning
    if c.class == "Spotify" then
        awful.client.movetotag(tags[1][9])
    end
end)
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter",
    function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- No border for maximized clients
client.connect_signal("focus", function(c)
    if c.maximized_horizontal == true and c.maximized_vertical == true then
        c.border_color = beautiful.border_normal
    else
        c.border_color = beautiful.border_focus
    end
end)

client.connect_signal("unfocus",
function(c) c.border_color = beautiful.border_normal
end)

-- Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", 
    function ()
        local clients = awful.client.visible(s)
    local layout  = awful.layout.getname(awful.layout.get(s))

    if #clients > 0 then -- Fine grained borders and floaters control
      for _, c in pairs(clients) do -- Floaters always have borders
        if awful.client.floating.get(c) or layout == "floating" then
          c.border_width = beautiful.border_width

        -- No borders with only one visible client
        elseif #clients == 1 or layout == "max" then
          c.border_width = 0
        else
          c.border_width = beautiful.border_width
        end
      end
    end
  end)
end

-- }}}

--modal.add("ss", function() awful.util.spawn("scrot -s") end, "scrot --select")
--modal.add("s ", function() awful.util.spawn("scrot") end, "scrot")
--modal.add("t", function() awful.util.spawn(terminal) end, "terminal")


function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
--function run_once(prg)
--  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")")
--end
--run_once("nm-applet")
run_once("skippysh")
run_once("xcmenu")
run_once("emacs --daemon")
--run_once("dropboxd")
--run_once("udisks-glue")

local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

--udisks.init()

