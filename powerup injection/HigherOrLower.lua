-- Unique powerup from Die of Fate
local cardOrder = {"Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"}
function powerupUsed( d )
	if Global.getVar("roundStateID")~=2 and Global.getVar("roundStateID")~=3 then return end
	
	local sets = Global.getTable("objectSets")
	local lastCard = Global.getVar( "lastCard" )
	if (not lastCard) or (lastCard==nil) then
		broadcastToColor("Could not find last card. Has it been discarded?", d.setUser.color, {1,0.5,0.5})
		return false
	end
	if lastCard.getName()=="Joker" then
		broadcastToColor("This powerup cannot modify a Joker.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	local cardID
	for i=1,#cardOrder do
		if cardOrder[i]==lastCard.getName() then
			if math.random(1,2)==1 then
				cardID = (i==#cardOrder) and 1 or (i+1)
			else
				cardID = (i==1) and #cardOrder or (i-1)
			end
		end
	end
	
	if not cardID then
		broadcastToColor("This powerup cannot modify that card.", d.setUser.color, {1,0.5,0.5})
		return false
	end
	
	
	local pos = d.powerup.getPosition()
	local allDecks = Global.getVar("deckBag").takeObject({pos.x, pos.y+5, pos.z})
	allDecks.shuffle()
	local deck = allDecks.takeObject({pos.x, pos.y+6, pos.z})
	deck.shuffle()
	allDecks.destruct()
	
	local deckCards = deck.getObjects()
	
	-- Find Card
	local foundCard
	for i=1,#deckCards do
		if deckCards[i].nickname==cardOrder[cardID] then
			foundCard = deck.takeObject({index=deckCards[i].index, position={pos.x, pos.y+8, pos.z}})
			break
		end
	end
	
	if foundCard then
		-- Store data
		local pos = lastCard.getPosition()
		local rot = lastCard.getRotation()
		local set = lastCard.getTable("blackjack_playerSet")
		lastCard.destruct()
		
		-- Position Card
		foundCard.setPosition(pos)
		foundCard.setRotation(rot)
		
		Global.setVar( "lastCard", foundCard )
		Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={foundCard, {targetPos=pos, set=set, isStarter=set, flip=true}}} )
	end
	
	deck.destruct()
	destroyObject(d.powerup)
	
	return true
end
function onLoad()
	local effectTable = Global.getTable("powerupEffectTable")
	effectTable[self.getName()] = {who="Self Only", effect="CrackedSkullCurse"}
	Global.setTable("powerupEffectTable", effectTable)
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 100
	tbl["Laughing Skull"] = 12
	Global.setTable("cardNameTable", tbl)
end
