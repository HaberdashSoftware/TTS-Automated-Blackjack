--[[                  Kieron's Autosave and Retrieval                       ]]--


-- Setup --
-----------
function onload()
	if findSaveStorage() then
		printToAll("Failed to deploy Save Storage: Bag already exists.", {1,0.75,0.75})
		ForceDestruct = true
		destroyObject(self)
		return
	end
	
    playerZone = {
        ["Black"] = {zone=getObjectFromGUID("275a5d")},
        ["Pink"] = {zone=getObjectFromGUID("44f05e"), prestige=getObjectFromGUID("0b4a58"), tbl=getObjectFromGUID("bb54b1")},
        ["Purple"] = {zone=getObjectFromGUID("63ef4e"), prestige=getObjectFromGUID("17ddfd"), tbl=getObjectFromGUID("b2ab0b")},
        ["Blue"] = {zone=getObjectFromGUID("423ae1"), prestige=getObjectFromGUID("f87e7b"), tbl=getObjectFromGUID("7a414f")},
        ["Teal"] = {zone=getObjectFromGUID("5c2692"), prestige=getObjectFromGUID("3484cc"), tbl=getObjectFromGUID("d21b66")},
        ["Green"] = {zone=getObjectFromGUID("595fa9"), prestige=getObjectFromGUID("a7bb1b"), tbl=getObjectFromGUID("2612ed")},
        ["Yellow"] = {zone=getObjectFromGUID("5b82fd"), prestige=getObjectFromGUID("944b87"), tbl=getObjectFromGUID("a7596f")},
        ["Orange"] = {zone=getObjectFromGUID("38b2d7"), prestige=getObjectFromGUID("844d3d"), tbl=getObjectFromGUID("efae07")},
        ["Red"] = {zone=getObjectFromGUID("8b37f7"), prestige=getObjectFromGUID("d8cd49"), tbl=getObjectFromGUID("b54e19")},
        ["Brown"] = {zone=getObjectFromGUID("1c13af"), prestige=getObjectFromGUID("6c29ce"), tbl=getObjectFromGUID("688678")},
        ["White"] = {zone=getObjectFromGUID("a751f4"), prestige=getObjectFromGUID("88482c"), tbl=getObjectFromGUID("33b903")},
    }
    hadStarter = {}
    saveBag = getObjectFromGUID("4c4c08")
    starterBag = getObjectFromGUID("f3ea0f")
    buttonHandler = getObjectFromGUID("81dac7")
    sitRetrieve = true
    lockout = false
    populateTable()
    createButtons()
	
	ThisScript = self.getLuaScript()
end
function populateTable()
    local saveObjects = self.getObjects()
    for i, object in ipairs(saveObjects) do
		hadStarter[object.name or ""] = true
    end
end

function findSaveStorage()
	for _,obj in pairs(getAllObjects()) do
		if obj.getName()==self.getName() and obj.getTable("hadStarter") and not (obj==nil) then -- Exists, matches, and initialised
			return obj -- Return it
		end
	end
end


-- Process Save --
------------------

function doObjectName(object, color)
    object.setName("Player save: " .. Player[color].steam_name)
    object.setDescription(Player[color].steam_id  .." - ".. Player[color].steam_name)
end

local saveQueue = {}
function DoSaveQueue()
	if #saveQueue==0 then Timer.destroy("DoSaveQueue") return end
	
	local box,col,force = saveQueue[1][1],saveQueue[1][2],saveQueue[1][3]
	
	while saveQueue[1] and saveQueue[1][1]==box do
		force = force or saveQueue[1][3]
		table.remove(saveQueue, 1)
	end
	
	if (not box) or (box==nil) then return end
	
	box.unlock()
	
	local saveObjects = self.getObjects()
	local params = {}
	params.position = self.getPosition()
	
	local id = box.getDescription():match("^(%d+)")
	if not id then
		if col then
			broadcastToColor("Error: Failed to find ID in description.", col or "Black", {1,0.25,0.25})
		else
			print( "Failed to find ID in description. Autosave failed.")
		end
		return
	end
	
	if not force then
		local foundCol
		for _,col in pairs(getSeatedPlayers()) do
			if Player[col].seated and Player[col].steam_id==id then
				foundCol = col
				break
			end
		end
		if foundCol then
			local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={foundCol}} )
			if set and set.zone then
				box.setPosition( set.zone.getPosition() )
				box.setRotation( {0,0,0} )
				
				return
			end
		end
	end
	
	self.putObject(box)
