-- Unique powerup from Cursed Deck
local CardScript = [[function ChooseCard(o,c)
	if c and ActivePlayer and (c~=ActivePlayer) and not Player[c].admin then
		broadcastToColor("You did not use this powerup.", c, {1,0.5,0.5})
		return
	end
	if not ActiveZone then
		broadcastToColor("Error: Could not find zone.", c, {1,0.5,0.5})
		return
	end
	
	for _,v in pairs(ActiveZone.getObjects()) do
		if v.tag=="Card" and v~=self and v.getName():sub(1,17)=="Deck's Blessing: " then
			destroyObject(v)
		end
	end
	
	
	local cardsInZone = Global.call( "forwardFunction", {function_name="findCardsInZone", data={ActiveZone}} )
	local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={ActiveZone, math.max(#cardsInZone-2, 1)}} )
	
	self.setPosition(pos)
	self.clearButtons()
	self.setName( self.getName():sub(18,-1) )
	Global.setVar("lastCard", self)
end]]
function powerupUsed( d )
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	if d.setTarget.count<=0 or d.setTarget.value<=0 then
		broadcastToColor("Must use on a hand that is in play.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	local deck = Global.getVar("mainDeck")
	if not deck then
		broadcastToColor("Could not find deck.", d.setUser.color, {1,0.5,0.5})
		return
	end
	if #deck.getObjects()<=10 then
		broadcastToColor("Not enough cards in deck.", d.setUser.color, {1,0.5,0.5})
		return
	end
	
	d.powerup.destruct()
	
	local params = {}
	params.position = {0, 2.5, 0}
	params.rotation = {0, 0, 0}
	params.smooth = false
	
	for i=1,3 do
		params.position = Global.call( "forwardFunction", {function_name="findCardPlacement", data={d.setTarget.zone, 3+i}} )
		params.position[2] = params.position[2] + 0.5
		
		local drawnCard = deck.takeObject(params)
		drawnCard.setName( "Deck's Blessing: " .. drawnCard.getName() ) -- Don't count unless it's chosen
		drawnCard.setLock( true )
		
		drawnCard.createButton({
			label="Select", click_function="ChooseCard", function_owner=drawnCard,
			position={-0.4, 1.1, -0.95}, rotation={0,0,0}, width=350, height=350, font_size=130
		})
		
		drawnCard.setLuaScript( CardScript )
		drawnCard.setVar( "ActivePlayer", d.setUser.color )
		drawnCard.setVar( "ActiveZone", d.setTarget.zone )
	end
	
	return true
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Self Only", effect="DecksBlessing"}
	Global.setTable("powerupEffectTable", effectTable)
end
