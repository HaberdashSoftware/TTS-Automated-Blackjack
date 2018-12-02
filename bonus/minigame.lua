
Expired = false
function onDeploy()
	self.setColorTint({r=1,g=1,b=1})
	Expired = false
end
function preRoundStart()
	if Expired then return end
	Expired = true
	self.setColorTint({r=0.05,g=0.05,b=0.05})
	self.setDescription("Ended")
	
	Global.call( "forwardFunction", {function_name="beginMiniGame", data={}} )
	
	return true
end
