
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	Global.call( "forwardFunction", {function_name="clearBonus", data={}} )
	Global.call( "forwardFunction", {function_name="addBonus", data={}} )
	
	destroyObject(d.powerup)
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="StartBonus"} )
end
