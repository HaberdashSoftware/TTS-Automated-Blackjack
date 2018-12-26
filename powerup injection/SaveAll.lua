
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local dlr = sets[1].value
	
	local MultiHelp = Global.call("GetSetting", {"Powerups.MultiHelp", true})
	
	local found = false
	local foundOther = false
	for i=2,#sets do
		local target = sets[i]
		local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={target.zone}} )
		local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={target.zone}} ) or {}  for i=1,#decks do table.insert(cardsInZone, decks[i]) end
		
		if target.color~=d.setUser.color and target.UserColor~=d.setUser.color and #cardsInZone ~= 0 and (target.value<=21 and target.value<dlr and (dlr<=21 or dlr==69)) then
			found = true
			
			if MultiHelp then Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) end
			
			if target.color~=d.setUser.color and target.UserColor~=d.setUser.color then
				foundOther = true
			end
			
			Global.call( "forwardFunction", {function_name="clearCards", data={target.zone}} )
		end
	end
	
	if found then
		if not MultiHelp then Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) end
		destroyObject(d.powerup)
		return true
	end
	
	broadcastToColor("Must use powerup when there is at least one player losing and not busted.", d.setUser.color, {1,0.5,0.5})
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="SaveAll"} )
end
