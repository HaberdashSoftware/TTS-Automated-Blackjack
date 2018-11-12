
local function doAltClear(user, target, powerup, name)
	Global.call( "forwardFunction", {function_name="clearCards", data={target.zone}} )
	
	local pos = Global.call("forwardFunction", {function_name="findPowerupPlacement", data={target.zone, 1}})
	local clone = powerup.clone({position = pos})
	clone.setPosition(pos)
	clone.setRotation({0,0,0})
	clone.setLock(true)
	clone.setColorTint( stringColorToRGB(user.color) or {1,1,1} )
	
	clone.setLuaScript("")
	clone.setName(name)
end
local effect = {
	function(userSet, targetSet, pwup) -- Bust
		doAltClear(userSet, targetSet, pwup, pwup.getName().. " (Bust)")
	end,
	function(userSet, targetSet, pwup) -- Blackjack
		doAltClear(userSet, targetSet, pwup, pwup.getName().. " (Blackjack)")
	end,
	function(userSet, targetSet, pwup) -- Bust
		doAltClear(userSet, targetSet, pwup, pwup.getName().. " (Joker)")
	end,
	function(userSet, targetSet, pwup) -- Exit
		Global.call( "forwardFunction", {function_name="clearCards", data={targetSet.zone}} )
	end,
	function(userSet, targetSet, pwup) -- Redraw
		Global.call( "forwardFunction", {function_name="clearCards", data={targetSet.zone}} )
		Global.call( "forwardFunction", {function_name="dealPlayer", data={targetSet.zone, {1,2}}} )
	end,
	function(userSet, targetSet, pwup) -- Draw One
		Global.call( "forwardFunction", {function_name="forcedCardDraw", data={targetSet.zone}} )
	end,
	function(userSet, targetSet, pwup) -- Draw Two
		local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={targetSet.zone}} ) or {}
		local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={targetSet.zone}} ) or {}
		Global.call( "forwardFunction", {function_name="dealPlayer", data={targetSet.zone, {#cards+#decks+1,#cards+#decks+2}}} )
	end,
	function(userSet, targetSet, pwup) -- Remove Card
		local cards = Global.call( "forwardFunction", {function_name="findCardsInZone", data={targetSet.zone}} ) or {}
		local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={targetSet.zone}} ) or {}
		
		local cardObjects = {}
		for i=1,#cards do table.insert(cardObjects,cards[i]) end
		for i=1,#decks do -- Multiple entires based on number of cards
			for n = 1,decks[i].getQuantity() do table.insert(cardObjects, decks[i]) end
		end
		
		local card = cards[ math.random(1, #cards) ] -- Failsafe
		local obj = cardObjects[ math.random(1, #cardObjects) ]
		if obj.tag=="Deck" then
			obj.shuffle()
			
			local pos = obj.getPosition()
			pos.y = pos.y+2
			card = obj.takeObject({position=pos})
		else
			card = obj
		end
		
		if card then
			destroyObject(card)
		end
	end,
}
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local tableZ1 = Global.call( "forwardFunction", {function_name="findCardsInZone", data={d.setTarget.zone}} )
	local decksOne = Global.call( "forwardFunction", {function_name="findDecksInZone", data={d.setTarget.zone}} ) for i=1,#decksOne do table.insert(tableZ1, decksOne[i]) end
	
	if #tableZ1==0 or (d.setTarget.value>21 and not (d.setTarget.value>=68 and d.setTarget.value<=72)) then
		broadcastToColor("Must use powerup on a zone with cards in it, cannot be played while busted.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local handSets = {}
	for i=2,#sets do
		if sets[i].count>0 and sets[i].value>0 then
			local find = Global.call( "forwardFunction", {function_name="findCardsInZone", data={sets[i].zone}} ) or {}
			local decks = Global.call( "forwardFunction", {function_name="findDecksInZone", data={sets[i].zone}} ) or {}
			if #find>0 or #decks>0 then
				table.insert( handSets, sets[i] )
			end
		end
	end
	
	if #handSets==0 then
		broadcastToColor("There must be at least one player hand to use this powerup.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	broadcastToAll("The table descends into chaos!", {1,0,0})
	
	for i=1,#handSets do
		effect[math.random(1,#effect)](d.setUser, handSets[i], d.powerup)
	end
	
	destroyObject(d.powerup)
	
	if d.setTarget.color=="Dealer" and Global.getVar("dealersTurn") then
		startLuaCoroutine( Global, "DoDealersCards" )
	end
	
	return true
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="Chaos"} )
	
	if string.match(self.getName(), " %(%.+%)$") then return end -- Duplicate obj, ignore
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName() .. " (Bust)"] = 100
	tbl[self.getName() .. " (Blackjack)"] = 69
	tbl[self.getName() .. " (Joker)"] = 68
	Global.setTable("cardNameTable", tbl)
end
