-- Unique powerup from Hunt Master
function powerupUsed( d )
	if d.setTarget.value>=21 or d.setTarget.count==0 then
		broadcastToColor("This powerup can only be used on a hand with value less than 21.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	math.randomseed( os.time() )
	local value = math.floor(math.random(1, 21-d.setTarget.value))
	
	local clone = d.powerup.clone(params)
	clone.setLock(false) -- We'll use lock status to determine whether it was used successfully
	clone.setName( ("%s (%+i)"):format(d.powerup.getName(), value) )
	clone.setLuaScript( ([===[function getCardValue()
		return (%i)
	end]===]):format(value) )
	
	Global.call( "forwardFunction", {function_name="activatePowerupEffect", data={"Card Mod", d.setTarget, clone, d.setUser}} ) -- Hijack function
	
	if clone.getLock() then -- Success!
		destroyObject(d.powerup)
	else -- Failure!
		destroyObject(clone)
	end
	
	return false -- In any case, tell the global script we failed. This prevents double messages.
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Anyone", effect="Venison"}
	Global.setTable("powerupEffectTable", effectTable)
end
