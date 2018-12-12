
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #cards==0 or (d.setTarget.value>=21 and (d.setTarget.value<68 or d.setTarget.value>72)) then
		broadcastToColor("Must use powerup on a zone with cards in it. Cannot be used on a bust hand.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	Global.call( "forwardFunction", {function_name="forcedCardDraw", data={d.setTarget.zone}} )
	
	local drawnCard = Global.getVar("lastCard")
	if not drawnCard then
		destroyObject(d.powerup)
		if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
			startLuaCoroutine( Global, "DoDealersCards" )
		end
		return true
	end
	
	function forcedCardDraw(targetZone)
		local targetCardList = findCardsInZone(targetZone)
		local cardToDraw = #targetCardList + 1
		local pos = findCardPlacement(targetZone, cardToDraw)
		placeCard(pos, true, findObjectSetFromZone(targetZone), false)
	end
	
	local handSets = {}
	for i=2,#sets do
		if sets[i].color~=d.setTarget.color and sets[i].count>0 and sets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={sets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={sets[i].zone}} ) or {}
			if #find>0 or #decks>0 then
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={sets[i].zone, #find+1}} )
				
				local clone = drawnCard.clone({position=pos, smooth=false})
				clone.setPosition(pos)
				clone.setRotation({0,0,0})
				clone.lock()
			end
		end
	end
	
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	destroyObject(d.powerup)
	return true
end

function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="Flood"} )
end
