
function onDeploy()
	self.setColorTint({r=1,g=1,b=1})
end
function preRoundStart()
	Global.call( "forwardFunction", {function_name="beginMiniGame", data={}} )
	self.destruct()
	
	return true
end
