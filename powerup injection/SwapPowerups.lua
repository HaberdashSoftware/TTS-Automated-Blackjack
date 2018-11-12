
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local figurinesInZone = Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={d.setTarget.zone}} )
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksInZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )
	
	local figurinesInUserZone = Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={d.setUser.zone}} )
	local cardsInUserZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	local decksInUserZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} )
	if (#figurinesInZone~=0 and (#cardsInUserZone~=0 or #decksInUserZone~=0 or #figurinesInUserZone~=0)) or (#figurinesInUserZone~=0 and (#cardsInZone~=0 or #decksInZone~=0 or #figurinesInZone~=0)) then
		for i=1,#figurinesInZone do
			figurinesInZone[i].setPosition( Global.call("forwardFunction", {function_name="findPowerupPlacement", data={d.setUser.zone, i}}) )
		end
		for i=1,#figurinesInUserZone do
			figurinesInUserZone[i].setPosition( Global.call("forwardFunction", {function_name="findPowerupPlacement", data={d.setTarget.zone, i}}) )
		end
		
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with active powerups, or you must have active powerups on your zone.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="SwapPowerups"} )
end
