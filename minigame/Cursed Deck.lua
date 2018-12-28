
local PowerupScript = [=[-- Unique powerup from Cursed Deck
local CardScript = [[function ChooseCard(o,c)
	if c and ActivePlayer and (c~=ActivePlayer) and not Player[c].admin then
		broadcastToColor("You did not use this powerup.", c, {1,0.5,0.5})
		return
	end
	if not ActiveZone then
		broadcastToColor("Error: Could not find zone.", c, {1,0.5,0.5})
		return
	end
	
	for _,v in pairs(ActiveZone.getObjects()) do
		if v.tag=="Card" and v~=self and v.getName():sub(1,17)=="Deck's Blessing: " then
			destroyObject(v)
		end
	end
	
	
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={ActiveZone}} )
	local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={ActiveZone, math.max(#cardsInZone-2, 1)}} )
	
	self.setPosition(pos)
	self.clearButtons()
	self.setName( self.getName():sub(18,-1) )
	Global.setVar("lastCard", self)
end]]
function powerupUsed( d )
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	if d.setTarget.count<=0 or d.setTarget.value<=0 then
		broadcastToColor("Must use on a hand that is in play.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local deck = Global.getVar("mainDeck")
	if not deck then
		broadcastToColor("Could not find deck.", d.setUser.color, {1,0.5,0.5})
		return
	end
	if #deck.getObjects()<=10 then
		broadcastToColor("Not enough cards in deck.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	d.powerup.destruct()
	
	local params = {}
	params.position = {0, 2.5, 0}
	params.rotation = {0, 0, 0}
	params.smooth = false
	
	for i=1,3 do
		params.position = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, 3+i}} )
		params.position[2] = params.position[2] + 0.5
		
		local drawnCard = deck.takeObject(params)
		drawnCard.setName( "Deck's Blessing: " .. drawnCard.getName() ) -- Don't count unless it's chosen
		drawnCard.setLock( true )
		
		drawnCard.createButton({
			label="Select", click_function="ChooseCard", function_owner=drawnCard,
			position={-0.4, 1.1, -0.95}, rotation={0,0,0}, width=350, height=350, font_size=130
		})
		
		drawnCard.setLuaScript( CardScript )
		drawnCard.setVar( "ActivePlayer", d.setUser.color )
		drawnCard.setVar( "ActiveZone", d.setTarget.zone )
	end
	
	return true
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Self Only", effect="DecksBlessing"}
	Global.setTable("powerupEffectTable", effectTable)
end
]=]
local rewardData = {
	["Reward"] = {name="Reward token", scale={0.75,0.75,0.75}, color={190/255,190/255,190/255}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/5NJpNnn.png", material=2, specular_intensity=0.1, specular_sharpness=8, type=5}},
	["Royal"] = {name="Royal token", scale={0.75,0.75,0.75}, color={222/255,180/255,68/255}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/zV3wNQ5.png", material=2, specular_intensity=0.1, specular_sharpness=8, type=5}},
	["Power"] = {name="Random powerup draw", scale={0.75,0.75,0.75}, color={1,1,1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/BONyszA.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}},
	["Rupee"] = {name="Random rupee pull", scale={0.75,0.75,0.75}, color={1,1,1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/nyCqLZ3.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}},
	["Special"] = {
		name="Deck's Blessing",
		desc="[b]Unique Powerup[/b]\nBlessed by the Cursed Deck\n\nUse on your own hand to to draw three cards. Choose one to keep, discard the others.",
		script = PowerupScript,
		scale={0.72,0.72,0.72}, color={r=1,g=1,b=1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/522OFW6.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}
	},
}

-- Initialisation

function onLoad()
	broadcastToAll("Minigame: Cursed Deck!", {0.5,1,0.25})
	
	printToAll("The Cursed Deck of Skulls beckons you... Will you walk away rich, or will the deck claim your soul?\nYou may draw up to three cards in this minigame. Some powerups are enabled.", {0.5,1,0.25})
	
	userCol = nil
	playing = false
	cardNumber = 0
	
	bonusZone = nil
	
	roundTimer = Global.getVar("roundTimer")
	
	if Global.getVar("minigame")==self then
		activate()
	else
		Timer.destroy("CursedDeckMinigame_Activate")
		Timer.create( {identifier="CursedDeckMinigame_Activate", function_name="activate", delay = 5} )
	end
end

function activate()
	bonusZone = Global.getVar("bonusZone")
	
	Global.setVar("inMinigame", true)
	Global.setVar("minigame", self)
	
	local deck = Global.getVar("mainDeck")
	if deck and not (deck==nil) then destroyObject(deck) end -- We need an empty deck zone
	
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
	
	if bonusZone then
		self.interactable = false
		
		local pos = bonusZone.getPosition()
		pos.y = pos.y - 1
		self.setPosition( pos )
		self.setRotation( {0,0,180} )
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
	
	if userCol==nil then -- Nobody joined the round
		endGame()
	else -- Give time for powerups
		local time = Global.call("GetSetting", {"Rounds.PowerupsTime", 20})
		Global.call( "forwardFunction", {function_name="setRoundState", data={3, time}} )
	end
end

-- Play

local function newDeck()
	local deckZone = Global.getVar("deckZone")
	local deckBag = Global.getVar("deckBag")
	
	local deckPos = deckZone.getPosition()
	local params = {}
	params.position = {deckPos.x, deckPos.y, deckPos.z}
	
	params.rotation = {0,0,180}
	params.callback = "shuffleNewDeck"
	params.callback_owner = Global
	
	local clone = self.clone(params)
	clone.shuffle()
	clone.setPosition(params.position)
	clone.setRotation(params.rotation)
	clone.setLuaScript("")
	clone.interactable = true
	
	Global.setVar("mainDeck", clone)
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
	
	-- Reset deck
	local deck = Global.getVar("mainDeck")
	if deck and not (deck==nil) then destroyObject(deck) end
	newDeck()
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
	Global.setVar("lastCard", nil)
	
	playing = true
	cardNumber = 1
	
	doCard(set.zone, cardNumber)
	
	local lastCard = Global.getVar("lastCard")
	if lastCard and (lastCard.getName() == "Cracked Skull" or lastCard.getName() == "Refresh") then
		findNextPlayer()
		return
	end
	
	playerButtons(set.btnHandler)
end


local objectsCache = {}
function getObjectByName( name )
	if objectsCache[name] and not (objectsCache[name]==nil) then
		return storedPowerupObjects[name]
	end
	
	local chosenObject
	for _,obj in pairs(getAllObjects()) do
		if obj.getLock() and obj.getName()==name then
			chosenObject = obj
			
			break
		end
	end
	if not chosenObject then return end
	
	objectsCache[name] = chosenObject
	
	return chosenObject
end

local function giveReward(typ, pos, col)
	local data = rewardData[typ]
	if not data then return end
	
	local obj = getObjectByName(data.name)
	local newObj
	
	if obj and obj.tag~="Card" then
		if obj.tag=="Infinite" then
			newObj = obj.takeObject({position = pos, smooth = false})
		else
			newObj = obj.clone({position = pos, smooth = false})
		end
	else 
		newObj = spawnObject({type = "Custom_Model"})
		newObj.setCustomObject(data.mesh)
		
		newObj.setScale(data.scale or {1,1,1})
		newObj.setColorTint(data.color or {1,1,1})
	end
	
	newObj.setPosition(pos)
	newObj.setRotation({0,0,0})
	newObj.setLock(false)
	
	local protection = col and Player[col].seated and ("%s - %s\n\n"):format(Player[col].steam_id, Player[col].steam_name) or ""
	
	newObj.setName(data.name)
	newObj.setDescription( protection .. (data.desc or "") )
	
	if data.script then
		newObj.setLuaScript( data.script )
	end
end
function endGame()
	local objectSets = Global.getTable("objectSets")
	
	for hand, set in ipairs(objectSets) do
		local result = countCards(set)
		if result then
			Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
			
			if result.bust then
				Global.call( "forwardFunction", {function_name="clearBets", data={set.zone, true}} )
			elseif result.mult>0 then
				
				local pos = set.zone.getPosition()
				for i=1,(result.specialPowerup * result.mult) do
					giveReward("Special", pos, set.color)
					pos.y = pos.y + 0.25
				end
				for i=1,(result.power * result.mult) do
					giveReward("Power", pos, set.color)
					pos.y = pos.y + 0.25
				end
				for i=1,(result.reward * result.mult) do
					giveReward("Reward", pos, set.color)
					pos.y = pos.y + 0.25
				end
				for i=1,(result.royal * result.mult) do
					giveReward("Royal", pos, set.color)
					pos.y = pos.y + 0.25
				end
				for i=1,(result.rupee * result.mult) do
					giveReward("Rupee", pos, set.color)
					pos.y = pos.y + 0.25
				end
				
				if result.add>0 then
					Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, result.add * result.mult, true}} )
				end
			end
		end
		
		local powerupEffectTable = Global.getTable("powerupEffectTable") or {}
		-- Unlock Chips
		local zoneObjects = set.zone.getObjects()
		local tableObjects = set.tbl.getObjects()
		local prestigeObjects = set.prestige.getObjects()
		
		for zid,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
			for j, bet in ipairs(zone) do
				if (bet.tag == "Chip" and not powerupEffectTable[bet.getName()]) or (bet.tag == "Bag" and bet.getName():sub(1,11)~="Player save") and not bet.interactable then
					bet.interactable = true
					bet.setLock(false)
					
					if zid==1 and set.SplitUser and set.SplitUser.container then -- Only affects bet zone
						set.SplitUser.container.putObject(bet)
					end
				end
			end
		end
	end
	
	self.interactable = true
	self.setLock(false)
	
	local time = Global.call("GetSetting", {"Rounds.BetTime", 30})
	Global.call( "forwardFunction", {function_name="setRoundState", data={1, time}} )
	coroutineQuit = true
	
	Global.call( "forwardFunction", {function_name="newDeck", data={}} )
	
	self.destruct()
