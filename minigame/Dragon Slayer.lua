
local TARGET_DRAGON = 0
local TARGET_ALLY = 1
local TARGET_SELF = 2
local TARGET_ALL = 3

local monsterName = "the dragon"

local lootIcon = "https://i.imgur.com/HeAqP16.png"
local effectIconDefault = "https://i.imgur.com/SIyiVgm.png"
local effectMdl = {mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse=effectIconDefault, material=1, specular_intensity=0.05, specular_sharpness=3, type=1}
local classData = {
	["Fighter"] = {
		hp = 10,
		actions = {
			{name="Attack", tooltip=("Deal 3 damage to the %s."):format(monsterName), effects={
				{ dmg = 3, icon = "https://i.imgur.com/ZyO8EgA.png?1" },
			}},
			{name="Reckless Stance", tooltip=("For the next 4 turns, deal 2 additional damage to %s.\nIncreases all damage taken by 1."):format(monsterName), effects= {
				{ dmg = 2, vulnerability = 1, turns = 4, icon = "https://i.imgur.com/Zf9UXJu.png" },
			}},
			{name="Defend",  tooltip="Reduce damage taken by 2 this round.", effects={
				{ def = 2, icon = "https://i.imgur.com/gXgvNPo.png?1" },
			}},
		}
	},
	["Paladin"] = {
		hp = 8,
		actions = {
			{name="Attack", tooltip=("Deal 3 damage to %s."):format(monsterName), effects={
				{ dmg = 3, icon = "https://i.imgur.com/ZyO8EgA.png?1" },
			}},
			{name="Heal Self", tooltip="Restore 2 hit points", effects={
				{ heal = 2, icon = "https://i.imgur.com/QHc977e.png" },
			}},
			{name="Protect", target = TARGET_ALLY, tooltip="Reduce the damage a player takes by 4 for 3 turns.", effects={
				{ def = 4, turns = 3, icon = "https://i.imgur.com/gXgvNPo.png?1" },
			}},
			{name="Thorns Aura", target = TARGET_ALL, tooltip="Reduce the damage all players take by 1 this round.\nPlayers deal 1 damage when attacked.", effects={
				{ thorns = 2, def = 1, icon = "https://i.imgur.com/dribtTm.png" },
			}},
		}
	},
	["Wizard"] = {
		hp = 4,
		actions = {
			{name="Fireball",  tooltip=("Deal 5 damage to the %s."):format(monsterName), effects={
				{ dmg = 5, icon = "https://i.imgur.com/ud2siei.png?1" },
			}},
			{name="Lightning Storm", tooltip=("At the end of the next 3 turns, deal 3 damage to %s."):format(monsterName), effects={
				{ dmg = 3, icon = "https://i.imgur.com/dY1FlB6.png?1", turns = 3 },
			}},
			{name="Ice Shield",  tooltip="Reduce damage taken by 3 for 3 turns.",effects={
				{ def = 3, turns = 3, icon = "https://i.imgur.com/buC4jSk.png" },
			}},
		}
	},
	["Cleric"] = {
		hp = 6,
		actions = {
			{name="Smite",  tooltip=("Deal 1 damage to %s and heal yourself for 2 hit points."):format(monsterName), effects={
				{ dmg = 1, heal = 2, icon = "https://i.imgur.com/l7XzInu.png?1" },
			}},
			{name="Heal Target", target = TARGET_ALLY, tooltip="Heal a player for 4 hit points.", effects={
				{ heal = 4, icon = "https://i.imgur.com/QHc977e.png" },
			}},
			{name="Heal All", target = TARGET_ALL, tooltip="Heal everyone for 1 hit point.", effects={
				{ heal = 1, icon = "https://i.imgur.com/QHc977e.png" },
			}},
			{name="Pray", tooltip="The gods will save you.\nHeal yourself for 3 hit points.\nReduce damage taken by 2 for 3 rounds.", effects={
				{ def = 2, turns = 3, icon = "https://i.imgur.com/sF5CxWi.png" },
				{ heal = 3, icon = "https://i.imgur.com/DP9pMoO.png" },
			}},
		}
	},
	["Thief"] = {
		hp = 8,
		actions = {
			{name="Sneak Attack",  tooltip=("Deal 3 damage to the %s."):format(monsterName), effects={
				{ dmg = 3, icon = "https://i.imgur.com/CWqZM87.png" },
			}},
			{name="Pillage", tooltip = "Gain one loot for the next 3 turns. Increase damage taken by 1.", effects={
				{ attemptLoot = true, vulnerability = 1, turns = 3, icon = "https://i.imgur.com/hplVGRR.png"},
			}},
			{name="Vanish", tooltip="Reduce damage taken by 3 for 2 turns.", effects={
				{ def = 3, turns = 2, icon = "https://i.imgur.com/x1ueuqk.png" },
			}},
		}
	},
	["Druid"] = {
		hp = 6,
		actions = {
			{name="Vine Snare",  tooltip=("Deal 2 damage to %s.\nDeal an additional 4 damage if you are attacked this round.\nReduce damage taken by 1 this round."):format(monsterName), effects={
				{ dmg = 2, thorns = 4, def = 1, icon = "https://i.imgur.com/iywrYNA.png" },
			}},
			{name="Plant Growth", target = TARGET_ALLY, tooltip="Target player regenerates 1 health.\nPlayer deals 2 damage when attacked.\nPlayer's damage taken is reduced by 1.\nLasts for 4 rounds.", effects={
				{ heal = 1, thorns = 2, def = 1, turns = 4, icon = "https://i.imgur.com/Xy7fag5.png" },
			}},
			{name="Purify", target = TARGET_ALL, tooltip="Remove debuffs from all players.", effects={
				{ purify = true, icon = "https://i.imgur.com/iKJuoEB.png" },
			}},
		}
	},
}
local sortedClasses = {}
for k in pairs(classData) do table.insert(sortedClasses, k) end
table.sort(sortedClasses)

FigurineModeChanged = false
local DragonHeartPowerup = [[-- Unique powerup from Dragon's Lair
local objData = {
	scale = {0.72,0.72,0.72},
	mesh = {mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/o9e0zob.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1},
}
local function doAddCard(user, target, powerup, name, desc, image)
	local newMesh = {}
	for k,v in pairs(objData.mesh) do newMesh[k]=v end
	newMesh.diffuse = image or newMesh.diffuse
	
	local newObj = spawnObject({type = "Custom_Model"})
	newObj.setCustomObject(newMesh)
	
	local figurines = #(Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={target.zone}} ) or {}) + 1
	local setPos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={target.zone, figurines}} ) or target.zone.getPosition()
	newObj.setPosition(setPos)
	
	newObj.setRotation( {0,0,0} )
	newObj.setLock( true )
	
	newObj.setName(name or "<N/A>")
	newObj.setDescription( desc or "" )
	newObj.setScale( objData.scale or {1,1,1} )
	newObj.setColorTint( stringColorToRGB(user.color) or {1,1,1} )