end

local autoSaveData = {}
function DoAutoSave(data, ...)
	local itemData = autoSaveData[data.color] or {}
	
	for i=1,math.min(10,#itemData) do
		local obj = itemData[1]
		
		if obj then
			if not (obj==nil) then -- Do not remove the brackets here. `(not obj==nil)` is not the same as `not (obj==nil)`
				obj.unlock()
				data.save.putObject( obj )
			end
			
			table.remove( itemData, 1 )
		elseif #itemData>1 then
			table.remove( itemData, 1 )
		else
			break
		end
	end
	
	if #itemData<=0 then
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={data.color}} )
		
		if set and set.container.getQuantity()>0 then
			local params = {}
			params.position = set.container.getPosition()
			for i=1,math.min(set.container.getQuantity(), 20) do
				params.position.y = params.position.y + 0.25
				
				local taken = set.container.takeObject(params)
				taken.unlock()
				
				-- table.insert( autoSaveData[data.color], taken )
				data.save.putObject( taken )
			end
			
			Timer.destroy("Autosave"..data.color)
			Timer.create({identifier="Autosave"..data.color, function_name="DoAutoSave", parameters={save=data.save, color=data.color}, delay=0.5, repetitions=2})
		else
			autoSaveData[data.color] = nil
			
			table.insert(saveQueue, {data.save})
			
			Timer.destroy("Autosave"..data.color)
			Timer.destroy("DoSaveQueue")
			Timer.create({identifier="DoSaveQueue", function_name="DoSaveQueue", delay=0.25, repetitions=0})
		end
	end
end

function save(o, color)
    if not lockout then
        lockoutTimer(1.2)
        local foundObjects = playerZone[color].zone.getObjects()
        local saveObjects = self.getObjects()
        local saveFound = false
        local params = {}
        params.position = self.getPosition()
        for i, object in ipairs(foundObjects) do
            if string.find(object.getName(), 'Player save:') then
				table.insert(saveQueue, {object, color, true})
				saveFound = true
            end
        end
		if saveFound then
			Timer.destroy("DoSaveQueue")
			Timer.create({identifier="DoSaveQueue", function_name="DoSaveQueue", delay=0.25, repetitions=0})
		else
			broadcastToColor("Error: No save found.\nPlease position your save inside your colored zone.", color, {1,0.25,0.25})
		end
    else
        broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
    end
end


-- Process Dropped Object --
----------------------------

function onObjectEnterContainer(bag,o)
	if o==self then
		doPlacedInBag(bag)
		return
	end
	if bag~=self then return end
	
	local isSaveFormat = o.getName():match("| %d+ | %d+$")
	if isSaveFormat then return end -- Proper format, we can assume it's fine (Probably added by script)
	
	local saveBox = o.getName():find("Player save:")
	local foundID = o.getDescription():match("^(%d+) %- .*")
	if not foundID then return EjectGrabbedObject(o) end -- Not a saveable object (no id)
	
	local targetPos = self.getPosition()
	targetPos.y = targetPos.y - 10
	targetPos.z = targetPos.z - 5
	
	local params = {position = targetPos, smooth = false}
	
	local matchingSave
	for _,box in ipairs(self.getObjects()) do
		if box.name:find(foundID) then
			matchingSave = box
			break
		end
	end
	
	if matchingSave then
		params.index = matchingSave.index
		local deployedBox = self.takeObject(params)
		if deployedBox then
			local lastFoundObj
			for _,obj in ipairs(self.getObjects()) do -- params.guid always starts from the bottom regardless of params.top
				if obj.guid==o.getGUID() then
					lastFoundObj = obj
				end
			end
			
			if lastFoundObj then
				-- Place object into found save box
				params.index = lastFoundObj.index
				local deployedInserted = self.takeObject(params)
				if deployedInserted then
					deployedBox.putObject(deployedInserted)
					
					-- Wait.frames(function() -- Replace save box
						self.putObject(deployedBox)
					-- end, 1)
					
					destroyObject(deployedInserted) -- This is necessary to stop duplicated. Not entirely sure why.
				end
			else
				self.putObject(deployedBox)
			end
		end
		
		return
	elseif saveBox and not matchingSave then
		-- Get obj
		local lastFoundObj
		for _,obj in ipairs(self.getObjects()) do
			if obj.guid==o.getGUID() then
				lastFoundObj = obj
			end
		end
		if lastFoundObj then
			params.index = lastFoundObj.index
			local deployedObject = self.takeObject(params)
			if deployedObject then
				-- Rename and replace
				deployedObject.setName( ("%s | %i | %s"):format(o.getName(), os.time(), foundID) )
				deployedObject.setDescription("")
				
				self.putObject(deployedObject)
			end
		end
		
		return
	end
	
	EjectGrabbedObject(o)
