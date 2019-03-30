
-- Results

local objects = {
	["Cup"] = {mesh="https://paste.ee/r/3JPfK", diffuse="http://www.littlewebhut.com/images/woodsample.jpg"},
	["Wolf"] = {mesh="https://drive.google.com/uc?export=download&id=0B60T7NhNNqG_SU1tOHhRZWVjd0U", specular_color={1,0,0}},
	["Deer"] = {mesh="https://drive.google.com/uc?export=download&id=0B60T7NhNNqG_WXJwci1TLTJkRUU", specular_color={0,1,0}},
	["Venison"] = {mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/kUkMh2F.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1},
}
local VenisonScript = [[-- Unique powerup from Hunt Master
function powerupUsed( d )
	if d.setTarget.value>=21 or d.setTarget.count==0 then
		broadcastToColor("This powerup can only be used on a hand with value less than 21.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	math.randomseed( os.time() )
	local value = math.floor(math.random(1, 21-d.setTarget.value))
	
	local clone = d.powerup.clone(params)
	clone.setLock(false) -- We'll use lock status to determine whether it was used successfully
	clone.setName( ("%s (%+i)"):format(d.powerup.getName(), value) )
	clone.setLuaScript( ([===[function getCardValue()
		return (%i)
	end]===]):format(value) )
	
	Global.call( "forwardFunction", {function_name="activatePowerupEffect", data={"Card Mod", d.setTarget, clone, d.setUser}} ) -- Hijack function
	
	if clone.getLock() then -- Success!
		destroyObject(d.powerup)
	else -- Failure!
		destroyObject(clone)
	end
	
	return false -- In any case, tell the global script we failed. This prevents double messages.
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Anyone", effect="Venison"}
	Global.setTable("powerupEffectTable", effectTable)
end
]]
local results = {
	[0] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="clearBets", data={set.zone, true}} )
		
		printToAll("Wolf! "..tostring(col).." has lost their bet.", {0.75,0.8,0.25})
	end,
	[1] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 1, true}} )
		
		printToAll("Success! "..tostring(col).." has hunted the deer and claimed a 1:1 payout.", {0.5,1,0.25})
	end,
	[2] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 3, true}} )
		
		printToAll("Success! "..tostring(col).." has hunted the deer and claimed a 3:1 payout.", {0.5,1,0.25})
	end,
	[3] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 10, true}} )
		
		printToAll("Exceptional! "..tostring(col).." has hunted the deer and claimed a 10:1 payout.", {0.5,1,0.25})
	end,
	[4] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 25, true}} )
		
		printToAll("Impossible! "..tostring(col).." has hunted the deer and claimed a 25:1 payout.", {0.5,1,0.25})
		
		local spawnPos = set.zone.getPosition()
		local protection = Player[col].seated and ("%s - %s\n\n"):format(Player[col].steam_id, Player[col].steam_name) or ""
		
		local powerup = spawnObject({type = "Custom_Model"})
		powerup.setCustomObject(objects["Venison"])
		
		powerup.setPosition(spawnPos)
		powerup.setRotation({0,0,0})
		powerup.setLock(false)
		
		powerup.setName("Venison")
		powerup.setScale( {0.72,0.72,0.72} )
		powerup.setDescription( protection .. "[b]Unique Powerup[/b]\nAwarded to Hunt Masters.\n\nUse on any hand with a value of less than 21 to add a random value to that hand. Will not cause a player to bust." )
		
		powerup.setLuaScript( VenisonScript )
	end,
}

-- Initialisation

function onLoad()
	broadcastToAll("Minigame: Hunt Master!", {0.5,1,0.25})
	
	printToAll("Are you the master of the hunt? Stalk your prey and find the deer to claim your reward. But be careful, if you come accross a wolf you'll lose a hand!", {0.5,1,0.25})
	
	userCol = nil
	playing = false
	wolfCount = 0
	safeNumber = 0
	cupObjects = {}
	cleanupFigurnes()
	
	bonusZone = nil
	
	roundTimer = Global.getVar("roundTimer")
	
	if Global.getVar("minigame")==self then
		activate()
	else
		Timer.destroy("HuntMasterMinigame_Activate")
		Timer.create( {identifier="HuntMasterMinigame_Activate", function_name="activate", delay = 5} )
	end
