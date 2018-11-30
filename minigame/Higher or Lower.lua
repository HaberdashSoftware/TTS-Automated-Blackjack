
-- Results

local results = {
	[0] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="clearBets", data={set.zone, true}} )
		
		printToAll("Incorrect! "..tostring(col).." has lost their bet.", {0.5,1,0.25})
	end,
	[1] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 1, true}} )
		
		printToAll("One Correct! "..tostring(col).." has won a 1:1 payout.", {0.5,1,0.25})
	end,
	[2] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 2, true}} )
		
		printToAll("Two in a row! "..tostring(col).." has won a 2:1 payout.", {0.5,1,0.25})
	end,
	[3] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 5, true}} )
		
		printToAll("Three in a row! "..tostring(col).." has won a 5:1 payout.", {0.5,1,0.25})
	end,
	[4] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 10, true}} )
		
		printToAll("Four in a row! "..tostring(col).." has won a 10:1 payout!", {0.5,1,0.25})
	end,
	[5] = function(col)
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
		Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, 20, true}} )
		
		printToAll("Jackpot! "..tostring(col).." has won a 20:1 payout!", {0.5,1,0.25})
	end,
}

local cardNameTable = {
	["Ace"]=1, ["Two"]=2, ["Three"]=3, ["Four"]=4, ["Five"]=5,
	["Six"]=6, ["Seven"]=7, ["Eight"]=8, ["Nine"]=9, ["Ten"]=10,
	["Jack"]=10, ["Queen"]=10, ["King"]=10, ["Joker"]=12,
}

-- Initialisation

function onLoad()
	broadcastToAll("Minigame: Higher or Lower!", {0.5,1,0.25})
	
	printToAll("Are you good at guessing? Guess whether the next card is higher or lower and you could win up to 20x your bet!", {0.5,1,0.25})
	
	userCol = nil
	playing = false
	cardNumber = 0
	cardValue = 0
	
	bonusZone = nil
	
	roundTimer = Global.getVar("roundTimer")
	
	if Global.getVar("minigame")==self then
		activate()
	else
		Timer.destroy("HighLowMinigame_Activate")
		Timer.create( {identifier="HighLowMinigame_Activate", function_name="activate", delay = 5} )
	end
end

function activate()
	bonusZone = Global.getVar("bonusZone")
	
	Global.setVar("inMinigame", true)
	Global.setVar("minigame", self)
	
	Global.call( "forwardFunction", {function_name="newDeck", data={}} ) -- Always use a fresh deck for this minigame
	resetPosition()
	
	for i, set in pairs(Global.getTable("objectSets")) do
		Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
	end
	
	findNextPlayer()
end

function resetPosition()
	playing = false
	cardNumber = 0
	cardValue = 0
	
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
				Global.call( "forwardFunction", {function_name="setRoundState", data={2, 20}} )
				
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

-- Play

function doCard(zone, slot)
	local lastCard = Global.getVar("lastCard")
	if lastCard then
		lastCard.setName("")
	end
	
	local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={zone, slot}} )
	Global.call( "forwardFunction", {function_name="placeCard", data={pos, true}} )
	
	local lastCard = Global.getVar("lastCard")
	if lastCard and lastCard.getName() == "Joker" then
		lastCard.destruct()
		return doCard(zone, slot)
	end
	
	cardValue = cardNameTable[(lastCard and lastCard.getName()) or ""] or 0
end

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
	Global.setVar("lastCard", nil)
	
	playing = true
	cardNumber = 0
	
	doCard(objectSets[1].zone, cardNumber+1)
	printToColor( "The first card value is "..tostring(cardValue)..".", col, {0,1,0} )
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	playerButtons(set.btnHandler)
end

function playerButtons(handler)
	handler.createButton({
		label="Higher", click_function="guessHigher", function_owner=self, scale = {1.5,1.5,1.5},
		position={0, 0.25, 1}, rotation={0,0,0}, width=450, height=350, font_size=130
	})
	handler.createButton({
		label="Equal", click_function="guessEqual", function_owner=self, scale = {1.5,1.5,1.5},
		position={0, 0.25, 2}, rotation={0,0,0}, width=450, height=350, font_size=130
	})
	handler.createButton({
		label="Lower", click_function="guessLower", function_owner=self, scale = {1.5,1.5,1.5},
		position={0, 0.25, 3}, rotation={0,0,0}, width=450, height=350, font_size=130
	})
	handler.createButton({
		label="Cash Out", click_function="cashOut", function_owner=self,
		position={1.5, 0.25, 3.5}, rotation={0,0,0}, width=600, height=300, font_size=130
	})
end

-- Actions
function cashOut(_,col)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	if cardNumber==0 and col~="Lua" then
		broadcastToColor( "You must play at least one round.", col, {1,0,0} )
		return
	end
	
	results[cardNumber or 0](userCol)
	passTurn(_,"Lua")
end

function performGuess(col, testFunc)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	local oldValue = cardValue
	
	local objectSets = Global.getTable("objectSets")
	doCard(objectSets[1].zone, cardNumber+2)
	
	local pass = testFunc(oldValue, cardValue)
	if pass then
		cardNumber = cardNumber + 1
		
		if cardNumber>=5 then
			cardNumber = 5
			cashOut(_, "Lua")
		else
			printToColor( "Correct! You have guessed "..tostring(cardNumber).." card(s) correctly.\nThe new card value is "..tostring(cardValue)..".", col, {0,1,0} )
		end
	else
		cardNumber = 0
		cashOut(_, "Lua")
	end
end
function guessHigher(_,col)
	performGuess(col, function(old,new) return new>old end)
end
function guessEqual(_,col)
	performGuess(col, function(old,new) return new==old end)
end
function guessLower(_,col)
	performGuess(col, function(old,new) return new<old end)
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


-- Display
function blackjackDisplayResult(d)
	if not (d.set and d.set.color=="Dealer") then return end -- Don't override
	
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.set.zone}} )
	local cardNames = Global.getTable("cardNameTable")
	for _,card in pairs(cardsInZone) do
		if cardNames[card.getName()] then
			return cardNames[card.getName()]
		end
	end
	return ""
end

local safePowerups = { ["Royal token"] = true, ["Reward token"] = true, ["Random powerup draw"] = true, }
function blackjackCanUsePowerup(d)
	return safePowerups[d.object.getName()]
end
