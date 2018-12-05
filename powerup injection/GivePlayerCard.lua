
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cardsInTargetZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksInTargetZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksInTargetZone do table.insert(cardsInTargetZone, decksInTargetZone[i]) end
	
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	local decksInZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} )
	if (#cardsInZone~=0 or #decksInZone~=0) and #cardsInTargetZone~=0 and (d.setUser.value<=21 or (d.setUser.value>=68 and d.setUser.value<=72)) then
		local dlr = sets[1].value
		
		local cardObjects = {}
		for i=1,#cardsInZone do table.insert(cardObjects,cardsInZone[i]) end
		for i=1,#decksInZone do -- Multiple entires based on number of cards
			for n = 1,decksInZone[i].getQuantity() do table.insert(cardObjects, decksInZone[i]) end
		end
		
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
		
		if not card then
			broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
			return
		end
		
		local cVal = Global.getTable("cardNameTable")[card.getName()]
		if not cVal then return end -- Someone's done something bad
		if cVal==0 then cVal=1 end -- Ace
		
		if d.setUser.color~=d.setTarget.color and d.setUser.color~=d.setTarget.UserColor then
			local newVal = d.setTarget.value + cVal
			if newVal>=68 and newVal<=72 and d.setTarget.count<4 then -- Special hand
				Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
			elseif newVal<=21 and (not (d.setTarget.value>=68 and d.setTarget.value<=72)) and newVal>dlr and dlr<=21 and d.setTarget.value<=dlr then
				Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
			elseif d.setTarget.count==4 and (dlr<=21 or dlr==69) and (d.setTarget.value<dlr or (d.setTarget.value>21 and (d.setTarget.value<68 or d.setTarget.value>72))) then
				Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) -- Loss to 5-card bust
			end
		end
		
		local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, #cardsInTargetZone+1}} )
		card.setPosition(pos)
		Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setTarget, isStarter=false, flip=true}}} )
		
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it while you also have a hand with cards. Cannot be used while you are bust.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="GivePlayerRandomCard"} )
end