end

function playerButtons(handler)
	handler.createButton({
		label="Stand", click_function="passTurn", function_owner=self,
		position={-1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
	})
	handler.createButton({
		label="Hit", click_function="playerHit", function_owner=self,
		position={1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
	})
end

-- Actions
function doCard(zone, slot)
	local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={zone, slot}} )
	Global.call( "forwardFunction", {function_name="placeCard", data={pos, true}} )
end
function playerHit(handler,col)
	if col~=userCol and col~="Lua" and not Player[col].admin then
		broadcastToColor( "It's not your turn!", col, {1,0,0} )
		return
	end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={userCol}} )
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
	
	if cardNumber>=3 or #(Global.call( "forwardFunction", {function_name="findCardsInZone", data={set.zone}} ) or {})>=3 then findNextPlayer() return end
	
	cardNumber = cardNumber+1
	doCard(set.zone, cardNumber)
	
	local lastCard = Global.getVar("lastCard")
	if cardNumber>=3 or (lastCard and (lastCard.getName() == "Cracked Skull" or lastCard.getName() == "Refresh")) then
		findNextPlayer()
	else
		playerButtons(handler)
	end
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

local safePowerupTypes = {
	["Royal Token"] = true, ["Reward Token"] = true, ["Powerup Draw"] = true, ["Reset Timer"] = true, -- Standard safe powerups
	
	["Clear"] = true, ["Swap"] = true, ["Clone"] = true, ["Destroy"] = true,  -- Default Powerups
	
	-- Extra Powerups table
	["StartBonus"] = true, ["CopyRandom"] = true, ["DestroyPlayerRandomCard"] = true, ["DoNothing"] = true, ["SwapRandom"] = true, ["SwapRandomAll"] = true, ["ViewNextCard"] = true, ["Reset Timer"] = true,
}
local safePowerupNames = {
	["Royal token"] = true, ["Reward token"] = true, ["Random powerup draw"] = true,
}
function blackjackCanUsePowerup(d)
	return safePowerupTypes[d.effect] or safePowerupNames[d.object.getName()]
