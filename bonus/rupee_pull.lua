
function onDeploy()
	self.createButton({
		label="Give", click_function="DoPull", function_owner=self,
		position={0,0,0}, rotation={0,0,0}, width=450, height=450, font_size=150
	})
	
	self.setColorTint({r=1,g=1,b=1})
end
function onRoundStart()
	GiveRupeePowerup()
	self.destruct()
end

function DoPull(o, color)
	if color == "Black" or Player[color].promoted or Player[color].host then
		Global.call( "forwardFunction", {function_name="deployRupees", data={}} )
		self.destruct()
	end
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
