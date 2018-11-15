PrestigeChip = "$1 Octillion"
PrestigeLevel = 2

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
	
	-- Additional Rewards
	local chest = getObjectFromGUID("353a8f").takeObject({position = data.set.zone.getPosition()}) -- Silver Chest
	
	if Player[data.set.color].seated then
		local plyData = Player[data.set.color]
		chest.setName("Player save: " .. plyData.steam_name)
		chest.setDescription(plyData.steam_id)
		
		newGem.setDescription( ("%s - %s\n\n%s"):format(plyData.steam_id, plyData.steam_name, self.getDescription()) )
	end
	
	return true
end
