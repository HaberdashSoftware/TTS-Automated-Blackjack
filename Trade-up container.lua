-- Trade-Up Box
-- A quick hack that uses MrStump's Universal Chip Converter for data

local chipConverterGUID = "ad770c"
local chipConverter

local stackSeparatorGUID = "9ac0b7"
local stackSeparator

local chipConversionTable = {}
local nameToIndex = {}

local toTake = {}
local separators = {}

function onLoad()
	chipConverter = getObjectFromGUID(chipConverterGUID)
	if not chipConverter then return end
	
	chipConversionTable = chipConverter.getTable("chipList")
	if not chipConversionTable then return end
	
	stackSeparator = getObjectFromGUID(stackSeparatorGUID)
	
	for i = 1,#chipConversionTable - 1 do
		nameToIndex[chipConversionTable[i].name] = i
	end
	
	makeButtons()
end

local waitTimer
function doTradeUp(s, strCol)
	doTrade( strCol, true )
end
function doTradeDown(s, strCol)
	doTrade( strCol, false )
end
function doTrade(strCol, isUp)
	local ourColor = strCol and self.getName():lower():find(strCol:lower())
	if not (strCol and (Player[strCol].admin or ourColor)) then
		broadcastToColor( "This does not belong to you!", strCol, {1,0.2,0.2} )
		return
	end
	
	local contents = self.getObjects()
	
	if #contents>5 and not isUp then
		broadcastToColor( "Too many objects to trade down!", strCol, {1,0.2,0.2} )
		return
	end
	
	if not chipConverter then chipConverter = getObjectFromGUID(chipConverterGUID) end -- Converter missing, attempt to find
	if not chipConverter then -- Still missing, abort
		broadcastToColor( "Chip converter is missing! Try again later.", strCol, {1,0.2,0.2} )
		return
	end
	
	local params = {}
	local chips = {}
	
	local plyID = Player[strCol].steam_id
	local totalCount = 0
	local foundObjects = {}
	-- Find valid chips
	for i = #contents,1,-1 do
		if totalCount>5 and not isUp then break end
		
		if nameToIndex[contents[i].name] then
			params.index = contents[i].index
			
			local newObj = self.takeObject(params)
			
			if newObj then
				local chipID = contents[i].description:match("^(%d+) %- .*") 
				if ourColor and (chipID and chipID~=plyID) and not Player[strCol].admin then
					broadcastToColor( ("Removed object \"%s\" (Does not belong to you)"):format(contents[i].name), strCol, {1,0.2,0.2} )
					
					newObj.destruct()
				else
					local count = newObj.getQuantity()
					if count==-1 then count = 1 end
					
					totalCount = totalCount + count
					
					chips[nameToIndex[contents[i].name]] = (chips[nameToIndex[contents[i].name]] or 0) + count
					
					-- newObj.destruct()
					table.insert(foundObjects, newObj)
				end
			end
		end
	end
	
	if totalCount>5 and not isUp then
		broadcastToColor( "Too many chips to trade down!", strCol, {1,0.2,0.2} )
		Wait.frames(function()
			for i=1,#foundObjects do
				self.putObject( foundObjects[i] )
				destroyObject( foundObjects[i] )
			end
		end, 1)
		return
	end
	
	for i=1,#foundObjects do
		destroyObject( foundObjects[i] )
	end
	
	if isUp then -- Find highest chips from values
		for i=1,#chipConversionTable do -- Most entries should be nil, but this means we only need to loop once
			if chips[i] and chips[i]>=chipConversionTable[i].tierUp and chipConversionTable[i+1] then
				chips[i+1] = (chips[i+1] or 0) + math.floor(chips[i]/chipConversionTable[i].tierUp)
				chips[i] = chips[i] % chipConversionTable[i].tierUp -- Modulo (remainder)
			end
		end
	else -- Same thing, but trading down instead
		for i=1,#chipConversionTable do
			if chips[i] and chipConversionTable[i-1] and not chipConversionTable[i].upOnly then
				chips[i-1] = (chips[i-1] or 0) + (chipConversionTable[i-1].tierUp * (chips[i] or 0))
				chips[i] = nil -- If there's chips on the next step up, they'll overwrite this value next iteration
			end
		end
	end
	
	-- Spawn chips
	params.index = nil
	params.position = self.getPosition()
	params.position.y = params.position.y
	params.callback_function = unlockObject
	params.smooth = false
	
	for k,v in pairs(chips) do -- Loop through any values we have to spawn chips
		if params.position.y>20 then
			params.position.y = self.getPosition().y + 2
			params.position.z = params.position.z + 2
		end
		
		if v and v>0 then
			params.position.y = params.position.y + 1
			
			if stackSeparator then
				params.callback_function = nil
				
				local sep = stackSeparator.clone(params)
				table.insert(separators, sep)
				
				sep.setLock( true )
				sep.interactable = false
				
				params.position.y = params.position.y + 1
				params.callback_function = unlockObject
			end
			
			chipConverter.Call( "spawnChip", {id=k, num=v, pos=params.position} )
		end
	end
	
	if waitTimer then
		Wait.stop( waitTimer )
	end
	Wait.time( processTake, 1 )
end

function processTake()
	for i=#toTake, 1, -1 do
		if toTake[i] then
			toTake[i].interactable = true
			toTake[i].setLock(false)
		end
		
		toTake[i] = nil
	end
	
	for i=#separators, 1, -1 do
		if separators[i] and separators[i]~=NULL then
			separators[i].destruct()
		end
		
		separators[i] = nil
	end
end
function unlockObject(obj)
	obj.interactable = true
	obj.setLock(false)
end

function makeButtons()
	self.createButton({
		click_function='doTradeUp', label='\u{2191}', function_owner=self,
		position={-0.27,0,1.23}, rotation={0,0,0}, width=250, height=200, font_size=150,
		tooltip = "Trade your chips up to the next tier.",
	})
	self.createButton({
		click_function='doTradeDown', label='\u{2193}', function_owner=self,
		position={0.27,0,1.23}, rotation={0,0,0}, width=250, height=200, font_size=150,
		tooltip = "Trade your chips down to the previous tier.",
	})
end
