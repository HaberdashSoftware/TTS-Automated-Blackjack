
function powerupUsed( data ) -- data keys: setTarget zone, powerup object, setUser zone
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={data.setTarget.zone}} )
	local dlr = Global.getTable("objectSets")[1].value
	if #cardsInZone ~= 0 and (data.setTarget.value<=21 and data.setTarget.value<dlr and (dlr<=21 or dlr==69)) then
		if data.setTarget.color~=data.setUser.color and data.setTarget.UserColor~=data.setUser.color then
			Global.call( "forwardFunction", {function_name="giveReward", data={"Help", data.setUser.zone}} )
		end
		
		destroyObject(data.powerup)
		Global.call( "forwardFunction", {function_name="clearCards", data={data.setTarget.zone}} )
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it, also the targeted player must be losing and not busted.", data.setUser.color, {1,0.5,0.5})
	end
	
	return false
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Anyone", effectName="ClearHandTest"} )
end
