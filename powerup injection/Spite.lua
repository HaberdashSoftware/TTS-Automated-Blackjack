
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
		
	local sets = Global.getTable("objectSets")
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksInZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )  for i=1,#decksInZone do table.insert(cardsInZone, decksInZone[i]) end
	
	local cardsInUserZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	local decksInUserZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} ) for i=1,#decksInUserZone do table.insert(cardsInUserZone, decksInUserZone[i]) end
	if #cardsInZone~=0 and #cardsInUserZone~=0 and (d.setTarget.value<=21 or (d.setTarget.value>=68 and d.setTarget.value<=72)) and (d.setUser.value<=21 or (d.setUser.value>=68 and d.setUser.value<=72)) then
		if d.setTarget.color~=d.setUser.color and d.setTarget.UserColor~=d.setUser.color then
			local dealerValue = sets[1].value
			local v = Global.getTable("cardNameTable")[d.powerup.getName()] or 0
			
			if (d.setTarget.value>dealerValue and v<=dealerValue) or (d.setTarget.value==dealerValue and v<dealerValue) then
				if d.setUser.value<d.setTarget.value and (Global.getTable("hostSettings").bHostilePowerups and Global.getTable("hostSettings").bHostilePowerups.getDescription()=="false") then
					broadcastToColor("This powerup cannot be used to make another player lose.", setUser.color, {1,0.5,0.5})
					
					return false
				end
			elseif dealerValue<=21 and v>0 and (v<=21 and ((v>dealerValue and d.setTarget.value<=dealerValue) or (v>=dealerValue and d.setTarget.value<dealerValue))) or (d.setTarget.value<=dealerValue and v>=68 and v<=72) then
				Global.call( "forwardFunction", {function_name="Help", data={d.setUser.zone}} )
			end
		end
		
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={d.setTarget.zone}} )
		Global.call( "forwardFunction", {function_name="clearCardsOnly", data={d.setUser.zone}} )
		
		local numFigurines = #(Global.call( "forwardFunction", {function_name="findFigurinesInZone", data={d.setUser.zone}} ) or {})
		local pos = Global.call("forwardFunction", {function_name="findPowerupPlacement", data={d.setUser.zone, numFigurines+1}})
		local clone = d.powerup.clone({position = pos})
		clone.setPosition(pos)
		clone.setLock(true)
		clone.setColorTint( stringColorToRGB(d.setUser.color) or {1,1,1} )
		
		
		if Global.getVar("currentPlayerTurn")==d.setTarget.color then
			Global.call( "forwardFunction", {function_name="playerStand", data={d.setTarget.btnHandler,"Black"}} )
		elseif Global.getVar("currentPlayerTurn")==d.setUser.color then
			Global.call( "forwardFunction", {function_name="playerStand", data={d.setUser.btnHandler,"Black"}} )
		end
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it, cannot be played on a busted player.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Double Alt. Clear"} )
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 100
	Global.setTable("cardNameTable", tbl)
end
