
function onDeploy()
	local bonusTimer = Global.getVar("bonusTimer")
	local setTime = math.max(0, ((bonusTimer and bonusTimer~=NULL and bonusTimer.getValue()) or 0)-900 )
	Global.call( "forwardFunction", {function_name="resetTimer", data={setTime}} )
	
	self.setColorTint({r=1,g=1,b=1})
end
