
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksInZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )
	if #cardsInZone>0 or #decksInZone>0 then
		-- Get cards list
		local cardObjects = {}
		for i=1,#cardsInZone do table.insert(cardObjects,cardsInZone[i]) end
		for i=1,#decksInZone do -- Multiple entires based on number of cards
			for n = 1,decksInZone[i].getQuantity() do table.insert(cardObjects, decksInZone[i]) end
		end
		
		-- Find our chosen card
		local card = cardsInZone[ math.random(1, #cardsInZone) ] -- Failsafe
		local obj = cardObjects[ math.random(1, #cardObjects) ]
		if obj.tag=="Deck" then
			obj.shuffle()
			
			local pos = obj.getPosition()
			pos.y = pos.y+2
			card = obj.takeObject({position=pos})
		else
			card = obj
		end
		
		-- Validate
		if not card then
			broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
			return
		end
		
		local cardValueName = Global.getTable("cardNameTable")[card.getName()]
		local cardValue = (cardValueName=="Ace" and 1) or tonumber(cardValueName) or 0
		
		-- Get new deck
		local pos = d.powerup.getPosition()
		local allDecks = Global.getVar("deckBag").takeObject({pos.x, pos.y+5, pos.z})
		allDecks.shuffle()
		local deck = allDecks.takeObject({pos.x, pos.y+6, pos.z})
		deck.shuffle()
		local deckCards = deck.getObjects()
		
		-- Find Ace
		local foundAce
		for i=1,#deckCards do
			if deckCards[i].nickname=="Ace" then
				foundAce = deck.takeObject({index=deckCards[i].index, position={pos.x, pos.y+8, pos.z}})
				break
			end
		end
		
		allDecks.destruct()
		deck.destruct()
		
		if foundAce then
			-- Store data
			local pos = card.getPosition()
			local rot = card.getRotation()
			local set = card.getTable("blackjack_playerSet")
			
			-- Check rewards
			local dlr = sets[1].value
			if d.setUser.color~=d.setTarget.color and d.setUser.color~=d.setTarget.UserColor then
				local newVal = d.setTarget.value - cardValue + 1
				local newHighVal = d.setTarget.value - cardValue + 11
				if d.setTarget.value>21 and (not (d.setTarget.value>=68 and d.setTarget.value<=72)) then -- Was bust
					if d.setTarget.count<5 and ((newVal<=21 and newVal>=dlr) or (newHighVal<=21 and newHighVal>=dlr)) or ((newVal<=21 and newVal>dlr) or (newHighVal<=21 and newHighVal>dlr)) then
						Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
					end
				elseif d.setTarget.value<=21 and (dlr<=21 or (dlr>=69 and dlr<=72)) and newVal<=21 and ((d.setTarget.value<dlr and (newVal>=dlr or (newHighVal<=21 and newHighVal>=dlr))) or (d.setTarget.value==dlr and (newVal>dlr or (newHighVal<=21 and newHighVal>dlr)))) then
					Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
				end
			end
			
			card.destruct()
			
			-- Position Ace
			foundAce.setPosition(pos)
			foundAce.setRotation(rot)
			
			Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={foundAce, {targetPos=pos, set=set, isStarter=set, flip=true}}} )
			
			destroyObject(d.powerup)
			
			return true
		end
		
		broadcastToColor("Could not find a valid deck! Is this table missing aces?", d.setUser.color, {1,0.5,0.5})
		return false
	else
		broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Any Player", effectName="DestroyPlayerRandomCard"} )
end
