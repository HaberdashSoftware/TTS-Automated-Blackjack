------------------------
-- Collectable Trader --
------------------------
--- by my_hat_stinks ---
------------------------

-- If you're looking in this file, you probably want to know
-- all the possible formats for collectable item descriptions.
--
--
-- Details
-- Collectable <append> - This is REQURIED on the first line of every collectable.
--                        `Collectible` is also acceptable.
--                        If you use the <append> value, it will be added to the end
--                        of the collectable's name in the trade menu. This allows you
--                        two have two separate listings for one item.
--
-- Cost <quantity> <name> - The cost for the item. If <quantity> is excluded, it will default
--                       to one of the listed item. <name> must match the required item
--                       name exactly, including formatting.
--                       Multiple Cost lines are allowed, all items will be required.
--                       If <name> matches a set, all items in that set are added to cost.
--
-- CostType <type> - Cost type, defaults to "all" if excluded. Only one CostType can be listed.
--                   All - All listed Cost items (including sets) are required to purchase
--                         this item.
--                   Any - Any listed Cost items (matching <quantity>) can be used to purchase
--                         this item.
--                         If a set is listed in Cost, <quantity> is the number of items from the
--                         set required to purchase this item.
--
-- Requires <name> - Items that are required, but NOT consumed, when purchasing this listing.
--                   Completely optional.  <name> must match the required item name exactly,
--                   including formatting.
--                   `Require` is also acceptable.
--
-- Limit <quantity> - The user can't purchase another of this item if they already have <quantity>.
--                    If the item is part of a set, the limit counts for the entire set.
--                    
--
-- SpawnAs <name> - Optional. Renames this item when it is spawned. Can include additional variables
--                  for dynamic names, case sensitive:
--                   {name} - Changes to the Steam name of the user.
--                   {id} - Changes to the Steam ID of the user.
--                   {color} - Changes to the color of the user at time of purchase.
--                  os.date() formatting is also available, eg "%Y-%b-%d" to mark the purchase date.
--
-- Category <Directory> - The menu this item should appear under. `>` indicates a sub-menu.
--                        Items without a Category will be listed on the main menu.
--                        Only one Category can be listed per item. Use Collectable <append>
--                        for additional listings.
--
-- Set <set name> - Optional. Marks this item as part of a set. Items do not need to be purchasable
--                  to be part of a set.
--
--
-- Complete Example:
--
-- Collectable
-- CostType: All
-- Cost: 20 Collectable token
-- Cost: Reward token
-- Requires: [DEB444]Prestige 8[-]
-- Require: Bankruptcy token
-- Category: Main Directory > Sub Directory > Bottom Directory
--


TradeItems = {}

DirectoryPath = {}

ListData = {}
ListReference = {}
ListPage = 0
ListTitle = ""

AdminMode = false

SpawnPos = { 1.168, 3.01, 0.02 }

COST_ALL = 0
COST_ANY = 1

function onLoad()
	refreshAllItems()
	
	mainMenu()
end
function doNull() end


-- Buy Item --
--------------

function spawnObject( item, c, spawnAs )
	local ourColor = c and self.getName():lower():find(c:lower())
	
	local params = {}
	params.position = self.positionToWorld(SpawnPos)
	
	local clone
	if item.tag=="Infinite" then
		clone = item.takeObject(params)
	else
		clone = item.clone(params)
	end
	clone.interactable = true
	clone.setLock(false)
	clone.setPosition(params.position)
	clone.setDescription( ourColor and ("%s - %s"):format( Player[c].steam_id, Player[c].steam_name) or "" )
	
	Wait.frames(function()
		if (not clone) or clone==nil then return end
		
		if clone.tag=="Bag" then
			clone.reset()
		end
		
		if spawnAs and ourColor and Player[c].seated then
			local newStr = os.date(spawnAs, os.time()):gsub("{name}", Player[c].steam_name):gsub("{id}", Player[c].steam_id):gsub("{color}", c)
			
			clone.setName( newStr )
		end
	end, 0)
