GuildJoinerator.defaults = {
	profile = {
		lastJoinType = 0,
		hideMinimapToggle = false,
		primaryGuild = "Alpha",
		usePrimaryGuild = true,
		secondaryGuild = "Bravo",
		useSecondaryGuild = true,
		tertiaryGuild = "Charlie",
		useTertiaryGuild = true,
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
GuildJoinerator.options = {
	type = "group",
	name = "Zdeyn's Guild Joinerator - Options",
	icon = "Interface\\Icons\\Inv_misc_summerfest_braziergreen",
	args = {
		descHeading = {
			type = "description",
			order = 0,
			fontSize = "large",
			name = "Zdeyn's Guild Joinerator",
			image = "Interface\\Icons\\Inv_misc_summerfest_braziergreen",
		},
		descText = {
			type = "description",
			order = 1,
			fontSize = "large",
			name = "    a) Choose destination,    b) Mash button,    c) Receive invite!",
		},
		configureDestinationsHeading = {
			type = "description",
			order = 2,
			fontSize = "large",
			name = "\nConfigure Destinations:",
		},
		primaryGroup = {
			type = "group",
			name = "Primary Guild",
			inline = true,
			order = 3,
			args = {
				usePrimaryGuild = {
					order = 1,
					type = "toggle",
					name = "Use Primary Guild?",
					desc = "Enable or Disable the use of the Primary guild",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.useprimary
					end,
					set = function(info, value)
						dbprint("Use Primary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.useprimary = value
						GuildJoinerator.options.args.primaryGroup.args.primaryGuild.disabled = not value
					end,
				},
				primaryGuild = {
					order = 2,
					type = "input",
					name = "Primary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.primary
					end,
					set = function(info, value)
						dbprint("Primary Guild set to:", value)
						GuildJoinerator.db.profile.guilds.primary = value
					end,
				},
			},
		},
		secondaryGroup = {
			type = "group",
			name = "Secondary Guild",
			inline = true,
			order = 4,
			args = {
				useSecondaryGuild = {
					order = 1,
					type = "toggle",
					name = "Use Secondary Guild?",
					desc = "Enable or Disable the use of the Secondary guild",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.usesecondary
					end,
					set = function(info, value)
						dbprint("Use Secondary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.usesecondary = value
						GuildJoinerator.options.args.secondaryGroup.args.secondaryGuild.disabled = not value
					end,
				},
				secondaryGuild = {
					order = 2,
					type = "input",
					name = "Secondary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.secondary
					end,
					set = function(info, value)
						dbprint("Secondary Guild set to:", value)
						GuildJoinerator.db.profile.guilds.secondary = value
					end,
				},
			},
		},
		tertiaryGroup = {
			type = "group",
			name = "Tertiary Guild",
			inline = true,
			order = 4,
			args = {
				useTertiaryGuild = {
					order = 1,
					type = "toggle",
					name = "Use Tertiary Guild?",
					desc = "Enable or Disable the use of the Tertiary guild",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.usetertiary
					end,
					set = function(info, value)
						dbprint("Use Tertiary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.usetertiary = value
						GuildJoinerator.options.args.tertiaryGroup.args.tertiaryGuild.disabled = not value
					end,
				},
				tertiaryGuild = {
					order = 2,
					type = "input",
					name = "Tertiary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					--width = "half",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.tertiary
					end,
					set = function(info, value)
						dbprint("Tertiary Guild set to:", value)
						GuildJoinerator.db.profile.guilds.tertiary = value
					end,
				},
			},
		},
		hideMinimapToggle = {
			type = "toggle",
			order = -1,
			name = "Hide Minimap icon",
			desc = "Hide the Minimap icon?",
			-- inline getter/setter example
			get = function(info)
				return GuildJoinerator.db.profile.minimap.hide
			end,
			set = function(info, value)
				dbprint("Minimap Toggled to: Hidden =", value)
				GuildJoinerator.db.profile.minimap.hide = value
				GuildJoinerator:UpdateMinimap()
			end,
		},
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function GuildJoinerator:GetValue(info)
	return self.db.profile[info[#info]]
end

function GuildJoinerator:SetValue(info, value)
	self.db.profile[info[#info]] = value
	dbprint("The " .. info[#info] .. " was set to: " .. tostring(value))
end