end

function activate()
	bonusZone = Global.getVar("bonusZone")
	resetPosition()
	
	for i, set in pairs(Global.getTable("objectSets")) do
		Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
	end
	
	findNextPlayer()
end

function resetPosition()
	playing = false
	wolfCount = 0
	safeNumber = 0
	cupObjects = {}
	--cleanupFigurnes()
	
	if bonusZone then
		self.interactable = false
		
		local pos = bonusZone.getPosition()
		pos.y = pos.y - 1
		self.setPosition( pos )
		self.setRotation( {0,0,0} )
		self.setLock(true)
	end
end
function findNextPlayer()
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		seated[seated[i]] = true
		seated[i] = nil
	end
	
	local foundOldCol = userCol==nil -- If nil, take first valid player
	local sets = Global.getTable("objectSets")
	for i=#sets,1,-1 do
		if foundOldCol then
			if seated[sets[i].color] then
				userCol = sets[i].color
				resetPosition()
				
				Global.call( "forwardFunction", {function_name="clearPlayerActions", data={sets[i].zone}} )
				
				sets[i].btnHandler.createButton({
					label="Pass", click_function="passTurn", function_owner=self,
					position={-1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
				})
				sets[i].btnHandler.createButton({
					label="Begin", click_function="beginGame", function_owner=self,
					position={1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
				})
				
				broadcastToColor( "It's your turn! You have 30 seconds to begin or you will be skipped.", userCol, {0.5,1,0} )
				
				
				startLuaCoroutine(self, "autoPassPlayer")
				Global.call( "forwardFunction", {function_name="setRoundState", data={2, 30}} )
				
				return
			end
		elseif sets[i].color==userCol then
			foundOldCol = true
		end
	end
	
	self.interactable = true
	self.setLock(false)
	
	local time = Global.call("GetSetting", {"Rounds.BetTime", 30})
	Global.call( "forwardFunction", {function_name="setRoundState", data={1, time}} )
	coroutineQuit = true
	
	self.destruct()
end

-- Play

function beginGame(_, col)
	if col~=userCol and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} )
	local powerupEffectTable = Global.getTable("powerupEffectTable")
	local zoneObjectList = set.zone.getObjects()
	local validBet = false
	for j, bet in ipairs(zoneObjectList) do
		if ((bet.tag == "Chip" and not powerupEffectTable[bet.getName()]) or (bet.tag == "Bag" and bet.getName():sub(1,11)~="Player save" and bet.getQuantity()>0)) and bet.held_by_color==nil then
			bet.interactable = false
			bet.setLock(true)
			validBet = true
			
			if bet.tag == "Bag" then -- Additional bag protections
				local fullContents = bet.getObjects()
				local guids = {}
				
				for i=1,#fullContents do
					guids[fullContents[i].guid] = (guids[fullContents[i].guid] or 0) + 1 -- Account for multiple instances of a single guid
				end
				
				bet.setTable("Blackjack_BetBagContents", guids)
			end
		end
	end
	
	if not validBet then
		broadcastToColor( "This minigame requires a bet. Place a chip on the table and try again.", col, {1,0,0} )
		return
	end
	
	local objectSets = Global.getTable("objectSets")
	Global.call( "forwardFunction", {function_name="clearCardsOnly", data={objectSets[1].zone}} )
	
	playing = true
	wolfCount = 0
	safeNumber = 0
	cupObjects = {}
	cleanupFigurnes()
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	playerButtons(set.btnHandler)
end

function playerButtons(handler)
	handler.createButton({
		label="[b]Easy[/b]\nOne Wolf", click_function="setWolf1", function_owner=self, scale = {1,1,1},
		position={-0.9, 0.25, 1}, rotation={0,0,0}, width=750, height=450, font_size=130
	})
	handler.createButton({
		label="[b]Medium[/b]\nTwo Wolves", click_function="setWolf2", function_owner=self, scale = {1,1,1},
		position={0.9, 0.25, 1}, rotation={0,0,0}, width=750, height=450, font_size=130
	})
	handler.createButton({
		label="[b]Hard[/b]\nThree Wolves", click_function="setWolf3", function_owner=self, scale = {1,1,1},
		position={-0.9, 0.25, 2}, rotation={0,0,0}, width=750, height=450, font_size=130
	})
	handler.createButton({
		label="[b]Impossible[/b]\nFour Wolves", click_function="setWolf4", function_owner=self, scale = {1,1,1},
		position={0.9, 0.25, 2}, rotation={0,0,0}, width=750, height=450, font_size=130
	})
