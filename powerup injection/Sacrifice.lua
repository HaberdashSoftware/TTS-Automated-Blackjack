
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) or {}  for i=1,#decks do table.insert(cardsInZone, decks[i]) end
	
	local dlr = sets[1].value
	if #cardsInZone ~= 0 and (d.setTarget.value<=21 and (d.setTarget.value>=dlr or (dlr>21 and dlr~=69) or (d.setTarget.value>=68 and d.setTarget.value<=72))) then
		local foundPlayers = 0
		
		local settings = Global.getTable("hostSettings")
		local MultiHelp = settings.bMultiHelpRewards and (settings.bMultiHelpRewards.getDescription()=="true")
		for i=2,#sets do
			local target = sets[i]
			if target.color~=d.setUser.color and target.UserColor~=d.setUser.color then
				local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={target.zone}} )
				local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={target.zone}} ) or {}  for i=1,#decks do table.insert(cardsInZone, decks[i]) end
				
				if #cardsInZone ~= 0 and target.value>21 and not (target.value>=68 and target.value<=72) then
					foundPlayers = foundPlayers + 1
					
					if MultiHelp then Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) end
					
					if target.color~=d.setUser.color and target.UserColor~=d.setUser.color then
						foundOther = true
					end
					
					Global.call( "forwardFunction", {function_name="clearCards", data={target.zone}} )
				end
			end
		end
		
		if foundPlayers>0 then
			if not MultiHelp then Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) end
			Global.call( "forwardFunction", {function_name="clearCards", data={d.setTarget.zone}} )
			
			local tbl = {} for i=1,foundPlayers do table.insert(tbl, i) end
			Global.call( "forwardFunction", {function_name="dealPlayer", data={d.setTarget.color, tbl}} )
			
			destroyObject(d.powerup)
			
			return true
		else
			broadcastToColor("This powerup can only be used when there are other busted players.", d.setUser.color, {1,0.5,0.5})
		end
	else
		broadcastToColor("Must use powerup on a zone with cards in it, also the targeted player must be winning and not busted.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="SacrificeSaveAll"} )
end
