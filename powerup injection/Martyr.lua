
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) or {}
	for i=1,#decks do
		for n=1,decks[i].getQuantity() do table.insert(cardsInZone, decks[i]) end -- Add once for each card to get an accurate count
	end
	
	local dlr = sets[1].value
	if #cardsInZone ~= 0 and (d.setTarget.value<=21 and (d.setTarget.value>=dlr or (dlr>21 and dlr~=69)) or (d.setTarget.value>=68 and d.setTarget.value<=72)) then
		local blackjackCount = #cardsInZone
		
		Global.call( "forwardFunction", {function_name="clearBets", data={d.setTarget.zone, true}} )
		Global.call( "forwardFunction", {function_name="clearPlayerActions", data={d.setTarget.zone}} )
		Global.call( "forwardFunction", {function_name="clearCards", data={d.setTarget.zone}} )
		
		if Global.getVar("currentPlayerTurn")==d.setTarget.color then Global.call("forwardFunction", {function_name="playerStand", data={d.setTarget.btnHandler, "Black"}}) end
		
		local foundPlayers = {}
		
		local settings = Global.getTable("hostSettings")
		local MultiHelp = settings.bMultiHelpRewards and (settings.bMultiHelpRewards.getDescription()=="true")
		for i=2,#sets do
			local target = sets[i]
			if target.color~=d.setUser.color then
				local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={target.zone}} )
				local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={target.zone}} ) or {}  for i=1,#decks do table.insert(cardsInZone, decks[i]) end
				
				if #cardsInZone~=0 then
					table.insert(foundPlayers, target)
				end
			end
		end
		
		local foundOther = false
		while blackjackCount>0 and #foundPlayers>0 do
			local chosen = math.random(1,#foundPlayers)
			local set = foundPlayers[chosen]
			
			blackjackCount = blackjackCount-1
			table.remove(foundPlayers, chosen)
			
			if set.UserColor~=d.setUser.color and (dlr<=21 and dlr>=set.value) then
				if MultiHelp then
					Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
				end
				foundOther = true
			end
			
			Global.call( "forwardFunction", {function_name="clearCards", data={set.zone}} )
			
			local pos = Global.call("forwardFunction", {function_name="findPowerupPlacement", data={set.zone, 1}})
			local clone = d.powerup.clone({position = pos})
			clone.setPosition(pos)
			clone.setLock(true)
			clone.setColorTint( stringColorToRGB(d.setUser.color) or {1,1,1} )
			clone.setLuaScript("")
		end
		
		if foundOther and not MultiHelp then Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} ) end
		
		destroyObject(d.powerup)
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it, the targeted player must be winning and not bust.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="MartyrBlackjackOthers"} )
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 69
	Global.setTable("cardNameTable", tbl)
end
