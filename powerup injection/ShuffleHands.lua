
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zonelocal sets = Global.getTable("objectSets")
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local tableZ2 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setUser.zone}} )
	
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} )
	local decksTwo = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setUser.zone}} )
	
	if (#tableZ1~=0 or #decksOne~=0) and (#tableZ2~=0 or #decksTwo~=0) and (d.setUser.value<=21 or (d.setUser.value>=68 and d.setUser.value<=72)) then
		local combined = {}
		local combinedDecks = {}
		
		for _,c in pairs(tableZ1) do table.insert( combined, c ) end
		for _,c in pairs(tableZ2) do table.insert( combined, c ) end
		for _,d in pairs(decksOne) do table.insert( combinedDecks, d ) end
		for _,d in pairs(decksTwo) do table.insert( combinedDecks, d ) end
		
		local userHandSize = 0
		local targetHandSize = 0
		
		for i=1,#combinedDecks do
			combinedDecks[i].shuffle()
			local quantity = combinedDecks[i].getQuantity()
			for n=1,quantity do
				if n==1 then -- Move deck to position first - Deck destroyed when second last card removd, this is effectively last card position
					if #combined==0 and i==#combinedDecks and n==quantity and (targetHandSize==0 or userHandSize==0) then
						if targetHandSize==0 then
							targetHandSize = targetHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, 1}} )
							combined[i].setPosition(pos)
						elseif userHandSize==0 then
							userHandSize = userHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, 1}} )
							combined[i].setPosition(pos)
						end
					else
						if math.random(1,2)==1 then -- User Hand
							userHandSize = userHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, userHandSize}} )
							combinedDecks[i].setPosition(pos)
						else -- Target Hand
							targetHandSize = targetHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, targetHandSize}} )
							combinedDecks[i].setPosition(pos)
						end
					end
				else
					if i==#combinedDecks and n==quantity then
						if targetHandSize==0 then
							targetHandSize = targetHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, targetHandSize}} )
							local card = combinedDecks[i].takeObject({position=pos})
							Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setTarget, isStarter=true, flip=true}}} )
							break
						elseif userHandSize==0 then
							userHandSize = userHandSize + 1
							
							local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, userHandSize}} )
							local card = combinedDecks[i].takeObject({position=pos})
							Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setUser, isStarter=true, flip=true}}} )
							break
						end
					end
					
					if math.random(1,2)==1 then -- User Hand
						userHandSize = userHandSize + 1
						
						local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, userHandSize}} )
						local card = combinedDecks[i].takeObject({position=pos})
						Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setUser, isStarter=userHandSize<=2, flip=true}}} )
					else -- Target Hand
						targetHandSize = targetHandSize + 1
						
						local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, targetHandSize}} )
						local card = combinedDecks[i].takeObject({position=pos})
						Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={card, {targetPos=pos, set=d.setTarget, isStarter=targetHandSize<=2, flip=true}}} )
					end
				end
			end
		end
		
		for i=1,#combined do
			if i==#combined then
				if targetHandSize==0 then
					local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, 1}} )
					combined[i].setPosition(pos)
					Wait.frames(function()
						Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={combined[i], {targetPos=pos, set=d.setTarget, isStarter=true, flip=true}}} )
					end, 1)
					break
				elseif userHandSize==0 then
					local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, 1}} )
					combined[i].setPosition(pos)
					
					Wait.frames(function()
						Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={combined[i], {targetPos=pos, set=d.setUser, isStarter=true, flip=true}}} )
					end, 1)
					break
				end
			end
			
			if math.random(1,2)==1 then -- User Hand
				userHandSize = userHandSize + 1
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setUser.zone, userHandSize}} )
				combined[i].setPosition(pos)
				Wait.frames(function()
					Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={combined[i], {targetPos=pos, set=d.setUser, isStarter=userHandSize<=2, flip=true}}} )
				end, 1)
			else -- Target Hand
				targetHandSize = targetHandSize + 1
				
				local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, targetHandSize}} )
				combined[i].setPosition(pos)
				Wait.frames(function()
					Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={combined[i], {targetPos=pos, set=d.setTarget, isStarter=targetHandSize<=2, flip=true}}} )
				end, 1)
			end
		end
		
		Wait.frames(function()
			destroyObject(d.powerup)
		end, 1)
		
		if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
			startLuaCoroutine( Global, "DoDealersCards" )
		end
		
		return true
	else
		broadcastToColor("Must use powerup on a zone with cards in it while you also have cards, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
	end
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Shuffle Hands"} )
end
