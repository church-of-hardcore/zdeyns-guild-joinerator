GuildJoinerator.defaults = {
	profile = {
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
	name = "Guild Joinerator",
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
			fontSize = "medium",
			name = "Instructions for Main Window:\n    a) Choose destination,\n    b) Mash button",
		},
		guildsGroup = {
			type = "group",
			name = "Configure Destinations",
			order = 2,
			args = {
				usePrimaryGuild = {
					order = 1,
					type = "toggle",
					name = "Use Primary Guild?",
					desc = "Enable or Disable the use of the Primary guild",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.useprimary
					end,
					set = function(info, value)
						print("Use Primary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.useprimary = value
						GuildJoinerator.options.args.guildsGroup.args.primaryGuild.disabled = not value
					end,
				},
				primaryGuild = {
					order = 2,
					type = "input",
					name = "Primary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.primary
					end,
					set = function(info, value)
						print("Primary Guild set to:", value)
						GuildJoinerator.db.profile.guilds.primary = value
					end,
				},
				useSecondaryGuild = {
					order = 3,
					type = "toggle",
					name = "Use Secondary Guild?",
					desc = "Enable or Disable the use of the Secondary guild",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.usesecondary
					end,
					set = function(info, value)
						print("Use Secondary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.usesecondary = value
						GuildJoinerator.options.args.guildsGroup.args.secondaryGuild.disabled = not value
					end,
				},
				secondaryGuild = {
					order = 4,
					type = "input",
					name = "Secondary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.secondary
					end,
					set = function(info, value)
						print("Secondary Guild set to:", value)
						GuildJoinerator.db.profile.guilds.secondary = value
					end,
				},
				useTertiaryGuild = {
					order = 5,
					type = "toggle",
					name = "Use Tertiary Guild?",
					desc = "Enable or Disable the use of the Tertiary guild",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.usetertiary
					end,
					set = function(info, value)
						print("Use Tertiary Toggled to: Use =", value)
						GuildJoinerator.db.profile.guilds.usetertiary = value
					end,
				},
				tertiaryGuild = {
					order = 6,
					type = "input",
					name = "Tertiary Guild",
					desc = "Enter the name of a guild, excluding < and >",
					get = function(info)
						return GuildJoinerator.db.profile.guilds.tertiary
					end,
					set = function(info, value)
						print("Tertiary Guild set to:", value)
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
				print("Minimap Toggled to: Hidden =", value)
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
	print("The " .. info[#info] .. " was set to: " .. tostring(value))
end
