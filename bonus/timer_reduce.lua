
function onLoad()
	self.createButton({
		label="Activate", click_function="bonusRoundActivate", function_owner=self,
		position={0,0,0}, rotation={0,0,0}, width=450, height=450, font_size=150
	})
end
function bonusRoundActivate(o,c)
	if c~="Black" and not Player[c].admin then return end
	if Global.getVar("activateBonus") then Global.Call("forwardFunction", {function_name="activateBonus", data={self}} ) end
end

function onDeploy()
	self.clearButtons()
	
	local bonusTimer = Global.getVar("bonusTimer")
	local setTime = math.max(0, ((bonusTimer and bonusTimer~=NULL and bonusTimer.getValue()) or 0)-900 )
	Global.call( "forwardFunction", {function_name="resetTimer", data={setTime}} )
	
	self.setColorTint({r=1,g=1,b=1})
end
