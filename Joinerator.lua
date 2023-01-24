

JoineratorCache = {}

function JoineratorCache:Init()
	GuildJoinerator:dbprint("JoineratorCache:Init()")
	self.guilds = {}
	self.counts = {}
end

function JoineratorCache:Dump()
	GuildJoinerator:dbprint("DUMPING:")
	if self.guilds == nil then
		GuildJoinerator:dbprint("dump says self.guilds is nil")
		return
	end
	for g, t in pairs(self.guilds) do
		GuildJoinerator:dbprint("Guild: ", g, "cached count:", self.counts[g])
		for k, v in pairs(t) do GuildJoinerator:dbprint(k, v) end
	end
end

function JoineratorCache:AddGuild(guild)
	-- add a guild to the cache - ensures all things are set up properly
	-- safe to call multiple times
	-- PrintArray(self.guilds)
	-- self:Dump()
	if not self.guilds or not self.counts then GuildJoinerator:dbprint("Adding Guild:", guild) end
	self.guilds = self.guilds or {}
	self.counts = self.counts or {}
	self.guilds[guild] = (self.guilds[guild] or {})
	self.counts[guild] = (self.counts[guild] or 0)
end

function JoineratorCache:GetNames(guild)
	-- returns a list of player names, and a count: names, count = {"a", "b", ..}, 2.0

	local names, count = {}, 0.0
	local current_player = UnitName("player")

	if not self.guilds then 		
		return names, count 
	end

	local g = self.guilds[guild]

	if g == nil then -- no guild? no names, no count
		return names, count
	end

	-- PrintArray(g)

	if type(g) ~= "table" then
		return names, count
	end

	for n, ls in pairs(g) do
		if n == current_player then
			GuildJoinerator:dbprint('Skipping over myself')
			return
		end
		--print("n is type:", type(n))
		--print("ls is type:", type(ls))
		--print("g is type:", type(g))
		table.insert(names, n)
		count = count + 1
	end
	GuildJoinerator:dbprint("GetNames result: (count)", tostring(count))
	-- PrintArray(names)
	return names, count
end

function JoineratorCache:AddEntry(guild, name, lastseen)
	-- inserts an entry for name into guild, with lastseen
	self:AddGuild(guild)
	self.guilds[guild][name] = lastseen
	self.counts[guild] = self.counts[guild] + 1
	GuildJoinerator:dbprint("Added:", name, "to", guild, "for", lastseen)
end

function JoineratorCache:RemoveEntry(guild, name)
	-- removes an entry for a given name within guild
	local g = self.guilds
	if g[guild] == nil then
		GuildJoinerator:dbprint("Guild does not exist in table, shortcut exit")
		return
	end
	if g[guild][name] == nil then
		GuildJoinerator:dbprint("Name does not exist in guild, shortcut exit")
		return
	end
	g[guild][name] = nil
	self.counts[guild] = self.counts[guild] - 1
	GuildJoinerator:dbprint("Removed:", name, "from", guild)
end

function JoineratorCache:PruneEntries(cutoff)
	-- checks all entries in all guilds, removing expired entries
	-- expired is anything older than the given cuttoff
	if not self.guilds then 
		GuildJoinerator:dbprint("no guild found to prune")
		return 
	end

	local obsoletes = {}

	-- first, ensure all guild entries exist - saves logic later
	for g, t in pairs(self.guilds) do obsoletes[g] = {} end

	-- next, loop over all entries, mark any that need to be removed
	for g, t in pairs(self.guilds) do
		for n, ls in pairs(t) do
			if ls <= cutoff then
				obsoletes[g][n] = true
				GuildJoinerator:dbprint(n, "from", g, "has expired:", ls, "<", cutoff)
			end
		end
	end

	-- finally, loop over entries in `obsoletes`, and remove them from main cache
	for g, t in pairs(obsoletes) do for n, _ in pairs(t) do self:RemoveEntry(g, n) end end

end

-- -- -- [[ GuildJoinerator ]] -- -- --

JoineratorEngine = {
	["version"] = "0.1",
} -- JoineratorEngine is a table
JoineratorEngine.JoineratorCache = JoineratorCache
JoineratorEngine.STATES = {
	["STARTUP"] = "STARTUP",
	["WAITING"] = "WAITING",
	["SEARCHING"] = "SEARCHING",
	["TEARDOWN"] = "TEARDOWN",
	["JOINING"] = "JOINING",
	["LISTENING"] = "LISTENING",
}
JoineratorEngine.STRATEGIES = {
	["NONE"] = "NONE",
	["SINGLE"] = "SINGLE",
	["SMALLEST"] = "SMALLEST",
}
JoineratorEngine.state = JoineratorEngine.STATES.STARTUP
JoineratorEngine.strategy = JoineratorEngine.STRATEGIES.NONE
JoineratorEngine.target_guild = nil
JoineratorEngine.hooked = false

