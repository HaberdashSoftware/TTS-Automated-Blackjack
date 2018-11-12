--[[                  Kieron's Autosave and Retrieval                       ]]--

function onload()
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
end

function populateTable()
    local saveObjects = self.getObjects()
    for i, object in ipairs(saveObjects) do
        -- table.insert(hadStarter, object.name)
		hadStarter[object.name or ""] = true
    end
end

function updateSave(object, color)
    object.setName("Player save: " .. Player[color].steam_name)
    object.setDescription(Player[color].steam_id  .." - ".. Player[color].steam_name)
end

local saveQueue = {}
function DoSaveQueue()
	if #saveQueue==0 then Timer.destroy("DoSaveQueue") return end
	
	local box,col = saveQueue[1][1],saveQueue[1][2]
	table.remove(saveQueue, 1)
	
	if (not box) or box==nil then return end
	
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
	for j, found in ipairs(saveObjects) do
		if found.name:find(id) then
			if col then
				broadcastToColor("Error: Duplicate save found.\nRetrieve your save before trying again.", col or "Black", {1,0.25,0.25})
			else
				print( "Duplicate save found. Autosave failed.")
			end
			return
		end
	end
	
	local clonedObject = box.clone(params)
	box.destruct()
	clonedObject.setName( ("%s | %i | %s"):format(box.getName(), os.time(), id) )
	clonedObject.setDescription('')
	
	self.putObject(clonedObject)
end

local autoSaveData = {}
function DoAutoSave(data, ...)
	local obj = autoSaveData[data.color][1]
	
	if obj then
		if not (obj==nil) then -- DO NOT remove the brackets here. (obj==nil) == (not obj==nil), (obj==nil) != (not (obj==nil))
			obj.unlock()
			-- obj.setPosition( data.targetPos )
			data.save.putObject( obj )
		end
		
		table.remove( autoSaveData[data.color], 1 )
	elseif #autoSaveData>1 then
		table.remove( autoSaveData[data.color], 1 )
	else
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={data.color}} )
		
		if set and set.container.getQuantity()>0 then
			local params = {}
			params.position = set.container.getPosition()
			params.position.y = params.position.y + 0.25
			
			local taken = set.container.takeObject(params)
			taken.lock()
			
			table.insert( autoSaveData[data.color], taken )
			
			Timer.destroy("Autosave"..data.color)
			Timer.create({identifier="Autosave"..data.color, function_name="DoAutoSave", parameters={save=data.save, color=data.color}, delay=0.2, repetitions=2})
		else
			autoSaveData[data.color] = nil
			
			table.insert(saveQueue, {data.save})
			
			Timer.destroy("DoSaveQueue")
			Timer.create({identifier="DoSaveQueue", function_name="DoSaveQueue", delay=0.25, repetitions=0})
		end
	end