end

-- Actions
function resetObjectPosition(obj, targetPos)
	if targetPos then
		obj.setPosition(targetPos)
	end
end
function setWolves(handler, col, numWolves)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} ).zone, i}} )
	
	cupObjects = {}
	cleanupFigurnes()
	
	local objectSets = Global.getTable("objectSets")
	for i=1,numWolves+1 do
		local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={objectSets[1].zone, i}} )
		local cup = spawnObject({type = "Custom_Model", callback_function=function(o) resetObjectPosition(o,targetPos) end})
		cup.setCustomObject(objects["Cup"])
		
		cup.setPosition(pos)
		cup.setRotation({0,0,180})
		cup.setLock(true)
		
		cup.createButton({
			label=("[b]Select[/b]\nCup %i"):format(i), click_function="guess"..tostring(i), function_owner=self, scale = {1.5,1.5,1.5},
			position={0, -2.25, 0}, rotation={0,0,180}, width=400, height=350, font_size=100
		})
		handler.createButton({
			label="Cup "..i, click_function="guess"..tostring(i), function_owner=self, scale = {1.5,1.5,1.5},
			position={ (i%2==0) and 0.9 or -0.9, 0.25, 1 + math.floor((i-1)/2)}, rotation={0,0,0}, width=550, height=250, font_size=130
		})
		
		table.insert(cupObjects, cup)
	end
	
	wolfCount = numWolves
	safeNumber = math.min(math.floor(math.random(1, numWolves+1)), numWolves+1)
end
for i=1,5 do _G["setWolf"..tostring(i)] = function(handler,col) setWolves(handler, col, i) end end

function guessNumber(col, number)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	cleanupFigurnes()
	
	for i=1,#cupObjects do
		local pos = cupObjects[i].getPosition()
		local figurine = spawnObject({type = "Custom_Model", callback_function=function(o) resetObjectPosition(o,targetPos) end})
		figurine.setCustomObject(i==safeNumber and objects["Deer"] or objects["Wolf"])
		
		figurine.setColorTint( i==safeNumber and {r=0,g=1,b=0} or {r=1,g=0,b=0} )
		figurine.setPosition(pos)
		figurine.setLock(true)
		
		cupObjects[i].destruct()
		cupObjects[i] = nil
		
		table.insert(figurineObjects, figurine)
	end
	
	Timer.destroy("HuntMaster_CleanupFigurines")
	Timer.create( {identifier="HuntMaster_CleanupFigurines", function_name="cleanupFigurnes", delay=5} )
	
	if number==safeNumber then
		if results[wolfCount] then results[wolfCount](userCol) end
	else
		if results[0] then results[0](userCol) end
	end
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={Global.call("forwardFunction", {function_name="findObjectSetFromColor", data={userCol}}).zone, i}} )
	findNextPlayer()
end
for i=1,5 do _G["guess"..tostring(i)] = function(_,col) guessNumber(col, i) end end

-- Other

function doNull() end
function cleanupFigurnes()
	if figurineObjects then
		for i=1,#figurineObjects do
			destroyObject(figurineObjects[i])
			figurineObjects[i] = nil
		end
	end
	figurineObjects = {}
end

-- Pass

function passTurn(_,col)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} )
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	
	findNextPlayer()
end
function autoPassPlayer()
	coroutine.yield(0) -- Time for timer to setup
	while (not coroutineQuit) and (not playing) and ((not roundTimer) or roundTimer.getValue()>0) do
		coroutine.yield(0)
	end
	
	if (not coroutineQuit) and (not playing) and (roundTimer and roundTimer.getValue()<=0) then
		passTurn(_,"Lua")
	end
	
	return 1
end

local safePowerups = { ["Royal token"] = true, ["Reward token"] = true, ["Random powerup draw"] = true, }
function blackjackCanUsePowerup(d)
	return safePowerups[d.object.getName()]
end