function JoineratorEngine:Init()
	-- Init all of the things - no hooks, just prep
	GuildJoinerator:dbprint("JoineratorEngine:Init()")
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", JoineratorEngine.ChatFilterOutgoing)
	--ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", JoineratorEngine.ChatFilterIncoming)
	--print ("I am in:", GetGuildInfo("player")[1])
	self:NextState(self.STATES.WAITING)
end

function JoineratorEngine:NextState(state)
	-- check if state is a valid transition, and handle anything that needs to be done in-between
	local old_state = self.state
	if (old_state == self.STATES.STARTUP) then
		-- only valid transition for STARTUP is WAITING
		if (state == self.STATES.WAITING) then
			GuildJoinerator:dbprint("Transitioning from:", old_state, "to", state)
			self.state = state
		else
			GuildJoinerator:dbprint("Failed to transition from (found):", old_state, "to", state)
		end
	elseif (old_state == self.STATES.WAITING) then
		if (state == self.STATES.SEARCHING) then
			-- confirm all the things
			GuildJoinerator:dbprint("Transitioning from:", old_state, "to", state)
			self.state = state
		else
			GuildJoinerator:dbprint("Failed to transition from (found):", old_state, "to", state)
		end
	elseif (old_state == self.STATES.SEARCHING) then
		if (state == self.STATES.JOINING) then
			-- confirm all the things
			GuildJoinerator:dbprint("Transitioning from:", old_state, "to", state)
			self.state = state
		else
			GuildJoinerator:dbprint("Failed to transition from (found):", old_state, "to", state)
		end
	elseif (old_state == self.STATES.JOINING) then
		if (state == self.STATES.WAITING) then
			-- confirm all the things
			GuildJoinerator:dbprint("Transitioning from:", old_state, "to", state)
			self.state = state
		else
			GuildJoinerator:dbprint("Failed to transition from (found):", old_state, "to", state)
		end
	else
		GuildJoinerator:dbprint("Failed to transition from:", old_state, "to", state)
	end
end

function JoineratorEngine:HookWorldClicks()
	-- installs all the hooks and macro-tweaks to allow for background sarching based on user input activations
	hook_world_clicks = true -- this should be read from Ace3 config

	if (hook_world_clicks) and (self.hooked == false) then
		self.hooked = true
		WorldFrame:HookScript("OnMouseDown", function(self, button) -- this can't be unhooked, but it can call a dead Pump()
			JoineratorEngine:Pump()
		end)
	end
end

function JoineratorEngine:Pump()
	-- intended to crank along the /who results
	if self.state ~= self.STATES.SEARCHING then
		GuildJoinerator:dbprint("JoineratorEngine:Pump() - returning early, not in the right state:", self.state)
		return -- bail early if we're not in the right state for pumping
	end

	-- worth putting a 'dont thump the pump' time-out in here to bail early if needed
	-- self.JoineratorCache:PruneEntries(time() - 60) -- one minute or older = fried
	-- do we need to re-issue a new search, or something? If so, figure it here
	if self.strategy == self.STRATEGIES.SINGLE then
		local names, count = self.JoineratorCache:GetNames(self.target_guild)
		GuildJoinerator:dbprint("JoineratorEngine:Pump() - Found", tostring(count), "names in guild:", self.target_guild)
		if count > 5 then
			JoineratorEngine:CompleteSingleSearchStrategy(self.target_guild)
		end
		return
	end
	-- are we just priming the handle with the equivalent of GetNextWho() or ManualWho() or whatever - poke it until results happen!
	-- dbprint("JoineratorEngine:Pump() - Pumping!")
end

function JoineratorEngine:StartSingleSearchStrategy(target_guild, restricted)
	-- configure the search to look for members of given guild	
	local pattern = 'g-"' .. target_guild .. '"'
	if restricted then
		pattern = ' 15-'
	end
	GuildJoinerator:dbprint(pattern)

	self.target_guild = target_guild
	self.strategy = self.STRATEGIES.SINGLE
	self:NextState(self.STATES.SEARCHING)
	self:HookWorldClicks()
	FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
	GuildJoinerator:RegisterEvent("WHO_LIST_UPDATE")
	C_FriendList.SetWhoToUi(1) -- ensures result of SendWho is returned as WHO_LIST_UPDATE event rather than CHAT_MSG_SYSTEM
	GuildJoinerator:dbprint("New Search Pattern:", pattern)
	C_FriendList.SendWho(pattern)
