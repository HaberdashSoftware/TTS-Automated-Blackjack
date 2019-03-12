--[[                   Universal Chip Converter                   ]]--

-- Fomat arguments:
--   1: String  - Object type (Custom_Model_Stack or Custom_Model)
--   2: String  - Chip Name
--   3: Integer - Stack Size
--   4: String  - Chip Image
local chipJSON = [[{
  "Name": "%s",
  "Transform": {
	"posX": 0,
	"posY": 0,
	"posZ": 0,
	"rotX": 0,
	"rotY": 0,
	"rotZ": 0,
	"scaleX": 0.825,
	"scaleY": 0.825,
	"scaleZ": 0.825
  },
  "Nickname": "%s",
  "Description": "",
  "ColorDiffuse": { "r": 1, "g": 1, "b": 1 },
  "Locked": false,
  "Grid": true,
  "Snap": true,
  "IgnoreFoW": false,
  "Autoraise": true,
  "Sticky": true,
  "Tooltip": true,
  "GridProjection": false,
  "HideWhenFaceDown": false,
  "Hands": false,
  "MaterialIndex": -1,
  "MeshIndex": -1,
  "Number": %i,
  "CustomMesh": {
	"MeshURL": "https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IeTM4ZHU5TFdKc0U",
	"DiffuseURL": "%s",
	"NormalURL": "",
	"ColliderURL": "",
	"Convex": true,
	"MaterialIndex": 0,
	"TypeIndex": 5,
	"CustomShader": {
	  "SpecularColor": { "r": 1.0, "g": 1.0, "b": 1.0 },
	  "SpecularIntensity": 0.0,
	  "SpecularSharpness": 7.0,
	  "FresnelStrength": 0.4
	},
	"CastShadows": true
  },
  "XmlUI": "",
  "LuaScript": "",
  "LuaScriptState": "",
  "GUID": "5dbe11"
}]]

