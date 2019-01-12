
Menu = {
	Hands = {
		{
			Label = "Dealer's Ace always counts as 1",
			Tooltip = "Dealer cannot have soft hands.",
			SettingName = "Hands.DealerAceIsOne",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Dealer's Stand Value",
			Tooltip = "Dealer stands when their hand is this value or greater.",
			SettingName = "Hands.DealerStandValue",
			Default = 17,
			Type = "int",
		},
		{
			Label = "Split based on card value",
			Tooltip = "While enabled, hands can be split based on card value (eg any face cards) instead of only on card name (eg two Queens)",
			SettingName = "Hands.SplitOnValue",
			Default = false,
			Type = "boolean",
		},
	},
	Rupee = {
		{
			Label = "Max Chips",
			Tooltip = "Only this number of chips can be used during a rupee pull. 0 for no limit.",
			SettingName = "Rupee.MaxChips",
			Default = 1,
			Type = "int",
		},
	},
	Powerups = {
		{
			Label = "Allow Hostile",
			Tooltip = "Powerups can be used to make other players lose.",
			SettingName = "Powerups.AllowHostile",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Allow Fifth Card",
			Tooltip = "Powerups can always be used as a fifth card on losing or bust hands.",
			SettingName = "Powerups.FifthCard",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Multiple Help Rewards",
			Tooltip = "A single powerup can give multiple Help rewards when helping more than one other player.",
			SettingName = "Powerups.MultiHelp",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Reveal Dealer is Helping",
			Tooltip = "Players receive a Help reward for revealing the dealer's face-down card.",
			SettingName = "Powerups.RevealIsHelp",
			Default = false,
			Type = "boolean",
		},
	},
	Bankruptcy = {
		{
			Label = "Bankruptcy Clears Chips",
			Tooltip = "Players lose their chips gem when they declare bankruptcy.",
			SettingName = "Bankruptcy.ClearChips",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Bankruptcy Clears Powerups",
			Tooltip = "Players lose their powerups gem when they declare bankruptcy.",
			SettingName = "Bankruptcy.ClearPowerups",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Bankruptcy Clears Prestige",
			Tooltip = "Players lose their prestige gem when they declare bankruptcy.",
			SettingName = "Bankruptcy.ClearPrestige",
			Default = false,
			Type = "boolean",
		},
	},
	Prestige = {
		{
			Label = "Prestige Clears Chips",
			Tooltip = "Players lose their chips when they prestige.",
			SettingName = "Prestige.ClearChips",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Prestige Clears Powerups",
			Tooltip = "Players lose their powerups when they prestige.",
			SettingName = "Prestige.ClearPowerups",
			Default = true,
			Type = "boolean",
		},
	},
	Rounds = {
		{
			Label = "Turn Time Limit",
			Tooltip = "Time in seconds players have to take their turn. 0 to disable.",
			SettingName = "Rounds.TurnTimeLimit",
			Default = 30,
			Type = "int",
		},
		{
			Label = "Time Limit Ends After Action",
			Tooltip = "When enabled, players have no time limit after taking their first action on their turn.",
			SettingName = "Rounds.TurnTimeLimitEnds",
			Default = false,
			Type = "boolean",
		},
		{
			Label = "Bet Time Limit",
			Tooltip = "Time in seconds players have to place their bets.",
			SettingName = "Rounds.BetTime",
			Default = 25,
			Type = "int",
		},
		{
			Label = "Powerups Time Limit",
			Tooltip = "Time in seconds for the Powerups round phase to last.",
			SettingName = "Rounds.PowerupsTime",
			Default = 20,
			Type = "int",
		},
	},
	Misc = {
		{
			Label = "Use Automated Minigames",
			Tooltip = "If this is disabled, minigames will have to be handled manually.",
			SettingName = "Minigame.Automated",
			Default = true,
			Type = "boolean",
		},
		{
			Label = "Allow Trading Chips",
			Tooltip = "When enabled, players can give their chips to other players.",
			SettingName = "Chips.AllowTrading",
			Default = false,
			Type = "boolean",
		},
		{
			Label = "Global Bet Multiplier",
			Tooltip = "Multiply all bet payouts by this value.",
			SettingName = "Bet.Multiplier",
			Default = 1,
			Type = "int",
		},
	},
	Table = {
		{
			Label = "Table Model",
			Tooltip = "Model/Mesh for the table board object.",
			SettingName = "Table.Model",
			Default = "https://pastebin.com/MFqUm1QA",
			Type = "string",
			OnSet = function( newVal, oldVal )
				local board = getObjectFromGUID("ad770c")
				if not board then return end
				
				local custom = board.getCustomObject()
				if not custom then return end
				
				custom.mesh = newVal
				board.setCustomObject( custom )
				board.reload()
			end,
		},
		{
			Label = "Table Image",
			Tooltip = "Diffuse/Image for the table board object.",
			SettingName = "Table.Diffuse",
			Default = "https://i.imgur.com/Fil06bD.jpg",
			Type = "string",
			OnSet = function( newVal, oldVal )
				local board = getObjectFromGUID("ad770c")
				if not board then return end
				
				local custom = board.getCustomObject()
				if not custom then return end
				
				custom.diffuse = newVal
				board.setCustomObject( custom )
				board.reload()
			end,
		},
		{
			Label = "Table Normals",
			Tooltip = "Normal/Bump for the table board object.",
			SettingName = "Table.Normal",
			Default = "https://i.imgur.com/2LtkN4S.jpg",
			Type = "string",
			OnSet = function( newVal, oldVal )
				local board = getObjectFromGUID("ad770c")
				if not board then return end
				
				local custom = board.getCustomObject()
				if not custom then return end
				
				custom.normal = newVal
				board.setCustomObject( custom )
				board.reload()
			end,
		},
		{
			Label = "Table Collider",
			Tooltip = "Collider for the table board object.",
			SettingName = "Table.Collider",
			Default = "https://pastebin.com/UTx70Jff",
			Type = "string",
			OnSet = function( newVal, oldVal )
				local board = getObjectFromGUID("ad770c")
				if not board then return end
				
				local custom = board.getCustomObject()
				if not custom then return end
				
				custom.collider = newVal
				board.setCustomObject( custom )
				board.reload()
			end,
		},
		{
			Label = "Reset Table Board",
			Tooltip = "Reset table board to defaults",
			SettingName = "Table.Reset",
			-- Default = false,
			Type = "Action",
			OnSet = function()
				local board = getObjectFromGUID("ad770c")
				if not board then return end
				
				local custom = board.getCustomObject()
				if not custom then return end
				
				custom.mesh = "https://pastebin.com/MFqUm1QA"
				custom.diffuse = "https://i.imgur.com/Fil06bD.jpg"
				custom.normal = "https://i.imgur.com/2LtkN4S.jpg"
				custom.collider = "https://pastebin.com/UTx70Jff"
				board.setCustomObject( custom )
				board.reload()
				
				Settings["Table.Model"] = custom.mesh
				Settings["Table.Diffuse"] = custom.diffuse
				Settings["Table.Normal"] = custom.normal
				Settings["Table.Collider"] = custom.collider
				Settings["Table.Reset"] = false
			end,
		},
	},
}

