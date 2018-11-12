
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local tableZ2 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	local decksTwo = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} ) for i=1,#decksTwo do table.insert(tableZ2, decksTwo[i]) end
	
	if #tableZ1 ~= 0 and #tableZ2 ~= 0 and (d.setUser.value>21 and not (d.setUser.value>=68 and d.setUser.value<=72)) and (d.setTarget.value<=21 or (d.setTarget.value>=68 and d.setTarget.value<=72)) then
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={d.setTarget.zone}} )
		Global.call( "forwardFunction", {function_name="swapHandZones", data={d.setTarget.zone, d.setUser.zone, tableZ1, tableZ2}} )
		
		destroyObject(d.powerup)
		
		if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
			startLuaCoroutine( Global, "DoDealersCards" )
		end
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it while you also have cards, can only be played while busted.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Backstab"} )
end
