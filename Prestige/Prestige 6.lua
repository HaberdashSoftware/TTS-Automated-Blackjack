PrestigeChip = "$1 Quattuorvigintillion"
PrestigeLevel = 6

function onLoad()
	Global.call("AddPrestige", {obj=self} )
end

function doPrestige(data)
	if not data.set then return end
	
	printToAll("Prestige: " .. data.set.color .. " has prestiged to " .. self.getName() .. "!", {0.5,1,0.5})
	
	-- Prestige Gem
	local newGem = self.clone({position=data.set.prestige.getPosition()})
	newGem.setLuaScript("")
	newGem.setLock(false)
	newGem.interactable = true
	
	return true
end
