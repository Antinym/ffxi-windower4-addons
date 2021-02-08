_addon.name = 'Logger'
_addon.author = 'Aikar'
_addon.version = '1.0.2.1'

require('chat')
files = require('files')
config = require('config')

defaults = {}
defaults.AddTimestamp = true
defaults.UseArchiveFolders = true
defaults.TimestampFormat = '%H:%M:%S'

settings = config.load(defaults)

name = windower.ffxi.get_player() and windower.ffxi.get_player().name
last_line = ''

windower.register_event('login', function(new_name)
    name = new_name
end)

windower.register_event('incoming text', function(_, text, _, _, blocked)
    if blocked or text == '' then
        return
    end

    local date = os.date('*t')
    local archive_folder = settings.UseArchiveFolders and '%s/%.4u_%.2u/':format(name,date.year,date.month) or ''
    local new_line = '%s%s\n':format(settings.AddTimestamp and os.date(settings.TimestampFormat, os.time()) or '', text:strip_format())

    local file = files.new('../../logs/%s%s_%.4u.%.2u.%.2u.log':format(archive_folder, name, date.year, date.month, date.day))

    if not file:exists() then
        file:create()
    end

    if new_line ~= old_line then
        file:append(new_line)
        old_line = new_line
    end
end)

--[[
Copyright © 2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