end
function EjectGrabbedObject(o)
	local lastFoundObj
	for _,obj in ipairs(self.getObjects()) do -- params.guid always starts from the bottom regardless of params.top
		if obj.guid==o.getGUID() then
			lastFoundObj = obj
		end
	end
	
	local params = {position = {0,10,0}, smooth = false}
	if lastFoundObj then
		params.index = lastFoundObj.index
		local deployedObject = self.takeObject(params)
		
		if deployedObject then
			local id,name = o.getDescription():match("^(%d+) %- ([^\n]*)")
			if Player["Black"].seated then
				broadcastToColor( ("Save Storage: Ejected object \"%s\" owned by %s (%s)"):format(deployedObject.getName(), name or "nobody", id or "no id"), "Black", {1,0,0} )
			end
			for k,adminCol in pairs(getSeatedPlayers()) do
				if Player[adminCol].admin then
					broadcastToColor( ("Save Storage: Ejected object \"%s\" owned by %s (%s)"):format(deployedObject.getName(), name or "nobody", id or "no id"), adminCol, {1,0,0} )
				end
			end
		end
	end
end

function doPlacedInBag( bag )
	local lastFoundObj
	for _,obj in ipairs(bag.getObjects()) do -- params.guid always starts from the bottom regardless of params.top
		if obj.guid==self.getGUID() then
			lastFoundObj = obj
		end
	end
	
	local params = {position = {0,10,0}, smooth = false}
	if lastFoundObj then
		params.index = lastFoundObj.index
		local deployedObject = bag.takeObject(params)
		destroyObject(deployedObject)
	end
end

local RespawnPos = {-2.00,1.46,-20.50}
local RespawnRot = {0,0,0}
local RespawnScale = {0.68,0.68,0.68}
function onDestroy()
	if ForceDestruct then return end -- We're destroying ourself
	if self.held_by_color and Player[self.held_by_color].admin then return end -- Held by admin, assume it's legit
	
	local json = self.getJSON()
	
	local params = {
		json = json,
		position = RespawnPos,
		rotation = RespawnRot,
		scale = RespawnScale,
	}
	
	printToAll("Warning: Save Storage has gone missing! Attempting restore...", {1,0,0})
	
	local newObj = spawnObjectJSON(params)
	newObj.setLuaScript( ThisScript )
	newObj.setLock(true)
end

-- Process Load --
------------------

function claim(o, color)
    if not lockout then
        lockoutTimer(1.2)
        local saveObjects = self.getObjects()
        local saveFound = false
        local params = {}
        params.position = playerZone[color].zone.getPosition()
        for i, object in ipairs(saveObjects) do
			if object.name:match("%d+$") == Player[color].steam_id then
                params.index = object.index
                local foundObject = self.takeObject(params)
                doObjectName(foundObject, color)
                return
            end
        end
        broadcastToColor("Error: No save found.\nDo you already have your save?", color, {1,0.25,0.25})
    else
        broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
    end
