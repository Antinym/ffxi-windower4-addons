-- Copyright © 2017, Cair
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of ROE nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cair BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'ROE'
_addon.version = '1.3.1'
_addon.author = "Cair"
_addon.commands = {'roe'}

packets = require('packets')
config = require('config')
require('logger')


local defaults = T{
    profiles = T{
        default = S{},
    },
    blacklist = S{},
    clear = true,
    clearprogress = false,
    clearall = false,
    log_last_records_added = false,
    packet_delay = .5,
    debug = false
}

settings = config.load(defaults)

_roe = T{
    active = T{},
    complete = T{},    
    max_count = 30,
    last_packet_time,
    first_run = true
}

local function cancel_roe(id)
    id = tonumber(id)
    
    if not id then return end
    
    if settings.blacklist[id] or not _roe.active[id] then return end

    -- in case user makes multiple calls (e.g. macro mashing)
    if _roe.last_packet_time then
        local packet_delay_delta = settings.packet_delay - (os.time() - _roe.last_packet_time)
        if packet_delay_delta > 0 then
            coroutine.sleep(packet_delay_delta)
        end
    end

    local p = packets.new('outgoing', 0x10d, {['RoE Quest'] = id })
    packets.inject(p)
    _roe.last_packet_time = os.time()
end

local function accept_roe(id)
    id = tonumber(id)
    
    if not id or _roe.complete[id] or _roe.active[id] then return end

    -- in case user makes multiple calls (e.g. macro mashing)
    if _roe.last_packet_time then
        local packet_delay_delta = settings.packet_delay - (os.time() - _roe.last_packet_time)
        if packet_delay_delta > 0 then
            coroutine.sleep(packet_delay_delta)
        end
    end
    
    local p = packets.new('outgoing', 0x10c, {['RoE Quest'] = id })
    packets.inject(p)
    _roe.last_packet_time = os.time()
end

local function eval(...)
    assert(loadstring(table.concat({...}, ' ')))()
end

local function save(name, records)
    if not type(name) == "string" then
        error('`save` : specify a profile name')
        return
    end
    
    name = name:lower()

    settings.profiles[name] = records and S(records):sort() or S(_roe.active:keyset()):sort()
    settings:save('global')
    if not records then
        notice('saved %d objectives to the profile %s':format(_roe.active:length(), name))
    end
end

local function list()
    notice('You have saved the following profiles: ')
    notice(settings.profiles:keyset())
end


local function parse_args(cmd,...)
    local cmdln_set = T{...}
    local last_set = S{}
    local name
    if #cmdln_set > 1 or cmdln_set[1]:contains(',') then
        name = 'last_cmdln_'..cmd
        for n in cmdln_set:it() do
            if n:contains(',') then
                n:split(','):map(function(el) if tonumber(el) then last_set:add(tonumber(el)) end end)
            else
                last_set:add(tonumber(n))
            end
        end
        settings.profiles[name] = T(last_set:copy())
    else
        name = cmdln_set[1]
    end

    name = name and type(name) == "string" and name:lower() or name
    local roe_id = not settings.profiles[name] and tonumber(name) or nil

    return name, roe_id
end

local function set(...)
    local name, roe_id = parse_args('set',...)

    if (not name or not type(name) == "string") and not roe_id then
        error('`set` : specify a profile name or a valid RoE id number.')
        return
    end
    
    if not roe_id and not settings.profiles[name] then
        error('`set` : the profile \'%s\' does not exist':format(name))
        return
    end
    
    local needed_quests = (roe_id and S{roe_id} or S(settings.profiles[name])):diff(_roe.active:keyset())
    local available_slots = _roe.max_count - _roe.active:length()
    local to_remove = S{}
           
    if settings.clearall then
        to_remove:update(_roe.active:keyset())
    elseif settings.clear then
        for id,progress in pairs(_roe.active) do
            if (needed_quests:length() - to_remove:length()) <= available_slots then
                break
            end
            if (progress == 0 or settings.clearprogress) and not settings.blacklist[id] then
                to_remove:add(id)
            end
        end
    end
            
        
    if (needed_quests:length() - to_remove:length()) > available_slots then
        error('you do not have enough available quest slots')
        return
    end
    
    for id in to_remove:it() do
        cancel_roe(id)
        coroutine.sleep(.5)
    end
    
    for id in needed_quests:it() do
        accept_roe(id)
        coroutine.sleep(settings.packet_delay)
    end

    if roe_id then
       notice('loaded the Objective with id \'%s\'':format(name))
    else
        notice('loaded the profile \'%s\'':format(name))
    end

end

local function unset(...)
    local name, roe_id = parse_args('unset',...)

    if roe_id then
        cancel_roe(name)
        notice('unset RoE Objective [ \'%d\' ]':format(name))
    elseif name and settings.profiles[name] then
        for id in _roe.active:keyset():intersection(S(settings.profiles[name])):it() do
            log('id:',id)
            cancel_roe(id)
            coroutine.sleep(settings.packet_delay)
        end
        notice('unset the profile \'%s\'':format(name))
    elseif name then
        error('`unset` : the profile \'%s\' does not exist':format(name))
    elseif not name then
        notice('clearing ROE objectives.')
        for id,progress in pairs(_roe.active:copy()) do
            if progress == 0 or settings.clearprogress then
                cancel_roe(id)
                coroutine.sleep(settings.packet_delay)
            end
        end
    end

end

