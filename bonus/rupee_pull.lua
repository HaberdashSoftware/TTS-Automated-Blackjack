
function onDeploy()
	self.setColorTint({r=1,g=1,b=1})
end
function onRoundStart()
	GiveRupeePowerup()
	self.destruct()
end

function GiveRupeePowerup()
	local seated = getSeatedPlayers()
	for i=1,#seated do -- Convert to reference table, saves us looping multiple times
		seated[seated[i]] = true
		seated[i] = nil
	end
	
	local sets = Global.getTable("objectSets")
	for i=#sets,1,-1 do
		if seated[sets[i].color] then
			local pos = sets[i].zone.getPosition()
			pos.y = pos.y + 2
			
			local clone = self.clone({position = pos})
			clone.setPosition(pos)
			clone.setLock(false)
			clone.setColorTint( {1,1,1} )
			clone.setLuaScript("")
			
			clone.setName( "Random rupee pull" )
			clone.setDescription( Player[sets[i].color].steam_id .." - ".. Player[sets[i].color].steam_name )
		end
	end
end
