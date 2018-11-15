PrestigeChip = "$1 Duotrigintillion"
PrestigeLevel = 8

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
	
	if Player[data.set.color].seated then
		local plyData = Player[data.set.color]
		
		newGem.setDescription( ("%s - %s\n\n%s"):format(plyData.steam_id, plyData.steam_name, self.getDescription()) )
	end
	
	return true
end
