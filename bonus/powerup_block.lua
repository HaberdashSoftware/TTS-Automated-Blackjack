
IsActive = false
RoundsRemaining = 5
function onDeploy()
	IsActive = false
	
	self.setDescription( "In effect next hand." )
end
function onRoundStart()
	self.setColorTint({r=1,g=1,b=1})
	
	IsActive = true
	RoundsRemaining = RoundsRemaining - 1
	
	if RoundsRemaining<0 then
		self.destruct()
		return
	elseif RoundsRemaining>0 then
		self.setDescription( ("%i hands remaining"):format(RoundsRemaining) )
	else
		self.setDescription( "Final Hand" )
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

local whitelist = {
	["Royal token"] = true, ["Reward token"] = true, ["Prestige token"] = true,
	["Random powerup draw"] = true, ["Random rupee pull"] = true, 
}
function canUsePowerup( data )
	if IsActive and not whitelist[data.powerup.getName()] then return false end
end
