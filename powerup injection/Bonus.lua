
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	Global.call( "forwardFunction", {function_name="clearBonus", data={}} )
	-- Global.call( "forwardFunction", {function_name="bonusRound", data={}} )
	
	local bonusTable = Global.getTable("bonusTable")
	local bonusZone = Global.getVar("bonusZone")
	
	local chosenBonus = math.random(1, #bonusTable)
	local params = {}
	params.position = bonusZone.getPosition()
	params.position.y = params.position.y - 1.7
	params.callback = "activateBonus"
	params.callback_owner = Global
	bonusObject = bonusTable[chosenBonus].takeObject(params)
	bonusObject.setColorTint({r=0.25,g=0.25,b=0.25})
		
	Global.setVar("chosenBonus", chosenBonus)
	Global.setVar("bonusObject", bonusObject)
	
	destroyObject(d.powerup)
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="StartBonus"} )
end
