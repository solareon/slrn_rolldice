fx_version 'cerulean'
game 'gta5'

name 'slrn-rolldice'
description 'A simple dice rolling script for Qbox'
author 'solareon.'
version '1.1.0'

client_scripts {
    'client/main.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua'
}

server_scripts {
    'server/main.lua',
}

files {
    'config/shared.lua'
}

lua54 'yes'