end
function buyItem( data, c )
	if not data.item then
		broadcastToColor( "Something went wrong! (Item no longer exists)", c, {1,0.2,0.2} )
		return
	end
	
	local ourColor = c and self.getName():lower():find(c:lower())
	
	if ourColor then
		if (not AdminMode) and Global.getVar("findObjectSetFromColor") then -- TODO: Support for non-blackjack tables?
			local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={c}} )
			
			if not set then
				broadcastToColor( "Something went wrong! (Your zones do not exist)", c, {1,0.2,0.2} )
				return
			end
			
			local zoneObjects = set.zone.getObjects()
			local tableObjects = set.tbl.getObjects()
			local prestigeObjects = set.prestige.getObjects()
			
			if data.req then
				local req = {}
				for i=1,#data.req do
					req[data.req[i]] = true
				end
				for _,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
					for _, obj in ipairs(zone) do
						req[obj.getName():match("^%s*(.-)%s*$") or obj.getName() ] = nil
					end
				end
				
				for missing in pairs(req) do
					broadcastToColor( ("You need a %s on your table to buy this item."):format(tostring(missing)), c, {1,0.2,0.2} )
					return
				end
			end
			
			if data.cost then
				if data.costType==COST_ANY then
					if not processCostAny(c, data, set) then return end
				else
					if not processCostAll(c, data, set) then return end
				end
			end
		end
	elseif not AdminMode then
		broadcastToColor( "You can't spawn items from other people's Traders. Toggle Admin Mode first.", c, {1,0.2,0.2} )
		return
	end
	
	spawnObject( data.item, c, data.spawnAs )
end

function processCostAll( c, data, set )
	local costData = data.cost
	
	local missingCost = TranslateSetsToItems( CopyTable(costData) )
	local foundStacks = {}
	
	local sort = function(a,b)
		return self.positionToLocal(a.getPosition()).z > self.positionToLocal(b.getPosition()).z
	end
	local zoneObjects = set.zone.getObjects()  table.sort(zoneObjects, sort)
	local tableObjects = set.tbl.getObjects()  table.sort(tableObjects, sort)
	local prestigeObjects = set.prestige.getObjects()  table.sort(prestigeObjects, sort)
	
	for _,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
		-- for j, item in ipairs(zone) do
		for i=1,#zone do
			local item = zone[i]
			local name = item.getName():match("^%s*(.-)%s*$") or item.getName()
			if missingCost[name] and missingCost[name]>0 and item.interactable and not (item.getLock()) then
				local count = item.getQuantity()
				if count==-1 then count = 1 end
				
				if item.tag=="Bag" then
					count = 1
				end
				
				if count>missingCost[name] then
					table.insert(foundStacks, {item, missingCost[name]})
					
					missingCost[name] = nil
				elseif count==missingCost[name] then
					table.insert(foundStacks, {item})
					
					missingCost[name] = nil
				else
					table.insert(foundStacks, {item})
					
					missingCost[name] = (missingCost[name] or 0) - count
				end
			end
		end
	end
	
	for missing,cost in pairs(missingCost) do -- Should only run if there's values left
		broadcastToColor( ("You need %i more %s on your table to buy this item."):format(tonumber(cost) or 0, tostring(missing)), c, {1,0.2,0.2} )
		return false
	end
	
	if exeedsLimits( data, {zoneObjects, tableObjects, prestigeObjects}, foundStacks ) then
		broadcastToColor( "You have already reached your limit for this item.", c, {1,0.2,0.2} )
		return false
	end
	
	local pos = self.getPosition()
	pos.y = pos.y + 5
	
	for i=1,#foundStacks do
		local tbl = foundStacks[i]
		
		if tbl[2] then
			for i=1,tbl[2] do
				local taken = tbl[1].takeObject( {position=pos, rotation={0,0,0}} )
				destroyObject(taken)
			end
		else
			destroyObject(tbl[1])
		end
	end
	
	return true