end

function JoineratorEngine:CompleteSingleSearchStrategy(target_guild)
	-- we've got enough name data to get us an invite - move to next phase
	self.target_guild = target_guild
	self.strategy = self.STRATEGIES.NONE
	self:NextState(self.STATES.JOINING) -- ensures no more results are coming through
	GuildJoinerator:UnregisterEvent("WHO_LIST_UPDATE")
	FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
	C_FriendList.SetWhoToUi(0) -- ensures result of SendWho is returned as WHO_LIST_UPDATE event rather than CHAT_MSG_SYSTEM
	local names, count = self.JoineratorCache:GetNames(target_guild)
	GuildJoinerator:dbprint("JoineratorEngine:CompleteSingleSearchStrategy(" .. target_guild .. ") = Count:", count)

	-- choose a name from the list randomly, and whisper them with "ginvite please"
	JoineratorEngine:SendInviteRequests(names, count)
end

function GuildJoinerator:WHO_LIST_UPDATE(event)
	local numWhoResults = C_FriendList.GetNumWhoResults()

	GuildJoinerator:dbprint(event, "Results:", numWhoResults)
	GuildJoinerator:dbprint("GetWhoInfo()")
	for i = 1, numWhoResults do
		p = C_FriendList.GetWhoInfo(i)
		-- PrintArray(p)
		GuildJoinerator:dbprint(format("%s: %s of <%s> (level %d %s %s) is in %s as of %s", 
			i, p.fullName, p.fullGuildName, p.level, p.raceStr, p.classStr, p.area, time())
		)
		JoineratorCache:AddEntry(p.fullGuildName, p.fullName, time())
	end

	JoineratorEngine:CompleteSingleSearchStrategy(JoineratorEngine.target_guild)

end

function JoineratorEngine:SendInviteRequests(names, count)
	JoineratorEngine.outgoings = JoineratorEngine.outgoings or {}
	if not count then 
		GuildJoinerator:dbprint('Early bail, no count in SendInviteRequests')
		return 
	end
	local max_invites = min(count, 5)
	local names_copy = {}
	local r = nil
	for i = 1, max_invites do
		r = names[math.random( #names )]
		--print("Random: r=", r)
		names_copy[r] = true
	end
	local dumpout = {}
	for k, v in pairs(names_copy) do
		table.insert(dumpout, k)
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", JoineratorEngine.ChatFilterOutgoing)
	for i = 1, #dumpout do
		print("Whispering:", dumpout[i], "...")
		JoineratorEngine.outgoings[dumpout[i]] = true
		SendChatMessage("ginvite, please! (automated request from Zdeyn's Guild Joinerator)", "WHISPER", "Common", dumpout[i]);
	end
end

function JoineratorEngine:ChatFilterOutgoing(_, message, characterName, _)
	--local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...
	--local current_player = UnitName("player")
	--print("Player:", current_player)
	--print("ChatFilter: event, ...", event, ...)
	local short_recipient, _ = strsplit( "-", characterName, 2 )
	--print("Recipient, Me:", short_recipient, current_player)
	if JoineratorEngine.outgoings[short_recipient] then
		JoineratorEngine.outgoings[short_recipient] = nil
		--print("Suppressed!", arg1, arg2)
		return true
	end
	return false
end

function JoineratorEngine:ChatFilterIncoming(_, message, characterName, _)
	-- local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...
	-- return true, ...
	local short_recipient, _ = strsplit( "-", characterName, 2 )
	GuildJoinerator:dbprint("INBOUND:", message, short_recipient)
	if not IsInGuild() then 
		GuildJoinerator:dbprint("I'm not guilded")
		return 
	end

	if message:find("ginv") then
		GuildJoinerator:dbprint("found ginv from:", characterName, short_recipient)
		local dialog = StaticPopup_Show("JoineratorGuildInvitePopup", characterName)
		if (dialog) then
			GuildJoinerator:dbprint('yay dialog')
			dialog.data = characterName
		end
		return
	end
end

--[[ function PrintArray(array)
	if array == nil then
		dbprint("(nil)")
		return
	end
	for k, v in pairs(array) do
		if type(v) == "table" then
			dbprint(v, "contains:")
			PrintArray(v)
		else
			print(v)
		end
	end
end ]]

-- function JoineratorEngine:ProcessWhoResults(query, result, complete)
