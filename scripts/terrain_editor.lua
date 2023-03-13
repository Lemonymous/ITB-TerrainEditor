
modApi:appendAssets("img/debugdraw/", "img", "")

local CURSOR_ICON_OFFSET = Point(5,-40)
local OUT_OF_BOUNDS = Point(-1,-1)
local selectedButton
local isRightButtonDown = false

local tiles = {
	{
		img = "clear.png",
		code = "Board:ClearSpace(%s)",
	},
	{
		img = "terrain_road.png",
		code = "Board:SetTerrain(%s, TERRAIN_ROAD)",
	},
	{
		img = "terrain_water.png",
		code = "Board:SetTerrain(%s, TERRAIN_WATER)",
	},
	{
		img = "terrain_forest.png",
		code = "Board:SetTerrain(%s, TERRAIN_FOREST)",
	},
	{
		img = "terrain_mountain.png",
		code = "Board:SetTerrain(%s, TERRAIN_MOUNTAIN)",
	},
	{
		img = "terrain_building.png",
		code = "Board:SetTerrain(%s, TERRAIN_BUILDING)",
	},
	{
		img = "terrain_rubble.png",
		code = "Board:SetTerrain(%s, TERRAIN_RUBBLE)",
	},
	{
		img = "terrain_sand.png",
		code = "Board:SetTerrain(%s, TERRAIN_SAND)",
	},
	{
		img = "terrain_ice.png",
		code = "Board:SetTerrain(%s, TERRAIN_ICE)",
	},
	{
		img = "terrain_acid.png",
		code = "Board:SetTerrain(%s, TERRAIN_ACID)",
	},
	{
		img = "terrain_lava.png",
		code = "Board:SetTerrain(%s, TERRAIN_LAVA)",
	},
	{
		img = "terrain_hole.png",
		code = "Board:SetTerrain(%s, TERRAIN_HOLE)",
	},
	{
		img = "effect_fire.png",
		code = "Board:SetFire(%s, true)",
	},
	{
		img = "effect_fire_rem.png",
		code = "Board:SetFire(%s, false)",
	},
	{
		img = "effect_smoke.png",
		code = "Board:SetSmoke(%s, true, true)",
	},
	{
		img = "effect_smoke_rem.png",
		code = "Board:SetSmoke(%s, false, true)",
	},
	{
		img = "effect_acid.png",
		code = "Board:SetAcid(%s, true)",
	},
	{
		img = "effect_acid_rem.png",
		code = "Board:SetAcid(%s, false)",
	},
	{
		img = "effect_frozen.png",
		code = "Board:SetFrozen(%s, true, true)",
	},
	{
		img = "effect_frozen_rem.png",
		code = "Board:SetFrozen(%s, false, true)",
	},
	{
		img = "effect_shield.png",
		code = "Board:SetShield(%s, true, true)",
	},
	{
		img = "effect_shield_rem.png",
		code = "Board:SetShield(%s, false, true)",
	},
	{
		img = "enemy_clear.png",
		code = "Board:RemovePawn(%s)",
	},
	{
		img = "enemy_scorpion.png",
		code = "Board:AddPawn('Scorpion1', %s)",
	},
	{
		img = "enemy_scorpion_alpha.png",
		code = "Board:AddPawn('Scorpion2', %s)",
	},
	{
		img = "enemy_spiderling.png",
		code = "Board:AddPawn('Spiderling1', %s)",
	},
	{
		img = "enemy_hornet.png",
		code = "Board:AddPawn('Hornet1', %s)",
	},
	{
		img = "enemy_scarab.png",
		code = "Board:AddPawn('Scarab1', %s)",
	},
}

local function clamp(value, low, high)
	return math.max(low, math.min(value, high))
end

local function createDrawButton(tile)
	local surface = sdlext.getSurface{
		path = "img/debugdraw/"..tile.img,
		transformations = {
			{ outline = { border = 1, color = deco.colors.buttonborder } },
		},
	}

	local ui = Ui()
		:sizepx(40, 40)
		:clip()
		:decorate{
			DecoButton(),
			DecoAnchor(),
			DecoSurfaceAligned(surface, "center", "center"),
		}

	function ui:clicked(button)
		if button == 1 then
			selectedButton = self
			isRightButtonDown = false
		end

		return true
	end

	function ui:runCode()
		if Board then
			local p = Board:GetHighlighted()
			if p ~= OUT_OF_BOUNDS then
				local d = SpaceDamage()
				d.sScript = string.format(self.code, p:GetString())
				Board:DamageSpace(d)
			end
		end
	end

	ui.img = tile.img
	ui.surface = surface
	ui.code = tile.code
	ui.tooltip = string.format(tile.code, "loc")

	if tile.code:find("AddPawn") then
		ui.code = "local loc = %s if not Board:IsPawnSpace(loc) then "..string.format(ui.code, "loc").." end"
	end

	return ui
