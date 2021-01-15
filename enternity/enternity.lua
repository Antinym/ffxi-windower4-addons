--[[
enternity v1.20210114

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of enternity nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require('sets')

_addon.name    = 'enternity'
_addon.author  = 'Zohno'
_addon.modifier = 'Antinym'
_addon.version = '1.1.1.1'

blist = S{
    'Paintbrush of Souls',  -- Requires correct timing, should not be skipped
    'Geomantic Reservoir',  -- Causes dialogue freeze for some reason
    'Jadamo',               -- to view the time til next race
}

local _enternity = {
    enabled = true,
    skipall = false
}

do 
    windower.send_command('alias eon lua i enternity toggle enabled on')
    windower.send_command('alias eoff lua i enternity toggle enabled off')
    windower.send_command('alias enternity lua i enternity toggle')
    windower.send_command('alias eskip lua i enternity skipall')
end

--[[ This is a fairly flawed function, at least from a ux perspective.
    I think I'd have to process 'addon command' events to find my ux happy place.
    Doing that would sacrifice my amusement of not doing that...
]]
function toggle(set, val)
    
    local _lookups = {      -- alternate names for specific settings
        enabled = 'enabled',
        enable = 'enabled',
        on = 'enabled',
        active = 'enabled',
        pause = 'enabled',
        unpause = 'enabled',
        paused = 'enabled',
        skipall = 'skipall',
        skip = 'skipall',
        eskip = 'skipall',
        overdrive = 'skipall',
        superskip = 'skipall',
        cantstopwontstop = 'skipall',
    }

    local setting = _lookups[set:lower()] or set:lower()
    if not setting or not _enternity[setting] then return false end
    if not val then 
        _enternity[setting] = not _enternity[setting] 
    elseif T{'false','f','nil','off','end'}:contains(val:lower()) then
        _enternity[setting] = false
    else
        _enternity[setting] = true        
    end
    print(setting..' set to: '..tostring(_enternity[setting]))
end

windower.register_event('incoming text', function(original, modified, mode)
    if _enternity.enabled and (mode == 150 or mode == 151) 
        and (not original:match(string.char(0x1e, 0x02)) 
        or _enternity.skipall) then
            local target = windower.ffxi.get_mob_by_target('t')
            if not (target and blist:contains(target.name)) then
                modified = modified:gsub(string.char(0x7F, 0x31), '')
        end
    end

    return modified
end)
