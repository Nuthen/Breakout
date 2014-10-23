Map = class('Map')

function Map:initialize(width, height, realWidth, realHeight)
	self.width = width
	self.height = height
	
	self.realWidth = realWidth -- whole board
	self.realHeight = realHeight
	
	
	self.paddingTop = 50
	self.paddingBottom = 200
	self.paddingLeft = 50
	self.paddingRight = 50
	
	self.tileWidth  = (self.realWidth-self.paddingLeft-self.paddingRight)/self.width
	self.tileHeight = (self.realHeight-self.paddingTop-self.paddingBottom)/self.height
	
	self.tiles = {}
	
	for iy = 1, self.height do
		self.tiles[iy] = {}
		for ix = 1, self.width do
			self.tiles[iy][ix] = {
				tile = 1,
			}
		end
	end
end

function Map:draw()
	love.graphics.setLineWidth(2)

	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	
	local x, y = scrnWidth/2 - self.realWidth/2, scrnHeight/2 - self.realHeight/2
	
	love.graphics.setColor(78, 78, 78)
	love.graphics.rectangle('fill', x, y, self.realWidth, self.realHeight)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('line', x, y, self.realWidth, self.realHeight)
	
	local x, y = x+self.paddingLeft, y+self.paddingTop
	local width, height = self.tileWidth, self.tileHeight
	
	for iy = 1, self.height do
		for ix = 1, self.width do
			if self.tiles[iy][ix].tile == 1 then
				love.graphics.setColor(math.floor((255/self.width)*ix), 0, math.floor((255/self.height)*iy))
				love.graphics.rectangle('fill', x + (ix-1)*width, y + (iy-1)*height, width, height)
				
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle('line', x + (ix-1)*width, y + (iy-1)*height, width, height)
			end
		end
	end
end