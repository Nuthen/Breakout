function genTiles(gen, width, height)
	local tbl = {}
	if gen == 1 then
		for iy = 1, height do
		tbl[iy] = {}
			for ix = 1, width do
				local tile = 1
				if ix > 2 and ix < width - 1 then
					if iy % 3 < 2 then
						tile = 0
					end
				end
				
				tbl[iy][ix] = tile
			end
		end
		
	elseif gen == 2 then
		for iy = 1, height do
		tbl[iy] = {}
			for ix = 1, width do
				local tile = 1
				if ix > 2 and ix < width - 1 then
					if iy > 2 and iy < height - 1 then
						tile = 0
					end
				end
				if ix < 5 or ix > width - 4 then
					if iy < 5 or iy > height - 4 then
						tile = 1
					end
				end
				
				tbl[iy][ix] = tile
			end
		end
	end
	
	return tbl
end


levels = {

	{
		width = 7,
		height = 15,
		realWidth = 450,
		realHeight = 600,
		
		color1 = {math.random(255), math.random(255), math.random(255)},
		color2 = {math.random(255), math.random(255), math.random(255)},
	
		paddingTop = 50,
		paddingBottom = 180,
		paddingLeft = 0,
		paddingRight = 0,
		
		tiles = {{1, 1, 1, 1, 1, 1, 1},
				 {1, 0, 0, 0, 0, 0, 1},
				 {1, 1, 1, 1, 1, 1, 1},
				 {1, 0, 0, 0, 0, 0, 1},
				 {1, 1, 1, 1, 1, 1, 1},
				 {0, 0, 0, 0, 0, 0, 0},
				 {0, 0, 0, 0, 0, 0, 0},
				 {1, 1, 1, 1, 1, 1, 1},
				 {1, 1, 1, 1, 1, 1, 1},
				 {1, 1, 1, 1, 1, 1, 1},
				 {0, 0, 0, 0, 0, 0, 0},
				 {0, 0, 0, 0, 0, 1, 1},
				 {0, 1, 0, 0, 0, 1, 1},
				 {-1, -1, 1, 1, 1, -1, -1},
				 {-1, -1, -1, 0, -1, -1, -1}},
	},


	-- Level One
	{
		width = 7,
		height = 15,
		realWidth = 450,
		realHeight = 600,
		
		color1 = {math.random(255), math.random(255), math.random(255)},
		color2 = {math.random(255), math.random(255), math.random(255)},
	
		paddingTop = 50,
		paddingBottom = 180,
		paddingLeft = 40,
		paddingRight = 40,
		
		tiles = genTiles(1, 7, 15),
	},
	
	-- Level Two
	{
		width = 13,
		height = 13,
		realWidth = 450,
		realHeight = 600,
		
		color1 = {math.random(255), math.random(255), math.random(255)},
		color2 = {math.random(255), math.random(255), math.random(255)},
	
		paddingTop = 35,
		paddingBottom = 225,
		paddingLeft = 35,
		paddingRight = 35,
		
		tiles = genTiles(2, 13, 13),
	},
}


return levels