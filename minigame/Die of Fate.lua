
-- Results

local results = {
	[1] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="doBankruptDestruction", data={set}} )
		Global.call( "forwardFunction", {function_name="takeObjectFromContainer", data={set.zone, "15a03a"}} )
		
		printToAll("[FF0000]Cracked Skull![-] "..tostring(col).." has lost everything!", {0.5,1,0.25})
	end,
	[2] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="clearBets", data={set.zone, true}} )
		
		printToAll("[D06000]Theif's Hand![-] "..tostring(col).." lost their bet!", {0.5,1,0.25})
	end,
	[6] = function(col)
		printToAll("[2020FF]Laughing Skull![-] Nothing happened...", {0.5,1,0.25})
	end,
	[10] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 1, true}} )
		
		printToAll("[A0A000]Crowned Coin![-] "..tostring(col).." won their bet!", {0.5,1,0.25})
	end,
	[16] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 2, true}} )
		
		printToAll("[C0C000]Crowned Coins![-] "..tostring(col).." won double their bet!", {0.5,1,0.25})
	end,
	[18] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="takeObjectFromContainer", data={set.zone, "16c67a"}} )
		
		printToAll("[E0E000]Royal Token![-] "..tostring(col).." has found a royal token!", {0.5,1,0.25})
	end,
	[19] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="takeObjectFromContainer", data={set.zone, "ea79f0"}} )
		
		printToAll("[60C060]Rupee![-] "..tostring(col).." has found a random rupee pull!", {0.5,1,0.25})
	end,
	[20] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="takeObjectFromContainer", data={set.zone, "ea79f0"}} )
		Global.call( "forwardFunction", {function_name="takeObjectFromContainer", data={set.zone, "ea79f0"}} )
		
		printToAll("[A0FF00]Double Rupee![-] "..tostring(col).." has found two random rupee pulls!", {0.5,1,0.25})
	end,
}
local f = function() end
for i=1,20 do if results[i] then f = results[i] else results[i] = f end end -- Auto-fill
f = nil

-- Initialisation

function onLoad()
	broadcastToAll("Minigame: Die of Fate!", {0.5,1,0.25})
	
	printToAll("Determine your fate with a roll of the die! Will you strike it rich with gems, or will you meet your doom at the hand of the Cracked Skull?", {0.5,1,0.25})
	
	userCol = nil
	rollTimeout = 0
	rollWaitTime = 0
	rolling = false
	pushes = 0
	
	bonusZone = nil
	
	roundTimer = Global.getVar("roundTimer")
	
	if Global.getVar("minigame")==self then
		activate()
	else
		Timer.destroy("DiceMinigame_Activate")
		Timer.create( {identifier="DiceMinigame_Activate", function_name="activate", delay = 5} )
	end
end

function activate()
	bonusZone = Global.getVar("bonusZone")
	
	resetPosition()
	
	-- Global.call( "forwardFunction", {function_name="setRoundState", data={2}} )
	for i, set in pairs(Global.getTable("objectSets")) do
		Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
	end
	
	findNextPlayer()
end

