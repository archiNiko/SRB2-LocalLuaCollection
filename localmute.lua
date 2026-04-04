-- All commands here are prefixed with "bagel_" so they don't get overwritten by a mod
-- i escape every apostrophe because im a coward, and use quotes for strings anyway, no i won't be changing it im too lazy

-- ladies, gentlemen and unspecified, my codebase is so dirty that i'm resulting to returning these monstrosities
local function gettimeStamp()
    return os.date("%Y").."-"..os.date("%m").."-"..os.date("%H").."-"..os.date("%M").."-"..os.date("%S")
end

local function updateLogName()
    return "client/LOCALMUTE/mutedlog-"..gettimeStamp()..".txt"
end

-- this is the log it'll save to if the thing is on
local locallog = updateLogName()

local localbooleanlist = {"silenceblocked", "unblockonleave", "blocklog"}
local localbooleandescription = {
    "Don\'t display messages from blocked people in chat",
    "If someone you\'ve muted leaves, remove them from list (AFTER rejointimeout)",
    "Save messages from blocked people into \"/luafiles/client/LOCALMUTE/\"!"
}

local localbooleanvalues = {
    "on",
    "on",
    "on"
}

-- this is where player_t's go
local mutedppl = {}

-- because you have no player_t on titlescreen
local function LocalPrint(msgtext)
    if (netgame) then
        CONS_Printf(consoleplayer, msgtext)
    else
        print(msgtext)
    end
end

-- string version of CheckSetting (bloat)
local function LocalBooleanState(localthing)
    if (localthing == "on") then
        return "\x82ON\x80"
    else
        return "\x85OFF\x80"
    end
end

local function CheckSetting(localboolpos)
    if (localbooleanvalues[localboolpos] == "on") then
        return true
    else
        return false
    end
end

-- flip value at position in list
local function FlipLocalBoolean(locallist, localthingid)
    if (locallist[localthingid] == "on") then
        locallist[localthingid] = "off"
    else
        locallist[localthingid] = "on"
    end

end

-- if it exists, return item #, else return false
local function FindItemInArrayByNum(array, item)
    local n = tonumber(item)
    for k,_ in pairs(array) do
        if (k == n) then
            return n
        end
    end

    return false
end

-- some mute stuff

-- this is incase i add more stuff to localmute
local function ResetMuteList()
    mutedppl = {}
end