end

modApi.events.onUiRootCreated:subscribe(function(screen, uiRoot)
	local clickOverlay = Ui()
		:size(1,1)
		:setVar("translucent", true)
		:addTo(uiRoot)

	local decoSurface = DecoSurfaceAligned(nil, "center", "center")
	local cursorIcon = Ui()
		:sizepx(40,40)
		:decorate{ decoSurface }
		:addTo(uiRoot)
	cursorIcon.decoSurface = decoSurface

	local buttons = UiFlowLayout()
		:size(1,1):vgap(1):hgap(1)

	for _, tile in ipairs(tiles) do
		buttons:add(createDrawButton(tile))
	end

	local width = 111
	local height = 524
	local rect = Boxes.space_info
	local sidebar = Ui()
		:sizepx(width, height)
		:pospx(rect.x + rect.w - width, rect.y - height - 5)
		:decorate{ DecoFrame() }
		:beginUi(UiWeightLayout)
			:size(1,1):vgap(0)
			:orientation(modApi.constants.ORIENTATION_VERTICAL)
			:beginUi(UiWeightLayout)
				:width(1):heightpx(20):vgap(0)
				:orientation(modApi.constants.ORIENTATION_VERTICAL)
				:beginUi()
					:size(1,1)
				:endUi()
				:beginUi()
					:width(1):heightpx(2)
					:decorate{ DecoSolid(deco.colors.buttonborder) }
				:endUi()
			:endUi()
			:beginUi(UiScrollArea)
				:size(1,1):padding(5)
				:add(buttons)
			:endUi()
		:endUi()
		:addTo(uiRoot)

	function sidebar:relayout()
		self.visible = Board ~= nil
		Ui.relayout(self)
	end

	sidebar:registerDragResize(2, 76)

	function clickOverlay:keydown(keycode)
		if keycode == SDLKeycodes.ESCAPE then
			selectedButton = nil
		end

		return false
	end

	function clickOverlay:mousedown(mx, my, button)
		if selectedButton == nil then
			return
		end

		if button == 1 then
			isRightButtonDown = true
			selectedButton:runCode()
		end

		return false
	end

	function clickOverlay:mouseup(mx, my, button)
		if button == 1 then
			isRightButtonDown = false
		elseif button == 3 then
			selectedButton = nil
		end

		return false
	end

	function clickOverlay:mousemove(mx, my)
		if isRightButtonDown and selectedButton then
			selectedButton:runCode()
		end

		return false
	end

	function clickOverlay:wheel(mx, my, y)
		if Board then
			local p = Board:GetHighlighted()
			if p ~= OUT_OF_BOUNDS then
				local terrain = Board:GetTerrain(p)
				local health = Board:GetHealth(p)
				local maxHealth = Board:GetMaxHealth(p)
				local is2hpTerrain = false
					or terrain == TERRAIN_ICE
					or terrain == TERRAIN_MOUNTAIN

				local maxHealthLimit = is2hpTerrain and 2 or 4
				local change = y > 0 and 1 or -1

				if sdlext.isCtrlDown() then
					local newMaxHealth = clamp(maxHealth + change, 1, maxHealthLimit)
					local newHealth = clamp(health, 0, newMaxHealth)
					Board:SetHealth(p, newHealth, newMaxHealth)
				else
					local newHealth = clamp(health + change, 0, maxHealth)
					Board:SetHealth(p, newHealth, maxHealth)
				end
			end
		end

		return false
	end

	function clickOverlay:relayout()
		self.visible = Board ~= nil
		Ui.relayout(self)
	end

	function cursorIcon:relayout()
		self.x = sdl.mouse.x() + CURSOR_ICON_OFFSET.x
		self.y = sdl.mouse.y() + CURSOR_ICON_OFFSET.y
		if self.prevSelectedButton ~= selectedButton then
			if selectedButton ~= nil then
				self.decoSurface.surface = selectedButton.surface
			else
				self.decoSurface.surface = nil
			end
			self.prevSelectedButton = selectedButton
		end

		self.visible = Board ~= nil and selectedButton ~= nil
		Ui.relayout(self)
	end
end)
