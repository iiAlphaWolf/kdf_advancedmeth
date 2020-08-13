fx_version "bodacious"
game "gta5"

author "KleurenDoof (Ralph Stoop)"
description "Advanced (Breaking Bad) meth script"
version "1.0.0"
ui_page "html/h.html"

client_script {
	"@es_extended/locale.lua",
	"client/client.lua",
	"locales/en.lua",
	"config.lua"
}
server_script {
	"@es_extended/locale.lua",
	"server/server.lua",
	"locales/en.lua",
	"config.lua"
}

files {
    "html/h.html"
}