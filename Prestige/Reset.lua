
PrestigeChip = "$100 Tretrigintillion"
PrestigeLevel = 9 -- Change this to one more than your highest prestige

NewPlayerGem = nil

PrestigePlayers = {}
OrderedPlayers = {}


-- Save/Load --
---------------
function onSave()
	local data = JSON.encode({PrestigePlayers = PrestigePlayers})
	self.script_state = data
end
function onLoad(saveData)
	Global.call("AddPrestige", {obj=self} )
	
	NewPlayerGem = getObjectFromGUID("93d6a6")
	
	if saveData then
		local decoded = JSON.decode( saveData )
		
		if decoded and decoded.PrestigePlayers then
			PrestigePlayers = decoded.PrestigePlayers
			generateOrder()
		end
	end
	
	createDisplay()
end


-- Spawned Objects --
---------------------
local RolloverObjScript = [[PrestigeRolloverLevel = %u
function onLoad()
	createDisplay()
end
function createDisplay()
	self.clearButtons()
	self.clearInputs()
	
	self.createButton({
		label=tostring(PrestigeRolloverLevel), click_function="createDisplay", function_owner=self,
		position={0,1.14,0.33}, rotation={-90,0,0}, width=0, height=0, font_size=110,
		font_color = {r=1,g=1,b=1},
	})
	self.createButton({
		label=tostring(PrestigeRolloverLevel), click_function="createDisplay", function_owner=self,
		position={0,1.14,-0.33}, rotation={90,0,180}, width=0, height=0, font_size=110,
		font_color = {r=1,g=1,b=1},
	})
end
]]
local RolloverObjectData = {name="Prestige Rollover Counter", meshData={mesh="http://pastebin.com/raw/0iWmAh9n", diffuse="https://i.imgur.com/m3HOuVr.png"}, scale = {1,1,1}, desc="Jokers are instawin with a 2:1 payout\n---\nReach $1 Quadrillion to prestige."}


-- Do Prestige --
-----------------
function doPrestige(data)
	if not data.set then return end
	
	local col = data.set.color
	if not Player[col].seated then return end
	local plyData = Player[col]
	
	PrestigePlayers[plyData.steam_id] = PrestigePlayers[plyData.steam_id] or {id=plyData.steam_id, name=plyData.steam_name, level=0}
	
	local rolloverCount = 0
	local rolloverObject
	
	local zoneObjects = data.set.zone.getObjects()
	local tableObjects = data.set.tbl.getObjects()
	local prestigeObjects = data.set.prestige.getObjects()
	
	for _,zone in pairs({zoneObjects, tableObjects, prestigeObjects}) do
		for _, obj in ipairs(zone) do
			if obj then
				local objReset = obj.getVar("PrestigeRolloverLevel")
				if type(objReset)=="number" and objReset>rolloverCount then
					rolloverCount = objReset
					rolloverObject = obj
				end
			end
		end
	end
	
	rolloverCount = math.max( PrestigePlayers[plyData.steam_id].level or 0, rolloverCount )
	
	printToAll("Prestige: " .. col .. " has completed a prestige rollover!", {0.5,1,0.5})
	
	-- Prestige Gem
	local newGem,rolloverAward
	if NewPlayerGem and not (NewPlayerGem==nil) then
		newGem = NewPlayerGem.takeObject({position=data.set.prestige.getPosition()})
		newGem.setLuaScript("")
		newGem.setLock(false)
		newGem.interactable = true
	else
		newGem = spawnObject({type = "Custom_Model"})
		newGem.setCustomObject(RolloverObjectData.meshData)
		newGem.setLuaScript("")
		newGem.setName("New Player")
		newGem.setScale(RolloverObjectData.scale)
		newGem.setPosition(data.set.prestige.getPosition())
	end
	
	if rolloverObject and not (rolloverObject==nil) then
		rolloverAward = rolloverObject
		rolloverAward.setLuaScript(RolloverObjScript:format(rolloverCount+1))
		rolloverAward.setVar("PrestigeRolloverLevel", rolloverCount+1)
	else
		rolloverAward = self.clone({position=data.set.zone.getPosition()})
		rolloverAward.setLock(false)
		rolloverAward.setLuaScript(RolloverObjScript:format(rolloverCount+1))
		rolloverAward.interactable = true
		rolloverAward.setName(RolloverObjectData.name)
		rolloverAward.setDescription(RolloverObjectData.desc)
	end
	
	if rolloverAward.getVar("createDisplay") then
		rolloverAward.call("createDisplay")
	end
	
	newGem.setDescription( ("%s - %s\n\n%s"):format(plyData.steam_id, plyData.steam_name, newGem.getDescription()) )
	rolloverAward.setDescription( ("%s - %s"):format(plyData.steam_id, plyData.steam_name) )
	
	PrestigePlayers[plyData.steam_id].level = rolloverCount + 1
	
	generateOrder()
	createDisplay()
	
	return true
end


