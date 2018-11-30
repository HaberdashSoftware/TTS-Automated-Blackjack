

local cardDestruct = [[
function onLoad()
	expireTime = os.time()+4
end
function onUpdate()
	if expireTime and os.time()>expireTime then destroyObject(self) end
end
function onObjectEnterContainer(bag,o)
	if o~=self then return end
	
	destroyObject(self)
	
	local contents = bag.getObjects()
	local targetPos = bag.getPosition()
	targetPos.y = targetPos.y + 2
	for i=#contents,1,-1 do
		if contents[i].lua_script==self.getLuaScript() then
			local obj = bag.takeObject({index=contents[i].index, position=targetPos})
			destroyObject(obj)
		end
	end
end
]]
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
	params.rotation = {0, 0, 180}
	
	local cloneDeck = deck.clone(params)
	
	params.rotation[3] = 0
	ActiveCard = cloneDeck.takeObject(params)
	ActiveCard.lock()
	ActiveCard.setLuaScript(cardDestruct)
	cloneDeck.destruct()
	
	return
end
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Self Only", effectName="ViewNextCard"} )
end
