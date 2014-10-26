Paddle = class('Paddle')

function Paddle:initialize(x, y, range, domain, offsetX, localPlayer)
	self.x = range/2 -- x can vary from self.width/2 to range-self.width/2
	self.y = y
	self.range = range
	self.domain = domain
	self.offsetX = offsetX
	self.localPlayer = localPlayer or true
	
	self.speed = 350
	
	self.width = 80
	self.height = 15
	
	self.bounceTimer = 0
	self.bounceTimerMax = .5
end

function Paddle:update(dt)
	if self.bounceTimer > 0 then
		self.bounceTimer = self.bounceTimer - dt
	end

	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	local mouseX = love.mouse.getX() - scrnWidth/2 + self.range/2 - self.offsetX -- aligns mouse 0 with paddle 0
	
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

function Paddle:bounceEffect()
	self.bounceTimer = self.bounceTimerMax
end

function Paddle:draw()
	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	
	local x, y = (scrnWidth/2 - self.range/2 + self.x) - self.width/2 + self.offsetX, (scrnHeight/2 - self.domain/2 + self.y) - self.height/2
	
	love.graphics.setColor(116, 204, 61)
	love.graphics.rectangle('fill', x, y, self.width, self.height)
	love.graphics.setColor(225, 255, 224)
	love.graphics.rectangle('line', x, y, self.width, self.height)
	
	if self.bounceTimer > 0 then
		love.graphics.setColor(225, 255, 224, (255/self.bounceTimerMax+1)*self.bounceTimer)
		local ox = 4 + math.floor(self.bounceTimerMax-self.bounceTimer)*5
		love.graphics.rectangle('line', x-ox, y-ox, self.width+ox*2, self.height+ox*2)
	end
end