end
function processCostAny( c, data, set )
	local tblCost = data.cost
	
	local missingFromSets = {}
	local foundInSets = {}
	
	for i=1,#tblCost do
		local setName = tblCost[i][1]
		local setCount = tblCost[i][2] or 1
		
		if TradeSets[setName] then
			missingFromSets[i] = {
				Required = setCount,
				Objects = {}
			}
			
			local tbl = missingFromSets[i].Objects
			for objName,objCount in pairs(TradeSets[setName]) do
				tbl[objName] = true
			end
		else
			missingFromSets[i] = {
				Required = setCount,
				Objects = {
					[setName] = true,
				}
			}
		end
	end
	
	local foundStacks
	
	local sort = function(a,b)
		return self.positionToLocal(a.getPosition()).z > self.positionToLocal(b.getPosition()).z
	end
	
	local zoneObjects = set.zone.getObjects()  table.sort(zoneObjects, sort)
	local tableObjects = set.tbl.getObjects()  table.sort(tableObjects, sort)
	local prestigeObjects = set.prestige.getObjects()  table.sort(prestigeObjects, sort)
	local done = false
	
	for _,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
		-- for j, item in ipairs(zone) do
		for i=1,#zone do
			local item = zone[i]
			local name = item.getName():match("^%s*(.-)%s*$") or item.getName()
			
			for i=1,#missingFromSets do
				local missingCost = missingFromSets[i]
				foundInSets[i] = foundInSets[i] or {}
				
				if missingCost.Objects[name] and missingCost.Required>0 and item.interactable and not (item.getLock()) then
					local count = item.getQuantity()
					if count==-1 then count = 1 end
					
					if count>missingCost.Required then
						table.insert(foundInSets[i], {item, missingCost.Required})
						
						missingCost.Required = nil
					elseif count==missingCost.Required then
						table.insert(foundInSets[i], {item})
						
						missingCost.Required = nil
					else
						table.insert(foundInSets[i], {item})
						
						missingCost.Required = (missingCost.Required or 0) - count
					end
					
					if (not missingCost.Required) or missingCost.Required<=0 then
						done = true
						
						foundStacks = foundInSets[i] or {}
						
						break
					end
				end
			end
			if done then break end
		end
		if done then break end
	end
	
	if not foundStacks then
		broadcastToColor( "You don't have the necessary items on your table to buy this item.", c, {1,0.2,0.2} )
		return false
	end
	if exeedsLimits( data, {zoneObjects, tableObjects, prestigeObjects}, foundStacks ) then
		broadcastToColor( "You have already reached your limit for this item.", c, {1,0.2,0.2} )
		return false
	end
	
	local pos = self.getPosition()
	pos.y = pos.y + 5
	
	for i=1,#foundStacks do
		local tbl = foundStacks[i]
		
		if tbl[2] then
			for i=1,tbl[2] do
				local taken = tbl[1].takeObject( {position=pos, rotation={0,0,0}} )
				destroyObject(taken)
			end
		else
			destroyObject(tbl[1])
		end
	end
	
	return true
end

function exeedsLimits( data, zones, skipObjects )
	if not data.limit then return false end
	
	local restrictedObjects = {}
	
	if data.item.tag=="Infinite" then
		local clone = data.item.takeObject(params)
		if clone then
			restrictedObjects[clone.getName() or "[ITEM]"] = true
		end
		destroyObject(clone)
	else
		restrictedObjects[data.item.getName() or "[ITEM]"] = true
	end
	
	local limitLeft = data.limit
	if data.sets then
		for i=1,#data.sets do
			for name in pairs(TradeSets[data.sets[i]] or {}) do
				restrictedObjects[name] = true
			end
		end
	end
	
	for _,zone in pairs(zones) do
		for j, item in ipairs(zone) do
			local name = item.getName()
			
			if restrictedObjects[name] then
				local count = item.getQuantity()
				if count==-1 then count = 1 end
				
				if item.tag=="Bag" then
					count = 1
				end
				
				for i=1,#skipObjects do
					local tbl = skipObjects[i]
					
					if tbl[1]==item then
						if tbl[2] then
							count = count - tbl[2]
						else
							count = count - 1
						end
					end
				end
				
				if count>0 then
					limitLeft = limitLeft - count
					
					if limitLeft<=0 then return true end
				end
			end
		end
	end
	if limitLeft<= 0 then return true end
	
	return false
end

-- Register Items --
--------------------

function clickAdminMode(o,c)
	if not Player[c].admin then
		printToColor( "You can't do this.", c, {1,0,0} )
		return
	end
	
	AdminMode = not AdminMode
	doMenu( ListPage )
end
function clickRefresh(o,c)
	if not Player[c].admin then
		printToColor( "You can't do this.", c, {1,0,0} )
		return
	end
	
	refreshAllItems()
