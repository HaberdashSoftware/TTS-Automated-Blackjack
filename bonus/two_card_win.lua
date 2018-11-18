
bonusDesc = "Earn 3x payout for every hand you win with 2 cards and no active powerups.\n\n"

IsActive = false
RoundsRemaining = 5
function onDeploy()
	IsActive = false
	
	self.setDescription( bonusDesc.."In effect next hand." )
end
function onRoundStart()
	self.setColorTint({r=1,g=1,b=1})
	
	IsActive = true
	RoundsRemaining = RoundsRemaining - 1
	
	if RoundsRemaining<0 then
		self.destruct()
		return
	elseif RoundsRemaining>0 then
		self.setDescription( ("%s%i hands remaining"):format(bonusDesc, RoundsRemaining) )
	else
		self.setDescription( bonusDesc.."Final Hand" )
	end
end
function onRoundEnd()
	if RoundsRemaining==0 then
		self.destruct()
	end
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
