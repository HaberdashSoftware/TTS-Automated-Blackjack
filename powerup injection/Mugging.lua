
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	local tableZ2 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	local decksTwo = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} ) for i=1,#decksTwo do table.insert(tableZ2, decksTwo[i]) end
	
	if #tableZ1==0 or #tableZ2==0 or (d.setUser.value>21 and not (d.setUser.value>=68 and d.setUser.value<=72)) then
		broadcastToColor("Must use powerup on a zone with cards in it, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	Global.call( "forwardFunction", {function_name="clearCards", data={d.setUser.zone}} )
	Global.call( "forwardFunction", {function_name="cloneHandZone", data={d.setTarget.zone, d.setUser.zone}} )
	Global.call( "forwardFunction", {function_name="forcedCardDraw", data={d.setTarget.zone}} )
	
	destroyObject(d.powerup)
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Mugging"} )
end