Settings = {}

function processSettings( tbl ) -- Applies default values
	for k,v in pairs(tbl) do
		if type(v)=="table" then
			if v.SettingName then -- It's a setting
				Settings[v.SettingName] = Settings[v.SettingName] or v.Default
			else -- It's a category
				processSettings( v )
			end
		end
	end
end
processSettings( Menu )

-- Save --
----------

function onSave()
	local data = JSON.encode(Settings)
	self.script_state = data
end
function onLoad(saveData)
	-- Load Data
	if saveData then
		local decoded = JSON.decode( saveData )
		
		-- Apply settings if they exist
		if decoded then
			for k,v in pairs(decoded) do
				if Settings[k]~=nil then
					Settings[k] = v
				end
			end
		end
	end
	
	-- Initialisation
	mainMenu() -- Open menu
end

-- Get Setting --
-----------------

function getSetting( var )
	if type(var)=="table" then -- Likely another object making the call
		var = var.index or var.id or var.setting or var[1]
	end
	if not (var and type(var)=="string") then return end
	
	return Settings[var]
end


-- Menus --
-----------

function mainMenu()
	ListTitle = "Blackjack Settings"
	ListReference = Menu
	ListData = {}
	
	DirectoryPath = {}
	
	doListData()
	
	doMenu( 1 )
end
function doListData()
	for k in pairs(ListReference) do
		table.insert(ListData, k)
	end
	table.sort(ListData, function(a,b)
		if ListReference[a].SettingName and not ListReference[b].SettingName then return false end
		if ListReference[b].SettingName and not ListReference[a].SettingName then return true end
		
		return a<b
	end)
end

function getSettingType( settingData )
	local settingType = settingData.Type
	if not settingType then
		local defType = type(settingData.Default)
		
		if defType=="boolean" or defType=="string" then
			settingType = defType
		elseif defType=="number" then
			settingType = "float"
		end
	end
	
	return settingType
end

