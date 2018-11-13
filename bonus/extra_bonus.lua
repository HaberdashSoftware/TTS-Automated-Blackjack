
function onDeploy()
	self.setColorTint({r=1,g=1,b=1})
	
	local pos = self.getPosition()
	pos.z = pos.z - 0.75
	
	self.setPosition( pos )
	
	pos.z = pos.z + 1.5
	pos.x = pos.x + 1
	
	Global.call( "forwardFunction", {function_name="addBonus", data={pos}} )
	pos.x = pos.x - 2
	Global.call( "forwardFunction", {function_name="addBonus", data={pos}} )
end
