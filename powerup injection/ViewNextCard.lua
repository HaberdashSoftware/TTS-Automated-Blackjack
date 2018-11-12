
ActiveCard = nil
function powerupUsed( d ) -- data keys: setTarget zone, powerup object, setUser zone
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	if ActiveCard then ActiveCard.destruct() end
	
	local deck = Global.getVar("mainDeck")
	if not deck then
		broadcastToColor("Could not find deck.", d.setUser.color, {1,0.5,0.5})
		return
	end
	local nextCard = (deck.getObjects()[1] or {}).nickname or ""
	
	d.powerup.destruct()
	
	printToAll("Powerup event: " ..d.setUser.color.. " used " ..d.powerup.getName().. ".", {0.5,0.5,1})
	printToAll("The next card is: "..tostring(nextCard)..".", {0.5,0.5,1})
	
	local params = {}
	params.position = {0, 2.5, 0}
	params.rotation = {0, 0, 0}
	
	local cloneDeck = deck.clone(params)
	ActiveCard = cloneDeck.takeObject(params)
	ActiveCard.lock()
	cloneDeck.destruct()
	
	-- Timer.create({identifier='pwup_RemoveActiveCard', function_name='removeActiveCard', delay=4})
	Timer.create({identifier=d.powerup.getGUID()..'_ViewNext_RemoveActiveCard', function_owner = Global, function_name='forwardFunction', delay=4, parameters={function_name="destroyObject", data={ActiveCard}}})
	
	return
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="ViewNextCard"} )
end
