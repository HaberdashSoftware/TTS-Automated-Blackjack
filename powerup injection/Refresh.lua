
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local figurinesInZone = Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={d.setTarget.zone}} )
	if #figurinesInZone~=0 then
		local oldValue = d.setTarget.value or 0
		for i=1,#figurinesInZone do
			destroyObject(figurinesInZone[i])
		end
		
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with active powerups.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Anyone", effectName="Refresh"} )
end
