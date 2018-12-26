-- Unique powerup from Die of Fate
local objData = {
	scale = {0.72,0.72,0.72},
	mesh = {mesh="http://pastebin.com/raw.php?i=jSYpUdgu", diffuse="https://i.imgur.com/p0GYtxY.png", material=1, specular_intensity=0.05, specular_sharpness=3, type=1},
}
local function doAddLaughing(user)
	local newObj = spawnObject({type = "Custom_Model"})
	newObj.setCustomObject(objData.mesh)
	
	local figurines = #(Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={user.zone}} ) or {}) + 1
	local setPos = Global.call( "forwardFunction", {function_name="findPowerupPlacement", data={user.zone, figurines}} ) or user.zone.getPosition()
	newObj.setPosition(setPos)
	
	newObj.setRotation( {0,0,0} )
	newObj.setLock( true )
	
	newObj.setName("Laughing Skull")
	newObj.setDescription( "You have been freed from the Cracked Skull's Curse!" )
	newObj.setScale( objData.scale or {1,1,1} )
	newObj.setColorTint( stringColorToRGB(user.color) or {1,1,1} )
end
function powerupUsed( d )
	if d.setTarget.count==0 or d.setTarget.value==0 then return end
	
	local foundPlayers = {}
	local objectSets = Global.getTable("objectSets")
	for i=2,#objectSets do
		if objectSets[i].color~=d.setTarget.color and objectSets[i].count>0 and objectSets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={objectSets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={objectSets[i].zone}} ) or {}
			if #find>0 or #decks>0 then
				table.insert( foundPlayers, objectSets[i] )
			end
		end
	end
	if #foundPlayers<3 then
		broadcastToColor("There must be at least three other hands with cards to use this powerup.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	math.randomseed( os.time() )
	local bustCount = math.random(1, math.min(20, #foundPlayers))
	
	printToAll( ("Powerup event: %s has sold their soul to the Cracked Skull! %i other player%s bust."):format(d.setUser.color, bustCount or 0, bustCount==1 and " has" or "s have"), {0.5,0.5,1})
	
	Global.call( "forwardFunction", {function_name="clearPlayerActions", data={d.setTarget.zone}} )
	Global.call( "forwardFunction", {function_name="clearCards", data={d.setTarget.zone}} )
	
	if Global.getVar("currentPlayerTurn")==d.setTarget.color then Global.call("forwardFunction", {function_name="playerStand", data={d.setTarget.btnHandler, "Black"}}) end
	
	while bustCount>0 and #foundPlayers>0 do
		local chosen = math.random(1,#foundPlayers)
		local set = foundPlayers[chosen]
		
		bustCount = bustCount-1
		table.remove(foundPlayers, chosen)
		
		Global.call( "forwardFunction", {function_name="clearCards", data={set.zone}} )
		
		local pos = Global.call("forwardFunction", {function_name="findPowerupPlacement", data={set.zone, 1}})
		local clone = d.powerup.clone({position = pos})
		clone.setPosition(pos)
		clone.setLock(true)
		clone.setColorTint( stringColorToRGB(d.setUser.color) or {1,1,1} )
		clone.setLuaScript("")
		clone.setDescription("You have been claimed by the Cracked Skull's Curse!")
	end
	
	doAddLaughing(d.setUser)
	destroyObject(d.powerup)
	
	return false
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Self Only", effect="CrackedSkullCurse"}
	Global.setTable("powerupEffectTable", effectTable)
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 100
	tbl["Laughing Skull"] = 12
	Global.setTable("cardNameTable", tbl)
end
