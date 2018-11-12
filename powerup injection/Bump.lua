
local cardOrder = {"Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"}
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	if #cardsInZone>0 then
		-- Get new deck
		local pos = d.powerup.getPosition()
		local allDecks = Global.getVar("deckBag").takeObject({pos.x, pos.y+5, pos.z})
		allDecks.shuffle()
		local deck = allDecks.takeObject({pos.x, pos.y+6, pos.z})
		deck.shuffle()
		allDecks.destruct()
		
		for _,card in pairs(cardsInZone) do
			local cardID = 0
			for i=1,#cardOrder do
				if cardOrder[i]==card.getName() then
					if math.random(1,2)==1 then
						cardID = (i==#cardOrder) and 1 or (i+1)
					else
						cardID = (i==1) and #cardOrder or (i-1)
					end
				end
			end
			
			if cardID~=0 then
				local deckCards = deck.getObjects()
				
				-- Find Ace
				local foundCard
				for i=1,#deckCards do
					if deckCards[i].nickname==cardOrder[cardID] then
						foundCard = deck.takeObject({index=deckCards[i].index, position={pos.x, pos.y+8, pos.z}})
						break
					end
				end
				
				if foundCard then
					-- Store data
					local pos = card.getPosition()
					local rot = card.getRotation()
					local set = card.getTable("blackjack_playerSet")
					card.destruct()
					
					-- Position Ace
					foundCard.setPosition(pos)
					foundCard.setRotation(rot)
					
					Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={foundCard, {targetPos=pos, set=set, isStarter=set, flip=true}}} )
				end
			end
		end
		
		deck.destruct()
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Any Player", effectName="BumpAllByOne"} )
end
