
Expired = false
function onDeploy()
	self.setColorTint({r=1,g=1,b=1})
	Expired = false
end
function preRoundStart()
	if Expired then return end
	Expired = true
	self.setColorTint({r=0.05,g=0.05,b=0.05})
	self.setDescription("Ended")
	
	GiveRupeePowerup()
end

local desc = "To use, drop into your own zone while you are not in play."
function GiveRupeePowerup()
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		seated[seated[i]] = true
		seated[i] = nil
	end
	
	local sets = Global.getTable("objectSets")
	for i=#sets,1,-1 do
		if seated[sets[i].color] then
			local pos = sets[i].zone.positionToWorld({0.5,-0.4,-0.5})
			
			local clone = self.clone({position = pos})
			clone.setPosition(pos)
			clone.setLock(false)
			clone.setColorTint( {1,1,1} )
			clone.setLuaScript("")
			
			clone.setName( "Random rupee pull" )
			clone.setDescription( ("%s - %s\n\n%s"):format(Player[sets[i].color].steam_id, Player[sets[i].color].steam_name, desc) )
		end
	end
end
