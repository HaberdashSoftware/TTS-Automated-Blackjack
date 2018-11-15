
bonusDesc = "Every player hand starts with a single Royal or Ace.\n\n"

IsActive = false
RoundsRemaining = 5
function onDeploy()
	IsActive = false
	
	self.setDescription( bonusDesc.."In effect next hand." )
end
function onRoundStart()
	self.setColorTint({r=1,g=1,b=1})
	
	IsActive = true
	RoundsRemaining = RoundsRemaining - 1
	
	if RoundsRemaining<0 then
		self.destruct()
		return
	elseif RoundsRemaining>0 then
		self.setDescription( ("%s%i hands remaining"):format(bonusDesc, RoundsRemaining) )
	else
		self.setDescription( bonusDesc.."Final Hand" )
	end
end
function onRoundEnd()
	if RoundsRemaining==0 then
		self.destruct()
	end
end
function isActive() if IsActive then return true end end

local Royals = {["King"]=true, ["Queen"]=true, ["Jack"]=true, ["Ace"]=true}
-- local Royals = {["Joker"]=true}

function dealPlayer( data )
	if IsActive then
		local color = data.color
		local whichCard = data.whichCard
		
		local set = Global.call( "forwardFunction", {function_name="findObjectSetFromColor", data={color}} )
		
		local mainDeck = Global.getVar("mainDeck")
		local newDeck
		
		for n,v in ipairs(whichCard) do
			local hasAce = v~=1
			
			local pos = Global.call( "forwardFunction", {function_name="findCardPlacement", data={set.zone, v}} )
			
			local callbackParams = {
				targetPos = pos,
				flip = true,
				set=set,
				isStarter = true,
			}
			local params = {
				position = pos,
				flip = true,
				callback_function = function(obj)
					Global.call( "forwardFunction", {function_name="cardPlacedCallback", data={obj,callbackParams}} )
				end
			}
			
			local foundCard
			local mainDeckCards = mainDeck.getObjects()
			for i=1,#mainDeckCards do
				if (hasAce and not Royals[mainDeckCards[i].nickname]) or (Royals[mainDeckCards[i].nickname] and not hasAce) then
					params.index = mainDeckCards[i].index
					foundCard = mainDeck.takeObject( params )
					break
				end
			end
			
			if not foundCard then
				if not newDeck then
					local pos = set.zone.getPosition()
					local allDecks = Global.getVar("deckBag").takeObject({pos.x, pos.y+5, pos.z})
					allDecks.shuffle()
					newDeck = allDecks.takeObject({pos.x, pos.y+6, pos.z})
					newDeck.shuffle()
					
					destroyObject(allDecks)
				end
				
				local newDeckCards = newDeck.getObjects()
				for i=1,#newDeckCards do
					if (hasAce and not Royals[newDeckCards[i].nickname]) or (Royals[newDeckCards[i].nickname] and not hasAce) then
						params.index = newDeckCards[i].index
						foundCard = newDeck.takeObject( params )
						break
					end
				end
			end
			
			if foundCard then
				Global.setVar("lastCard", foundCard)
			end
		end
		
		if newDeck then
			destroyObject(newDeck)
		end
		
		-- placeCard(pos, true, set, true)
		-- lastCard = mainDeck.takeObject({position=pos, flip=flipBool, callback="cardPlacedCallback", callback_owner=Global, params={targetPos=pos, flip=flipBool, set=set, isStarter=isStarter}})
		
		return true
	end
end
