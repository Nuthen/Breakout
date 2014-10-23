game = {}

function game:enter()
    self.map = Map:new(7, 15, 450, 600)
	self.paddle = Paddle:new(450/2, 600-30, 450, 600)
	self.ball = Ball:new(450/2, 600-50, 450, 600)
end

function game:update(dt)
	self.paddle:update(dt)
	self.ball:update(dt)
end

function game:mousepressed(x, y, button)

end

function game:keypressed(key, isrepeat)

end

function game:draw()
    love.graphics.setFont(fontBold[16])
	
	self.map:draw()
	self.paddle:draw()
	self.ball:draw()
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(love.timer.getFPS(), 5, 5)
end