end
function refreshAllItems()
	TradeItems = {}
	TradeSets = {}
	
	DirectoryPath = {}
	
	ListData = {}
	ListReference = {}
	ListPage = 0
	
	for _,obj in pairs(getAllObjects()) do
		if obj.getDescription():match("^[Cc]ollect[ai]ble") then
			registerItem( obj, obj.getDescription():match("^[Cc]ollect[ai]ble *([^\n]*)") )
		end
	end
	
	mainMenu()
end

local TextToCostType = {
	any = COST_ANY,
	all = COST_ALL,
}
function registerItem( obj, appendName )
	local desc = obj.getDescription()
	local name = obj.getName() or "[ITEM]"
	
	if obj.tag=="Infinite" then
		local clone = obj.takeObject(params)
		if clone then
			name = clone.getName() or name
		end
		destroyObject(clone)
	end
	
	if appendName then
		name = name .. " " .. tostring(appendName)
	end
	
	
	local CostType = COST_ALL
	local hasCost = false
	for foundType in desc:gmatch("[Cc]ost[Tt]ype:? *([^\n]+)") do
		foundType = foundType:match("^%s*(.-)%s*$") or foundType
		
		CostType = TextToCostType[ foundType:lower() ] or CostType
	end
	
	local cost = {}
	local hasCost = false
	for num,item in desc:gmatch("[Cc]ost:? +(%d*)x? *([^\n]+)") do
		num = tonumber(num) or 1
		if item then
			hasCost = true
			item = item:match("^%s*(.-)%s*$") or item
			
			if CostType==COST_ALL then
				cost[item] = (cost[item] or 0) + num
			elseif CostType==COST_ANY then
				table.insert(cost, {item,num})
			end
		end
	end
	if not hasCost then -- No cost, can't buy
		registerSet( obj )
		return
	end
	
	local req = {}
	for foundReq in desc:gmatch("[Rr]equires?:? *([^\n]+)") do
		foundReq = foundReq:match("^%s*(.-)%s*$") or foundReq
		table.insert(req, foundReq)
	end
	if #req==0 then
		req = nil
	end
	
	local spawnAs = ""
	for foundName in desc:gmatch("[Ss]pawn[Aa]s?:? *([^\n]+)") do
		spawnAs = foundName:match("^%s*(.-)%s*$") or foundName
		break
	end
	if #spawnAs==0 then
		spawnAs = nil
	end
	
	local limit = nil
	for foundLimit in desc:gmatch("[Ll]imit:? *(%d+)") do
		limit = tonumber(foundLimit) or 0
		break
	end
	
	local workingDir = TradeItems
	
	local cat = desc:match("[Cc]ategory:? *([^\n]+)")
	if cat then
		local exploded = {}
		
		local str = cat
		local s,e,before,after = str:find("^([^>]*)>(.*)$")
		while s and e do
			before = before:match( "^%s*(.+)$" ) or before
			
			-- before = before:match( "^(.-)%s*$" ) or before -- "Too complex", apparently.
			local posTrailingSpaces = before:find("%s*$")
			if posTrailingSpaces then
				before = before:sub(1,posTrailingSpaces-1)
			end
			if #before>0 then table.insert(exploded, before) end
			
			str = after
			s,e,before,after = str:find("^([^>]*)>(.*)$")
		end
		
		str = str:match( "^%s*(.+)$" ) or str
		local posTrailingSpaces = str:find("%s*$")
		if posTrailingSpaces then
			str = str:sub(1,posTrailingSpaces-1)
		end
		if #str>0 then table.insert(exploded, str) end
		
		for i=1,#exploded do
			if not exploded[i] then break end
			
			if (not workingDir[exploded[i]]) or (workingDir[exploded[i]].IsTraderItem) then -- Empty or an item, replace with category
				workingDir[exploded[i]] = {}
			end
			workingDir = workingDir[exploded[i]]
		end
	end
	
	workingDir[ name ] = {
		IsTraderItem = true,
		item = obj,
		
		costType = CostType,
		cost = cost,
		
		req = req,
		
		spawnAs = spawnAs,
		limit = limit,
		sets = registerSet( obj ),
	}