local true_strings = S{'true','t','y','yes','on'}
local false_strings = S{'false','f','n','no','off'}
local bool_strings = true_strings:union(false_strings)

local function handle_setting(setting,val)
    setting = setting and setting:lower() or setting
    val = val and val:lower() or val
    
    if not setting or not settings:containskey(setting) then
        error('specified setting (%s) does not exist':format(setting or ''))
    elseif type(settings[setting]) == "boolean" then
        if not val or not bool_strings:contains(val) then
            settings[setting] = not settings[setting]
        elseif true_strings:contains(val) then
            settings[setting] = true
        else    
            settings[setting] = false
        end
            
        notice('%s setting is now %s':format(setting, tostring(settings[setting])))
    end

end

local function blacklist(add_remove,id)
    add_remove = add_remove and add_remove:lower()
    id = id and tonumber(id)

    if add_remove and id then
        if add_remove == 'add' then
            settings.blacklist:add(id)
            notice('roe quest %d added to the blacklist':format(id))
        elseif add_remove == 'remove' then
            settings.blacklist:remove(id)
            notice('roe quest %d removed from the blacklist':format(id))
        else
            error('`blacklist` specify \'add\' or \'remove\'')
        end
    else
        error('`blacklist` requires two args, [add|remove] <quest id>')
    end
    
end


local function help()
    notice([[ROE - Command List:
1. help - Displays this help menu.
2. save <profile name> : saves the currently set ROE to the named profile
3. set <profile name> : attempts to set the ROE objectives in the profile
    - Objectives may be canceled automatically based on settings.
    - The default setting is to only cancel ROE that have 0 progress if space is needed
4. unset : removes currently set objectives
    - By default, this will only remove objectives without progress made
5. settings <settings name> : toggles the specified setting
    * settings:
        * clear : removes objectives if space is needed (default true)
        * clearprogress : remove objectives even if they have non-zero progress (default false)
        * clearall : clears every objective before setting new ones (default false)
6. blacklist [add|remove] <id> : blacklists a quest from ever being removed
    - I do not currently have a mapping of quest IDs to names]])
end

-- requires a valid record id and if a 2nd argument is passed the printed output will be suppressed.
-- returns 3 values: the record id parameter, the record progression, and (bool) if the record is active.
function check_status(id, silent)
    local roe_id = tonumber(id)
    local print_results = silent and false or true
    if not roe_id and (_roe.complete[roe_id] or _roe.active[roe_id]) then 
        error('please use a valid record id.')
        return
    end

    local record_progress = 'Not started yet.'
    local record_is_active = false
    if _roe.active[roe_id] then
        record_progress = _roe.active[roe_id]
        record_is_active = true
    elseif _roe.complete[roe_id] then
        record_progress = _roe.complete[roe_id]
    end

    local active_string = record_is_active and ' <active>' or ''
    -- BUG?: I think _roe.[active|complete] might have bool values in some cases
    local progress_string = record_progress and tostring(record_progress) or '<not started>'
    if print_results then 
        log('[%s]:%s %s':format(roe_id, active_string, progress_string))
    end

    return roe_id, record_progress, record_is_active
end

local cmd_handlers = {
    eval = eval,
    save = save,
    list = list,
    set = set,
    unset = unset,
    settings = handle_setting,
    blacklist = blacklist,
    help = help,
    check = check_status
}


local function inc_chunk_handler(id,data)
    if id == 0x111 then
        local last_active = settings.log_last_records_added and _roe.active:keyset() or nil
        _roe.active:clear()
        for i = 1, _roe.max_count do
            local offset = 5 + ((i - 1) * 4)
            local id,progress = data:unpack('b12b20', offset)
            if tonumber(id) > 0 then
                _roe.active[id] = progress
            end
        end
        if settings.log_last_records_added then
            local last_active_table = type(last_active) == 'table' and S(last_active) or S{tostring(last_active)}
            local last_record_ids = S(_roe.active:keyset():diff(last_active_table)):sort()
            if last_record_ids:length() > 0 then
                save('last_record_ids',last_record_ids)
                if _roe.first_run then
                    _roe.first_run = false
                else
                    debug('last_record_ids: '..last_record_ids:tostring())
                end
            end
        end
    elseif id == 0x112 then
        local complete = T{data:unpack('b1':rep(1024),4)}:key_map(
            function(k) 
                return (k + 1024*data:unpack('H', 133) - 1) 
            end):map(
            function(v) 
                return (v == 1)
            end)
        _roe.complete:update(complete)
    end
end

local function addon_command_handler(command,...)
    local cmd  = command and command:lower() or "help"
    if cmd == 'r' then
        return windower.send_command('lua r roe')
    elseif cmd == 'u' then
        return windower.send_command('lua u roe')
    elseif cmd_handlers[cmd] then
        cmd_handlers[cmd](...)
    else
        error('unknown command `%s`':format(cmd or ''))
    end

end

local function load_handler()
    for k,v in pairs(settings.profiles) do
        if type(v) == "string" then
            settings.profiles[k] = S(v:split(','):map(tonumber)):sort()
        elseif type(v) == 'number' then
            settings.profiles[k] = S{tostring(v)}
        end
    end
    
    local last_roe = windower.packets.last_incoming(0x111)
    if last_roe then inc_chunk_handler(0x111,last_roe) end

end

local function init_handler()
    _roe.first_run = true
end
windower.register_event('incoming chunk', inc_chunk_handler)
windower.register_event('addon command', addon_command_handler)
windower.register_event('load', load_handler)
windower.register_event('login', init_handler)
