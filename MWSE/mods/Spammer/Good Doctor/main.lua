local mod = "Good Doctor (Joseph Edit)"
local configPath = mod
local defaultConfig = {
	peaceful = { ["cliff racer"] = true, ["guar"] = true, ["shalk"] = true },
	pacifyDiseased = {
		["cliff racer_blighted"] = true,
		["shalk_diseased"] = true,
		["shalk_diseased_hram"] = true,
		["guar_feral"] = true,
	},
	pacifyBlighted = { ["cliff racer_blighted"] = true, ["shalk_blighted"] = true },
}

local config = mwse.loadConfig(configPath, defaultConfig)

---@param e table|spellResistEventData
event.register("spellResist", function(e)
	if (e.effect.id == tes3.effect.cureCommonDisease and config.pacifyDiseased[e.target.baseObject.id:lower()]) or
	(e.effect.id == tes3.effect.cureBlightDisease and config.pacifyBlighted[e.target.baseObject.id:lower()]) then
		e.target.mobile.fight = 0
		e.target.mobile.flee = 100
		e.target.mobile.actionData.aiBehaviorState = tes3.aiBehaviorState.flee
		e.target.mobile:stopCombat(true)
	end
end)

local function onInitialized()
	for creature in tes3.iterateObjects(tes3.objectType.creature) do
		if config.peaceful[creature.id] then
			creature.aiConfig.fight = 0
		end
	end
end
event.register("initialized", onInitialized)

local function registerModConfig()
	local template = mwse.mcm.createTemplate(mod)
	template.onClose = function()
		config.save()
	end
	template:register()

	local page = template:createPage({ label = "\"" .. mod .. "\" Settings" })
	page:createInfo{
		text = "Welcome to \"" .. mod .. "\" Configuration Menu. \n \n \n" ..
		"Original mod by Spammer, edited by JosephMcKean.",
	}
	page:createHyperLink{
		text = "Spammer's Nexus Profile",
		url = "https://www.nexusmods.com/users/140139148?tab=user+files",
	}
	local function createCreatureList()
		local creatures = {}
		for creature in tes3.iterateObjects(tes3.objectType.creature) do
			if not (creature.baseObject and creature.baseObject.id ~= creature.id) then
				creatures[#creatures + 1] = (creature.baseObject or creature).id:lower()
			end
		end
		table.sort(creatures)
		return creatures
	end
	template:createExclusionsPage{
		label = "Peaceful Creatures",
		description = "Move creatures into the left list to allow them to be peaceful." .. "\n" .. "\n" ..
		"Requires a RESTART and does not affect references that are already created.",
		variable = mwse.mcm.createTableVariable { id = "peaceful", table = config },
		leftListLabel = "Peaceful Creatures",
		rightListLabel = "Creatures",
		filters = { { label = "Creatures", callback = createCreatureList } },
	}
	template:createExclusionsPage{
		label = "Pacified by Cure Common Disease",
		description = "Move creatures into the left list to allow them to be pacified by Cure Common Disease spell." .. "\n" ..
		"\n" .. "Does not affect references that are already created.",
		variable = mwse.mcm.createTableVariable { id = "pacifyDiseased", table = config },
		leftListLabel = "Creatures that can be pacified by Cure Common Disease spell",
		rightListLabel = "Creatures",
		filters = { { label = "Creatures", callback = createCreatureList } },
	}
	template:createExclusionsPage{
		label = "Pacified by Cure Blight Disease",
		description = "Move creatures into the left list to allow them to be pacified by Cure Blight Disease spell." .. "\n" ..
		"\n" .. "Does not affect references that are already created.",
		variable = mwse.mcm.createTableVariable { id = "pacifyBlighted", table = config },
		leftListLabel = "Creatures that can be pacified by Cure Blight Disease spell",
		rightListLabel = "Creatures",
		filters = { { label = "Creatures", callback = createCreatureList } },
	}
end
event.register("modConfigReady", registerModConfig)
