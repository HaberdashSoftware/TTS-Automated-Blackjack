
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #tableZ1==0 or (d.setTarget.value>21 and not (d.setTarget.value>=68 and d.setTarget.value<=72)) then
		broadcastToColor("Must use powerup on a zone with cards in it, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local potentialSwaps = {}
	local handSets = {}
	for i=2,#sets do
		if sets[i].count>0 and sets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={sets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={sets[i].zone}} ) or {}  for i=1,#decks do table.insert(find, decks[i]) end
			if #find>0 then
				table.insert( potentialSwaps, find )
				table.insert( handSets, sets[i] )
			end
		end
	end
	
	if #potentialSwaps==0 then
		broadcastToColor("There must be at least one other player hand to use this powerup.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	for i=1,#handSets do
		local chosenID = math.random(1,#potentialSwaps)
		local chosenCards = potentialSwaps[chosenID]
		table.remove(potentialSwaps, chosenID)
		
		for n = 1,#chosenCards do
			chosenCards[n].setPosition( Global.call("forwardFunction", {function_name="findCardPlacement", data={handSets[i].zone, n}}) )
			Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setTarget, isStarter=(n<=2 and chosenCards[n].tag=="Card"), flip=true}}} )
		end
	end
	
	destroyObject(d.powerup)
	
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="SwapRandomAll"} )
end
