
function onPickUp( col )
	if self.getName()=="Bet Bag" then
		self.setColorTint( stringColorToRGB(col) or {1,1,1} )
		self.setName( tostring(col) .. " Bet Bag" )
	end
end