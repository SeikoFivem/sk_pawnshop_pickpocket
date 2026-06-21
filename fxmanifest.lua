fx_version 'cerulean'
game 'gta5'

author 'Seîko'
description 'Script Pawnshop / Pickpocket'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script '@mysql-async/lib/MySQL.lua' -- Import explicite pour compatibilité
shared_scripts {
    'locales/init.lua',
    'locales/fr.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/it.lua',
    'locales/de.lua',
    'config.lua'
}
client_script 'client.lua'
server_script 'server.lua'

dependency 'es_extended'
dependency 'ox_lib'
dependency 'ox_inventory'
dependency 'ox_target'
dependency 'oxmysql'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'pawnshop.sql'
}
