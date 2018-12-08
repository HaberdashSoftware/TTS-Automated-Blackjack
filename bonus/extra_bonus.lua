
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
