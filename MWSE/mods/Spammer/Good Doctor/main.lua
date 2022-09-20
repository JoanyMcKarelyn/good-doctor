local mod = {name = "Good Doctor (Joseph Edit)", ver = "1.0"}
local config = require("Spammer.Good Doctor.config").config
local logger = require("Spammer.Good Doctor.logging").createLogger("main")

---@param e table|spellResistEventData
event.register("spellResist", function(e)
    if (e.effect.id == tes3.effect.cureCommonDisease and
        config.pacifyDiseased[e.target.baseObject.id:lower()]) or
        (e.effect.id == tes3.effect.cureBlightDisease and
            config.pacifyBlighted[e.target.baseObject.id:lower()]) then
        e.target.mobile.fight = 0
        logger:debug("%s's fight value is now: %s", e.target.id,
                     e.target.mobile.fight)
        e.target.mobile.flee = 100
        e.target.mobile.actionData.aiBehaviorState = tes3.aiBehaviorState.flee
        e.target.mobile:stopCombat(true)
    end
end)

local function onInitialized()
    for creature in tes3.iterateObjects(tes3.objectType.creature) do
        if config.peaceful[creature.id] then creature.aiConfig.fight = 0 end
    end
end
event.register("initialized", onInitialized)

local function registerModConfig()
    local template = mwse.mcm.createTemplate(mod.name)
    template.onClose = function() config.save() end
    template:register()

    local page =
        template:createPage({label = "\"" .. mod.name .. "\" Settings"})
    page:createInfo{
        text = "Welcome to \"" .. mod.name .. "\" Configuration Menu. \n \n \n" ..
            "Original mod by Spammer, edited by JosephMcKean."
    }
    page:createHyperLink{
        text = "Spammer's Nexus Profile",
        url = "https://www.nexusmods.com/users/140139148?tab=user+files"
    }
    page:createDropdown{
        label = "Log Level",
        description = "Set the logging level.",
        options = {
            {label = "DEBUG", value = "DEBUG"},
            {label = "INFO", value = "INFO"},
            {label = "ERROR", value = "ERROR"}, {label = "NONE", value = "NONE"}
        },
        variable = mwse.mcm.createTableVariable {
            id = "logLevel",
            table = config
        },
        -- code that copied over from merlord's mod
        callback = function(self)
            for _, log in ipairs(require("Spammer.Good Doctor.logging").loggers) do
                mwse.log("Setting %s to log level %s", log.name,
                         self.variable.value)
                log:setLogLevel(self.variable.value)
            end
        end
    }
    local function createCreatureList()
        local creatures = {}
        for creature in tes3.iterateObjects(tes3.objectType.creature) do
            if not (creature.baseObject and creature.baseObject.id ~=
                creature.id) then
                creatures[#creatures + 1] =
                    (creature.baseObject or creature).id:lower()
            end
        end
        table.sort(creatures)
        return creatures
    end
end 
event.register("modConfigReady", registerModConfig)