end

function free(o, color)
    if not lockout then
        lockoutTimer(1.2)
		local hadSave = false
		if hadStarter[Player[color].steam_id or ""] then
			hadSave = true
			if color~="Black" and not Player[color].admin then
				broadcastToColor("Error: You either already have a save or\nyou have already claimed your free starter.", color, {1,0.25,0.25})
				
				return
			end
		end
		
        local params = {}
        params.position = playerZone[color].zone.getPosition()
        local saveContainer = saveBag.takeObject(params)
        saveContainer.shuffle()
        local playerSave = saveContainer.takeObject(params)
        saveContainer.destruct()
        if not hadSave then doObjectName(playerSave, color) end
		
        params.position.y = params.position.y + 2
        local starter = starterBag.takeObject(params)
        local starterObjects = starter.getObjects()
        for i, object in ipairs(starterObjects) do
            params.position.y = params.position.y + 1.5
            local taken = starter.takeObject(params)
			
			if taken then
				local oldDesc = taken.getDescription() or ""
				if #oldDesc>0 then oldDesc = "\n\n"..oldDesc end
				
				taken.setDescription( ("%s - %s%s"):format( Player[color].steam_id, Player[color].steam_name, oldDesc ) )
				playerSave.putObject(taken)
			end
        end
        starter.destruct()
		hadStarter[Player[color].steam_id or ""] = true
    else
        broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
    end
end


-- Player Join/Leave --
-----------------------
function onPlayerChangeColor(color)
	-- Auto Save --
	for _,oldCol in pairs(Player.getAvailableColors()) do
		local zone = playerZone[oldCol]
		if oldCol~="Black" and zone.wasSeated and not (Player[oldCol].seated or autoSaveData[oldCol]) then -- Player currently seated or currently saving this table
			local tblObjects = zone.tbl.getObjects()
			local prestigeObjects = zone.prestige.getObjects()
			local zoneObjects = zone.zone.getObjects()
			
			local plyID = zone.wasSeatedID
			local foundSave = nil
			for _,objList in pairs({tblObjects,zoneObjects,prestigeObjects}) do
				for _,v in pairs(objList) do
					if v.interactable and not v.getLock() and v.getName():find("Player save", 1, false) then
						local id = v.getDescription():match("^(%d+) %- .*")
						if (not id) or (id==plyID) then
							foundSave = v
							break
						end
					end
				end
				if foundSave then break end
			end
			
			if foundSave then
				foundSave.lock()
				foundSave.setRotation( {0,0,0} )
				
				local objectsTbl = {}
				
				-- Table stuff
				for _,objList in pairs({tblObjects,zoneObjects,prestigeObjects}) do
					for _,v in pairs(objList) do
						if v~=foundSave and v.interactable and v.held_by_color~=oldCol and not v.getLock() then
							local id = v.getDescription():match("^(%d+) %- .*")
							if (not id) or (id==plyID) then
								table.insert(objectsTbl, v)
								v.lock()
							end
						end
					end
				end
				
				-- Delayed unfreeze and save
				print( tostring(oldCol)..": Auto saving" )
				autoSaveData[oldCol] = objectsTbl
				Timer.create({identifier="Autosave"..oldCol, function_name="DoAutoSave", parameters={save=foundSave, color=oldCol}, delay=0.5, repetitions=#objectsTbl+1})
			end
		end
		
		zone.wasSeated = (color==oldCol or Player[oldCol].seated)
		zone.wasSeatedID = Player[oldCol].seated and  Player[oldCol].steam_id or nil
	end
	
	-- Auto load --
    if sitRetrieve and (color ~= "Black" and color ~= "Grey") then
        local saveObjects = self.getObjects()
        local params = {}
        params.position = playerZone[color].zone.getPosition()
        for i, object in ipairs(saveObjects) do
            if object.name:match("%d+$") == Player[color].steam_id then
                params.index = object.index
                local foundObject = self.takeObject(params)
                doObjectName(foundObject, color)
                broadcastToColor("Save found: Welcome back ".. Player[color].steam_name .."!", color, {0.25,1,0.25})
				
				hadStarter[Player[color].steam_id or ""] = true
                return
            end
        end
		
		-- Auto New --
		if not hadStarter[Player[color].steam_id or ""] then
			local params = {}
			params.position = playerZone[color].zone.getPosition()
			local saveContainer = saveBag.takeObject(params)
			saveContainer.shuffle()
			local playerSave = saveContainer.takeObject(params)
			saveContainer.destruct()
			doObjectName(playerSave, color)
			params.position.y = params.position.y + 2
			local starter = starterBag.takeObject(params)
			local starterObjects = starter.getObjects()
			for i, object in ipairs(starterObjects) do
				params.position.y = params.position.y + 1.5
				local taken = starter.takeObject(params)
				
				if taken then
					local oldDesc = taken.getDescription() or ""
					if #oldDesc>0 then oldDesc = "\n\n"..oldDesc end
					
					taken.setDescription( ("%s - %s%s"):format( Player[color].steam_id, Player[color].steam_name, oldDesc ) )
					playerSave.putObject(taken)
				end
			end
			starter.destruct()
			
			hadStarter[Player[color].steam_id or ""] = true
		else
			broadcastToColor("Auto-load: Failed to load save.\nDo you already have your save?", color, {1,0.25,0.25})
		end
	end
end


-- Buttons --
-------------

function lockoutTimer(time)
    lockout = true
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='concludeLockout', delay=time})
end
function concludeLockout()
    lockout = false