end
function onPlayerChangeColor(color)
	-- Auto Save --
	for _,oldCol in pairs({"Pink","Purple","Blue","Teal","Green","Yellow","Orange","Red","Brown","White"}) do -- Wouldn't it be nice if this function incldued the previous colour?
		if playerZone[oldCol].wasSeated and not (Player[oldCol].seated or autoSaveData[oldCol]) then -- Player currently seated or currently saving this table
			local tblObjects = playerZone[oldCol].tbl.getObjects()
			local prestigeObjects = playerZone[oldCol].prestige.getObjects()
			local zoneObjects = playerZone[oldCol].zone.getObjects()
			
			local foundSave = nil
			for _,v in pairs(tblObjects) do
				if v.interactable and not v.getLock() and v.getName():find("Player save", 1, false) then
					foundSave = v
					break
				end
			end
			if not foundSave then
				for _,v in pairs(zoneObjects) do
					if v.interactable and not v.getLock() and v.getName():find("Player save", 1, false) then
						foundSave = v
						break
					end
				end
			end
			if not foundSave then
				for _,v in pairs(prestigeObjects) do
					if v.interactable and not v.getLock() and v.getName():find("Player save", 1, false) then
						foundSave = v
						break
					end
				end
			end
			
			if foundSave then
				foundSave.lock()
				foundSave.setRotation( {0,0,0} )
				
				-- local delay = 1
				local objectsTbl = {}
				
				-- local targetPos = foundSave.getPosition()
				-- targetPos.y = targetPos.y + 1
				
				-- Table stuff
				for _,v in pairs(tblObjects) do
					if v~=foundSave and v.interactable and not v.getLock() then
						table.insert(objectsTbl, v)
						v.lock()
					end
				end
				-- Prestige stuff
				for _,v in pairs(prestigeObjects) do
					if v~=foundSave and v.interactable and not v.getLock() then
						table.insert(objectsTbl, v)
						v.lock()
					end
				end
				
				-- Play zone stuff, if not in round
				local inRound = false
				for _,v in pairs(zoneObjects) do
					if v.tag=="Card" or (v.tag=="Figurine" and v.getLock()) then
						inRound = true
						break
					end
				end
				if not inRound then
					for _,v in pairs(zoneObjects) do
						if v~=foundSave and v.interactable and not v.getLock() then
							table.insert(objectsTbl, v)
							v.lock()
						end
					end
				end
				
				-- Delayed unfreeze and save
				print( tostring(oldCol)..": Auto saving" )
				autoSaveData[oldCol] = objectsTbl
				Timer.create({identifier="Autosave"..oldCol, function_name="DoAutoSave", parameters={save=foundSave, color=oldCol}, delay=0.2, repetitions=#objectsTbl+1})
			end
		end
		
		playerZone[oldCol].wasSeated = (color==oldCol or Player[oldCol].seated)
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
                updateSave(foundObject, color)
                broadcastToColor("Save found: Welcome back ".. Player[color].steam_name .."!", color, {0.25,1,0.25})
				
				-- table.insert(hadStarter, Player[color].steam_id)
				hadStarter[Player[color].steam_id or ""] = true
                return
            end
        end
        -- broadcastToColor("No save found: To get your free starter bag click the 'Free' button.", color, {0.25,1,0.25})
		
		-- Auto New --
		if not hadStarter[Player[color].steam_id or ""] then
			local params = {}
			params.position = playerZone[color].zone.getPosition()
			local saveContainer = saveBag.takeObject(params)
			saveContainer.shuffle()
			local playerSave = saveContainer.takeObject(params)
			saveContainer.destruct()
			updateSave(playerSave, color)
			params.position.y = params.position.y + 2
			local starter = starterBag.takeObject(params)
			local starterObjects = starter.getObjects()
			for i, object in ipairs(starterObjects) do
				params.position.y = params.position.y + 1.5
				local taken = starter.takeObject(params)
				
				if taken then
					playerSave.putObject(taken)
				end
			end
			starter.destruct()
			
			-- table.insert(hadStarter, Player[color].steam_id)
			hadStarter[Player[color].steam_id or ""] = true
		else
			broadcastToColor("Auto-load: Failed to load save.\nDo you already have your save?", color, {1,0.25,0.25})
		end
	end
end

function lockoutTimer(time)
    lockout = true
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='concludeLockout', delay=time})
end

function concludeLockout()
    lockout = false
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
                -- local id = object.getDescription()
                -- for j, found in ipairs(saveObjects) do
                    -- if found.name == id then
                        -- broadcastToColor("Error: Duplicate save found.\nRetrieve your save before trying again.", color, {1,0.25,0.25})
                        -- return
                    -- end
                -- end
                -- local clonedObject = object.clone(params)
                -- object.destruct()
                -- clonedObject.setName(id)
                -- clonedObject.setDescription('')
                -- return
				
				table.insert(saveQueue, {object, color})
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

function claim(o, color)
    if not lockout then
        lockoutTimer(1.2)
        local saveObjects = self.getObjects()
        local saveFound = false
        local params = {}
        params.position = playerZone[color].zone.getPosition()
        for i, object in ipairs(saveObjects) do
            -- if object.name == Player[color].steam_id then
			if object.name:match("%d+$") == Player[color].steam_id then
                params.index = object.index
                local foundObject = self.takeObject(params)
                updateSave(foundObject, color)
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
        if not hadSave then updateSave(playerSave, color) end
        params.position.y = params.position.y + 2
        local starter = starterBag.takeObject(params)
        local starterObjects = starter.getObjects()
        for i, object in ipairs(starterObjects) do
            params.position.y = params.position.y + 1.5
            starter.takeObject(params)
        end
        starter.destruct()
        -- table.insert(hadStarter, Player[color].steam_id)
		hadStarter[Player[color].steam_id or ""] = true
    else
        broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
    end
end

function purge(time, col) -- Based on unix time, so time argument is seconds
	if not (col == "Black" or Player[col].promoted or Player[col].host) then
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
			--destroyObject(foundObject)
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