end
local effect = {
	function(userSet, targetSet, pwup) -- Dragon's Luck (Add what you need)
		printToAll("Powerup event: " ..userSet.color.. " has consumed a Dragon Heart and received Dragon's Luck!", {0.5,0.5,1})
		
		local reqNum = 21 - (targetSet.value or 21)
		local pwupName = ("Dragon's Luck (%+i)"):format(reqNum)
		
		local tbl = Global.getTable("cardNameTable")
		tbl[pwupName] = reqNum
		Global.setTable("cardNameTable", tbl)
		
		doAddCard(userSet, targetSet, pwup, pwupName, "You feel the dragon's luck wash over you.\n\nGives you what you need.", "https://i.imgur.com/U99uqPB.png")
	end,
	function(userSet, targetSet, pwup) -- Dragon's Blood (Joker)
		printToAll("Powerup event: " ..userSet.color.. " has consumed a Dragon Heart and received Dragon's Blood!", {0.5,0.5,1})
		
		doAddCard(userSet, targetSet, pwup, "Dragon Blood", "The Dragon's blood courses through your veins.\n\nNothing can defeat you!", "https://i.imgur.com/L5NYlqv.png")
	end,
	function(userSet, targetSet, pwup) -- Dragon's Hoard (6 card 21)
		printToAll("Powerup event: " ..userSet.color.. " has consumed a Dragon Heart and found the Dragon's Hoard!", {0.5,0.5,1})
		
		Global.call( "forwardFunction", {function_name="clearCards", data={targetSet.zone}} )
		
		local pos = pwup.getPosition()
		local allDecks = Global.getVar("deckBag").takeObject({pos.x, pos.y+5, pos.z})
		allDecks.shuffle()
		local deck = allDecks.takeObject({pos.x, pos.y+6, pos.z})
		deck.shuffle()
		allDecks.destruct()
		
		for n,card in ipairs({"Ace","Two","Three","Four","Five","Six"}) do
			local deckCards = deck.getObjects()
			
			-- Find Card
			local foundCard
			for i=1,#deckCards do
				if deckCards[i].nickname==card then
					foundCard = deck.takeObject({index=deckCards[i].index, position={pos.x, pos.y+8, pos.z}})
					break
				end
			end
			
			if foundCard then
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={targetSet.zone,n}} )
				
				-- Position Ace
				foundCard.setPosition(pos)
				foundCard.setRotation({0,0,0})
				
				Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={foundCard, {targetPos=pos, set=targetSet, isStarter=(n<=2), flip=true}}} )
				
				foundCard.setLock(true)
				foundCard.interactable = false
			end
		end
		
		destroyObject(deck)
	end
}
function powerupUsed( d )
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	effect[math.random(1,#effect)](d.setUser, d.setTarget, d.powerup)
	
	destroyObject(d.powerup)
	
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	return false
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Self Only", effect="DragonHeart"}
	Global.setTable("powerupEffectTable", effectTable)
	
	local tbl = Global.getTable("cardNameTable")
	tbl["Dragon's Lucky Number"] = 7
	tbl["Dragon Blood"] = 12
	Global.setTable("cardNameTable", tbl)
end]]
local rewardData = {
	["1x Payout"] = {
		icon = "https://i.imgur.com/6L2vk7M.png?1",
		payout = 1,
		chance = 100,
	},
	["2x Payout"] = {
		icon = "https://i.imgur.com/qcWB0Qj.png?1",
		payout = 2,
		chance = 50,
	},
	["Powerup"] = {
		icon = "https://i.imgur.com/BONyszA.png",
		spawnObject = {name="Random powerup draw", scale={0.75,0.75,0.75}, color={1,1,1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/BONyszA.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}},
		chance = 25,
	},
	["Reward Token"] = {
		icon = "https://i.imgur.com/5NJpNnn.png",
		spawnObject = {name="Reward token", scale={0.75,0.75,0.75}, color={r=190/255,g=190/255,b=190/255}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/5NJpNnn.png", material=2, specular_intensity=0.1, specular_sharpness=8, type=5}},
		chance = 10,
	},
	["Royal Token"] = {
		icon = "https://i.imgur.com/zV3wNQ5.png",
		spawnObject = {name="Royal token", scale={0.75,0.75,0.75}, color={r=222/255,g=180/255,b=68/255}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/zV3wNQ5.png", material=2, specular_intensity=0.1, specular_sharpness=8, type=5}},
		chance = 5,
	},
	["Dragon's Heart"] = {
		icon = "https://i.imgur.com/o9e0zob.png",
		spawnObject = {name="Dragon's Heart", desc="[b]Unique Powerup[/b]\nLooted from Dragon's Lair\n\nUse on your own hand to consume the heart and receive a random boon.", scale={0.72,0.72,0.72}, color={r=1,g=1,b=1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/o9e0zob.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}},
		spawnScript = DragonHeartPowerup,
		chance = 2,
	},
	["Rupee"] = {
		icon = "https://i.imgur.com/nyCqLZ3.png",
		spawnObject = {name="Random rupee pull", scale={0.75,0.75,0.75}, color={1,1,1}, mesh={mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/nyCqLZ3.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1}},
		chance = 1,
	},
}
local weightedRewards = {}
for name,data in pairs(rewardData) do
	for i=1,(data.chance or 1) do
		table.insert( weightedRewards, name )
	end
end


local DragonEffects = {
	["Roar"] = true, ["Dragon Flight"] = true,
	["In the Dragon's Maw"] = true, ["Dragon Fire"] = true,
}
local dragonDebuffs = {
	function()
		broadcastToAll( "The dragon roars!", {0.7, 0.2, 0.2} )
		printToAll( "You feel more vulnerable.", {0.7, 0.2, 0.2} )
		
		local effects = {vulnerability = 2, turns=3, icon="https://i.imgur.com/9rqatoI.png?1"}
		
		local sets = Global.getTable("objectSets")
		for i=#sets,1,-1 do
			local set = sets[i]
			if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
				addEffect( "Dragon", set.zone, "Roar", effects )
			end
		end
	end,
	function()
		broadcastToAll( "The dragon takes flight!", {0.7, 0.2, 0.2} )
		printToAll( "You can't escape this turn!", {0.7, 0.2, 0.2} )
		
		FigurineModeChanged = true
		self.RPGFigurine.changeMode()
		
		local effects = {preventRun = true, icon="https://i.imgur.com/5OkM3Pq.png"}
		
		local sets = Global.getTable("objectSets")
		for i=#sets,1,-1 do
			local set = sets[i]
			if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
				addEffect( "Dragon", set.zone, "Dragon Flight", effects )
			end
		end
	end,
	function()
		broadcastToAll( "The dragon regenerates!", {0.7, 0.2, 0.2} )
		
		local count = 0
		for _,v in pairs(playingUsers) do
			if v.CurHP>0 then count = count + 1 end
		end
		
		local healAmount = math.random( 1, math.ceil(count*1.5) )
		printToAll( ("The dragon regains %i health points!"):format(healAmount), {0.7, 0.2, 0.2} )
		
		DragonHealth = math.max( DragonHealth, math.min(DragonHealth + healAmount, getDragonMaxHealth(count)) )
	end,
	function()
		broadcastToAll( "The dragon stomps around in anger", {0.7, 0.2, 0.2} )
		
		local sets = Global.getTable("objectSets")
		for i=1,#sets do
			local set = sets[i]
			if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
				local zoneObjectList = set.zone.getObjects()
				for i, object in ipairs(zoneObjectList) do
					if (object.tag == "Figurine" and object.getLock()) and object.getName()=="Loot" then
						destroyObject( object )
						
						printToColor( "You dropped your loot!", set.color, {0.7, 0.2, 0.2} )
						
						break
					end
				end
			end
		end
	end,
	function()
		local potentialTargets = {}
		local sets = Global.getTable("objectSets")
		for i=1,#sets do
			local set = sets[i]
			if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
				for i, object in ipairs(set.zone.getObjects()) do
					if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" and not DragonEffects[object.getName()] then
						table.insert( potentialTargets, {color=set.color, zone=set.zone} )
						break
					end
				end
			end
		end
		if #potentialTargets==0 then return end
		
		local chosen = potentialTargets[ math.random(1, #potentialTargets) ]
		if not chosen then return end
		
		broadcastToAll( ("The dragon glares at %s, they lose the will to fight!"):format(chosen.color), {0.7, 0.2, 0.2} )
		printToColor( "All player effects have been removed from you.", chosen.color, {0.7, 0.2, 0.2} )
		
		for i, object in ipairs(chosen.zone.getObjects()) do
			if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" and not DragonEffects[object.getName()] then
				destroyObject(object)
			end
		end
	end,
}

local function ChooseTarget()
	local potentialTargets = {}
	
	local sets = Global.getTable("objectSets")
	for i=1,#sets do
		local set = sets[i]
		if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
			table.insert( potentialTargets, {color=set.color, zone=set.zone} )
		end
	end
	
	if #potentialTargets==0 then return end
	
	return potentialTargets[ math.random(1, #potentialTargets) ]
end
local dragonAttacks = {
	function() -- Bite
		local chosen = ChooseTarget()
		if not chosen then return end
		
		local mod = getDamageMod( chosen.zone )
		local dmg = math.random(2,5)
		local moddedDamage = math.max( dmg + mod, 0 )
		
		if mod~=0 then
			broadcastToAll( ("The dragon takes a bite out of %s for %i (%i) damage!"):format(chosen.color, dmg, moddedDamage), {0.7, 0.2, 0.2} )
		else
			broadcastToAll( ("The dragon takes a bite out of %s for %i damage!"):format(chosen.color, dmg), {0.7, 0.2, 0.2} )
		end
		
		playingUsers[chosen.color].CurHP = playingUsers[chosen.color].CurHP - moddedDamage
		
		local effects = {preventRun = true, icon="https://i.imgur.com/6qE6LHu.png"}
		addEffect( "Dragon", chosen.zone, "In the Dragon's Maw", effects )
		
		
		local thorns = getThornsMod( chosen.zone ) or 0
		if thorns>0 then
			DragonHealth = DragonHealth - thorns
			broadcastToAll( ("The dragon takes %i damage in return!"):format(thorns), {0.2, 0.7, 0.2} )
		end
	end,
	function() -- Fire Breath
		broadcastToAll( "The dragon breathes fire!", {0.7, 0.2, 0.2} )
		
		local effects = {burn=math.random(2,3), turns=2, icon="https://i.imgur.com/lMF59X2.png?1"}
		
		local sets = Global.getTable("objectSets")
		for i=1,#sets do
			local set = sets[i]
			if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
				addEffect( "Dragon", set.zone, "Dragon Fire", effects )
			end
		end
	end,
	function() -- Claw
		local chosen = ChooseTarget()
		if not chosen then return end
		
		local mod = getDamageMod( chosen.zone )
		local dmg = math.random(3,8)
		local moddedDamage = math.max( dmg + mod, 0 )
		
		if mod~=0 then
			broadcastToAll( ("The dragon claws at %s for %i (%i) damage!"):format(chosen.color, dmg, moddedDamage), {0.7, 0.2, 0.2} )
		else
			broadcastToAll( ("The dragon claws at %s for %i damage!"):format(chosen.color, dmg), {0.7, 0.2, 0.2} )
		end
		
		playingUsers[chosen.color].CurHP = playingUsers[chosen.color].CurHP - moddedDamage
		
		local thorns = getThornsMod( chosen.zone ) or 0
		if thorns>0 then
			DragonHealth = DragonHealth - thorns
			broadcastToAll( ("The dragon takes %i damage in return!"):format(thorns), {0.2, 0.7, 0.2} )
		end
	end,
}

-- Initialisation

function onLoad()
	broadcastToAll("Minigame: Dragon's Lair!", {0.5,1,0.25})
	
	printToAll("You have stumbled upon the lair of a mighty Dragon!\nWill you fell the foul beast, or grab some gold and dash? Just how much do you trust your allies?", {0.5,1,0.25})
	
	playingUsers = {}
	waitingFor = {}
	hasStarted = false
	inTurn = false
	DragonHealth = 120
	
	roundTimer = Global.getVar("roundTimer")
	
	if Global.getVar("minigame")==self then
		activate()
	else
		Timer.destroy("DragonSlaterMinigame_Activate")
		Timer.create( {identifier="DragonSlaterMinigame_Activate", function_name="activate", delay = 5} )
	end
end

function activate()
	resetPosition()
	
	Global.setVar("inMinigame", true)
	Global.setVar("minigame", self)
	
	clearButtons()
	selectCharacters()
end
function resetPosition()
	local sets = Global.getTable("objectSets")
	
	if sets and sets[1] and sets[1].zone then
		local pos = sets[1].zone.getPosition()
		pos.z = pos.z - 5
		pos.y = pos.y - 2
		-- pos
		
		self.interactable = false
		self.setPosition( pos )
		self.setRotation( {0,0,0} )
		self.setLock(true)
	end
end
function clearButtons( col )
	for i, set in pairs(Global.getTable("objectSets")) do
		if (not col) or set.color==col then
			Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
			Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
		end
	end
end
function clearAll( col, plusBet )
	for i, set in pairs(Global.getTable("objectSets")) do
		if (not col) or set.color==col then
			Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
			Global.call( "forwardFunction", {function_name="clearCards", data={set.zone}} )
			
			if plusBet then
				Global.call( "forwardFunction", {function_name="clearBets", data={set.zone, true}} )
			end
		end
	end
end
function doNull() end

-- Character Selection

function selectCharacters()
	clearAll()
	
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		if seated[i]~="Black" then
			seated[seated[i]] = true
		end
		seated[i] = nil
	end
	
	waitingFor = {}
	hasStarted = false
	inTurn = true
	
	local sets = Global.getTable("objectSets")
	for i=#sets,1,-1 do
		local set = sets[i]
		if seated[set.color] then
			set.btnHandler.createButton({
				label="Pass", click_function="skipGame", function_owner=self,
				position={-1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
			})
			
			for i=1,#sortedClasses do
				local sortPos = i-1
				set.btnHandler.createButton({
					label=sortedClasses[i], click_function="chooseClass"..sortedClasses[i], function_owner=self, scale = {1.2,1.2,1.2},
					position={ -0.7 + ((sortPos)%2)*1.5, 0.25, 1 + math.floor(sortPos/2)*0.85}, rotation={0,0,0}, width=550, height=350, font_size=130
				})
			end
			
			broadcastToColor( "You have 30 seconds to choose a class or you will be skipped.", set.color, {0.5,1,0} )
			
			table.insert( waitingFor, set.color )
		end
	end
	
	Global.call( "forwardFunction", {function_name="setRoundState", data={2, 30}} )
	startLuaCoroutine(self, "autoEndTurn")
end

function setupBet( col )
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
	if not set then return false end
	
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
	
	return validBet
end
function chooseClass( col, class )
	if hasStarted then return end
	if not classData[class] then return end
	
	if not setupBet( col ) then
		broadcastToColor( "This minigame requires a bet. Place a chip on the table and try again.", col, {1,0,0} )
		return
	end
	
	local hasValue = false
	for i=#waitingFor,1,-1 do
		if waitingFor[i]==col then
			hasValue = true
			table.remove( waitingFor, i ) -- We'll remove all matching entries
		end
	end
	if not hasValue then return end -- Already answered or otherwise invalid
	
	local data = classData[class]
	if not data then return end
	
	playingUsers[col] = {
		Class = class,
		MaxHP = data.hp,
		CurHP = data.hp,
	}
	
	clearButtons( col )
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
	if set and set.btnHandler then
		set.btnHandler.createButton({
			label=class, click_function="doNull", function_owner=self, scale = {1.2,1.2,1.2},
			position={0, 0.25, 2}, rotation={0,0,0}, width=550, height=350, font_size=130,
			color={0.8,0.8,0.8}
		})
	end
	
	if #waitingFor==0 then
		endTurn()
	end
end
function skipGame(o,c)
	local col = getButtonHandlerColor(o)
	if (not col) or (col~=c and not Player[c].admin) then return end
	
	clearButtons( col )
	
	for i=#waitingFor,1,-1 do
		if waitingFor[i]==col then
			table.remove( waitingFor, i ) -- We'll remove all matching entries
		end
	end
	
	if #waitingFor==0 then
		endTurn()
	end
end

function getButtonHandlerColor( handler )
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromButtons", data={handler}} )
	
	return set and set.color
end
for i=1,#sortedClasses do
	_G["chooseClass"..sortedClasses[i]] = function(o,c)
		local setCol = getButtonHandlerColor(o)
		if setCol and (setCol==c or Player[c].admin) then
			return chooseClass( setCol, sortedClasses[i] )
		end
	end
end

-- Start Turn

function startTurn()
	if FigurineModeChanged then -- Reset animation
		FigurineModeChanged = false
		self.RPGFigurine.changeMode()
	end
	
	inTurn = true
	hasStarted = true
	
	clearButtons()
	
	Global.call( "forwardFunction", {function_name="setRoundState", data={2, 30}} )
	startLuaCoroutine(self, "autoEndTurn")
	
	local sets = Global.getTable("objectSets")
	for i=2,#sets do
		local set = sets[i]
		setupActions(set)
	end
end

function setupActions(set)
	if not set then return end
	
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		if seated[i]~="Black" then
			seated[seated[i]] = true
		end
		seated[i] = nil
	end
	
	if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
		playingUsers[set.color].PendingAction = nil
		local class = playingUsers[set.color].Class
		if seated[set.color] and class and classData[class] then
			set.btnHandler.createButton({
				label="Run", click_function="actionRun", function_owner=self,
				position={-1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
			})
			set.btnHandler.createButton({
				label="Loot", click_function="actionLoot", function_owner=self,
				position={1, 0.25, 0}, rotation={0,0,0}, width=400, height=350, font_size=130
			})
			
			local actions = classData[class].actions
			for i=1,#actions do
				set.btnHandler.createButton({
					label=actions[i].name or "<Action>", click_function="takeAction"..i, function_owner=self, scale = {1.2,1.2,1.2},
					position={0, 0.25, 0.25 + i*0.9}, rotation={0,0,0}, width=950, height=325, font_size=130, tooltip = actions[i].tooltip
				})
			end
			
			broadcastToColor( "You have 30 seconds to choose an action.", set.color, {0.5,1,0} )
			
			table.insert( waitingFor, set.color )
		else
			playingUsers[set.color] = nil
			clearAll(set.color, true)
		end
	end
end

local function validPlayer( col )
	local hasValue = false
	for i=#waitingFor,1,-1 do
		if waitingFor[i]==col then
			hasValue = true
			table.remove( waitingFor, i ) -- We'll remove all matching entries
		end
	end
	if not hasValue then return false end -- Already answered or otherwise invalid
	if not playingUsers[col] then return false end -- Not in minigame
	if playingUsers[col].CurHP<=0 then -- Dead
		playingUsers[col] = nil
		return false
	end
	
	return true
end
function takeAction( col, actionID )
	if not hasStarted then return end
	
	if not (col and actionID) then return end
	if not validPlayer(col) then return clearButtons(col) end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
	local data = classData[ playingUsers[col].Class ]
	local action = data.actions[actionID]
	
	if not action then
		printToColor( "Invalid action.", col, {0.7,0.2,0.2} )
		table.insert( waitingFor, col ) -- Re-insert to table
		return
	end
	
	clearButtons(col)
	
	if action.target==TARGET_DRAGON then
		local dragonSet = Global.getTable("objectSets")[1]
		if dragonSet then
			for i=1,#action.effects do
				local eff = action.effects[i]
				
				if eff.target==TARGET_ALL then
					for i, objectSet in pairs(Global.getTable("objectSets")) do
						if playingUsers[objectSet.color] and playingUsers[objectSet.color].CurHP>0 then
							addEffect( col, objectSet.zone, eff.name or action.name, eff, i-1 )
						end
					end
				elseif eff.target==TARGET_SELF then
					addEffect( col, set.zone, eff.name or action.name, eff, i-1 )
				else
					addEffect( col, dragonSet.zone, eff.name or action.name, eff, i-1 )
				end
			end
		end
	elseif action.target==TARGET_ALL then
		for i=1,#action.effects do
			local eff = action.effects[i]
			
			if eff.target==TARGET_SELF then
				addEffect( col, set.zone, eff.name or action.name, eff, i-1 )
			elseif eff.target==TARGET_DRAGON then
				local dragonSet = Global.getTable("objectSets")[1]
				if dragonSet then
					addEffect( col, dragonSet.zone, eff.name or action.name, eff, i-1 )
				end
			else
				for i, objectSet in pairs(Global.getTable("objectSets")) do
					if playingUsers[objectSet.color] and playingUsers[objectSet.color].CurHP>0 then
						addEffect( col, objectSet.zone, eff.name or action.name, eff, i-1 )
					end
				end
			end
		end
	elseif action.target==TARGET_ALLY then
		table.insert( waitingFor, col ) -- Re-insert to table
		playingUsers[col].PendingAction = actionID
		
		setupTargetButtons( set.btnHandler )
	else
		for i=1,#action.effects do
			local eff = action.effects[i]
			addEffect( col, set.zone, eff.name or action.name, eff, i-1 )
		end
	end
	
	Wait.frames( function()
		cleanupEffects( true )
	end, 1)
	actionComplete()
end
for i=1,10 do
	_G["takeAction"..i] = function(o,c)
		local setCol = getButtonHandlerColor(o)
		if setCol and (setCol==c or Player[c].admin) then
			return takeAction( setCol, i )
		end
	end
end

function actionRun( o,col )
	if not hasStarted then return end
	
	local setCol = getButtonHandlerColor(o)
	if (not setCol) or (setCol~=col and not Player[col].admin) then return end
	
	col = setCol
	
	clearButtons( col )
	if not validPlayer(col) then return end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
	if set then
		addEffect( col, set.zone, "Flee", {attemptRun=true, icon="https://i.imgur.com/UsFjFov.png"} )
	end
	
	actionComplete()
end

function actionLoot( o,col )
	if not hasStarted then return end
	
	local setCol = getButtonHandlerColor(o)
	if (not setCol) or (setCol~=col and not Player[col].admin) then return end
	
	col = setCol
	
	clearButtons( col )
	if not validPlayer(col) then return end
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={col}} )
	if set then
		addEffect( col, set.zone, "Looting", {attemptLoot=true, icon="https://i.imgur.com/uN4s8iP.png"} )
	end
	
	actionComplete()
end

function actionComplete()
	if #waitingFor==0 then
		endTurn()
	end
end

-- Targetting

function setupTargetButtons( handler )
	local id = 0
	
	handler.createButton({
		label="Select Target", click_function="doNull", function_owner=self, scale = {1,1,1},
		position={0, 0.25, 0.9}, rotation={0,0,0}, width=950, height=325, font_size=130,
		color={0.8,0.8,0.8},
	})
	
	handler.createButton({
		label="Back", click_function="cancelTargetCol", function_owner=self, scale = {1,1,1},
		position={1.6, 0.25, 2.9}, rotation={0,0,0}, width=450, height=275, font_size=120,
	})
	
	local sets = Global.getTable("objectSets")
	for i=2,#sets do
		local set = sets[i]
		if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
			handler.createButton({
				label="", click_function="targetCol"..set.color, function_owner=self, scale = {1,1,1},
				position={(math.floor(id%4)*0.5) - 0.75, 0.25, 1.5 + math.floor(id/4)*0.8}, rotation={0,0,0}, width=200, height=200, font_size=130,
				color = stringColorToRGB( set.color ) or {0.5,0.5,0.5},
			})
			
			id = id + 1
		end
	end
end

function cancelTargetCol( o,c )
	local setCol = getButtonHandlerColor(o)
	if not (setCol and (setCol==c or Player[c].admin)) then return end
		
	if not validPlayer(setCol) then return clearButtons(setCol) end
	
	if not playingUsers[setCol].PendingAction then return end
	
	clearButtons( setCol )
	
	setupActions( Global.call("forwardFunction", {function_name="findObjectSetFromColor", data={setCol}}) )
end

function targetColor( user, target )
	if not (user and target) then return end
	if not validPlayer(user) then return clearButtons(user) end
	
	if not playingUsers[user].PendingAction then return end
	
	local actionID = playingUsers[user].PendingAction
	
	local data = classData[ playingUsers[user].Class ]
	local action = data.actions[actionID]
	
	if not action then return end
	
	clearButtons(user)
	
	local targetSet = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={target}} )
	if targetSet then
		for i=1,#action.effects do
			local eff = action.effects[i]
			
			if eff.target==TARGET_ALL then
				for i, objectSet in pairs(Global.getTable("objectSets")) do
					if playingUsers[objectSet.color] and playingUsers[objectSet.color].CurHP>0 then
						addEffect( user, objectSet.zone, eff.name or action.name, eff, i-1 )
					end
				end
			elseif eff.target==TARGET_SELF then
				local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={user}} )
				if set then
					addEffect( user, set.zone, eff.name or action.name, eff, i-1 )
				end
			elseif eff.target==TARGET_DRAGON then
				local dragonSet = Global.getTable("objectSets")[1]
				if dragonSet then
					addEffect( user, dragonSet.zone, eff.name or action.name, eff, i-1 )
				end
			else
				addEffect( user, targetSet.zone, eff.name or action.name, eff, i-1 )
			end
		end
	end
	
	cleanupEffects( true )
	actionComplete()
end
for _,targetCol in pairs({"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink"}) do
	_G["targetCol"..targetCol] = function(o,c)
		local setCol = getButtonHandlerColor(o)
		if setCol and (setCol==c or Player[c].admin) then
			return targetColor( setCol, targetCol )
		end
	end
end

-- Effects

local purifyEffects = {
	"Increase damage taken by %i\n",
}

local effToFunc = {
	purify = function( col, zone )
		for i, object in ipairs(zone.getObjects()) do
			if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" and DragonEffects[object.getName()] then
				destroyObject(object)
			end
		end
		
		local targetSet = Global.call("forwardFunction", {function_name="findObjectSetFromZone", data={zone}} )
		if targetSet and targetSet.color then
			printToColor( "All dragon effects have been removed from you.", targetSet.color, {0.7, 0.2, 0.2} )
		end
	end
}
local effToString = {
	dmg = "Deal %i damage\n",
	def = "Reduce damage taken by %i\n",
	thorns = "Return %i damage\n",
	vulnerability = "Increase damage taken by %i\n",
	heal = "Restore %i health\n",
	burn = "Take %i damage\n",
	
	purify = "Debuffs have been removed\n",
	
	attemptLoot = "You are looting\n",
	attemptRun = "You are fleeing\n",
	preventRun = "You cannot flee\n",
}
function addEffect( col, zone, name, effect, addPos )
	if not (zone and effect) then return end
	if not col then col="Dragon" end
	
	
	local desc = ""
	
	for eff,num in pairs(effect) do
		if effToString[eff] then
			desc = desc .. effToString[eff]:format(num or 0)
		end
		if effToFunc[eff] then
			effToFunc[eff]( col, zone )
		end
	end
	
	if effect.turns and effect.turns>1 then
		desc = desc .. ("%i turns"):format(effect.turns)
	else
		desc = desc .. ("This turn"):format()
	end
	
	local zoneObjectList = zone.getObjects()
	local foundEffects = {}
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
			table.insert(foundEffects, object)
		end
	end
	
	local pos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={zone, #foundEffects + 1 + (addPos or 0)}} )
	pos[1] = pos[1] + 4.5
	
	local effColor = col=="Dragon" and {r=0.5,g=0.5,b=0.5} or stringColorToRGB(col)
	createEffectObject( pos, effect.icon, effect.name or name or "<effect>", desc, effColor )
end
function addLoot( zone, addPos )
	local count = 0
	
	local set = Global.call( "forwardFunction", {function_name="findObjectSetFromZone", data={zone}} )
	if set then
		count = cleanupLoot(set)
	else
		local zoneObjectList = zone.getObjects()
		local foundEffects = {}
		for i, object in ipairs(zoneObjectList) do
			if (object.tag == "Figurine" and object.getLock()) and object.getName()=="Loot" then
				table.insert(foundEffects, object)
			end
		end
		
		count = #foundEffects
	end
	
	local pos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={zone, count + 1 + (addPos or 0)}} )
	createEffectObject( pos, lootIcon, "Loot", "When the game ends, this transforms into a random reward.", {r=1,g=1,b=1} )
end

function createEffectObject( pos, icon, name, desc, col, scale )
	effectMdl.diffuse = icon or effectIconDefault
	
	local obj = spawnObject({type = "Custom_Model", callback="resetObjectPosition", callback_owner=self, params={targetPos=pos}})
	obj.setCustomObject(effectMdl)
	
	obj.setPosition(pos)
	obj.setRotation({0,0,0})
	obj.setLock(true)
	
	obj.setName(name or "<N/A>")
	obj.setDescription( desc or "" )
	obj.setScale(scale or {0.72, 0.72, 0.72})
	obj.setColorTint(col or {r=0.5,g=0.5,b=0.5})
end

function getDamageMod( zone )
	local mod = 0
	
	local zoneObjectList = zone.getObjects()
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
			local desc = object.getDescription()
			local add = tonumber( desc:match("Increase damage taken by (%d+)") ) or 0
			local subtract = tonumber( desc:match("Reduce damage taken by (%d+)") ) or 0
			
			mod = (mod + add) - subtract
		end
	end
	
	return mod
end
function getThornsMod( zone )
	local mod = 0
	
	local zoneObjectList = zone.getObjects()
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
			local desc = object.getDescription()
			local add = tonumber( desc:match("Return (%d+) damage") ) or 0
			
			mod = mod + add
		end
	end
	
	return mod
end

-- End Turn

function getDragonMaxHealth( count )
	return 5 + ((count or 12) * 9)
end
function endTurn()
	inTurn = false
	
	clearButtons()
	waitingFor = {}
	
	local count = 0
	for col in pairs(playingUsers) do count = count + 1 end
	if count==0 then
		clearButtons()
		
		Global.call( "forwardFunction", {function_name="setRoundState", data={2, 1}} )
		
		startLuaCoroutine( self, "processLoot" )
		return
	end
	
	if not hasStarted then
		DragonHealth = getDragonMaxHealth( count )
		
		startTurn()
		return
	end
	
	startLuaCoroutine( self, "doDragonTurn" )
end

-- Turn Timer

function autoEndTurn()
	coroutine.yield(0) -- Time for timer to setup
	while (not coroutineQuit) and (inTurn and ((not roundTimer) or roundTimer.getValue()>0)) do
		coroutine.yield(0)
	end
	
	if (not coroutineQuit) and (inTurn) and (roundTimer and roundTimer.getValue()<=0) then
		endTurn()
	end
	
	return 1
end


-- Dragon's Turn

function preDragonEffects( col, zone )
	if not playingUsers[col] then return end
	
	local heal = 0
	local dmg = 0
	
	local zoneObjectList = zone.getObjects()
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
			local desc = object.getDescription()
			local addDmg = math.max(tonumber( desc:match("Deal (%d+) damage") ) or 0, 0)
			local addHeal = math.max(tonumber( desc:match("Restore (%d+) health") ) or 0, 0)
			
			dmg = dmg + addDmg
			heal = heal + addHeal
			
		end
	end
	
	if dmg>0 then
		printToAll( ("%s has dealt %i damage to %s."):format(col, dmg, monsterName), stringColorToRGB(col) )
		
		DragonHealth = DragonHealth - dmg
	end
	if heal>0 then
		printToColor( ("You have regained %i health."):format(heal), col, {0.7, 0.2, 0.2} )
		
		playingUsers[col].CurHP = math.min(playingUsers[col].CurHP + heal, playingUsers[col].MaxHP)
	end
end

function waitTime(tm)
	local endTime = os.clock() + tm
	while os.clock() < endTime do
		coroutine.yield(0)
	end
end
function doDragonTurn()
	waitTime( 1 ) -- Effects need time to set up
	
	local playerCount = 0
	for i, set in pairs(Global.getTable("objectSets")) do
		if playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
			preDragonEffects( set.color, set.zone )
			
			if playingUsers[set.color].CurHP>0 then -- Still alive, add to count
				playerCount = playerCount + 1
			end
		end
	end
	
	if DragonHealth<=0 then
		doDragonDeath()
		return 1
	end
	
	waitTime( 2 )
	doDragonDebuffs()
	waitTime( 3 )
	
	doDragonAttacks( math.ceil(playerCount/4) )
	if coroutineQuit then return 1 end
	waitTime( 3 )
	
	if DragonHealth<=0 then
		doDragonDeath()
		return 1
	end
	
	for i, set in pairs(Global.getTable("objectSets")) do
		if coroutineQuit then break end
		
		if playingUsers[set.color] then -- We do player death in here, so don't check health
			postRoundEffects( set.color, set.zone )
		end
	end
	
	if (not coroutineQuit) then
		cleanupEffects()
		startTurn()
	end
	
	return 1
end

function doDragonDebuffs()
	dragonDebuffs[ math.random(1, #dragonDebuffs) ]()
end
function doDragonAttacks( numAttacks )
	self.RPGFigurine.attack()
	
	if (not numAttacks) or numAttacks<=1 then
		dragonAttacks[ math.random(1, #dragonAttacks) ]()
		return
	end
	
	local possibleAttacks = {}
	for i=1,#dragonAttacks do
		table.insert(possibleAttacks, i)
	end
	
	if numAttacks>1 and #possibleAttacks>1 then
		broadcastToAll( "Multi-Attack!", {0.7, 0.2, 0.2} )
	end
	
	while (numAttacks>0 and #possibleAttacks>0) do
		waitTime( 0.25 )
		
		local att = math.random(1,#possibleAttacks)
		
		dragonAttacks[ possibleAttacks[att] ]()
		
		table.remove(possibleAttacks, att)
		numAttacks = numAttacks - 1
	end
end

function doDragonDeath()
	broadcastToAll( ("%s has been defeated!"):format( monsterName:sub(1,1):upper() .. monsterName:sub(2,-1) ), {0.2, 0.7, 0.2} )
	printToAll( ("Survivors pillage %s's hoard!"):format(monsterName), {0.2, 0.7, 0.2} )
	
	self.RPGFigurine.die()
	
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		if seated[i]~="Black" then
			seated[seated[i]] = true
		end
		seated[i] = nil
	end
	
	for i, set in pairs(Global.getTable("objectSets")) do
		if seated[set.color] and playingUsers[set.color] and playingUsers[set.color].CurHP>0 then
			for i=0,15 do
				addLoot( set.zone, i )
			end
		end
	end
	
	waitTime( 2 )
	
	beginPayout()
end


-- End of Round

function postRoundEffects( col, zone )
	local burn = 0
	
	local canFlee = true
	local isFleeing = false
	
	local isLooting = 0
	
	local zoneObjectList = zone.getObjects()
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
			local desc = object.getDescription()
			local add = math.max(tonumber( desc:match("Take (%d+) damage") ) or 0, 0)
			
			burn = burn + add
			
			if desc:match("You are looting") then
				isLooting = isLooting + 1
			end
			if desc:match("You cannot flee") then
				canFlee = false
			end
			if desc:match("You are fleeing") then
				isFleeing = true
			end
		end
	end
	
	if burn>0 then
		local mod = getDamageMod( zone ) or 0
		local totalBurn = math.max(burn + mod, 0)
		
		if totalBurn>0 then
			if mod~=0 then
				printToColor( ("You have taken %i (%i) damage at the end of the round."):format(burn, totalBurn), col, {0.7, 0.2, 0.2} )
			else
				printToColor( ("You have taken %i damage at the end of the round."):format(burn), col, {0.7, 0.2, 0.2} )
			end
			
			playingUsers[col].CurHP = playingUsers[col].CurHP - totalBurn
		end
	end
	if playingUsers[col].CurHP<=0 then
		playerDeath( col )
		
		return
	end
	
	if isFleeing then
		if canFlee then
			playerEscape( col )
			
			return
		else
			printToColor( "You failed to get away this round!", col, {0.7, 0.2, 0.2} )
		end
	end
	if isLooting and isLooting>0 then
		for i=1,isLooting do
			addLoot( zone, i-1 )
		end
		printToColor( "You successfully looted this round.", col, {0.2, 0.7, 0.2} )
	end
end

function cleanupEffects( ignoreTurns )
	for i, set in pairs(Global.getTable("objectSets")) do
		local zoneObjectList = set.zone.getObjects()
		local remainingObjects = {}
		for i, object in ipairs(zoneObjectList) do
			if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
				if ignoreTurns then
					table.insert( remainingObjects, object )
				else
					local desc = object.getDescription()
					
					local turns = 0
					desc = desc:gsub("(%d+) turns", function(num)
						turns = math.max(turns, num-1)
						return ""
					end)
					
					if turns and turns>0 then
						while desc:match("\n\n$") do
							desc = desc:gsub("\n\n$", "")
						end
						
						if turns>1 then
							object.setDescription( ("%s%i turns"):format(desc, turns) )
						else
							object.setDescription( ("%sThis turn"):format(desc) )
						end
						
						table.insert( remainingObjects, object )
					else
						destroyObject( object )
					end
				end
			end
		end
		
		table.sort( remainingObjects, function(a,b)
			local aPos = a.getPosition()
			local bPos = b.getPosition()
			
			if aPos.y==bPos.y then
				return aPos.z>bPos.z
			end
			
			return aPos.y<bPos.y
		end)
		
		for i=1,#remainingObjects do
			local newPos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={set.zone, i}} )
			newPos[1] = newPos[1] + 4.5
			
			remainingObjects[i].setPosition( newPos )
			remainingObjects[i].setRotation({0,0,0})
		end
	end
end
function cleanupLoot( set )
	local zoneObjectList = set.zone.getObjects()
	local remainingObjects = {}
	for i, object in ipairs(zoneObjectList) do
		if (object.tag == "Figurine" and object.getLock()) and object.getName()=="Loot" then
			if object==nil then
			else
				table.insert( remainingObjects, object )
			end
		end
	end
	
	for i=1,#remainingObjects do
		local newPos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={set.zone, i}} )
		
		remainingObjects[i].setPosition( newPos )
		remainingObjects[i].setRotation({0,0,0})
	end
	
	return #remainingObjects
end

function playerDeath( col )
	printToAll( ("%s has been defeated!"):format(col), {0.25,1,0.25})
	
	playingUsers[col] = nil
	clearAll( col, true )
	
	for k in pairs(playingUsers) do
		return -- At least one other player
	end
	-- No players left
	
	beginPayout()
end
function playerEscape( col )
	printToAll( ("%s has escaped!"):format(col), {0.75,0.5,0.55})
	
	playingUsers[col] = nil
	clearButtons(col)
	
	destroyEffects(col)
	
	for k in pairs(playingUsers) do
		return -- At least one other player
	end
	-- No players left
	
	beginPayout()
end

-- End Game

function beginPayout()
	inTurn = false
	
	for i, set in pairs(Global.getTable("objectSets")) do
		Global.call( "forwardFunction", {function_name="clearPlayerActions", data={set.zone}} )
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={set.zone}} )
		
		local zoneObjectList = set.zone.getObjects()
		for i, object in ipairs(zoneObjectList) do
			if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
				destroyObject( object )
			end
		end
	end
	
	startLuaCoroutine( self, "processLoot" )
end

function destroyEffects( col )
	-- Destroy non-loot objects
	for i, set in pairs(Global.getTable("objectSets")) do
		if (not col) or set.color==col then
			local zoneObjectList = set.zone.getObjects()
			for i, object in ipairs(zoneObjectList) do
				if (object.tag == "Figurine" and object.getLock()) and object.getName()~="Loot" then
					destroyObject( object )
				end
			end
		end
	end
end
function processLoot()
	destroyEffects()
	
	local foundLoot = false
	local toProcess = false
	local slot = 0
	repeat -- Process loot objects
		waitTime( 0.25 )
		
		foundLoot = false
		for i, set in pairs(Global.getTable("objectSets")) do
			local zoneObjectList = set.zone.getObjects()
			for i, object in ipairs(zoneObjectList) do
				if (object.tag == "Figurine" and object.getLock()) and object.getName()=="Loot" then
					destroyObject( object )
					
					addRandomLoot( set.zone, slot )
					
					foundLoot = true
					toProcess = true
					break
				end
			end
		end
		
		slot = slot + 1
	until not foundLoot
	
	waitTime( toProcess and 5 or 1 )
	
	doPayout()
	
	return 1
end

function getNewLootPos( zone, slot )
	local pos = zone.getPosition()
	
	local row = (math.floor((slot%9)/3) - 1)
	local column = (1 - math.floor(slot%3))
	
	local zpos = pos.z + ( row * 1.5 ) -- Row
	local xpos = pos.x + ( column * 1.5 ) -- Column
	
	local height = math.min( math.floor((slot%81)/9)+1, 9 )
	local ypos = pos.y-4 + (0.5*height)
	
	return {xpos, ypos, zpos}
end
function addRandomLoot( zone, slot )
	local reward = weightedRewards[ math.random(1, #weightedRewards) ]
	
	local data = rewardData[reward]
	if not data then return end
	
	createEffectObject( getNewLootPos(zone, slot), data.icon, reward, "", {r=1,g=1,b=1} )
end

function resetObjectPosition(obj, data)
	if obj and data and data.targetPos then
		obj.setPosition(data.targetPos)
	end
end
function doPayout()
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		if seated[i]~="Black" then
			seated[seated[i]] = true
		end
		seated[i] = nil
	end
	
	local powerupEffectTable = Global.getTable("powerupEffectTable")
	
	for i, set in pairs(Global.getTable("objectSets")) do
		local zoneObjectList = set.zone.getObjects()
		local spawnPos = set.zone.getPosition()
		local payout = 0
		
		local protection = seated[set.color] and ("%s - %s\n\n"):format(Player[set.color].steam_id, Player[set.color].steam_name) or ""
		for i, object in ipairs(zoneObjectList) do
			if (object.tag == "Figurine" and object.getLock()) then
				local data = rewardData[object.getName()]
				
				if data then
					payout = payout + (data.payout or 0)
					
					if data.spawnObject then
						local newObj = spawnObject({type = "Custom_Model"})
						newObj.setCustomObject(data.spawnObject.mesh)
						
						newObj.setPosition(spawnPos)
						newObj.setRotation({0,0,0})
						newObj.setLock(false)
						
						newObj.setName(data.spawnObject.name or "<N/A>")
						newObj.setDescription( protection .. (data.spawnObject.desc or "") )
						newObj.setScale( data.spawnObject.scale or {1,1,1} )
						newObj.setColorTint(data.spawnObject.color or {r=1,g=1,b=1})
						
						if data.spawnScript then
							newObj.setLuaScript( data.spawnScript )
						end
						
						spawnPos.y = spawnPos.y + 0.15
					end
					
					destroyObject( object )
				end
			end
		end
		
		if payout>0 then
			Global.call( "forwardFunction", {function_name="processPayout", data={set.zone, payout, true}} )
		else
			local zoneObjectList = set.zone.getObjects()
			for i, object in ipairs(zoneObjectList) do -- Loop again to clear when there's no payout
				if (object.tag == "Chip" and not powerupEffectTable[object.getName()]) or (object.tag == "Bag" and object.getName():sub(1,11)~="Player save") then
					object.interactable = true
					object.setLock(false)
					
					if set.SplitUser and set.SplitUser.container then
						set.SplitUser.container.putObject(object)
					end
				end
			end
		end
	end
	
	endGame()
end

function endGame()
	self.interactable = true
	self.setLock(false)
	
	local time = Global.call("GetSetting", {"Rounds.BetTime", 30})
	Global.call( "forwardFunction", {function_name="setRoundState", data={1, time}} )
	coroutineQuit = true
	
	self.destruct()
end

-- Display

local colFull = {r=0.5,g=1,b=0.5}
local colHurt = {r=0.75,g=0.8,b=0.5}
local colDangerous = {r=1,g=0.25,b=0.25}
function blackjackDisplayResult(d)
	if not d.set then return end
	
	if (d.set and d.set.color=="Dealer") then
		return tostring(DragonHealth)
	end
	
	if not (playingUsers[d.set.color] and playingUsers[d.set.color].CurHP) then return "" end
	
	local hp = playingUsers[d.set.color].CurHP
	local max = playingUsers[d.set.color].MaxHP
	
	return hp, (hp==max and colFull) or (hp<=(max/2) and colDangerous) or colHurt
end

local safePowerups = { ["Royal token"] = true, ["Reward token"] = true, ["Random powerup draw"] = true, }
function blackjackCanUsePowerup(d)
	return safePowerups[d.object.getName()]
end
