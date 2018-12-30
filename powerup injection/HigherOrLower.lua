-- Unique powerup from Higher or Lower
function powerupUsed( d )
	if string.match(d.powerup.getName(), " %([%-%+]%d%d?%)$") then -- Already used then unlocked, but not renamed? Silly admin
		return Global.call( "forwardFunction", {function_name="activatePowerupEffect", data={"Card Mod", d.setTarget, d.powerup, d.setUser}} )
	end
	if (d.setTarget.value==21 and not d.setTarget.soft) or d.setTarget.value<=0 or (d.setTarget.value>=68 and d.setTarget.value<=72) then
		broadcastToColor("This hand can't be improved.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	local value = 21 - (d.setTarget.value or 21)
	if d.setTarget.soft then value = math.abs(value) + 10 end
	
	math.randomseed( os.time() )
	if math.random(1,2)==2 then value = -value end
	local name = ("%s (%+i)"):format(d.powerup.getName(), value)
	
	local tbl = Global.getTable("cardNameTable")
	tbl[name] = value
	Global.setTable("cardNameTable", tbl)
	
	local clone = d.powerup.clone(params)
	clone.setLock(false) -- We'll use lock status to determine whether it was used successfully
	clone.setName( name )
	clone.setLuaScript("")
	
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
	effectTable[self.getName()] = {who="Anyone", effect="HigherOrLower"}
	Global.setTable("powerupEffectTable", effectTable)
end
