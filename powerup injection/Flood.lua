
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #cards==0 or (d.setTarget.value>=21 and (d.setTarget.value<68 or d.setTarget.value>72)) then
		broadcastToColor("Must use powerup on a zone with cards in it. Cannot be used on a bust hand.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	-- Draw the original card
	Global.call( "forwardFunction", {function_name="forcedCardDraw", data={d.setTarget.zone}} )
	
	-- Find drawn card
	local drawnCard = Global.getVar("lastCard")
	if not drawnCard then -- Something went wrong, consume powerup anyway
		destroyObject(d.powerup)
		if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
			startLuaCoroutine( Global, "DoDealersCards" )
		end
		return true
	end
	
	-- Reward counter stuff
	local cardName = drawnCard.getName()
	local cardValue = (Global.getTable("cardNameTable") or {})[cardName]
	local dlr = sets[1].value
	local rewards = 0
	
	-- Copy card to hands
	local handSets = {}
	for i=2,#sets do
		local curSet = sets[i]
		if curSet.color~=d.setTarget.color and curSet.count>0 and curSet.value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={curSet.zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={curSet.zone}} ) or {}
			if #find>0 or #decks>0 then
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={curSet.zone, #find+1}} )
				
				local clone = drawnCard.clone({position=pos, smooth=false})
				clone.setPosition(pos)
				clone.setRotation({0,0,0})
				clone.lock()
				
				if curSet.value>21 and (curSet.value<68 or curSet.value>72) then -- Bust
					if cardName=="Joker" or curSet.count==4 then -- Now a win or 5 card push
						rewards = rewards + 1
					end
				elseif (dlr<=21 or dlr==69) and curSet.value<=dlr then
					if cardName=="Joker" then
						rewards = rewards + 1
					elseif cardValue then
						local newValue = curSet.value + cardValue
						
						if cardValue==0 then
							newValue = newValue + 1
							if newValue<=21 then newValue = newValue + 10 end
						end
						
						if newValue<=21 then
							if (newValue>dlr) or (newValue==dlr and curSet.value<dlr) then
								rewards = rewards + 1
							end
						end
					end
				end
			end
		end
	end
	
	-- Give rewards
	local settings = Global.getTable("hostSettings")
	local MultiHelp = settings.bMultiHelpRewards and (settings.bMultiHelpRewards.getDescription()=="true") -- Allow multiple rewards for one powerp use?
	for i=1,rewards do 
		Global.call( "forwardFunction", {function_name="giveReward", data={"Help", d.setUser.zone}} )
		if not MultiHelp then break end -- One reward max, exit loop
	end
	
	-- Restart dealer if appropriate
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	destroyObject(d.powerup)
	return true
end

function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="Flood"} )
end
