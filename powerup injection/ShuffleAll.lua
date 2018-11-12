
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )
	
	if (#tableZ1~=0 or #decksOne~=0) and (d.setUser.value<=21 or (d.setUser.value==68) or (d.setUser.value==69 and d.setUser.count==2) or (d.setUser.value==71 and d.setUser.count==2) or (d.setUser.value==70 and d.setUser.count==3)) then
		local allCards = {}
		
		local handsWithCards = {}
		local objectSets = Global.getTable("objectSets")
		for i=2,#objectSets do
			if objectSets[i].count>0 and objectSets[i].value>0 then
				local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={objectSets[i].zone}} ) or {}
				local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={objectSets[i].zone}} ) or {}
				if #find>0 or #decks>0 then
					table.insert( handsWithCards, objectSets[i] )
					
					for n=1,#find do table.insert(allCards, find[n]) end
					for n=1,#decks do table.insert(allCards, decks[n]) end
				end
			end
		end
		if #handsWithCards<=1 then
			broadcastToColor("There must be at least two hands with cards to use this powerup.", d.setUser.color, {1,0.5,0.5})
			return false
		end
		
		local cardCount = {} -- for i=1,#handsWithCards do cardCount[i] = 0 end
		local loggedCards = {}
		while #allCards>0 do
			local obj = allCards[#allCards]
			allCards[#allCards] = nil
			
			if obj.tag=="Deck" then
				local chosenHand = math.random(1,#handsWithCards)
				cardCount[chosenHand] = (cardCount[chosenHand] or 0) + 1
				loggedCards[chosenHand] = (loggedCards[chosenHand] or {})
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handsWithCards[chosenHand].zone, cardCount[chosenHand]}} )
				obj.setPosition(pos)
				obj.shuffle()
				
				-- Can't log deck properly, it's destroyed when the second last card is removed. Thanks TTS devs.
				
				for i=2,obj.getQuantity() do
					local chosenHand = math.random(1,#handsWithCards)
					cardCount[chosenHand] = (cardCount[chosenHand] or 0) + 1
					loggedCards[chosenHand] = (loggedCards[chosenHand] or {})
					
					local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handsWithCards[chosenHand].zone, cardCount[chosenHand]}} )
					local taken = obj.takeObject({position=pos})
					
					Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={taken, {targetPos=pos, set=handsWithCards[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
					
					table.insert(loggedCards[chosenHand], taken)
				end
			elseif obj.tag=="Card" then
				local chosenHand = math.random(1,#handsWithCards)
				cardCount[chosenHand] = (cardCount[chosenHand] or 0) + 1
				loggedCards[chosenHand] = (loggedCards[chosenHand] or {})
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handsWithCards[chosenHand].zone, cardCount[chosenHand]}} )
				obj.setPosition(pos)
				Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={obj, {targetPos=pos, set=handsWithCards[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
				
				table.insert(loggedCards[chosenHand], obj)
			end
		end
		
		local sortedLoggedCards = {}
		for k,v in pairs(loggedCards) do
			if cardCount[k]>1 and #v>0 then
				table.insert(sortedLoggedCards, {count=cardCount[k], id=k, cards=v})
			end
		end
		local emptyHands = {}
		for i=1,#handsWithCards do
			if not cardCount[i] then
				table.insert(emptyHands, i)
			end
		end
		
		while #sortedLoggedCards>0 and #emptyHands>0 do -- Have moveable cards, not yet given every hand a card
			local fillHand = emptyHands[#emptyHands]
			local chosenStealKey = math.random(1,#sortedLoggedCards)
			local chosenSteal = sortedLoggedCards[chosenStealKey]
			
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handsWithCards[fillHand].zone, 1}} )
			chosenSteal.cards[#chosenSteal.cards].setPosition(pos)
			Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={obj, {targetPos=pos, set=handsWithCards[fillHand], isStarter=true, flip=true}}} )
			
			table.remove(chosenSteal.cards)
			
			cardCount[fillHand] = (cardCount[fillHand] or 0)+1
			cardCount[chosenSteal.id] = cardCount[chosenSteal.id] - 1
			if cardCount[chosenSteal.id]<=1 or #chosenSteal.cards==0 then
				table.remove(sortedLoggedCards, chosenStealKey)
			end
			
			emptyHands[#emptyHands] = nil
		end
		
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on your own hand while you have cards, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="Shuffle All"} )
end
