
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=1 then
		broadcastToColor("This powerup must be used during the \"Place Bets\" round phase.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local params = {}
	params.position = Global.getVar("bonusZone").getPosition()
	
	local autoMinigames =  Global.getVar("minigameBag").takeObject(params)
	autoMinigames.shuffle()
	
	Global.call( "forwardFunction", {function_name="setRoundState", data={1, 30}} )
	Global.setVar("minigame", autoMinigames.takeObject(params))
	Global.setVar("inMinigame", true)
	
	autoMinigames.destruct()
	
	destroyObject(d.powerup)
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="Force Minigame"} )
end
