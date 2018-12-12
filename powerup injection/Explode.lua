
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #cards==0 then
		broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
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
	if #handSets==0 then
		broadcastToColor("There must be at least one other hand to play this card.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local cardCount = {}
	while #cards>0 do
		local obj = cards[#cards]
		cards[#cards] = nil
		
		if obj.tag == "Deck" then
			local chosenHand = math.random(1,#handSets)
			cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
			
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
			obj.setPosition(pos)
			obj.shuffle()
			
			for i=2,obj.getQuantity() do
				local chosenHand = math.random(1,#handSets)
				cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
				local taken = obj.takeObject({position=pos})
				Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={taken, {targetPos=pos, set=handSets[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
			end
		elseif obj.tag == "Card" then
			local chosenHand = math.random(1,#handSets)
			cardCount[chosenHand] = (cardCount[chosenHand] or #Global.call( "forwardFunction", {function_name="findCardsInZone", data={handSets[chosenHand].zone}} )) + 1
			
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={handSets[chosenHand].zone, cardCount[chosenHand]}} )
			obj.setPosition(pos)
			Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={obj, {targetPos=pos, set=handSets[chosenHand], isStarter=cardCount[chosenHand]<=2, flip=true}}} )
		end
	end
	
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
