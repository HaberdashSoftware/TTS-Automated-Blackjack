
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #tableZ1==0 or (d.setTarget.value>21 and not (d.setTarget.value>=68 and d.setTarget.value<=72)) then
		broadcastToColor("Must use powerup on a zone with cards in it, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local potentialSwaps = {}
	for i=2,#sets do
		if sets[i].color~=d.setTarget.color and sets[i].count>0 and sets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={sets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={sets[i].zone}} ) or {}  for i=1,#decks do table.insert(find, decks[i]) end
			if #find>0 then
				table.insert( potentialSwaps, {sets[i], find} )
			end
		end
	end
	
	if #potentialSwaps==0 then
		broadcastToColor("There must be at least one other player hand to use this powerup.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local chosen = potentialSwaps[ math.random(1,#potentialSwaps) ]
	if chosen[1].color~="Dealer" and chosen[1].color~=d.setUser.color and chosen[1].UserColor~=d.setUser.color then
		if (chosen[1].value==71 and chosen[1].count==2) or (chosen[1].value==70 and chosen[1].count==3) then -- Triple seven/Double joker copied
			Global.call( "forwardFunction", {function_name="giveReward", data={"CopyJokers", d.setUser.zone}} )
		end
	end
	
	Global.call( "forwardFunction", {function_name="clearCardsOnly", data={d.setTarget.zone}} )
	Global.call( "forwardFunction", {function_name="cloneHandZone", data={chosen[1].zone, d.setTarget.zone}} )
	destroyObject(d.powerup)
	
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="CopyRandom"} )
end
