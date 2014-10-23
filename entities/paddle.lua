Paddle = class('Paddle')

function Paddle:initialize(x, y, range, domain)
	self.x = range/2 -- x can vary from self.width/2 to range-self.width/2
	self.y = y
	self.range = range
	self.domain = domain
	
	self.speed = 350
	
	self.width = 80
	self.height = 15
end

function Paddle:update(dt)
	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	local mouseX = love.mouse.getX() - scrnWidth/2 + self.range/2 -- aligns mouse 0 with paddle 0
	
	local lastX = self.x
	
	local dx = mouseX - self.x
	if dx > 0 then
		if dx > self.speed*dt then
			self.x = self.x + self.speed*dt
		else
			self.x = mouseX
		end
	elseif dx < 0 then
		if dx < -self.speed*dt then
			self.x = self.x - self.speed*dt
		else
			self.x = mouseX
		end
	end
	
	if self.x + self.width/2 > self.range then
		self.x = self.range - self.width/2
	elseif self.x - self.width/2 < 0 then
		self.x = self.width/2
	end
end

function Paddle:draw()
	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	
	local x, y = (scrnWidth/2 - self.range/2 + self.x) - self.width/2, (scrnHeight/2 - self.domain/2 + self.y) - self.height/2
	
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle('fill', x, y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('line', x, y, self.width, self.height)
end