function resetPosition()
	rolling = false
	
	if bonusZone then
		self.interactable = false
		
		local pos = bonusZone.getPosition()
		self.setPosition( pos )
		self.setRotation( {x=math.random(0,360),y=math.random(0,360),z=math.random(0,360)} )
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
				
				Global.call( "forwardFunction", {function_name="clearPlayerActions", data={sets[i].zone}} )
				
				sets[i].btnHandler.createButton({
					label="Pass", click_function="passDie", function_owner=self,
					position={-1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
				})
				sets[i].btnHandler.createButton({
					label="Roll", click_function="rollDie", function_owner=self,
					position={1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
				})
				
				broadcastToColor( "It's your turn! You have 30 seconds to roll the die or you will be skipped.", userCol, {0.5,1,0} )
				
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
	
	local hostSettings = Global.getTable("hostSettings")
	Global.call( "forwardFunction", {function_name="setRoundState", data={1, hostSettings.iTimeBet and hostSettings.iTimeBet.getValue() or 30}} )
	coroutineQuit = true
	
	self.destruct()
end

-- Rolling

function rollDie(_, col)
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
	
	rolling = true
	Global.call( "forwardFunction", {function_name="setRoundState", data={2, 10}} )
	rollTimeout = os.time() + 10
	rollWaitTime = os.time() + 0.5
	pushes = 8
	
	self.setLock(false)
	
	self.randomize()
	self.addForce({0,20,0}) -- Add some extra upward force
	self.resting = false
	
	startLuaCoroutine( self, "checkRollEnd" )
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	rotationButtons(set.btnHandler)
end
function checkRollEnd()
	local waiting = true
	while (os.time()<rollWaitTime) or ((not self.resting) and (os.time()<rollTimeout)) do
	-- while (os.time()<rollWaitTime) or (os.time()<rollTimeout) do
		coroutine.yield(0)
	end
	
	if results[self.getValue()] then
		results[self.getValue()](userCol)
	end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} )
	local powerupEffectTable = Global.getTable("powerupEffectTable")
	local zoneObjectList = set.zone.getObjects()
	local zoneObjectList = set.zone.getObjects()
	for j, bet in ipairs(zoneObjectList) do
		if (bet.tag == "Chip" and not powerupEffectTable[bet.getName()]) or (bet.tag == "Bag" and bet.getName():sub(1,11)~="Player save") then
			bet.interactable = true
			bet.setLock(false)
		end
	end
	
	Timer.create( {identifier="DiceMinigame_ResetPos", function_name="resetPosition", delay = 0.9} )
	Timer.create( {identifier="DiceMinigame_WaitForNext", function_name="findNextPlayer", delay = 1} )
	
	rolling = false
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	
	return 1
end

-- Playing buttons
function rotationButtons(handler)
	handler.createButton({
		label="Nudges: "..tostring(pushes), click_function="null", function_owner=self, scale = {1,1,1},
		position={0, 0.25, 0.8}, rotation={0,0,0}, width=750, height=350, font_size=130
	})
	
	handler.createButton({
		label="↟", click_function="addRotUp", function_owner=self, scale = {1.5,1.5,1.5},
		position={0, 0.25, 1.8}, rotation={0,0,0}, width=350, height=350, font_size=130
	})
	handler.createButton({
		label="↡", click_function="addRotDown", function_owner=self, scale = {1.5,1.5,1.5},
		position={0, 0.25, 2.8}, rotation={0,0,0}, width=350, height=350, font_size=130
	})
	
	handler.createButton({
		label="↞", click_function="addRotLeft", function_owner=self, scale = {1.5,1.5,1.5},
		position={-1, 0.25, 2.3}, rotation={0,0,0}, width=350, height=350, font_size=130
	})
	handler.createButton({
		label="↠", click_function="addRotRight", function_owner=self, scale = {1.5,1.5,1.5},
		position={1, 0.25, 2.3}, rotation={0,0,0}, width=350, height=350, font_size=130
	})
end

function null() end
function addRotation(force, col)
	if col~=userCol and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	if (pushes or 0)<1 then
		printToColor( "You can't nudge the die any more.", col, {1,0,0} )
		return
	end
	
	self.addTorque(force)
	pushes = (pushes or 0)-1
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} )
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	rotationButtons(set.btnHandler)
end
function addRotUp(_,c) addRotation({-5,0,0}, c) end
function addRotDown(_,c) addRotation({5,0,0}, c) end
function addRotRight(_,c) addRotation({0,0,5}, c) end
function addRotLeft(_,c) addRotation({0,0,-5}, c) end


-- Passing

function passDie(_,col)
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
	while (not coroutineQuit) and (not rolling) and ((not roundTimer) or roundTimer.getValue()>0) do
		coroutine.yield(0)
	end
	
	if (not coroutineQuit) and (not rolling) and (roundTimer and roundTimer.getValue()<=0) then
		passDie(_,"Lua")
	end
	
	return 1
end

local safePowerups = { ["Royal token"] = true, ["Reward token"] = true, ["Random powerup draw"] = true, }
function blackjackCanUsePowerup(d)
	return safePowerups[d.object.getName()]
end
