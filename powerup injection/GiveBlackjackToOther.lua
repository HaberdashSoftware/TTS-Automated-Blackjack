
function onLoad()
	Global.call("AddPowerup", {obj=self, who="Other Player", effectName="Alt. Clear"} )
	
	local tbl = Global.getTable("cardNameTable")
	tbl[self.getName()] = 69
	Global.setTable("cardNameTable", tbl)
end
