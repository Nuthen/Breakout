menu = {}

function menu:enter()
    self.hosting = false
end

function menu:update(dt)

end

function menu:keyreleased(key, code)
    if key == 'return' then
        state.switch(game, self.hosting)
    end
end

function menu:keypressed(key, isrepeat)
	if key == '1' then
		if self.hosting then
			self.hosting = false
		else
			self.hosting = true
		end
	end
end

function menu:draw()
    local text = "> ENTER <"
    local x = love.window.getWidth()/2 - fontBold[48]:getWidth(text)/2
    local y = love.window.getHeight()/2
    love.graphics.setFont(fontBold[48])
    love.graphics.print(text, x, y)
	
	if self.hosting then
		love.graphics.print('You are hosting', 5, 5)
	end
end