function doMenu(page)
	self.clearButtons()
	self.clearInputs()
	
	ListPage = page or 1
	
	-- Title
	self.createButton({
		label=ListTitle, click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
		position={0, 0.1, -1.45}, rotation={0,0,0}, width=0, height=0, font_size=230,
		font_color = {r=1,g=1,b=1},
	})
	
	Targets = {}
	
	local displayFrom = (ListPage-1)*10
	-- List Page
	for i=1,10 do
		local data = ListData[displayFrom + i]
		
		if not (data and ListReference[data]) then break end
		
		local zpos = -1.37 + (i * 0.25)
		local col = AdminMode and {r=1,g=0.1,b=0.1} or {r=1,b=1,g=1}
		
		-- Button
		local refData = ListReference[data]
		if refData and refData.SettingName then
			local settingType = getSettingType( refData )
			
			if (not settingType) or settingType=="boolean" then
				self.createButton({
					label= ("[505050]%s:[-] [b]%s[b]"):format( tostring(refData.Label or refData.SettingName), Settings[refData.SettingName] and "[00AA00]true[-]" or "[AA0000]false[-]" ), click_function="doAction"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0, 0.1, zpos}, rotation={0,0,0}, width=2800, height=250, font_size=120,
					color = col, tooltip = refData.Tooltip,
				})
			elseif settingType=="int" or settingType=="float" then -- Number entry
				-- Label
				self.createButton({
					label= ("%s:"):format(tostring(refData.Label or refData.SettingName)), click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
					position={-0.5, 0.1, zpos}, rotation={0,0,0}, width=0, height=0, font_size=80,
					font_color = col, tooltip = refData.Tooltip,
				})
				
				-- Input
				self.createInput({
					label=tostring(refData.Label or refData.SettingName), input_function="doInput"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0.5, 0.1, zpos}, rotation={0,0,0}, width=750, height=200, font_size=120,
					validation = settingType=="float" and 3 or 2, alignment = 3, value = tostring(Settings[refData.SettingName]), -- Validation depends on type
					color = col, tooltip = refData.Tooltip,
				})
				
				-- Step Up/Down
				self.createButton({ -- Up
					label= ("^"):format(tostring(refData.Label or refData.SettingName)), click_function="doInputUp"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0.95, 0.1, zpos-0.06}, rotation={0,0,0}, width=100, height=90, font_size=80,
					color = col, tooltip = refData.Tooltip,
				})
				self.createButton({ -- Down
					label= ("^"):format(tostring(refData.Label or refData.SettingName)), click_function="doInputDown"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0.95, 0.1, zpos+0.06}, rotation={0,180,0}, width=100, height=90, font_size=80,
					color = col, tooltip = refData.Tooltip,
				})
			elseif settingType=="string" then
				-- Label
				self.createButton({
					label= ("%s:"):format(tostring(refData.Label or refData.SettingName)), click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
					position={-1, 0.1, zpos}, rotation={0,0,0}, width=0, height=0, font_size=80,
					font_color = col, tooltip = refData.Tooltip,
				})
				
				-- Input
				self.createInput({
					label=tostring(refData.Label or refData.SettingName), input_function="doInput"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0.35, 0.1, zpos}, rotation={0,0,0}, width=1900, height=200, font_size=100,
					validation = 1, alignment = 3, value = tostring(Settings[refData.SettingName]),
					color = col, tooltip = refData.Tooltip,
				})
			else -- Unrecognised type, probably an action button
				self.createButton({
					label= ("%s"):format( tostring(refData.Label or refData.SettingName) ), click_function="doAction"..i, function_owner=self, scale = {0.5,0.5,0.5},
					position={0, 0.1, zpos}, rotation={0,0,0}, width=2800, height=250, font_size=120,
					color = col, tooltip = refData.Tooltip,
				})
			end
		else
			self.createButton({
				label= ("[b]%s[b] >"):format( tostring(data) ), click_function="doAction"..i, function_owner=self, scale = {0.5,0.5,0.5},
				position={0, 0.1, zpos}, rotation={0,0,0}, width=2800, height=250, font_size=120,
				color = col
			})
		end
	end
	
	
	-- Page Navigaton
	local pageStr = ("Page %i of %i"):format( ListPage, math.ceil(#ListData/10) )
	self.createButton({
		label=pageStr, click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
		position={0, 0.1, 1.5}, rotation={0,0,0}, width=0, height=0, font_size=100,
		font_color = {r=1,g=1,b=1},
	})
	
	self.createButton({
		label="<", click_function="PrevPage", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
		position={-0.5, 0.1, 1.5}, rotation={0,0,0}, width=180, height=180, font_size=120,
		color = ListPage==1 and {0.5,0.5,0.5} or {1,1,1}
	})
	self.createButton({
		label=">", click_function="NextPage", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
		position={0.5, 0.1, 1.5}, rotation={0,0,0}, width=180, height=180, font_size=120,
		color = ListPage>=math.ceil(#ListData/10) and {0.5,0.5,0.5} or {1,1,1}
	})
	
	
	if #DirectoryPath>0 then
		-- Return
		self.createButton({
			label="Back", click_function="clickBack", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
			position={0.2, 0.1, 1.7}, rotation={0,0,0}, width=750, height=200, font_size=120,
		})
		self.createButton({
			label="Main Menu", click_function="clickMainMenu", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
			position={1.0, 0.1, 1.7}, rotation={0,0,0}, width=750, height=200, font_size=120,
		})
	end
end


function NextPage(o,c)
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	local maxPage = math.max( math.ceil(#ListData/10), 1 )
	
	doMenu( math.min(ListPage+1, maxPage) )
end
function PrevPage(o,c)
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	doMenu( math.max(ListPage-1, 1) )
end

function clickMainMenu(o,c)
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	mainMenu()
end
function clickBack(o,c)
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	table.remove(DirectoryPath)
	if #DirectoryPath==0 then
		mainMenu()
		return
	end
	
	local workingDir = TradeItems
	for i=1,#DirectoryPath do
		local newDir = workingDir[DirectoryPath[i]]
		if newDir and not newDir.IsTraderItem then
			workingDir = newDir
		else
			while #DirectoryPath>=i do
				table.remove(DirectoryPath)
			end
			break
		end
	end
	if #DirectoryPath==0 then
		mainMenu()
		return
	end
	
	ListReference = workingDir
	ListPage = 0
	ListTitle = DirectoryPath[#DirectoryPath]
	ListData = {}
	
	doListData()
	
	doMenu(1)
end

-- Actions --
-------------
function doAction( index, c )
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	local trueIndex = index + (ListPage-1)*10
	local data = ListData[trueIndex]
	local ref = data and ListReference[data]
	
	if not ref then
		broadcastToColor( "Something went wrong! (Button reference is missing)", c, {1,0.2,0.2} )
		mainMenu()
		return
	end
	
	if ref.SettingName then
		local settingType = getSettingType( ref )
		if (not settingType) or settingType=="boolean" then
			local old = Settings[ref.SettingName]
			Settings[ref.SettingName] = not old
		end
		if ref.OnSet then
			ref.OnSet( Settings[ref.SettingName], old )
		end
		
		doMenu( ListPage )
		
		return
	end
	
	table.insert(DirectoryPath, data)
	ListReference = ref
	ListPage = 0
	ListTitle = data
	ListData = {}
	
	doListData()
	
	doMenu(1)
end
for i=1,10 do
	_G["doAction"..i] = function(o,c) return doAction(i,c) end
end

function doInput( index, c, value, isSelected )
	if isSelected then return end
	
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		
		doMenu( ListPage )
		
		return
	end
	
	local trueIndex = index + (ListPage-1)*10
	local data = ListData[trueIndex]
	local ref = data and ListReference[data]
	
	if not (ref and ref.SettingName) then
		broadcastToColor( "Something went wrong! (Button reference is missing)", c, {1,0.2,0.2} )
		mainMenu()
		return
	end
	
	local old = Settings[ref.SettingName]
	local settingType = getSettingType( ref )
	if settingType=="int" or settingType=="float" then
		Settings[ref.SettingName] = tonumber(value) or 0
	elseif settingType=="string" then
		Settings[ref.SettingName] = tostring(value)
	end
	
	if ref.OnSet then
		ref.OnSet( Settings[ref.SettingName], old )
	end
	
	return
end
for i=1,10 do
	_G["doInput"..i] = function(o,c, str, sel) return doInput(i,c, str, sel) end
end

function doInputUp( index, c, addValue )
	if not (c and Player[c].admin) then
		broadcastToColor( "You can't do this.", c, {1,0.2,0.2} )
		return
	end
	
	local trueIndex = index + (ListPage-1)*10
	local data = ListData[trueIndex]
	local ref = data and ListReference[data]
	
	if not (ref and ref.SettingName) then
		broadcastToColor( "Something went wrong! (Button reference is missing)", c, {1,0.2,0.2} )
		mainMenu()
		return
	end
	
	local old = Settings[ref.SettingName]
	Settings[ref.SettingName] = (tonumber(old) or 0) + (addValue or  1)
	
	if ref.OnSet then
		ref.OnSet( Settings[ref.SettingName], old )
	end
	
	doMenu( ListPage )
end
for i=1,10 do
	_G["doInputUp"..i] = function(o,c) return doInputUp(i,c) end
end

function doInputDown( index, c )
	return doInputUp( index, c, -1 )
end
for i=1,10 do
	_G["doInputDown"..i] = function(o,c) return doInputDown(i,c) end
end
