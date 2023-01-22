local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnInitialize OnEnable etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then return xpcall(func, errorhandler, ...) end
end

local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

function GuildJoinerator:DestroyMainWindow(widget)
	if widget == nil then widget = self.main_window end
	self.main_window_exists = false
	self.AceGUI:Release(widget)
end

function GuildJoinerator:CreateMainWindow()
	-- This pattern used because GuildJoinerator:DestroyMainWindow() above
	-- doesn't *hide* the window, it *destroys* it.
	-- this hard-check prevents reconstructing what's already showing
	if self.main_window_exists == true then return end
	self.main_window_exists = true

	local window = self.AceGUI:Create("Window")
	self.main_window = window
	window:SetTitle("Zdeyn's Guild Joinerator")
	window:SetCallback("OnClose", function(widget)
		self:DestroyMainWindow(widget)
	end)
	window:SetLayout("Flow")
	window:SetWidth(400)
	window:SetHeight(120)

	-- Add the frame as a global variable under the name `GuildJoineratorMainWindow`
	_G["GuildJoineratorMainWindow"] = window.frame
	-- Register the global variable `GuildJoineratorMainWindow` as a "special frame"
	-- so that it is closed when the escape key is pressed.
	tinsert(UISpecialFrames, "GuildJoineratorMainWindow")

	-- local frame = window.frame

	local heading = self.AceGUI:Create("Heading")
	heading:SetText("A big thankyou to " .. self.COLORS.HEIRLOOM .. "Knics" .. self.COLORS.NORMAL ..
			                " for allowing this to happen!")
	heading:SetFullWidth(1)

	local label = self.AceGUI:Create("Label")
	label:SetFontObject(GameFontNormalLarge)
	label:SetJustifyH("CENTER")
	label:SetText("Choose your destination:")
	--label:SetFullWidth(1)
	--label:SetHeight(100)

	--[[ local editbox = self.AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("Log:")
	editbox:SetFullWidth(1)
	editbox:SetNumLines(14)
	editbox:DisableButton(true)
	editbox:SetFocus()
	editbox:SetDisabled(true)
	local log_string = "Empty!"
	editbox:SetText(log_string) ]]

	local dropdown = self.AceGUI:Create("Dropdown")
	local list = {
		--[0] = "Assign me, please!",
		[1] = self.db.profile.guilds.primary,
		[2] = self.db.profile.guilds.secondary, 
		[3] = self.db.profile.guilds.tertiary,
	}

	dropdown:SetList(list)
	dropdown:SetWidth(200)

	dropdown:SetItemDisabled(1, not GuildJoinerator.db.profile.guilds.useprimary)
	dropdown:SetItemDisabled(2, not GuildJoinerator.db.profile.guilds.usesecondary)
	dropdown:SetItemDisabled(3, not GuildJoinerator.db.profile.guilds.usetertiary)

	dropdown:SetValue(self.db.profile.lastjointype or 1)

	self.dropdown_widget = dropdown

	local button = self.AceGUI:Create("Button")
	button:SetText("Joinerate")
	button:SetWidth(170)
	button:SetCallback("OnClick", function()
		GuildJoinerator:JoinButton_OnClick()
	end)

	window:AddChild(heading)
	window:AddChild(label)
	window:AddChild(dropdown)
	window:AddChild(button)
	-- window:AddChild(editbox)
	dbprint("I am in a guild:", IsInGuild())

end

function GuildJoinerator:JoinButton_OnClick()
	-- if we're searching, this should call JoineratorEngine:Pump()
	if JoineratorEngine.state == JoineratorEngine.STATES.SEARCHING then
		JoineratorEngine:Pump()
		return
	end

	local value = self.dropdown_widget:GetValue()
	self.db.profile.lastjointype = value
	dbprint("Got:", value, "from dropdown")
	local guild = nil
	local restricted = false
	if value == 1 then
		guild = self.db.profile.guilds.primary
		restricted = self.db.profile.guilds.restrictprimary
		dbprint("Using Primary:", guild)
	elseif value == 2 then
		guild = self.db.profile.guilds.secondary
		restricted = self.db.profile.guilds.restrictsecondary
		dbprint("Using Secondary:", guild)
	elseif value == 3 then
		guild = self.db.profile.guilds.tertiary	
		restricted = self.db.profile.guilds.restricttertiary
		dbprint("Using Tertiary:", guild)
	else
		guild = nil
		dbprint("not found")
	end
	JoineratorEngine:Init()
	dbprint("Guild:", guild)
	dbprint("Restricted:", restricted)
	if guild then
		JoineratorEngine:StartSingleSearchStrategy(guild, restricted)
	else
		dbprint("Probably attempting a multi-search")
	end
end