end


function purge(time, col) -- Based on unix time, so time argument is seconds
	if not (col == "Black" or Player[col].host) then
		broadcastToColor("You cannot do this.", col, {1,0,0})
		return
	end
	
	local purgeTime = math.floor(os.time() - time)
	
	lockoutTimer(1.2)
	local saveObjects = self.getObjects()
	local params = {}
	params.position = self.getPosition()
	params.position.z = params.position.z + 20
	
	local count = 0
	for i, object in ipairs(saveObjects) do
		local find = object.name:match("| (%d+) | %d+$")
		
		if find and ((tonumber(find) or 0) <= purgeTime) then
			params.guid = object.guid
			local foundObject = self.takeObject(params)
			foundObject.destruct()
			
			count = count + 1
		end
	end
	
	if not (Player[col].host) then
		print( string.format("%s old saves purged by %s (%s).", count, col, Player[col].steam_name) )
	end
	broadcastToColor( string.format("Purged %s old saves.", count), col, {0.9,0.2,0} )
end
-- 86400 seconds per day
function purgeWeek(_, col) return purge(604800, col) end -- 604 800 seconds per week
function purgeMonth(_, col) return purge(2592000, col) end -- 2 592 000 seconds per month
function purgeYear(_, col) return purge(31536000, col) end -- 31 536 000 seconds per year

function createButtons()
	buttonHandler.clearButtons()
	
    buttonHandler.createButton({
        click_function='save', label='Save', function_owner=self,
        position={-0.92,0.19,-0.19}, rotation={0,0,0}, width=450, height=300, font_size=150
    })
    buttonHandler.createButton({
        click_function='claim', label='Claim', function_owner=self,
        position={0,0.19,-0.19}, rotation={0,0,0}, width=450, height=300, font_size=150
    })
    buttonHandler.createButton({
        click_function='free', label='Free', function_owner=self,
        position={0.92,0.19,-0.19}, rotation={0,0,0}, width=450, height=300, font_size=150
    })
	
    self.createButton({
        click_function='purgeWeek', label='Purge saves (Week)', function_owner=self,
        position={0,0.3,1.5}, rotation={0,0,0}, width=1500, height=300, font_size=150
    })
    self.createButton({
        click_function='purgeMonth', label='Purge saves (Month)', function_owner=self,
        position={0,0.3,2.1}, rotation={0,0,0}, width=1500, height=300, font_size=150
    })
    self.createButton({
        click_function='purgeYear', label='Purge saves (Year)', function_owner=self,
        position={0,0.3,2.7}, rotation={0,0,0}, width=1500, height=300, font_size=150
    })
end
