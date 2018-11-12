
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if string.match(d.powerup.getName(), " %(%-%d%d?%)$") then -- Already used then unlocked, but not renamed? Silly admin
		return Global.call( "forwardFunction", {function_name="activatePowerupEffect", data={"Card Mod", d.setTarget, d.powerup, d.setUser}} )
	end
	
	-- Okay, this is pretty ugly. Let's hope it works!
	math.randomseed( os.time() )
	local value = math.floor(math.random(-10, -0.01)) -- Slightly weighted against -1, but that's difficult to avoid. It's random enough.
	
	local clone = d.powerup.clone(params)
	clone.setLock(false) -- We'll use lock status to determine whether it was used successfully
	clone.setName( ("%s (%i)"):format(d.powerup.getName(), value) )
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
	Global.call("AddPowerup", {obj=self, who="Anyone", effectName="Random Card Mod"} )
	
	if string.match(self.getName(), " %(%-?%d+%)$") then return end -- Duplicate obj, ignore
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = -1 -- Failsafe is -1, because 0 counts as an ace
	for i=-1,-10,-1 do
		tbl[self.getName().." ("..tostring(i)..")"] = i
	end
	Global.setTable("cardNameTable", tbl)
end