end


function blackjackEndRound(d)
	endGame()
	
	return true
end

-- Card Counting

local displayCol = {
	["Win"] =   {r=0.75,g=1,   b=0.75},
	["Bust"] =  {r=0.75, g=0.5,b=0.5},
	["Clear"] = {r=1,   g=1,   b=1},
}
local cardValue = {
	["Payout Quadruple"] = {mult=4}, ["Payout Double"] = {mult=2}, ["Refresh"] = {mult=0},
	["Payout Ten"] = {add=10}, ["Payout Five"] = {add=5}, ["Payout One"] = {add=1}, --["Laughing Skull"] = {},
	["Cracked Skull"] = {bust = true}, ["Deck's Blessing"] = {specialPowerup = 1},
	["Reward token"] = {reward = 1}, ["Powerup"] = {power = 1}, ["Royal token"] = {royal = 1}, ["Rupee"] = {rupee = 1},
}
function countCards(set)
	local cardList = Global.call( "forwardFunction", {function_name="findCardsInZone", data={set.zone}} )
	local deckList = Global.call( "forwardFunction", {function_name="findDecksInZone", data={set.zone}} )
	local figurineList = Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={set.zone}} )
	if #cardList == 0 and #deckList == 0 and #figurineList == 0 then
		set.btnHandler.editButton({ index=0, label="0", color = displayCol.Clear })
		
		return
	end
	
	local cardNames = {}
	
	for i, card in ipairs(cardList) do
		local z = card.getRotation().z
		if z > 270 or z < 90 then table.insert(cardNames, card.getName()) end
	end
	for i, deck in ipairs(deckList) do
		local z = deck.getRotation().z
		if z > 270 or z < 90 then
			for j, card in ipairs(deck.getObjects()) do
				table.insert(cardNames, card.nickname)
			end
		end
	end
	for i, figurine in ipairs(figurineList) do
		table.insert(cardNames, figurine.getName())
	end
	
	local results = {
		add = 0, mult = 1,
		power = 0, reward = 0, royal = 0, rupee = 0,
		specialPowerup = 0, bust = false
	}
	for i,card in ipairs(cardNames) do
		local data = cardValue[card]
		if data then
			if data.bust then
				results.bust = true
			else
				for k,v in pairs(data) do
					if k=="mult" then
						results[k] = results[k]*v
					else
						results[k] = results[k]+v
					end
				end
			end
		end
	end
	
	if results.bust then
		set.btnHandler.editButton({ index=0, label="\u{2620}", color = displayCol.Bust })
	elseif results.mult==0 then
		set.btnHandler.editButton({ index=0, label="0", color = displayCol.Clear })
	elseif results.specialPowerup>0 or results.power>0 or results.reward>0 or results.royal>0 or results.rupee>0 then
		set.btnHandler.editButton({ index=0, label="\u{2664}", color = displayCol.Win })
	elseif results.add>0 then
		set.btnHandler.editButton({ index=0, label=tostring(results.add * results.mult), color = displayCol.Win })
	else
		set.btnHandler.editButton({ index=0, label="0", color = displayCol.Clear })
	end
	
	return results
end
function blackjackCountCards()
	local objectSets = Global.getTable("objectSets")
	
	for hand, set in ipairs(objectSets) do
		local results = countCards(set)
		objectSets[hand].count = #(Global.call( "forwardFunction", {function_name="findCardsInZone", data={set.zone}} ) or {})
		objectSets[hand].value = (results and results.bust and 100) or (objectSets[hand].count>0 and 1) or 0
	end
	
	Global.setTable("objectSets", objectSets)
	
	return true -- Override default count
end
