fx_version 'cerulean'
game "gta5"
author "FearlessStudios"
version '1.3.0'
lua54 'yes'

ui_page 'nui/index.html'

files {
  'nui/index.html',
  'nui/index.js'
}

server_scripts {
  'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

shared_scripts {
  'shared/*.lua'
}
