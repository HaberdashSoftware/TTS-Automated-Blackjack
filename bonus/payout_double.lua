
IsActive = false
RoundsRemaining = 5
function onDeploy()
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

function payoutMultiplier( data )
	if IsActive then
		local set = data.set
		local defaultMult = data.betMultiplier
		
		return defaultMult * 2
	end
end