local imgMissing = "https://i.imgur.com/yBmqIFG.png"
chipList = {
    {name="$1", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4ILWFqZTBoSnZUam8"},
    {name="$10", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IejNGRlFiVE5EZ1U"},
    {name="$100", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IY1prN0cwUzhKeEE"},
    {name="$1,000", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IUHZ5ZndoR2tzMGM"},
    {name="$10,000", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IeVhvNlVaeHlLREk"},
    {name="$100,000", tierUp=10, image="https://drive.google.com/uc?export=download&id=0B5tpZ_GxRg4IZlVBazl5ZjVlWWc"},
    {name="$1 Million", tierUp=10, image="http://i.imgur.com/rZWuKyA.jpg"},
    {name="$10 Million", tierUp=10, image="http://i.imgur.com/LNc3Seo.jpg"},
    {name="$100 Million", tierUp=10, image="http://i.imgur.com/VFMSotr.jpg"},
    {name="$1 Billion", tierUp=10, image="http://i.imgur.com/SnNT3yX.jpg"},
    {name="$10 Billion", tierUp=10, image="http://i.imgur.com/eBLU8Gk.png"},
    {name="$100 Billion", tierUp=10, image="http://i.imgur.com/Yk7yGY5.png"},
    {name="$1 Trillion", tierUp=10, image="http://i.imgur.com/zItIvcS.jpg"},
    {name="$10 Trillion", tierUp=10, image="http://i.imgur.com/1noo41R.jpg"},
    {name="$100 Trillion", tierUp=10, image="http://i.imgur.com/6hya2JL.jpg"},
    {name="$1 Quadrillion", tierUp=10, image="http://i.imgur.com/rujkM3p.jpg"},
    {name="$10 Quadrillion", tierUp=10, image="http://i.imgur.com/RPsvL8h.jpg"},
    {name="$100 Quadrillion", tierUp=10, image="http://i.imgur.com/Ngge1nL.jpg"},
    {name="$1 Quintillion", tierUp=10, image="http://i.imgur.com/oWf3WxR.png"},
    {name="$10 Quintillion", tierUp=10, image="http://i.imgur.com/yW9rLBB.png"},
    {name="$100 Quintillion", tierUp=10, image="http://i.imgur.com/0tgh4v9.png"},
    {name="$1 Sextillion", tierUp=10, image="http://i.imgur.com/W7NPU97.png"},
    {name="$10 Sextillion", tierUp=10, image="http://i.imgur.com/bn2idVa.png"},
    {name="$100 Sextillion", tierUp=10, image="http://i.imgur.com/z5hslhD.png"},
    {name="$1 Septillion", tierUp=10, image="http://i.imgur.com/BmKvTjf.jpg"},
    {name="$10 Septillion", tierUp=10, image="http://i.imgur.com/L4dITDA.jpg"},
    {name="$100 Septillion", tierUp=10, image="http://i.imgur.com/22cIKJP.jpg"},
    {name="$1 Octillion", tierUp=10, image="http://i.imgur.com/270i5Y4.jpg"},
    {name="$10 Octillion", tierUp=10, image="http://i.imgur.com/MR349Zi.jpg"},
    {name="$100 Octillion", tierUp=10, image="http://i.imgur.com/fUrYZoi.jpg"},
    {name="$1 Nonillion", tierUp=10, image="http://i.imgur.com/zB3XEJE.jpg"},
    {name="$10 Nonillion", tierUp=10, image="http://i.imgur.com/pyUxQw8.jpg"},
    {name="$100 Nonillion", tierUp=10, image="http://i.imgur.com/6A1UTNO.jpg"},
    {name="$1 Decillion", tierUp=10, image="http://i.imgur.com/rT2nBtL.jpg"},
    {name="$10 Decillion", tierUp=10, image="http://i.imgur.com/sTdG5Dd.jpg"},
    {name="$100 Decillion", tierUp=10, image="http://i.imgur.com/Eg3zj6R.jpg"},
    {name="$1 Undecillion", tierUp=10, image="https://i.imgur.com/wPWQ1Tn.png"},
    {name="$10 Undecillion", tierUp=10, image="https://i.imgur.com/r2ypF8q.png"},
    {name="$100 Undecillion", tierUp=10, image="https://i.imgur.com/ubymjOy.png"},
    {name="$1 Duodecillion", tierUp=10, image="https://i.imgur.com/9Ulh3m7.png"},
    {name="$10 Duodecillion", tierUp=10, image="https://i.imgur.com/uLJtm1L.png"},
    {name="$100 Duodecillion", tierUp=10, image="https://i.imgur.com/2fuW5YF.png"},
    {name="$1 Tredecillion", tierUp=10, image="https://i.imgur.com/ci75nbU.png"},
    {name="$10 Tredecillion", tierUp=10, image="https://i.imgur.com/buxrLhG.png"},
    {name="$100 Tredecillion", tierUp=10, image="https://i.imgur.com/DGm3vet.png"},
    {name="$1 Quattuordecillion", tierUp=10, image="https://i.imgur.com/hggyiuc.png"},
    {name="$10 Quattuordecillion", tierUp=10, image="https://i.imgur.com/IwW6i9f.png"},
    {name="$100 Quattuordecillion", tierUp=10, image="https://i.imgur.com/4crp0hg.png"},
    {name="$1 Quindecillion", tierUp=10, image="https://i.imgur.com/dcf8Iev.png"},
    {name="$10 Quindecillion", tierUp=10, image="https://i.imgur.com/BeKQ1MI.png"},
    {name="$100 Quindecillion", tierUp=10, image="https://i.imgur.com/zZmyFnQ.pngr.com/6A1UTNO.jpg"},
    {name="$1 Sexdecillion", tierUp=10, image="https://i.imgur.com/06wERQn.png"},
    {name="$10 Sexdecillion", tierUp=10, image="https://i.imgur.com/llHLRA4.png"},
    {name="$100 Sexdecillion", tierUp=10, image="https://i.imgur.com/nFfIB9J.png"},
    {name="$1 Septendecillion", tierUp=10, image="https://i.imgur.com/f095cEL.png"},
    {name="$10 Septendecillion", tierUp=10, image="https://i.imgur.com/qPNIiPq.png"},
    {name="$100 Septendecillion", tierUp=10, image="https://i.imgur.com/4GTuQqK.png"},
    {name="$1 Octodecillion", tierUp=10, image="https://i.imgur.com/ZcKzNwx.png"},
    {name="$10 Octodecillion", tierUp=10, image="https://i.imgur.com/IJrBX6x.png"},
    {name="$100 Octodecillion", tierUp=10, image="https://i.imgur.com/7pSJcrr.png"},
    {name="$1 Novemdecillion", tierUp=10, image="https://i.imgur.com/yy8IRgR.png"},
    {name="$10 Novemdecillion", tierUp=10, image="https://i.imgur.com/TVo0QW9.png"},
    {name="$100 Novemdecillion", tierUp=10, image="https://i.imgur.com/JxCYqGd.png"},
    {name="$1 Vigintillion", tierUp=10, image="https://i.imgur.com/G9MsMGk.png"},
    {name="$10 Vigintillion", tierUp=10, image="https://i.imgur.com/uLDsBLI.png"},
    {name="$100 Vigintillion", tierUp=10, image="https://i.imgur.com/4BzURrE.png"},
    {name="$1 Unvigintillion", tierUp=10, image="https://i.imgur.com/PgywnAg.png"},
    {name="$10 Unvigintillion", tierUp=10, image="https://i.imgur.com/PG5Q6xy.png"},
    {name="$100 Unvigintillion", tierUp=10, image="https://i.imgur.com/eHDqJbU.png"},
    {name="$1 Duovigintillion", tierUp=10, image="https://i.imgur.com/Z2wSgVQ.png"},
    {name="$10 Duovigintillion", tierUp=10, image="https://i.imgur.com/Q3Kfnbd.png"},
    {name="$100 Duovigintillion", tierUp=10, image="https://i.imgur.com/YGUm85H.png"},
    {name="$1 Trevigintillion", tierUp=10, image="https://i.imgur.com/dLNEzt4.png"},
    {name="$10 Trevigintillion", tierUp=10, image="https://i.imgur.com/EzDzPy8.png"},
    {name="$100 Trevigintillion", tierUp=10, image="https://i.imgur.com/vw4rk73.png"},
    {name="$1 Quattuorvigintillion", tierUp=10, image="https://i.imgur.com/Y6E9pYA.png"},
    {name="$10 Quattuorvigintillion", tierUp=10, image="https://i.imgur.com/BC8xl3o.png"},
    {name="$100 Quattuorvigintillion", tierUp=10, image="https://i.imgur.com/G9iDNpJ.png"},
    {name="$1 Quinvigintillion", tierUp=10, image="https://i.imgur.com/kKxnSR7.png"},
    {name="$10 Quinvigintillion", tierUp=10, image="https://i.imgur.com/sh5sgMT.png"},
    {name="$100 Quinvigintillion", tierUp=10, image="https://i.imgur.com/Dz1WjWm.png"},
    {name="$1 Sexvigintillion", tierUp=10, image="https://i.imgur.com/u2WdwR5.png"},
    {name="$10 Sexvigintillion", tierUp=10, image="https://i.imgur.com/w5kA9QQ.png"},
    {name="$100 Sexvigintillion", tierUp=10, image="https://i.imgur.com/4NJbvlL.png"},
    {name="$1 Septenvigintillion", tierUp=10, image="https://i.imgur.com/V6gIuH5.png"},
    {name="$10 Septenvigintillion", tierUp=10, image="https://i.imgur.com/npAiLNT.png"},
    {name="$100 Septenvigintillion", tierUp=10, image="https://i.imgur.com/Wq0cWAl.png"},
    {name="$1 Octovigintillion", tierUp=10, image="https://i.imgur.com/KEWZiqD.png"},
    {name="$10 Octovigintillion", tierUp=10, image="https://i.imgur.com/CYgQGSI.png"},
    {name="$100 Octovigintillion", tierUp=10, image="https://i.imgur.com/H5efndm.png"},
    {name="$1 Novemvigintillion", tierUp=10, image="https://i.imgur.com/Zzlmgf4.png"},
    {name="$10 Novemvigintillion", tierUp=10, image="https://i.imgur.com/WQNILVX.png"},
    {name="$100 Novemvigintillion", tierUp=10, image="https://i.imgur.com/0RROkma.png"},
    {name="$1 Trigintillion", tierUp=10, image="https://i.imgur.com/HsNiI0N.png"},
    {name="$10 Trigintillion", tierUp=10, image="https://i.imgur.com/dvCUtKK.png"},
    {name="$100 Trigintillion", tierUp=10, image="https://i.imgur.com/FcqbaeQ.png"},
    {name="$1 Untrigintillion", tierUp=10, image="https://i.imgur.com/eHB3Rng.png"},
    {name="$10 Untrigintillion", tierUp=10, image="https://i.imgur.com/cpQiQYy.png"},
    {name="$100 Untrigintillion", tierUp=10, image="https://i.imgur.com/W8pdyu8.png"},
    {name="$1 Duotrigintillion", tierUp=10, image="https://i.imgur.com/bwbXm6a.png"},
    {name="$10 Duotrigintillion", tierUp=10, image="https://i.imgur.com/y3FFRO2.png"},
    {name="$100 Duotrigintillion", tierUp=10, image="https://i.imgur.com/Y5OwRhK.png"},
    {name="$1 Tretrigintillion", tierUp=10, image="https://i.imgur.com/yUEAuOy.png"},
    {name="$10 Tretrigintillion", tierUp=10, image="https://i.imgur.com/Eu8nwxR.png"},
    {name="$100 Tretrigintillion", tierUp=10, image="https://i.imgur.com/jyyuCkV.png"},
}
nameToIndex = {}
for i = 1,#chipList do
	nameToIndex[chipList[i].name] = i
end

function onLoad()
	self.setLock(true)
	self.interactable = false
end

function doChipSpawn(name, pos, img, stack)
	stack = math.max(math.floor(stack or 1), 1)
	
	local params = {
		json = chipJSON:format( stack>1 and "Custom_Model_Stack" or "Custom_Model", name or "[CHIP NAME]", stack, img or imgMissing ),
		position = pos,
		sound = false,
	}
	
	return spawnObjectJSON( params )
end
function spawnChipID( id, pos, stack )
	local entry = chipList[id or -1]
	if entry then
		return doChipSpawn(entry.name, pos, entry.image, stack)
	else
		return doChipSpawn(nil, pos, nil, stack)
	end
end
function spawnChipName( name, pos, stack )
	local id = nameToIndex[name]
	if id then
		local entry = chipList[id]
		if entry then
			return doChipSpawn(entry.name, pos, entry.image, stack)
		end
	end
	
	return doChipSpawn(name, pos, nil, stack)
end

function spawnChip( data )
	if data.id then -- Spawn by ID
		return spawnChipID( data.id, data.pos, data.num )
	elseif data.image then -- Spawn custom chip
		return doChipSpawn( data.name, data.pos, data.image, data.num )
	elseif data.name then -- Spawn by name
		return spawnChipName( data.name, data.pos, data.num )
	else -- Spawn generic
		return doChipSpawn( nil, data.pos, nil, data.num )
	end
end
