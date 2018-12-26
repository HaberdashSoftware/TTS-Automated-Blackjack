
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

Expired = false
function onDeploy()
	self.clearButtons()
	
	self.setColorTint({r=1,g=1,b=1})
	Expired = false
end
function preRoundStart()
	if Expired or not Global.call("GetSetting", {"Minigame.Automated", true}) then return end
	Expired = true
	self.setColorTint({r=0.05,g=0.05,b=0.05})
	self.setDescription("Ended")
	
	Global.call( "forwardFunction", {function_name="beginMiniGame", data={}} )
	
	return true
end