-- Leaderboard --
-----------------
local suffix = {
	[1] = "st", [2] = "nd", [3] = "rd"
}
function PlaceToString(num)
	if not (num and type(num)=="number") then return "[N/A]" end
	
	num = math.floor(num)
	
	local finalChar = num%10
	local isTeens = math.floor(num/10)%10==1
	
	return tostring(num)..((isTeens and "th") or suffix[finalChar] or "th")
end

Lockout = false
function checkPlace(o,c)
	Lockout = true
	
	if PrestigePlayers[Player[c].steam_id] then
		local pos = nil
		
		if pos then
			self.editButton({
				index = 0, label= ("%s\n%s Place\n%i Prestige Rollovers"):format(Player[c].steam_name, PlaceToString(pos), PrestigePlayers[Player[c].steam_id].level or "[N/A]"),
			})
		else
			self.editButton({
				index = 0, label= ("%s\n[N/A] Place\n%i Prestige Rollovers"):format(Player[c].steam_name, PrestigePlayers[Player[c].steam_id].level or "[N/A]"),
			})
		end
	else
		self.editButton({
			index = 0, label= ("%s\n\nNo Prestige Rollovers"):format(Player[c].steam_name),
		})
	end
	
	Wait.time(function()
		Lockout = false
		self.editButton({
			index = 0, label="",
		})
	end, 5)
end

function generateOrder()
	OrderedPlayers = {}
	
	for id,data in pairs(PrestigePlayers) do
		table.insert( OrderedPlayers, {id=id, name=data.name, level=data.level} )
	end
	
	table.sort(OrderedPlayers, function(a,b)
		if a.level==b.level then
			if a.name==b.name then
				return a.id<b.id
			end
			return a.name<b.name
		end
		return a.level<b.level
	end)
end


-- Display and Buttons --
-------------------------
function createDisplay()
	self.clearButtons()
	self.clearInputs()
	
	self.createButton({
		label="", click_function="doNull", function_owner=self,
		position={0,0.5,0.2}, rotation={-90,0,0}, width=0, height=0, font_size=70,
		font_color = {r=1,g=1,b=1},
	})
	self.createButton({
		label="Check Place", click_function="checkPlace", function_owner=self,
		position={0,0.1,0.25}, rotation={-70,0,0}, width=400, height=50, font_size=40,
		color = {r=0.5,g=0.5,b=0.5},
	})
	
	self.createButton({
		label="*", click_function="doNull", function_owner=self,
		position={0,1.14,0.33}, rotation={-90,0,0}, width=0, height=0, font_size=110,
		font_color = {r=1,g=1,b=1},
	})
	self.createButton({
		label="*", click_function="doNull", function_owner=self,
		position={0,1.14,-0.33}, rotation={90,0,180}, width=0, height=0, font_size=110,
		font_color = {r=1,g=1,b=1},
	})
	
	if #OrderedPlayers==0 then return end
	-- Top 10
	local pos = {0,2,0}
	for i=math.min(#OrderedPlayers, 10),1,-1 do
		self.createButton({
			label=tostring(i)..".", click_function="doNull", function_owner=self,
			position={pos[1]-2.5,pos[2],pos[3]}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=0,g=0,b=0},
		})
		self.createButton({
			label=tostring(i), click_function="doNull", function_owner=self,
			position={pos[1]-2.52,pos[2],pos[3]-0.02}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=1,g=1,b=1},
		})
		
		self.createButton({
			label=OrderedPlayers[i].name or "{name}", click_function="doNull", function_owner=self,
			position={pos[1],pos[2],pos[3]}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=0,g=0,b=0},
		})
		self.createButton({
			label=OrderedPlayers[i].name or "{name}", click_function="doNull", function_owner=self,
			position={pos[1]-0.02,pos[2],pos[3]-0.02}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=1,g=1,b=1},
		})
		
		self.createButton({
			label=("%i Prestige Rollovers"):format(OrderedPlayers[i].level or 0), click_function="doNull", function_owner=self,
			position={pos[1]+3.5,pos[2],pos[3]}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=0,g=0,b=0},
		})
		self.createButton({
			label=("%i Prestige Rollovers"):format(OrderedPlayers[i].level or 0), click_function="doNull", function_owner=self,
			position={pos[1]+3.48,pos[2],pos[3]-0.02}, rotation={-90,0,0}, width=0, height=0, font_size=110,
			font_color = {r=1,g=1,b=1},
		})
		
		pos[2] = pos[2] + 0.25
	end
	
	self.createButton({
		label="Top Prestige Rollovers", click_function="doNull", function_owner=self,
		position={pos[1],pos[2],pos[3]}, rotation={-90,0,0}, width=0, height=0, font_size=110,
		font_color = {r=0,g=0,b=0},
	})
	self.createButton({
		label="Top Prestige Rollovers", click_function="doNull", function_owner=self,
		position={pos[1]-0.2,pos[2],pos[3]-0.02}, rotation={-90,0,0}, width=0, height=0, font_size=110,
		font_color = {r=1,g=1,b=1},
	})
end
function doNull() end
