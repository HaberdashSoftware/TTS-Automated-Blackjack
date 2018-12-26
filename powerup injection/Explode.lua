
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #cards==0 then
		broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	if not Global.call("GetSetting", {"Powerups.AllowHostile", true}) then
		local dealerValue = sets[1].value
		local targetVal = d.setTarget.value
		if ((d.setTarget.UserColor or d.setTarget.color) ~= d.setUser.color) and ((targetVal>=dealerValue and v<=21) or (targetVal>=68 and targetVal<=72)) then
			broadcastToColor("This powerup cannot be used to make another player lose.", setUser.color, {1,0.5,0.5})
			return false
		end
	end
	
	-- Check for viable other hands
	local handSets = {}
	for i=2,#sets do
		if sets[i].color~=d.setTarget.color and sets[i].count>0 and sets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={sets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={sets[i].zone}} ) or {}
			if #find>0 or #decks>0 then
				table.insert( handSets, sets[i] )
			end
		end
	end
	if #handSets==0 then -- No viable hands, fail here
		broadcastToColor("There must be at least one other hand with cards to play this powerup.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	-- Process cards
	local cardCount = {}
	local addedCards = {}
	while #cards>0 do
		local obj = cards[#cards]
		cards[#cards] = nil
		
		if obj.tag == "Deck" then -- Object is deck (backwards compatibility, this hasn't really been possible in normal play for a while)
			local chosenHand = math.random(1,#handSets)
			cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
			
			-- Position deck first, the deck object is destroyed when the second to last card is removed and we can't reference the last card
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
			obj.setPosition(pos)
			obj.shuffle()
			
			addedCards[chosenHand] = addedCards[chosenHand] or {}
			table.insert(addedCards[chosenHand], obj.getName())
			
			for i=2,obj.getQuantity() do
				-- Draw the rest of the cards
				local chosenHand = math.random(1,#handSets)
				cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
				local taken = obj.takeObject({position=pos})
				Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={taken, {targetPos=pos, set=handSets[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
				
				addedCards[chosenHand] = addedCards[chosenHand] or {}
				table.insert(addedCards[chosenHand], obj.getName())
			end
		elseif obj.tag == "Card" then -- It's a card, reposition and log
			local chosenHand = math.random(1,#handSets)
			cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
			
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
			obj.setPosition(pos)
			Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={obj, {targetPos=pos, set=handSets[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
			
			addedCards[chosenHand] = addedCards[chosenHand] or {}
			table.insert(addedCards[chosenHand], obj.getName())
		end
	end
	
	-- Count possible rewards
	local cardNameTable = Global.getTable("cardNameTable") or {}
	local dlr = sets[1].value
	local rewards = 0
	for handIndex,added in pairs(addedCards) do
		local hand = handSets[handIndex]
		if hand.color~=d.setUser.color and hand.UserColor~=d.setUser.color then -- Not one of our hands, Help is possible
			if hand.value<=21 and hand.value<=dlr and (dlr<=21 or dlr==69) then -- Losing, not bust
				if hand.value<dlr and hand.count<5 and hand.count+#added>=5 then -- Easy checks first, worst case this is loss to push
					rewards = rewards + 1
				else
					local hasAce = 0
					local addedValue = 0
					
					-- Count added cards
					for i=1,#added do
						local name = added[i]
						if name=="Joker" then -- Joker turns anything into a win
							addedValue = 0
							rewards = rewards + 1
							break
						elseif cardNameTable[name] then
							if cardNameTable[name] == 0 then
								addedValue = addedValue + cardNameTable[name]
								hasAce = true
							else
								addedValue = addedValue + cardNameTable[name]
							end
						end
					end
					
					-- Check if it helped
					if addedValue>=0 then
						local newTotal = hand.value + addedValue
						
						if newTotal<=11 and hasAce then newTotal = newTotal + 10 end
						
						if newTotal<=21 and newTotal>=dlr then
							if newTotal==dlr and hand.value<dlr then -- Loss to push
								rewards = rewards + 1
							elseif newTotal>dlr then -- Loss or push to win
								rewards = rewards + 1
							end
						end
					end
				end
			elseif hand.value>21 and (hand.value<68 or hand.value>72) then -- Bust
				if hand.count<5 and hand.count+#added>=5 then -- 5-card push
					rewards = rewards + 1
				else
					for i=1,#added do
						if added[i]=="Joker" then -- Joker turns a bust into a win
							rewards = rewards + 1
							break
						end
					end
				end
			end
		end
	end
	
	-- Give rewards
	local MultiHelp = Global.call("GetSetting", {"Powerups.MultiHelp", true}) -- Allow multiple rewards for one powerp use?
	for i=1,rewards do 
		Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
		if not MultiHelp then break end -- One reward max, exit loop
	end
	
	-- Restart dealer if appropriate
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	return true
end

function onLoad()
	Global.call("AddPowerup", {obj=self, who="Any Player", effectName="Explode"} )
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 100
	Global.setTable("cardNameTable", tbl)
end
