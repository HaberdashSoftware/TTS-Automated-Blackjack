--[[                   MrStump's Universal Chip Converter                   ]]--

--[[Setup Instructions:
        1. Save a copy of this token to your chest. Load it into your map
        2. Set up your own table
            a. Spawn the token first (ignore any errors)
            b. Create scripting zones
                Draw them all the same way (ex: upper-left to lower-right)
            c. Create chips. Give each a unique name (ex: $50, Fifty, whatever)
            d. Place those chips into infinite bags.
            e. SAVE YOUR GAME, then load it.
        3. Modify this script
            a. Enter the GUID of the scripting zone or zones
            b. Enter the names of chips
            c. Enter how many of chips are needed to trade up to the next level
            d. Enter GUIDs of the infinite bag that holds that chip type
            e. Fine-tune script using other variables below
            f. Hit Save and Apply ]]--

--[[Begin variable editing section. You will be prompted when to stop.]]--

--List of scripting zone GUIDs which will be chip converters.
--Right click script zone with the script zone tool to copy its GUID.
--Will work with 1 zone or with many zones.
--Zones should be of equal size/dimensions.
scriptZoneList_GUID = {
    "70f11d",
    "eef978"
}

--1 entry for each chip in ascending order.
--name is the name of the CHIP.
--tierUp is how many of that chip it takes to make the next level of chip.
--GUID is the GUID of the INFINITE BAG holding each chip type.
--FRACTIONS ARE NOT SUPPORTED. ex: tierUp=2.5 is not allowed
chipList = {
    {name="$1", tierUp=10, GUID="a9d013", upOnly = true},
    {name="$10", tierUp=10, GUID="818e9b", upOnly = true},
    {name="$100", tierUp=10, GUID="d335d9", upOnly = true},
    {name="$1,000", tierUp=10, GUID="abf04f"},
    {name="$10,000", tierUp=10, GUID="ef6d07"},
    {name="$100,000", tierUp=10, GUID="d8d57a"},
    {name="$1 Million", tierUp=10, GUID="10f129"},
    {name="$10 Million", tierUp=10, GUID="72a3a1"},
    {name="$100 Million", tierUp=10, GUID="5471d7"},
    {name="$1 Billion", tierUp=10, GUID="6cbb37"},
    {name="$10 Billion", tierUp=10, GUID="acf34e"},
    {name="$100 Billion", tierUp=10, GUID="596dfe"},
    {name="$1 Trillion", tierUp=10, GUID="9c54b6"},
    {name="$10 Trillion", tierUp=10, GUID="ec8eb6"},
    {name="$100 Trillion", tierUp=10, GUID="5e0666"},
    {name="$1 Quadrillion", tierUp=10, GUID="9e9ec0"},
    {name="$10 Quadrillion", tierUp=10, GUID="319f9e"},
    {name="$100 Quadrillion", tierUp=10, GUID="32a29e"},
    {name="$1 Quintillion", tierUp=10, GUID="4ad246"},
    {name="$10 Quintillion", tierUp=10, GUID="bae6b7"},
    {name="$100 Quintillion", tierUp=10, GUID="cc00d3"},
    {name="$1 Sextillion", tierUp=10, GUID="1d3e18"},
    {name="$10 Sextillion", tierUp=10, GUID="fff738"},
    {name="$100 Sextillion", tierUp=10, GUID="dc591b"},
    {name="$1 Septillion", tierUp=10, GUID="a7ec54"},
    {name="$10 Septillion", tierUp=10, GUID="ecad39"},
    {name="$100 Septillion", tierUp=10, GUID="de8d2e"},
    {name="$1 Octillion", tierUp=10, GUID="cdcbb5"},
    {name="$10 Octillion", tierUp=10, GUID="2e7112"},
    {name="$100 Octillion", tierUp=10, GUID="fd73b8"},
    {name="$1 Nonillion", tierUp=10, GUID="7064f4"},
    {name="$10 Nonillion", tierUp=10, GUID="71c275"},
    {name="$100 Nonillion", tierUp=10, GUID="64bb6b"},
    {name="$1 Decillion", tierUp=10, GUID="b51968"},
    {name="$10 Decillion", tierUp=10, GUID="f7d3dd"},
    {name="$100 Decillion", tierUp=10, GUID="9b53c7"},
    {name="$1 Undecillion", tierUp=10, GUID="be9778"},
    {name="$10 Undecillion", tierUp=10, GUID="83186d"},
    {name="$100 Undecillion", tierUp=10, GUID="91e8a7"},
    {name="$1 Duodecillion", tierUp=10, GUID="5c2498"},
    {name="$10 Duodecillion", tierUp=10, GUID="5fd6d0"},
    {name="$100 Duodecillion", tierUp=10, GUID="d3a12c"},
    {name="$1 Tredecillion", tierUp=10, GUID="e4f498"},
    {name="$10 Tredecillion", tierUp=10, GUID="6aa449"},
    {name="$100 Tredecillion", tierUp=10, GUID="70ea95"},
    {name="$1 Quattuordecillion", tierUp=10, GUID="881fb4"},
    {name="$10 Quattuordecillion", tierUp=10, GUID="116fa3"},
    {name="$100 Quattuordecillion", tierUp=10, GUID="f8c725"},
    {name="$1 Quindecillion", tierUp=10, GUID="44bee9"},
    {name="$10 Quindecillion", tierUp=10, GUID="3dfd50"},
    {name="$100 Quindecillion", tierUp=10, GUID="42b7f4"},
    {name="$1 Sexdecillion", tierUp=10, GUID="ed92f6"},
    {name="$10 Sexdecillion", tierUp=10, GUID="b54647"},
    {name="$100 Sexdecillion", tierUp=10, GUID="9e11d3"},
    {name="$1 Septendecillion", tierUp=10, GUID="105627"},
    {name="$10 Septendecillion", tierUp=10, GUID="409cd2"},
    {name="$100 Septendecillion", tierUp=10, GUID="b57c37"},
    {name="$1 Octodecillion", tierUp=10, GUID="dbc6b8"},
    {name="$10 Octodecillion", tierUp=10, GUID="600fd3"},
    {name="$100 Octodecillion", tierUp=10, GUID="343b01"},
    {name="$1 Novemdecillion", tierUp=10, GUID="a26dc0"},
    {name="$10 Novemdecillion", tierUp=10, GUID="152c18"},
    {name="$100 Novemdecillion", tierUp=10, GUID="203928"},
    {name="$1 Vigintillion", tierUp=10, GUID="55105a"},
    {name="$10 Vigintillion", tierUp=10, GUID="d34d3c"},
    {name="$100 Vigintillion", tierUp=10, GUID="3bbfd8"},
    {name="$1 Unvigintillion", tierUp=10, GUID="ed7103"},
    {name="$10 Unvigintillion", tierUp=10, GUID="ace75e"},
    {name="$100 Unvigintillion", tierUp=10, GUID="6eefe4"},
    {name="$1 Duovigintillion", tierUp=10, GUID="ec68b0"},
    {name="$10 Duovigintillion", tierUp=10, GUID="5c5295"},
    {name="$100 Duovigintillion", tierUp=10, GUID="9b4b1e"},
    {name="$1 Trevigintillion", tierUp=10, GUID="68e703"},
    {name="$10 Trevigintillion", tierUp=10, GUID="e3b81d"},
    {name="$100 Trevigintillion", tierUp=10, GUID="68e0ce"},
    {name="$1 Quattuorvigintillion", tierUp=10, GUID="fa2725"},
    {name="$10 Quattuorvigintillion", tierUp=10, GUID="599e08"},
    {name="$100 Quattuorvigintillion", tierUp=10, GUID="ce4dc5"},
    {name="$1 Quinvigintillion", tierUp=10, GUID="39b7c0"},
    {name="$10 Quinvigintillion", tierUp=10, GUID="996ff3"},
    {name="$100 Quinvigintillion", tierUp=10, GUID="b27082"},
    {name="$1 Sexvigintillion", tierUp=10, GUID="a9325f"},
    {name="$10 Sexvigintillion", tierUp=10, GUID="55604c"},
    {name="$100 Sexvigintillion", tierUp=10, GUID="abb327"},
    {name="$1 Septenvigintillion", tierUp=10, GUID="b8ba19"},
    {name="$10 Septenvigintillion", tierUp=10, GUID="8f05e4"},
    {name="$100 Septenvigintillion", tierUp=10, GUID="2e5f9d"},
    {name="$1 Octovigintillion", tierUp=10, GUID="4dcf6c"},
    {name="$10 Octovigintillion", tierUp=10, GUID="e20ba5"},
    {name="$100 Octovigintillion", tierUp=10, GUID="b408e6"},
    {name="$1 Novemvigintillion", tierUp=10, GUID="b05ac7"},
    {name="$10 Novemvigintillion", tierUp=10, GUID="49150d"},
    {name="$100 Novemvigintillion", tierUp=10, GUID="ab460b"},
    {name="$1 Trigintillion", tierUp=10, GUID="38b8ab"},
    {name="$10 Trigintillion", tierUp=10, GUID="e9669f"},
    {name="$100 Trigintillion", tierUp=10, GUID="756ef3"},
    {name="$1 Untrigintillion", tierUp=10, GUID="7b6edd"},
    {name="$10 Untrigintillion", tierUp=10, GUID="3cc247"},
    {name="$100 Untrigintillion", tierUp=10, GUID="9765f7"},
    {name="$1 Duotrigintillion", tierUp=10, GUID="17bf3c"},
    {name="$10 Duotrigintillion", tierUp=10, GUID="08f783"},
    {name="$100 Duotrigintillion", tierUp=10, GUID="bc4599"},
    {name="$1 Tretrigintillion", tierUp=10, GUID="aefc28"},
    {name="$10 Tretrigintillion", tierUp=10, GUID="de0f13"},
    {name="$100 Tretrigintillion", tierUp=10, GUID="0a42cc"},
}
local chipToIndex = {}
for i=1,#chipList do
	chipToIndex[chipList[i].name] = i
end

--Where the chip stacks are placed, relative to the middle of the zone.
--All of these spots should fall within the boundries of the scripting zone.
--Each line is one position. X is left/right, Z is up/down.
--Do not edit Y, this is the height off of the table.
stackPosList = {
    {x=0, y=0, z=0},
}

--Max chips that can be placed in a single stack before starting a new one
stackLimit = 50

--Max chips that this script can spawn at once.
overloadLimit = 50

--How much space is between each spawned chip and the one above it.
heightIncrease = 0.5

--Which way the chips face when placed
chipRotation = {0,0,0}

--Where to place a chip bag, relative to the center of script zone
--MUST be placed outside of the scripting zone
bagPlacementPos = {7,1,2.5}

--height offset when returning items back into a bag
--8 is fairly ideal for a stackLimit of 50.
--If you have larger stacks, this number will need to be increased
bagHeightIncrease = 8

--Decide if the script trades up only 1 tier or to the highest possible value
--false = Trade Up 1 tier
--true = Trade Up as much as is possible
tradeUpToMaxValue = true

--Turn on/off support for using bags
bagSupport = false

--The # of items a bag can hold is determines by the number of entires
--in stackPosList, above. Items = indiviual items, stack size does not matter

--To change the position and rotation of the buttons,
--go to the bottom of this script and edit the position and rotation values
--Button positions are RELATIVE TO HOW YOU DREW YOUR SCRIPTING ZONES
--All scripting zones should be the same size/shape,
--and drawn the same direction (ex. upper-left to lower-right)

--[[Do not edit code beneath this point (unless you know what you are doing)]]--

function onload()
    self.interactable = false
    scriptZoneList = {}
    for i, v in pairs(scriptZoneList_GUID) do
        table.insert(scriptZoneList, getObjectFromGUID(v))
    end
    createButtons()
    lockout = false
end

--Button activations starting the conversion process
function tradeUp(z, c) convertStart(z,c,"up") end
function tradeDown(z, c) convertStart(z,c,"down") end
--Activated when the bag support needs to trigger converStart
function restartConvertStart(o, varTable)
    convertStart(varTable.zone, varTable.color, varTable.upORdown, true)
end

--Primary logic for the script, triggers other functions as it goes
function convertStart(zone, color, upORdown, override)
    if lockout == false or override == true then
        --Checks for bag first
        local storageBagList = locateBagsInZone(zone)
        if storageBagList ~= nil and bagSupport == true then
            if #storageBagList > 1 then
                broadcastToColor("Error: Too many bags in chip zone.", color, {1,0.25,0.25})
            elseif storageBagList[1].getQuantity() > #stackPosList then
                broadcastToColor("Error: Too many items in storage bag.", color, {1,0.25,0.25})
                printToColor("Max different items in bag is set to [b]"..tostring(#stackPosList).."[/b] items.", color, {1,0.9,0.9})
            else
                emptyStorageBagAndConvert(zone, color, upORdown, storageBagList[1])
            end
        else
            --If no storage bag in zone, then it continues on with the conversion
            local chipsInZone = locateChipsInZone(zone, color)
            if chipsInZone == nil then
                broadcastToColor("Error: No valid chips in zone.", color, {1,0.25,0.25})
            else
                --Gets a list of chips to convert
                local conversionList = {}
                if upORdown == "up" then
                    conversionList = determineTradeUpList(chipsInZone)
                elseif upORdown == "down" then
                    conversionList = determineTradeDownList(chipsInZone)
                end
                --Check if this will exceepd overflow limit
                if overflowCheck(conversionList) == true then
                    broadcastToColor("Error: Too many chips would be spawned.", color, {1,0.25,0.25})
                    printToColor("Max spawn limit is set to [b]"..tostring(overloadLimit).."[/b] chips.", color, {1,0.9,0.9})
                else
                    local sortedList = {}
                    for i, v in pairs(conversionList) do
                        table.insert(sortedList, {key=i, value=v})
                    end
                    local sort_func = function( a,b ) return a.value > b.value end
                    table.sort(sortedList, sort_func)
                    convertChips(sortedList, zone, color)
                end
            end
        end
        lockout = true
        timerDelay()
    else
        broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
    end
end

--Creates a list of chips that match chipList entries in the zone
function locateChipsInZone(zone, color)
    local chipsInZone = {}
    deleteList = {}
	local plyID = Player[color].steam_id
    for i, object in ipairs(zone.getObjects()) do
		local chip = chipToIndex[object.getName()] and chipList[chipToIndex[object.getName()]]
		if chip then
			local chipID = object.getDescription():match("^(%d+) %- .*")
            if object.getName() == chip.name and (not (chipID and chipID~=plyID)) then
                local numberInStack = math.abs(object.getQuantity())
                if chipsInZone[chip.name] then
                    chipsInZone[chip.name] = chipsInZone[chip.name] + numberInStack
                else
                    chipsInZone[chip.name] = numberInStack
                end
                table.insert(deleteList, object)
            end
        end
    end
    --For loops is a way to check if chipsInZone has any entries. #chipsInZone will not work
    for i, v in pairs(chipsInZone) do
        return chipsInZone
    end
    return nil
end

--Guess what this does. Used for bag support
function locateBagsInZone(zone)
    local chipsInZone = {}
    for i, object in ipairs(zone.getObjects()) do
        if object.tag == "Bag" then
            table.insert(chipsInZone, object)
        end
    end
    if #chipsInZone == 0 then
        return nil
    else
        return chipsInZone
    end
end

--Empties bag and triggers an automatic conversion
function emptyStorageBagAndConvert(zone, color, upORdown, storageBag)
    --Move bag
    local pos = zone.getPosition()
    if zone == scriptZoneList[2] then
        storageBag.setPosition({pos.x - bagPlacementPos[1], pos.y + bagPlacementPos[2], pos.z - bagPlacementPos[3]})
    else
        storageBag.setPosition({pos.x + bagPlacementPos[1], pos.y + bagPlacementPos[2], pos.z - bagPlacementPos[3]})
    end
    --Pull out and place contents
    local bagContents = storageBag.getObjects()
    for i, content in ipairs(bagContents) do
        local param = {
            position = {
                pos.x + stackPosList[i].x,
                pos.y + stackPosList[i].y,
                pos.z + stackPosList[i].z,
            },
            rotation = chipRotation,
        }
        if i == #bagContents then
            param.callback = "restartConvertStart"
            param.callback_owner = self
            param.params = {zone=zone, color=color, upORdown=upORdown}
        end
        storageBag.takeObject(param)
    end
    createBagButton(zone)
end

--Determines a finalized list of chips to spawn
function determineTradeUpList(chipsInZone)
    local listToTradeUp = chipsInZone
    while true do
        local conversionList = {}
        local loopEnd = true
		for name, chipCount in pairs(listToTradeUp) do
			local id = chipToIndex[name]
			local chip = id and chipList[id]
			if chip then
				if id < #chipList then
					--quotient is how many of the next tier of chip to get
					local quotient = math.floor(chipCount/chip.tierUp)
					--remainder is how many chips can't be converted up (not eenough)
					local remainder = chipCount % chip.tierUp
					if quotient > 0 then
						conversionList = addToConversionList(conversionList, chipList[id+1].name, quotient)
						loopEnd = false
					end
					if remainder > 0 then
						conversionList = addToConversionList(conversionList, chipList[id].name, remainder)
					end
				else
					conversionList = addToConversionList(conversionList, chipList[id].name, chipCount)
				end
			end
		end
        --This gets us out of the while loop
        --While loop is to trade up to max value instead of just going up one tier
        if tradeUpToMaxValue == false or loopEnd == true then
            return conversionList
        else
            listToTradeUp = conversionList
        end
    end
end

--Determines a finalized list of chips to spawn
function determineTradeDownList(chipsInZone)
    local conversionList = {}
	for name, chipCount in pairs(chipsInZone) do
		local id = chipToIndex[name]
		local chip = id and chipList[id]
		if chip then
			if id > 1 then
				conversionList = addToConversionList(conversionList, chipList[chip.upOnly and id or id-1].name, chip.upOnly and chipCount or chipCount * chipList[id-1].tierUp)
			else
				conversionList = addToConversionList(conversionList, chipList[id].name, chipCount)
			end
		end
	end
    return conversionList
end

--Adds an entry, or increases the count of an entry, in conversionList
function addToConversionList(conversionList, name, count)
    if conversionList[name] then
        conversionList[name] = conversionList[name] + count
    else
        conversionList[name] = count
    end
    return conversionList
end

--Confirms that the number of chips spawned will not exceed the limit
function overflowCheck(conversionList)
    local totalCount = 0
    for name, entry in pairs(conversionList) do
        totalCount = totalCount + entry
    end
    if totalCount > overloadLimit then
        return true
    else
        return false
    end
end

--Spawns chips using the sorted conversionList entries
function convertChips(sortedList, zone, color)
    local spot = 1
    local spotCount = 0
    local heightMod = 0
    for i, chip in ipairs(deleteList) do
        destroyObject(chip)
    end
    --for name, entry in pairs(cList) do
    for i, v in ipairs(sortedList) do
        local name = v.key
        local chipCount = v.value
        local iBag = findBagFromName(name)
        local pos = zone.getPosition()
        local countRemaining = chipCount
        while countRemaining > 0 do
            local newObj = iBag.takeObject({
                position = {
                    pos.x + stackPosList[spot].x,
                    pos.y + stackPosList[spot].y + heightMod,
                    pos.z + stackPosList[spot].z,
                },
                rotation = chipRotation
            })
			if newObj and color~="Black" then
				newObj.setDescription( ("%s - %s"):format(Player[color].steam_id, Player[color].steam_name) )
			end
            countRemaining = countRemaining - 1
            spotCount = spotCount + 1
            heightMod = heightMod + heightIncrease
            if spot < #stackPosList then
                if spotCount >= stackLimit or countRemaining == 0 then
                    spot = spot + 1
                    heightMod = 0
                    spotCount = 0
                end
            end
        end
    end
end

--Finds the infinite bag matching the chip type
function findBagFromName(name)
	local id = chipToIndex[name]
	local chip = id and chipList[id]
	if chip then
		return getObjectFromGUID(chip.GUID)
	end
end

--Puts chips back into a bag if the return chips button is clicked
function returnChips(zone, color)
    if lockout == false then
        local zoneObjects = zone.getObjects()
        local pos = zone.getPosition()
        if zone == scriptZoneList[2] then
            pos = {
                pos.x - bagPlacementPos[1],
                pos.y + bagPlacementPos[2],
                pos.z - bagPlacementPos[3],
            }
        else
            pos = {
                pos.x + bagPlacementPos[1],
                pos.y + bagPlacementPos[2],
                pos.z - bagPlacementPos[3],
            }
        end
        for i, chip in ipairs(zoneObjects) do
            if chip.tag == "Chip" then
                chip.setPositionSmooth({pos[1], pos[2] + i * bagHeightIncrease, pos[3]}, false, true)
            end
        end
        zone.removeButton(2)
    end
end

--Turns off the lockoff that prevents button spam
function timerDelay()
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='lockoutOff', delay=2})
end

function lockoutOff()
    lockout = false
end

--Button Creation, positions and rotations can be changed below
--All positions/rotations are relative to the middle of the scripting zones
--The 3 numbers for position/rotation are their X/Y/Z
--You will likely only need to change X and Z. Y is height.
function createButtons()
    for i, zone in pairs(scriptZoneList) do
        local posUp   = {(i==1 and -0.7 or 0.7), -0.5, 0.27}
        local posDown = {(i==1 and -0.7 or 0.7), -0.5, -0.1}
		
		zone.clearButtons()
		
        zone.createButton({
            click_function='tradeUp', label='\u{2191}', function_owner=self, --scale={2,2,2},
            position=posUp, rotation={0,180,0}, width=130, height=160, font_size=130
        })
        zone.createButton({
            click_function='tradeDown', label='\u{2193}', function_owner=self, --scale={2,2,2},
            position=posDown, rotation={0,180,0}, width=130, height=160, font_size=130
        })
    end
end
function createBagButton(zone)
	zone.createButton({
		click_function='returnChips', label='\u{219D}', function_owner=self,
		position={zone == scriptZoneList[2] and -0.6 or 0.6, -0.5, -0.17}, rotation={0,180,0}, width=65, height=80, font_size=65
	})
end
