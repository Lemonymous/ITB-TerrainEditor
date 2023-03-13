
-- initialize mod
local mod = {
	id = "lmn_terrain_editor",
	name = "TerrainEditor",
	version = "0.1.0",
	description = "Adds a terrain editing ui for debug purposes",
	icon = "scripts/icon.png",
	dependencies = {"memedit"},
}

function mod:init()
	require(self.scriptPath.."terrain_editor")
end

function mod:load(options, version)
	
end

return mod
