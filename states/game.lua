game = {}

function game:enter(prev, hosting)
	love.graphics.setBackgroundColor(27, 171, 137)

	local offsetX = -250
    self.map = Map:new(5, 5, 450, 600, offsetX, true)
	self.paddle = Paddle:new(450/2, 600-40, 450, 600, offsetX, true)
	self.ball = Ball:new(450/2, 600-100, 450, 600, offsetX, true)
	
	self.map2 = Map:new(5, 5, 450, 600, -offsetX)
	self.paddle2 = Paddle:new(450/2, 600-40, 450, 600, -offsetX, false)
	self.ball2 = Ball:new(450/2, 600-100, 450, 600, -offsetX, false)
	
	
	self.lastSendPaddle = 0
	self.lastSendBall = 0
	
	self.tilesLeft = 0
	
	-- networking
	self.hosting = hosting
	
	self.state = 'waiting'
	
	self.levelCount = 1
	
	self.winner = nil
	
	-- server setup
	if self.hosting then
		self.ip = '*'
		self.port = '22122'
		
		self.host = enet.host_create(self.ip..':'..self.port)
		
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
		self.server = self.host:connect('69.137.215.69:22122')
		--self.server = self.host:connect('localhost:22122')
		self.host:compress_with_range_coder()
		
		self.timer = 0
	end
end

function game:restart()
	self.levelCount = self.levelCount + 1

	self.timer = 0

	local offsetX = -250
    self.map = Map:new(7, 15, 450, 600, offsetX, true)
	self.paddle = Paddle:new(450/2, 600-40, 450, 600, offsetX, true)
	self.ball = Ball:new(450/2, 600-100, 450, 600, offsetX, true)
	
	self.map2 = Map:new(7, 15, 450, 600, -offsetX)
	self.paddle2 = Paddle:new(450/2, 600-40, 450, 600, -offsetX, false)
	self.ball2 = Ball:new(450/2, 600-100, 450, 600, -offsetX, false)
	
	
	self.map.color1 = {math.random(255), math.random(255), math.random(255)}
	self.map.color2 = {math.random(255), math.random(255), math.random(255)}
	
	self.map2.color1 = {math.random(255), math.random(255), math.random(255)}
	self.map2.color2 = {math.random(255), math.random(255), math.random(255)}
	
	if self.levelCount == 3 then
		for iy = 1, self.map.height do
			for ix = 1, self.map.width do
				-- assumes both maps are the same size
				if ix > 2 and ix < self.map.width - 1 then
					if iy % 3 < 2 then
						self.map.tiles[iy][ix].tile = 0
						self.map2.tiles[iy][ix].tile = 0
					end
				end
			end
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
					self.map2.tiles[iy][ix].tile = tile
					
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
					game:restart()
					return
				end
				
			elseif event.type == 'disconnect' then
			
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
					self.map2.tiles[iy][ix].tile = tile
					
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
					game:restart()
					return
				end
				
			elseif event.type == 'disconnect' then
			
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
		
		-- if a tile is removed, a packet is sent out
		if tileX and tileY then
			if self.hosting then
				self.host:broadcast('t|'..tileX..' '..tileY..' '.. 0)
			else
				self.peer:send('t|'..tileX..' '..tileY..' '.. 0)
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
	
	-- Online Player
	self.map2:draw()
	self.paddle2:draw()
	self.ball2:draw()
	
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