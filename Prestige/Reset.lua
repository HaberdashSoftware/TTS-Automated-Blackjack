PrestigeChip = "$100 Tretrigintillion"
PrestigeLevel = 9 -- Change this to one more than your highest prestige

function onLoad()
	Global.call("AddPrestige", {obj=self} )
end

local ResetObjScript = [[PrestigeResetLevel = %u]]
local ResetPath = { -- Add your own objects here. 
	{name="Reset One", meshData={mesh="https://paste.ee/r/3JPfK", diffuse="http://www.littlewebhut.com/images/woodsample.jpg"}, scale = {1,1,1}},
	{name="Reset Two", meshData={mesh="https://paste.ee/r/3JPfK", diffuse="http://www.littlewebhut.com/images/woodsample.jpg"}, scale = {1,1,1}},
	{name="Reset Three", meshData={mesh="https://paste.ee/r/3JPfK", diffuse="http://www.littlewebhut.com/images/woodsample.jpg"}, scale = {1,1,1}},
	{name="Reset Four", meshData={mesh="https://paste.ee/r/3JPfK", diffuse="http://www.littlewebhut.com/images/woodsample.jpg"}, scale = {1,1,1}},
}
function doPrestige(data)
	if not data.set then return end
	
	
	local resetCount = 0
	
	local zoneObjects = data.set.zone.getObjects()
	local tableObjects = data.set.tbl.getObjects()
	local prestigeObjects = data.set.prestige.getObjects()
	
	for _,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
		for _, obj in ipairs(zone) do
			if obj then
				local objReset = obj.getVar("PrestigeResetLevel")
				if type(objReset)=="number" and objReset>resetCount then
					resetCount = objReset
				end
			end
		end
	end
	
	if resetCount==#ResetPath then
		broadcastToColor("Prestige: You have reached the maxmium prestige and resets.", data.set.color, {0.5,1,0.5})
		
		return false
	end
	
	printToAll("Prestige: " .. data.set.color .. " has reset their prestige!", {0.5,1,0.5})
	
	-- Prestige Gem
	local newGem = self.clone({position=data.set.prestige.getPosition()})
	newGem.setLuaScript("")
	newGem.setLock(false)
	newGem.interactable = true
	newGem.setName("New Player")
	
	local nextReset = ResetPath[resetCount+1]
	
	local resetAward = spawnObject({type = "Custom_Model"})
	resetAward.setCustomObject(nextReset.meshData)
	resetAward.setLuaScript(ResetObjScript:format(resetCount+1))
	resetAward.setName(nextReset.name)
	resetAward.setScale(scale)
	resetAward.setPosition(data.set.zone.getPosition())
	
	if Player[data.set.color].seated then
		resetAward.setDescription(Player[data.set.color].steam_id)
	end
	
	return true
end
