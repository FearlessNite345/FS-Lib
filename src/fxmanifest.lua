fx_version 'cerulean'
game 'gta5'

author 'FearlessStudios'
description 'FS-Lib by FearlessStudios'
version '1.5.0'

client_script 'dist/client/**/*.lua'
server_script 'dist/server/**/*.lua'

files {
    'nui/**/*',
    'stream/**/*',
    'data/**/*',
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'

ui_page 'nui/index.html'