end
function registerSet( obj )
	local desc = obj.getDescription()
	local name = obj.getName() or "[ITEM]"
	
	if obj.tag=="Infinite" then
		local clone = obj.takeObject(params)
		if clone then
			name = clone.getName() or name
		end
		destroyObject(clone)
	end
	
	local sets = {}
	local hasSets = false
	for num,setName in desc:gmatch("Set:? *(%d*)x? *([^\n]+)") do
		num = tonumber(num) or 1
		if setName then
			sets[setName] = (sets[setName] or 0) + num
			hasSets = true
		end
	end
	if not hasSets then return end -- Not part of a set
	
	local inSets = {}
	for setName,num in pairs(sets) do
		TradeSets[setName] = TradeSets[setName] or {}
		
		TradeSets[setName][name] = num
		table.insert(inSets, setName)
	end
	
	return inSets
end


-- Cost To String --
--------------------

function getCostString( costTable, costType )
	if not costTable then return "" end
	
	local str = ""
	local orderedCost = {}
	if costType==COST_ANY then
		orderedCost = CopyTable(costTable)
	else
		for item,num in pairs(costTable) do
			table.insert( orderedCost, {item,num} )
		end
	end
	table.sort( orderedCost, function(a,b)
		if a[2]==b[2] then
			return a[1]<b[1]
		end
		return a[2]<b[2]
	end)
	
	for i=1,#orderedCost do
		str = str .. ("%s%i %s[b]%s[/b]"):format(
			(i==1 and "") or (i==#orderedCost and (costType==COST_ANY and ", or " or ", and ")) or ", ",
			orderedCost[i][2],
			costType==COST_ANY and TradeSets[ orderedCost[i][1] ] and "from " or "",
			orderedCost[i][1]
		)
	end
	
	return str
end


-- Menu --
----------

function doListData()
	for k in pairs(ListReference) do
		table.insert(ListData, k)
	end
	table.sort(ListData, function(a,b)
		if ListReference[a].IsTraderItem and not ListReference[b].IsTraderItem then return false end
		if ListReference[b].IsTraderItem and not ListReference[a].IsTraderItem then return true end
		
		return a<b
	end)
end

function clickMainMenu(o,c)
	local ourColor = c and self.getName():lower():find(c:lower())
	if not (c and (Player[c].admin or ourColor)) then
		broadcastToColor( "This does not belong to you.", c, {1,0.2,0.2} )
		return
	end
	
	mainMenu()
end
function mainMenu()
	ListTitle = "Collectable Trader"
	ListReference = TradeItems
	ListData = {}
	
	DirectoryPath = {}
	
	doListData()
	
	doMenu( 1 )
end

function doMenu(page)
	self.clearButtons()
	self.clearInputs()
	
	ListPage = page or 1
	
	-- Title
	self.createButton({
		label=ListTitle, click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
		position={1.2, 0.25, -1.23}, rotation={0,0,0}, width=0, height=0, font_size=170,
		font_color = {r=1,g=1,b=1},
	})
	
	Targets = {}
	
	local displayFrom = (ListPage-1)*10
	-- List Page
	for i=1,10 do
		local data = ListData[displayFrom + i]
		
		if not (data and ListReference[data]) then break end
		
		local zpos = -1.17 + (i * 0.21)
		local col = AdminMode and {r=1,g=0.1,b=0.1} or {r=1,b=1,g=1}
		
		-- Button
		if ListReference[data].IsTraderItem then
			self.createButton({
				label= ("[b][u]%s[/u][/b]\n%s"):format( data, getCostString(ListReference[data].cost, ListReference[data].costType) ), click_function="doAction"..i, function_owner=self, scale = {0.5,0.5,0.5},
				position={1.2, 0.25, zpos}, rotation={0,0,0}, width=1800, height=220, font_size=80,
				color = col
			})
		else
			self.createButton({
				label= ("[b]%s[b] >"):format( data ), click_function="doAction"..i, function_owner=self, scale = {0.5,0.5,0.5},
				position={1.2, 0.25, zpos}, rotation={0,0,0}, width=1800, height=220, font_size=80,
				color = col
			})
		end
	end
	
	
	-- Page Navigaton
	local pageStr = ("Page %i of %i"):format( ListPage, math.ceil(#ListData/10) )
	self.createButton({
		label=pageStr, click_function="doNull", function_owner=self, scale = {0.5,0.5,0.5},
		position={1.2, 0.25, 1.12}, rotation={0,0,0}, width=0, height=0, font_size=100,
		font_color = {r=1,g=1,b=1},
	})
	
	self.createButton({
		label="<", click_function="PrevPage", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
		position={0.7, 0.25, 1.12}, rotation={0,0,0}, width=100, height=100, font_size=80,
		color = ListPage==1 and {0.5,0.5,0.5} or {1,1,1}
	})
	self.createButton({
		label=">", click_function="NextPage", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
		position={1.7, 0.25, 1.12}, rotation={0,0,0}, width=100, height=100, font_size=80,
		color = ListPage>=math.ceil(#ListData/10) and {0.5,0.5,0.5} or {1,1,1}
	})
	
	
	if #DirectoryPath>0 then
		-- Return
		self.createButton({
			label="Back", click_function="clickBack", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
			position={1.3, 0.25, 1.32}, rotation={0,0,0}, width=450, height=150, font_size=80,
		})
		self.createButton({
			label="Main Menu", click_function="clickMainMenu", function_owner=self, scale = {1,1,1}, scale = {0.5,0.5,0.5},
			position={1.8, 0.25, 1.32}, rotation={0,0,0}, width=450, height=150, font_size=80,
		})
	end
	
	-- Admin
	self.createButton({
		label="Admin Mode", click_function="clickAdminMode", function_owner=self, scale = {1,1,1}, scale = {0.3,0.3,0.3},
		position={0.2, 0.25, -1.33}, rotation={0,0,0}, width=450, height=50, font_size=70,
		color = AdminMode and {r=1,g=0,b=0} or {r=0.25,g=0.25,b=0.25},
	})
	self.createButton({
		label="Reload", click_function="clickRefresh", function_owner=self, scale = {1,1,1}, scale = {0.3,0.3,0.3},
		position={0.2, 0.25, -1.23}, rotation={0,0,0}, width=450, height=50, font_size=70,
		color = {r=0.25,g=0.25,b=0.25},
	})
end


-- Actions --
-------------
function doAction( index, c )
	local ourColor = c and self.getName():lower():find(c:lower())
	if not (c and (Player[c].admin or ourColor)) then
		broadcastToColor( "This does not belong to you.", c, {1,0.2,0.2} )
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
	
	if ref.IsTraderItem then
		buyItem( ref, c )
		
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

function clickBack(o,c)
	local ourColor = c and self.getName():lower():find(c:lower())
	if not (c and (Player[c].admin or ourColor)) then
		broadcastToColor( "This does not belong to you.", c, {1,0.2,0.2} )
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

function NextPage(o,c)
	local ourColor = c and self.getName():lower():find(c:lower())
	if not (c and (Player[c].admin or ourColor)) then
		broadcastToColor( "This does not belong to you.", c, {1,0.2,0.2} )
		return
	end
	
	local maxPage = math.max( math.ceil(#ListData/10), 1 )
	
	doMenu( math.min(ListPage+1, maxPage) )
end
function PrevPage(o,c)
	local ourColor = c and self.getName():lower():find(c:lower())
	if not (c and (Player[c].admin or ourColor)) then
		broadcastToColor( "This does not belong to you.", c, {1,0.2,0.2} )
		return
	end
	
	doMenu( math.max(ListPage-1, 1) )
end

-- Util --
----------

function CopyTable(from)
	local to = {}
	for k,v in pairs(from) do
		to[k]=v
	end
	return to
end
function TranslateSetsToItems( tbl )
	for setName,setCount in pairs(tbl) do
		if TradeSets[setName] then
			for objName,objCount in pairs(TradeSets[setName]) do
				tbl[objName] = (tbl[objName] or 0) + ((objCount or 1) * (setCount or 1))
			end
			tbl[setName] = nil
		end
	end
	
	return tbl
end

function PrintTable( tbl, indent, skipTables )
	indent = indent or 0
	skipTables = skipTables or {[tbl]=true}
	
	for k,v in pairs(tbl) do
		if type(v)=="table" and not skipTables[v] then
			skipTables[v]=true
			print( (" "):rep(indent+1), "\"",k,"\" = {" )
			PrintTable(v, indent+1, skipTables)
			print( (" "):rep(indent+1), "}" )
		else
			print( (" "):rep(indent+1), "\"", k, "\" = ", v )
		end
	end
end
