fx_version 'cerulean'
game 'gta5'

author 'Doxy'
description 'Tablet ui QBCore'
version '1.0'

lua54 'yes'

shared_script 'config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/main.lua'
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/main.lua',
}

ui_page 'ui/dashboard.html'

files {
    'ui/dashboard.html',
    'ui/app.js',
    'ui/style.css',
}