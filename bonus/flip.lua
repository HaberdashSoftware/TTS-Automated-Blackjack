
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

IsActive = false
RoundsRemaining = 5
function onDeploy()
	self.clearButtons()
	
	IsActive = false
	
	self.setDescription( "In effect next hand." )
end
function onRoundStart()
	RoundsRemaining = RoundsRemaining - 1
	
	if RoundsRemaining<0 then
		Expire()
		return
	elseif RoundsRemaining==1 then
		self.setDescription( ("%i hand remaining"):format(RoundsRemaining) )
	elseif RoundsRemaining>0 then
		self.setDescription( ("%i hands remaining"):format(RoundsRemaining) )
	else
		self.setDescription( "Final Hand" )
	end
	
	self.setColorTint({r=1,g=1,b=1})
	
	IsActive = true
end
function onRoundEnd()
	if RoundsRemaining==0 then
		Expire()
	end
end
function isActive() if IsActive then return true end end

function Expire()
	IsActive = false
	RoundsRemaining = -1
	
	self.setColorTint({r=0.05,g=0.05,b=0.05})
	
	self.setDescription( ("Ended"):format(bonusDesc, RoundsRemaining) )
end

function isActive()
	if IsActive then return true end
end

function canFlip()
	if IsActive then return true end
end
