
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

bonusDesc = "Earn 3x payout for every hand you win with 2 cards and no active powerups.\n\n"

IsActive = false
RoundsRemaining = 5
function onDeploy()
	self.clearButtons()
	
	IsActive = false
	
	self.setDescription( bonusDesc.."In effect next hand." )
end
function onRoundStart()
	RoundsRemaining = RoundsRemaining - 1
	
	if RoundsRemaining<0 then
		Expire()
		return
	elseif RoundsRemaining==1 then
		self.setDescription( ("%s%i hand remaining"):format(bonusDesc, RoundsRemaining) )
	elseif RoundsRemaining>0 then
		self.setDescription( ("%s%i hands remaining"):format(bonusDesc, RoundsRemaining) )
	else
		self.setDescription( bonusDesc.."Final Hand" )
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

function payoutMultiplier( data )
	if IsActive then
		local set = data.set
		local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={set.zone}} )
		
		if set.count<=2 and #cards==set.count then
			return (data.betMultiplier or 1) * 3
		end
	end
end