-- FIXME: Player names can be shoddy if someone's name is a singular character, and said character is shared in another name.
local function findPt(val)
    local n = tonumber(val)

    if not (n == nil) and (n >= 0) and (n < 32) then
        for player in players.iterate do
            if (#player == n) then
                return player
            end
        end
    end

	for player in players.iterate do
		if string.find(string.lower(player.name), string.lower(val)) then
			return player
		end
	end

    return nil
end

-- return item # of found player_t, or return false
local function findPtinMutes(pt)
    for k,v in pairs(mutedppl) do
        if (#pt == v) or (pt == v) or (pt.name == v) then
            return k
        end
    end

    return false
end

-- why doesn't BLua have a way to get the file size...
local function fileSizeThing(file)
    local f = io.openlocal(file, "rb")
    if not f then return 0 end
    local size = f:seek("end")
    f:close()
    return size
end

-- this sucks
local function returnteam(pl)
    local teams = {
        [0] =   "SPECTATOR",
        [1] =   "RED",
        [2] =   "BLUE"
    }

    if (G_GametypeHasTeams()) then
        if (pl.ctfteam < 3)
            return string.upper(tostring(teams[pl.ctfteam]))
        else
            return "UNKNOWN ("..pl.ctfteam..")"
        end
    else
        return "???"
    end
end

-- why am i doing this.
local function msgtypeReturn(msgt, pl)
    if (msgt == 0) then
        return ""
    end
    -- else's syntax is giving me an aneurysm so this is seperate, FIXME: fix this
    if (msgt == 1) then
        return "["..returnteam(pl).." TEAM] "
    else
        return "[PM] "
    end
end

local function SaveBlockedMsg(save)
    local log = io.openlocal(locallog, "a+")
    if not log then log = io.openlocal(locallog, "w") end
    if not log then LocalPrint("Something genuinely went horribly wrong. Maybe you haven\'t given SRB2 write access?") return end
    -- now reconstruct the message i guess
    log:write(tostring(save))
    log:flush()
    log:close()
end

-- list handler that is written in a stupidly disgusting manner
-- anything that modifies the mutedppl list or something relevant to it should be added here
-- numstr: player name/number to (un)mute
-- t: type ("a" == add, "r" == remove, "w" == wipe)
local function LocalMute(numstr, t)

    if (t == nil) then LocalPrint("Something\'s wrong.") return end

    if (numstr == nil) or (t == "w") then
        ResetMuteList()
        LocalPrint("\x83LOCALMUTE\x80: Wiped.")
        return
    end

    local itemfound -- INT or false
    local bpt -- player_t return of numstr (used as fallback for removal, and used in addition)

    if (t == "a") and not (netgame) then LocalPrint("\x83LOCALMUTE\x80: You can only mute people in netgames.") return end

    itemfound = FindItemInArrayByNum(mutedppl, numstr)
    bpt = findPt(numstr)
    if (itemfound == false) and (bpt ~= nil) then
        itemfound = findPtinMutes(bpt)
    else
        if (bpt == nil) and (itemfound == false) and (t == "r") then LocalPrint("\x83LOCALMUTE\x80: Found nothing!") return end
    end

    -- invalid p[name/num]
    if (bpt == nil) then LocalPrint("\x83LOCALMUTE\x80: Player not found!") return end
    if (bpt == consoleplayer) then LocalPrint("\x83LOCALMUTE\x80: You can\'t mute yourself, silly!") return end

    if (t == "a") then
        if (itemfound == false) then
            table.insert(mutedppl, bpt)
            SaveBlockedMsg("Blocked "..bpt.name.." (#"..#bpt..") @ "..gettimeStamp().." in \""..CV_FindVar("servername").string.."\".\n")
            LocalPrint("\x83LOCALMUTE\x80: Muted player \""..bpt.name.."\" ".."(Player "..#bpt..").")
            return
        else
            LocalPrint("\x83LOCALMUTE\x80: Already muted!")
            return
        end
    end

    if (t == "r") then
        if (itemfound == false) then
            LocalPrint("\x83LOCALMUTE\x80: Player isn\'t muted.")
            return
        else
            SaveBlockedMsg("Unblocked "..mutedppl[itemfound].name.." @ "..gettimeStamp().." in \""..CV_FindVar("servername").string.."\".\n")
            table.remove(mutedppl, itemfound)
            LocalPrint("\x83LOCALMUTE\x80: Removed.")
            return
        end
    end

end

-- returns the list of muted ppl as text.
local function ListMutes()
    local list = "\n"

    if (#mutedppl > 0) then
        for _,v in pairs(mutedppl) do
            list = $.."\t"..v.name.." (Player #\x82"..#v.."\x80)\n"
        end

        list = $.."\nEnd of list."
    else
        list = "\x83LOCALMUTE\x80: You haven\'t muted anyone!\n"
    end

    return list
end

COM_AddCommand("bagel_localmute", function(player, arg, arg2)
    if (arg == nil) and (arg2 == nil) then
        LocalPrint("bagel_localmute <a/r/w/l> <player[name/num]>: Mute player by name or playernum")
        LocalPrint("\t- \"a\": add, \"r\": remove, \"w\": wipe, \"l\": list all")
        LocalPrint("\t\t- eg. \"bagel_localmute a 1\", \"b_localmute r 1\"")
        return
    end

    if (arg == "w") then LocalMute(nil, "w") return end

    if (arg == "l") then LocalPrint(ListMutes()) return end

    if (arg2 == nil) then LocalPrint("\x83LOCALMUTE\x80: Player can\'t be nil!") return end

    if (arg == "a") then LocalMute(arg2, "a") return end

    if (arg == "r") then LocalMute(arg2, "r") return end

    LocalPrint("\x83LOCALMUTE\x80: Argument(s) invalid!")
end, COM_LOCAL)

COM_AddCommand("bagel_changelocalbool", function(player, arg)

    if (arg == nil) then
        LocalPrint("bagel_changelocalbool <bool> | toggle booleans, list:")
        for k,v in pairs(localbooleanlist) do LocalPrint("\t"..localbooleanlist[k].." (\x83#"..k.."\x80) | "..localbooleandescription[k].." | "..LocalBooleanState(localbooleanvalues[k])) end
        return
    end

    local anyresults = false
    local booleanid = 0

    for k,v in pairs(localbooleanlist)
        if (v == arg) or (k == tonumber(arg)) then
            anyresults = true
            booleanid = k
            break
        end
    end

    if (anyresults == false) or (booleanid == 0) then LocalPrint("Boolean doesnt exist!") return end

    FlipLocalBoolean(localbooleanvalues, booleanid)
    LocalPrint( "\x82"..localbooleanlist[booleanid].."\x80 is now "..LocalBooleanState(localbooleanvalues[booleanid])..".")
end, COM_LOCAL)

-- Hooks

addHook("PlayerMsg", function(s, ty, t, con)

    if not (CheckSetting(1))  then return end

    -- These redo chat
    if (PSO or juggy) then return end

    if (gametype == GT_LTMMURDERMYSTERY) or (gametype == GT_SAXASMM) then return end

    for _,v in pairs(mutedppl) do
        if ((rawequal(s, v)) or (#v == #s) or (v.name == s.name)) then
            if (CheckSetting(1) and CheckSetting(3)) then
                local towrite = "[\""..CV_FindVar("servername").string.."\"@"..gettimeStamp().."] "..msgtypeReturn(ty, s).."<"..s.name.."> "..con.."\n"
                local logsize = fileSizeThing(locallog)
                -- just gonna do slightly less than cap
                if ((logsize + towrite:len()) > ((1024*1024)-1000)) then locallog = updateLogName() end
                SaveBlockedMsg(towrite)
            end
            return true
        end
    end
        
end)

addHook("PlayerQuit", function(player)

    if not (CheckSetting(2)) or (#mutedppl == 0) then return end

    local mute = findPtinMutes(player)
    if (mute == false) then return end

    for k,v in pairs(mutedppl) do
        if ((rawequal(mutedppl[k], player)) or (v.name == mutedppl[k].name)) then
            LocalPrint("\x83LOCALMUTE (unblockonleave)\x80: player "..player.name.." ("..#player..") left, removing from list")
            table.remove(mutedppl, mute)
        end
    end

end)