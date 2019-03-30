-- Unique powerup from Dragon's Lair
local objData = {
	scale = {0.72,0.72,0.72},
	mesh = {mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/o9e0zob.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1},
}
local function doAddCard(user, target, value, name, desc, image)
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
	
	if value then
		newObj.setLuaScript( ([===[function getCardValue()
			return %s
		end]===]):format( type(value)=="string" and "\""..value.."\"" or tostring(value or 0) ) )
	end
end
local effect = {
	function(userSet, targetSet, pwup) -- Dragon's Luck (Add what you need)
		printToAll("Powerup event: " ..userSet.color.. " has consumed a Dragon Heart and received Dragon's Luck!", {0.5,0.5,1})
		
		local reqNum = 21 - (targetSet.value or 21)
		local pwupName = ("Dragon's Luck (%+i)"):format(reqNum)
		
		if (targetSet.value>=68 and targetSet.value<=72) then
			reqNum = "Joker"
			pwupName = ("Dragon's Luck (Joker)"):format(reqNum)
		end
		
		doAddCard(userSet, targetSet, reqNum, pwupName, "You feel the dragon's luck wash over you.\n\nGives you what you need.", "https://i.imgur.com/U99uqPB.png")
	end,
	function(userSet, targetSet, pwup) -- Dragon's Blood (Joker)
		printToAll("Powerup event: " ..userSet.color.. " has consumed a Dragon Heart and received Dragon's Blood!", {0.5,0.5,1})
		
		doAddCard(userSet, targetSet, "Joker", "Dragon Blood", "The Dragon's blood courses through your veins.\n\nNothing can defeat you!", "https://i.imgur.com/L5NYlqv.png")
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
	if d.setTarget.value==0 and d.setTarget.count==0 then return end
	
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
end