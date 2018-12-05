
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local targetSet = d.setTarget
	local userSet = d.setUser
	
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={targetSet.zone}} )
	local tableZ2 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={userSet.zone}} )
	
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={targetSet.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	local decksTwo = Global.call( "forwardFunction", {function_name="findDecksInZone", data={userSet.zone}} ) for i=1,#decksTwo do table.insert(tableZ2, decksTwo[i]) end
	
	if #tableZ1 ~= 0 and #tableZ2 ~= 0 and (userSet.value>21 and not (userSet.value>=68 and userSet.value<=72)) and (targetSet.value<=21 or (targetSet.value>=68 and targetSet.value<=72)) then
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={targetSet.zone}} )
		Global.call( "forwardFunction", {function_name="swapHandZones", data={targetSet.zone, userSet.zone, tableZ1, tableZ2}} )
		
		destroyObject(d.powerup)
		
		if targetSet.color=="Dealer" and Global.getVar("dealersTurn") then
			startLuaCoroutine( Global, "DoDealersCards" )
		end
		
		local sets = Global.getTable("objectSets")
		local dlr = sets[1].value
		if targetSet.UserColor~=userSet.color and userSet.count>=5 and targetSet.count<5 and ((dlr<=21 or dlr==69) and dlr>targetSet.value) then
			Global.call( "forwardFunction", {function_name="giveReward", data={"Help", userSet.zone}} ) -- Used on losing player to give 5-card.
		end
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it while you also have cards, can only be played while you are bust.", userSet.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Backstab"} )
end
