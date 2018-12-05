
function powerupUsed( d )
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksInZone = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )
	
	if #cardsInZone==0 and #decksInZone==0 then
		broadcastToColor("Must use powerup on a zone with cards in it.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	if d.setTarget.color=="Dealer" then
		if d.setTarget.value==69 or (d.setTarget.count==4 and d.setTarget.value<=21) then
			local settings = Global.getTable("hostSettings")
			local MultiHelp = settings.bMultiHelpRewards and (settings.bMultiHelpRewards.getDescription()=="true")
			
			local sets = Global.getTable("objectSets")
			for i=2,#sets do
				local target = sets[i]
				if target.color~=d.setUser.color and target.UserColor~=d.setUser.color then
					local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={target.zone}} )
					local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={target.zone}} ) or {}  for i=1,#decks do table.insert(cardsInZone, decks[i]) end
					
					if #cardsInZone ~= 0 and target.value<d.setTarget.value then
						if d.setTarget.value==69 then -- Dealer blackjack
							if target.value<=21 or (target.value>=69 and target.value<=72) then -- All winning hands (except joker) are helped
								Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
								if not MultiHelp then break end
							end
						elseif target.value<=21 and target.value<=d.setTarget.value then -- Was losing/pushed, now winning
							Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
							if not MultiHelp then break end
						end
					end
				end
			end
		end
	elseif d.setTarget.color~=d.setUser.color and d.setTarget.UserColor~=d.setUser.color and d.setTarget.value>21 and (d.setTarget.value<68 or d.setTarget.value>72) and d.setTarget.count==4 then
		Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
	end
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Anyone", effectName="DoNothing"} )
end
