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
	if not (strCol and (Player[strCol].admin or self.getName():lower():find(strCol:lower()))) then
		broadcastToColor( "This does not belong to you!", strCol, {1,0.2,0.2} )
		return
	end
	
	local contents = self.getObjects()
	
	local params = {}
	local chips = {}
	
	-- Find valid chips
	for i = #contents,1,-1 do
		if nameToIndex[contents[i].name] then
			params.index = contents[i].index
			
			local newObj = self.takeObject(params)
			if newObj then
				local count = newObj.getQuantity()
				if count==-1 then count = 1 end
				
				chips[nameToIndex[contents[i].name]] = (chips[nameToIndex[contents[i].name]] or 0) + count
				
				newObj.destruct()
			end
		end
	end
	
	-- Find highest chips from values
	for i=1,#chipConversionTable do -- Most entries should be nil, but this means we only need to loop once
		if chips[i] and chips[i]>=chipConversionTable[i].tierUp and chipConversionTable[i+1] then
			chips[i+1] = (chips[i+1] or 0) + math.floor(chips[i]/chipConversionTable[i].tierUp)
			chips[i] = chips[i] % chipConversionTable[i].tierUp -- Modulo (remainder)
		end
	end
	
	-- Spawn chips
	params.index = nil
	params.position = self.getPosition()
	params.position.y = params.position.y
	-- params.callback = unlockObject -- "unlockObject"
	params.callback_function = unlockObject
	
	for k,v in pairs(chips) do -- Now we're only interested in things with values
		local found = nil
		
		if params.position.y>20 then
			params.position.y = self.getPosition().y + 2
			params.position.z = params.position.z + 2
		end
		
		if v and v>0 then
			local bag = getObjectFromGUID(chipConversionTable[k].GUID)
			if bag then
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
				
				while v>0 do
					local newChip = bag.takeObject(params)
					
					if (not stackSeparator) and (not found) then
						found = newChip
						
						if v>2 then
							table.insert(toTake, newChip)
							
							newChip.setLock(true)
							newChip.interactable = false
						end
					end
					
					params.position.y = params.position.y + 0.5
					v = v-1
				end
			end
		end
	end
	
	if waitTimer then
		Wait.stop( waitTimer )
	end
	Wait.time( processTake, 2 )
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
		click_function='doTradeUp', label='Trade Up', function_owner=self,
		position={0,0,1.25}, rotation={0,0,0}, width=600, height=190, font_size=130
	})
end
