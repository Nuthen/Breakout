game = {}

function game:enter(prev, hosting)
	love.graphics.setBackgroundColor(27, 171, 137)

	self.levels = require 'data.levels'
	self.levelCount = 0
	
	game:restart()
	
	
	self.lastSendPaddle = 0
	self.lastSendBall = 0
	
	self.tilesLeft = 0
	
	-- networking
	self.hosting = hosting
	
	self.state = 'waiting'
	
	
	self.winner = nil
	
	-- server setup
	if self.hosting then
		self.ip = '*'
		self.port = '22122'
		
		self.host = enet.host_create(self.ip..':'..self.port, 1)
		
		if self.host == nil then
			error("Couldn't initialize host, there is probably another server running on that port")
		end
		
		self.host:compress_with_range_coder()
		self.timer = 0
		
		self.tock = 3
		self.tick = 0
		
		self.lastEvent = nil
		self.peer = nil
	
	else
		self.host = enet.host_create()
		--self.server = self.host:connect('69.137.215.69:22122')
		self.server = self.host:connect('localhost:22122')
		self.host:compress_with_range_coder()
		
		self.timer = 0
	end
end

function game:restart()
	self.levelCount = self.levelCount + 1

	self.timer = 0

	local level = self.levels[self.levelCount] or self.levels[math.random(#self.levels)]
	
	local offsetX = -level.realWidth*4/7
    self.map = Map:new(level.width, level.height, level.realWidth, level.realHeight, offsetX, level.paddingTop, level.paddingBottom, level.paddingLeft, level.paddingRight)
	self.paddle = Paddle:new(level.realWidth/2, level.realHeight-40, level.realWidth, level.realHeight, offsetX, true)
	self.ball = Ball:new(level.realWidth/2, level.realHeight-100, level.realWidth, level.realHeight, offsetX, true)
	
	self.map2 = Map:new(level.width, level.height, level.realWidth, level.realHeight, -offsetX, level.paddingTop, level.paddingBottom, level.paddingLeft, level.paddingRight)
	self.paddle2 = Paddle:new(level.realWidth/2, level.realHeight-40, level.realWidth, level.realHeight, -offsetX, false)
	self.ball2 = Ball:new(level.realWidth/2, level.realHeight-100, level.realWidth, level.realHeight, -offsetX, false)
	
	
	self.map.color1 = level.color1
	self.map.color2 = level.color2
	
	self.map2.color1 = level.color1
	self.map2.color2 = level.color2
	
	for iy = 1, #level.tiles do
		self.map.tiles[iy] = {}
		self.map2.tiles[iy] = {}
		for ix = 1, #level.tiles[iy] do
			self.map.tiles[iy][ix] = {tile = level.tiles[iy][ix]}
			self.map2.tiles[iy][ix] = {tile = level.tiles[iy][ix]}
		end
	end
end

function game:update(dt)
	-- networking
	if self.hosting then
		self.timer = self.timer + dt
		self.tick = self.tick + dt
		
		-- check some events, 100ms timeout
		local event = self.host:service(0)
		
		if event then
			self.lastEvent = event
			self.peer = event.peer
			
			if event.type == 'connect' then
				--self.host:broadcast('t|'..math.floor(self.timer*100))
				self.state = 'run'
				self.timer = 0
			elseif event.type == 'receive' then
				if string.find(event.data, 'p|') == 1 then -- True if it is paddle data 
					self.paddle2.x = string.gsub(event.data, 'p|', '')
					
				elseif string.find(event.data, 'b|') == 1 then -- True if it is ball data
					local str = string.gsub(event.data, 'b|', '')
					local ballTable = stringToTable(str)
					
					self.ball2.x = ballTable[1]
					self.ball2.y = ballTable[2]
					self.ball2.angle = ballTable[3]
				elseif string.find(event.data, 't|') == 1 then -- True if it is tile data
					local str = string.gsub(event.data, 't|', '')
					local tileTable = stringToTable(str)
					--error(dump(self.map2.tiles[15][7]))
					
					--error(tileTable[1]..' '..tileTable[2]..' '..tileTable[3])
					local iy = tonumber(tileTable[2])
					local ix = tonumber(tileTable[1])
					local tile = tonumber(tileTable[3])
					local level = tonumber(tileTable[4])
					
					if level == self.levelCount then
						self.map2.tiles[iy][ix].tile = tile
					end
					
				elseif string.find(event.data, 'r|') == 1 then -- True if it is paddle data 
					local str = string.gsub(event.data, 'r|', '')
					if str == 'true' then
						self.ball2.respawning = true
						
						self.ball2.x = self.ball2.startX
						self.ball2.y = self.ball2.startY
						self.ball2.angle = self.ball2.startingAngle
					else
						self.ball2.respawning = false
					end
					
				elseif string.find(event.data, 'w|') == 1 then -- True if it is paddle data 
					local winTime = string.gsub(event.data, 'w|', '')
					
					self.state = 'restart'
					self.winner = {'Opponent', winTime}
					self.host:flush()
					game:restart()
					return
				end
				
			elseif event.type == 'disconnect' then
				state.switch(menu, 'hostDisconnect')
			end
		end
		
		--[[
		if self.tick >= self.tock then
			self.tick = 0
			self.host:broadcast('t|'..math.floor(self.timer*100))
		end
		]]
	else
		self.timer = self.timer + dt
		
		-- check some events, 100ms timeout
		local event = self.host:service(0)

		if event then
			--event.peer:ping_interval(1000)
			self.lastEvent = event
			self.peer = event.peer
			
			if event.type == 'connect' then
				self.state = 'run'
				self.timer = 0
			
			elseif event.type == 'receive' then
				if string.find(event.data, 'p|') == 1 then -- True if it is paddle data 
					self.paddle2.x = string.gsub(event.data, 'p|', '')
					
				elseif string.find(event.data, 'b|') == 1 then -- True if it is ball data
					local str = string.gsub(event.data, 'b|', '')
					local ballTable = stringToTable(str)
					
					self.ball2.x = ballTable[1]
					self.ball2.y = ballTable[2]
					self.ball2.angle = ballTable[3]
					
				elseif string.find(event.data, 't|') == 1 then -- True if it is tile data
					local str = string.gsub(event.data, 't|', '')
					local tileTable = stringToTable(str)
					--error(str..' '..dump(tileTable))
					
					local iy = tonumber(tileTable[2])
					local ix = tonumber(tileTable[1])
					local tile = tonumber(tileTable[3])
					local level = tonumber(tileTable[4])
					
					if level == self.levelCount then
						self.map2.tiles[iy][ix].tile = tile
					end
					
				elseif string.find(event.data, 'r|') == 1 then -- True if it is paddle data 
					local str = string.gsub(event.data, 'r|', '')
					if str == 'true' then
						self.ball2.respawning = true
						
						self.ball2.x = self.ball2.startX
						self.ball2.y = self.ball2.startY
						self.ball2.angle = self.ball2.startingAngle
					else
						self.ball2.respawning = false
					end
					
				elseif string.find(event.data, 'w|') == 1 then -- True if it is paddle data 
					local winTime = string.gsub(event.data, 'w|', '')
					
					self.state = 'restart'
					self.winner = {'Opponent', winTime}
					self.host:flush()
					game:restart()
					return
				end
				
			elseif event.type == 'disconnect' then
				state.switch(menu, 'clientDisconnect')
			end
		end
	end
	
	if self.state == 'restart' then
		self.timer = self.timer + dt
		if self.timer > 5 then -- pause time between rounds
			self.state = 'run'
			self.timer = 0
			self.winner = nil
		end
	
	elseif self.state == 'run' then
		local paddleX = self.paddle.x
		local ballAngle = self.ball.angle
		local ballRespawning = self.ball.respawning
	
		self.paddle:update(dt)
		local tileX, tileY, tilesLeft = self.ball:update(dt)
		
		if tilesLeft then
			self.tilesLeft = tilesLeft
		end
		
		-- if a tile is removed, a packet is sent out
		if tileX and tileY then
			if self.hosting then
				self.host:broadcast('t|'..tileX..' '..tileY..' '.. 0 ..' '..self.levelCount)
			else
				self.peer:send('t|'..tileX..' '..tileY..' '.. 0 ..' '..self.levelCount)
			end
		end
		
		-- checks if paddle position changes, sends packet out
		if self.paddle.x ~= paddleX then
			if self.timer - self.lastSendPaddle > .5 then
				if self.hosting then
					self.host:broadcast('p|'..math.floor(self.paddle.x*100)/100)
				else
					self.peer:send('p|'..math.floor(self.paddle.x*100)/100)
				end
			end
		end
		
		-- checks if ball angle changes, sends packet out
		if math.floor(ballAngle*100)/100 ~= math.floor(self.ball.angle*100)/100 then
			if self.timer - self.lastSendBall > .5 then
				if self.hosting then
					self.host:broadcast('b|'..math.floor(self.ball.x*100)/100 ..' '..math.floor(self.ball.y*100)/100 ..' '..math.floor(self.ball.angle*100)/100)
				else
					self.peer:send('b|'..math.floor(self.ball.x*100)/100 ..' '..math.floor(self.ball.y*100)/100 ..' '..math.floor(self.ball.angle*100)/100)
				end
			end
		end
		
		-- checks if ball respawn status changes
		if self.ball.respawning ~= ballRespawning then
			if self.hosting then
				self.host:broadcast('r|'..tostring(self.ball.respawning))
			else
				self.peer:send('r|'..tostring(self.ball.respawning))
			end
		end
		
		-- checks if all tiles are gone
		if tilesLeft == 0 then
			if self.hosting then
				self.host:broadcast('w|'..self.timer)
			else
				self.peer:send('w|'..self.timer)
			end
			
			self.state = 'restart'
			self.winner = {'You', self.timer}
			game:restart()
		end
		
		--self.paddle2:update(dt)
		self.ball2:update(dt)
	end
end

function game:mousepressed(x, y, button)

end

function game:keypressed(key, isrepeat)

end

function game:draw()
    love.graphics.setFont(fontBold[16])
	
	-- Local Player
	self.map:draw()
	self.paddle:draw()
	self.ball:draw()
	
    love.graphics.setFont(fontBold[28])
	
	local x, y = love.graphics.getWidth()/2 - self.map.realWidth/2 + self.map.offsetX, love.graphics.getHeight()/2 + self.map.realHeight/2
	love.graphics.print('You', x + 5, y + 5)
	
	-- Online Player
	self.map2:draw()
	self.paddle2:draw()
	self.ball2:draw()
	
	local x, y = love.graphics.getWidth()/2 - self.map2.realWidth/2 + self.map2.offsetX, love.graphics.getHeight()/2 + self.map2.realHeight/2
	love.graphics.print('Opponent', x + 5, y + 5)
	
	
    love.graphics.setFont(fontBold[16])
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(love.timer.getFPS()..'FPS '..self.tilesLeft..' tiles', 5, 5)
	
	if self.hosting then
		love.graphics.print('Running server on ' .. self.ip .. ':' .. self.port, 5, 25)
		love.graphics.print('Server Time: '..math.floor(self.timer*100)/100, 5, 45)
		love.graphics.print('Sent: '..self.host:total_sent_data()*.000001 ..'MB; Received: '..self.host:total_received_data()*.000001 ..'MB', 5, 85)
	else
		love.graphics.print('Server Time: '..math.floor(self.timer*100)/100, 5, 45)
		love.graphics.print('Sent: '..self.host:total_sent_data()*.000001 ..'MB; Received: '..self.host:total_received_data()*.000001 ..'MB', 5, 85)
	end
	
	if self.lastEvent then
        local msg = 'Last message: '..tostring(self.lastEvent.data)..' from '..tostring(self.peer:index())
        love.graphics.print(msg, 5, 65)
    end
	
	if self.peer then
		love.graphics.print(self.peer:round_trip_time()..'ms', 5, 105)
	end
	
	if self.state == 'restart' then
		love.graphics.setFont(fontBold[32])
		love.graphics.print(self.winner[1]..' won in '..math.floor(self.winner[2]*100)/100 ..' seconds!\nPrepare for a new round.', 200, 30)
	end
end


function game:quit()
	if self.peer then
		if self.hosting then
			self.peer:disconnect()
			self.host:flush()
		else
			self.peer:disconnect()
			self.host:flush()
		end
	end
end