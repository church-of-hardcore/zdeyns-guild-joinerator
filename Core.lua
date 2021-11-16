-- we can mixin more Ace libs here
GuildJoinerator = LibStub("AceAddon-3.0"):NewAddon("GuildJoinerator", "AceEvent-3.0", "AceConsole-3.0")

local COLORS = { -- https://pixelimperfectdotcom.wordpress.com/2013/09/05/all-world-of-warcraft-hex-color-codes/
	NORMAL = "|r",
	GENERAL = "|cfffec1c0",
	SYSTEM = "|cffffff00",
	GUILD = "|cff3ce13f",
	OFFICER = "|cff40bc40",
	-- ...
	WHISPER = "|cffff7eff",
	YELL = "|cffff3f40",
	-- ...
	BNET_WHISPER = "|cff00faf6",
	BNET_CONVERSATION = "|cff00afef",
	-- ...
	POOR = "|cff889d9d",
	COMMON = "|cffffffff",
	UNCOMMON = "|cff1eff0c",
	RARE = "|cff0070ff",
	SUPERIOR = "|cffa335ee",
	LEGENDARY = "|cffff8000",
	HEIRLOOM = "|cffe6cc80",
	-- ...
	LIGHT_BLUE = "|cff00afef",
}

GuildJoinerator.COLORS = COLORS

function GuildJoinerator:OnInitialize()
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("GuildJoineratorDB", {
		profile = {
			minimap = {
				hide = false,
			},
			guilds = {
				useprimary = true,
				usesecondary = true,
				usetertiary = true,
				primary = "Alpha",
				secondary = "Bravo",
				tertiary = "Charlie",
			}
		},
	})

	self.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GuildJoinerator", {
		type = "data source",
		text = "GuildJoinerator Text",
		icon = "Interface\\Icons\\Inv_misc_summerfest_braziergreen",
		OnClick = function(clicked_frame, button)
			if button == "RightButton" then
				-- TODO: If config window is open, close it instead
				GuildJoinerator:ToggleConfig()
			else	
				GuildJoinerator:ToggleMainWindow()
			end
		end,
	
		OnTooltipShow = function(tt)
			tt:AddLine(COLORS.LEGENDARY .. "Guild Joinerator" .. COLORS.NORMAL .. " by " .. COLORS.LEGENDARY .. "Zdeyn")
			tt:AddLine(COLORS.UNCOMMON .. "Click" .. COLORS.NORMAL .. " to toggle the Guild Joinerator window")
			tt:AddLine(COLORS.UNCOMMON .. "Right-click" .. COLORS.NORMAL .. " to open the options menu")
		end,
	})

	self.icon = LibStub("LibDBIcon-1.0")
	self.icon:Register("GuildJoinerator", self.LDB, self.db.profile.minimap)

	-- self.DBI = LibStub("LibDBIcon-1.0")
	self.AC = LibStub("AceConfig-3.0")
	self.ACD = LibStub("AceConfigDialog-3.0")
	self.AceGUI = LibStub("AceGUI-3.0")

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-registry-3-0
	self.AC:RegisterOptionsTable("GuildJoinerator_Options", self.options)
	self.optionsFrame = self.ACD:AddToBlizOptions("GuildJoinerator_Options", "Guild Joinerator")
	self.customWindowFrame = nil

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.AC:RegisterOptionsTable("GuildJoinerator_Profiles", profiles)
	self.ACD:AddToBlizOptions("GuildJoinerator_Profiles", "Profiles", "GuildJoinerator_Options")

	-- define other useful booleans for now
	self.main_window_exists = false

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("gj", "SlashCommand")
	self:RegisterChatCommand("guildjoiner", "SlashCommand")
	self:RegisterChatCommand("guildjoinerator", "SlashCommand")

	-- perform final bits here
end

function GuildJoinerator:OnEnable()
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	-- self:RegisterEvent("CHAT_MSG_CHANNEL")
end

function GuildJoinerator:PLAYER_STARTED_MOVING(event)
	print(event)
end

function GuildJoinerator:SlashCommand(input, editbox)
	if input == "main" then
		self:ToggleMainWindow()

	elseif input == "options" then
		self:ToggleConfig()

	elseif input == "toggle" then
		self:ToggleMinimap()
		local state = (self.db.profile.minimap.hide and 'Hidden') or 'Shown'
		print(COLORS.HEIRLOOM .. "Guild Joinerator:" .. COLORS.NORMAL .. state)
	
	elseif input == "join" then
		print("I'd join something, but I don't know how yet")

	else -- A R G B -> |caarrggb blsadfjsdhf |r default-text blah
		self:Print(COLORS.HEIRLOOM .. "Guild Joinerator" .. COLORS.NORMAL)
		self:Print(COLORS.LIGHT_BLUE .. "Syntax:" .. COLORS.NORMAL .. " /guildjoinerator [command]")
		self:Print(COLORS.LIGHT_BLUE .. "Syntax:" .. COLORS.NORMAL .. " /gj [command]")
		self:Print(COLORS.UNCOMMON .. "Commands:" .. COLORS.NORMAL .. " main options toggle join")
	end
end

function GuildJoinerator:ToggleMainWindow()
	print("Toggling Main Window")
	if self.main_window_exists then
		print "Closing.."
        GuildJoinerator:DestroyMainWindow()
    else
		print "Opening.."
        GuildJoinerator:CreateMainWindow()
    end
end

function GuildJoinerator:ToggleMinimap()
	print("Toggling! Initial value:", self.db.profile.minimap.hide)
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	
	print("After value:", self.db.profile.minimap.hide)
	GuildJoinerator:UpdateMinimap()
end

function GuildJoinerator:UpdateMinimap()
	print("UPDATING MINI-MAP: Hidden = " ..tostring(self.db.profile.minimap.hide))
	if self.db.profile.minimap.hide then 
		self.icon:Hide("GuildJoinerator")
	else
		self.icon:Show("GuildJoinerator")
	end
end

function GuildJoinerator:ToggleConfig()
    if self.customWindowFrame then
        self.ACD:Close("GuildJoinerator_Options")
		self.customWindowFrame:Release()
		self.customWindowFrame = nil
    else
		self.customWindowFrame = self.AceGUI:Create("Window")
        self.ACD:Open("GuildJoinerator_Options", self.customWindowFrame)
    end
end

--[[ function GuildJoinerator:ShowConfig()
    if InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame_Show()
    else
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
end ]]
