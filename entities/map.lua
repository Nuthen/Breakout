Map = class('Map')

function Map:initialize(width, height, realWidth, realHeight, offsetX)
	self.width = width
	self.height = height
	self.realWidth = realWidth   -- whole board
	self.realHeight = realHeight -- whole board
	self.offsetX = offsetX
	
	self.color1 = {153, 100, 80}
	self.color2 = {255, 100, 109}
	
	
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
	
	local x, y = scrnWidth/2 - self.realWidth/2 + self.offsetX, scrnHeight/2 - self.realHeight/2
	
	love.graphics.setColor(153, 100, 80)
	love.graphics.rectangle('fill', x, y, self.realWidth, self.realHeight)
	love.graphics.setColor(225, 255, 224)
	love.graphics.rectangle('line', x, y, self.realWidth, self.realHeight)
	
	local x, y = x+self.paddingLeft, y+self.paddingTop
	local width, height = self.tileWidth, self.tileHeight
	
	for iy = 1, self.height do
		for ix = 1, self.width do
			if self.tiles[iy][ix].tile == 1 then
				local r = ((self.color2[1] - self.color1[1])/self.width)*ix + self.color1[1]
				local b = ((self.color2[3] - self.color1[3])/self.width)*iy + self.color1[3]
				--love.graphics.setColor(math.floor((255/self.width)*ix), 0, math.floor((255/self.height)*iy))
				love.graphics.setColor(r, 100, b)
				--love.graphics.setColor(255, 102, 109)
				love.graphics.rectangle('fill', x + (ix-1)*width, y + (iy-1)*height, width, height)
				
				love.graphics.setColor(225, 255, 224)
				love.graphics.rectangle('line', x + (ix-1)*width, y + (iy-1)*height, width, height)
			end
		end
	end
end