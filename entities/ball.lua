Ball = class('Ball')

function Ball:initialize(x, y, range, domain, offsetX, localPlayer)
	self.startX = x
	self.startY = y

	self.x = x
	self.y = y
	self.range = range
	self.domain = domain
	self.offsetX = offsetX
	self.localPlayer = localPlayer
	
	self.width = 10
	self.height = 10
	
	self.color = {204, 167, 153}
	
	self.startingAngle = math.rad(-45)
	self.angle = math.rad(-45)
	
	self.speed = 280
	
	self.respawning = false
	self.respawnTimerMax = 3
	self.respawnTimer = 0
end

function Ball:update(dt)
	if self.respawning then
		self.respawnTimer = self.respawnTimer + dt
		if self.respawnTimer >= self.respawnTimerMax then
			self.respawnTimer = 0
			self.respawning = false
			
			self.angle = self.startingAngle
		end
	
	else
		local vx, vy = math.cos(self.angle)*self.speed*dt, math.sin(self.angle)*self.speed*dt

		local newX, newY = self.x + vx, self.y + vx
		
		local tileX, tileY = nil, nil
		local tilesLeft = 0
		
		if self.localPlayer then
		
			-- handles bouncing off outer walls
			if newX + self.width/2 > self.range then -- hits right
				-- brings it as close to the wall as possible for this frame
				--vx = self.range - (self.x + self.width/2)		-- newX + self.width/2 = self.range
				--vy = math.tan(self.angle) * vx					-- newX = self.range - self.width/2
				-- keep angle the same
				
				-- bounce the component
				vx = -vx
				self.x = self.x - 2 -- so it doesn't get stuck
				
			elseif newX - self.width/2 < 0 then -- hits left
				-- brings it as close to the wall as possible for this frame
				--vx = 0 + (self.x - self.width/2)
				--vy = math.tan(self.angle) * vx
				-- keep angle the same
				
				
				-- bounce the component
				vx = -vx
				self.x = self.x + 2 -- so it doesn't get stuck
				--error(self.angle..' '..math.atan2(vy, vx)..' '..vx..' '..vy)
			end
			
			if newY + self.height/2 > self.domain then -- hits bottom
				-- brings it as close to the wall as possible for this frame
				--vy = self.domain - (self.y + self.height/2)
				--vx = vy / math.tan(self.angle)
				-- keep angle the same
				
				-- bounce the component
				--vy = -vy
				--vy = vy+2
				
				-- place ball at starting position, wait for the duration of self.respawnTimerMax
				self.respawning = true
				
				self.x = self.startX
				self.y = self.startY
				
			elseif newY - self.height/2 < 0 then -- hits top
				-- brings it as close to the wall as possible for this frame
				--vy = 0 + (self.y - self.height/2)
				--vx = vy / math.tan(self.angle)
				-- keep angle the same
				
				-- bounce the component
				vy = -vy
				self.y = self.y + 2 -- so it doesn't get stuck
			end
			
			
			-- handles bouncing off the paddle
			local paddle = game.paddle
			
			if self.x - self.width/2 < paddle.x + paddle.width/2 and self.x + self.width/2 > paddle.x - paddle.width/2 and self.y - self.height/2 < paddle.y + paddle.height/2 and self.y + self.height/2 > paddle.y - paddle.height/2 then -- collision with paddle
				-- bounces off paddle based on where it hits on the paddle
				local paddleHitPercentage = (self.x-paddle.x)/paddle.width -- goes from about -.5 to .5
				self.angle = math.rad(160)*paddleHitPercentage-math.rad(80) -- range vargies from about -80 degress to 80 degrees
				vx, vy = math.cos(self.angle)*self.speed*dt, math.sin(self.angle)*self.speed*dt
				
				paddle:bounceEffect()
			end
			
			
			-- handles bouncing off tiles
			local map = game.map
			local x, y = map.paddingLeft, map.paddingTop
			
			for iy = 1, #map.tiles do
				for ix = 1, #map.tiles[iy] do
					local tile = map.tiles[iy][ix]
					if tile.tile ~= 0 then
						local width, height = map.tileWidth, map.tileHeight
						local x = x + (ix-1)*width
						local y = y + (iy-1)*height
						
						if self.x - self.width/2 < x + width and self.x + self.width/2 > x and self.y - self.height/2 < y + height and self.y + self.height/2 > y then -- colliding with tile
							if tile.tile == 1 then
								tile.tile = 0 -- "deletes" tile, invisible with no collisions
							
								--self.speed = self.speed + 10
								tileX = ix
								tileY = iy
							end
							
							-- find which side
							local extra = 5 -- how far to allow inward for side detection (the ball will go partly into the tile)
							if self.x + self.width/2 <= x + extra and vx > 0 then -- left
								vx = -vx
							elseif self.x - self.width/2 >= x + width - extra and vx < 0 then -- right
								vx = -vx
							end
							
							if self.y + self.height/2 <= y + extra and vy > 0 then -- top
								vy = -vy
							elseif self.y - self.height/2 >= y + height - extra and vy < 0 then -- bottom
								vy = -vy
							end
						end
					end
					
					if tile.tile == 1 then
						tilesLeft = tilesLeft + 1
					end
				end
			end
			
			
			-- set the new angle (in case it changes)
			self.angle = math.atan2(vy, vx)
			
		else -- collision for the other player. everything here is purely predictive
			
			-- handles bouncing off outer walls
			if newX + self.width/2 > self.range then -- hits right
				-- brings it as close to the wall as possible for this frame
				--vx = self.range - (self.x + self.width/2)		-- newX + self.width/2 = self.range
				--vy = math.tan(self.angle) * vx					-- newX = self.range - self.width/2
				-- keep angle the same
				
				-- bounce the component
				vx = -vx
				self.x = self.x - 2 -- so it doesn't get stuck
				
			elseif newX - self.width/2 < 0 then -- hits left
				-- brings it as close to the wall as possible for this frame
				--vx = 0 + (self.x - self.width/2)
				--vy = math.tan(self.angle) * vx
				-- keep angle the same
				
				
				-- bounce the component
				vx = -vx
				self.x = self.x + 2 -- so it doesn't get stuck
				--error(self.angle..' '..math.atan2(vy, vx)..' '..vx..' '..vy)
			end
			
			if newY + self.height/2 > self.domain then -- hits bottom
				-- brings it as close to the wall as possible for this frame
				--vy = self.domain - (self.y + self.height/2)
				--vx = vy / math.tan(self.angle)
				-- keep angle the same
				
				-- bounce the component
				--vy = -vy
				--vy = vy+2
				
				-- place ball at starting position, wait for the duration of self.respawnTimerMax
				self.respawning = true
				
				self.x = self.startX
				self.y = self.startY
				
			elseif newY - self.height/2 < 0 then -- hits top
				-- brings it as close to the wall as possible for this frame
				--vy = 0 + (self.y - self.height/2)
				--vx = vy / math.tan(self.angle)
				-- keep angle the same
				
				-- bounce the component
				vy = -vy
				self.y = self.y + 2 -- so it doesn't get stuck
			end
			
			
			-- handles bouncing off the paddle
			local paddle = game.paddle2
			
			if self.x - self.width/2 < paddle.x + paddle.width/2 and self.x + self.width/2 > paddle.x - paddle.width/2 and self.y - self.height/2 < paddle.y + paddle.height/2 and self.y + self.height/2 > paddle.y - paddle.height/2 then -- collision with paddle
				-- bounces off paddle based on where it hits on the paddle
				local paddleHitPercentage = (self.x-paddle.x)/paddle.width -- goes from about -.5 to .5
				self.angle = math.rad(160)*paddleHitPercentage-math.rad(80) -- range vargies from about -80 degress to 80 degrees
				vx, vy = math.cos(self.angle)*self.speed*dt, math.sin(self.angle)*self.speed*dt
			end
			
			
			-- handles bouncing off tiles
			local map = game.map2
			local x, y = map.paddingLeft, map.paddingTop
			
			for iy = 1, #map.tiles do
				for ix = 1, #map.tiles[iy] do
					local tile = map.tiles[iy][ix]
					if tile.tile ~= 0 then
						local width, height = map.tileWidth, map.tileHeight
						local x = x + (ix-1)*width
						local y = y + (iy-1)*height
						
						if self.x - self.width/2 < x + width and self.x + self.width/2 > x and self.y - self.height/2 < y + height and self.y + self.height/2 > y then -- colliding with tile
							if tile.tile == 1 then
								tile.tile = 0 -- "deletes" tile, invisible with no collisions
								
								--self.speed = self.speed + 10
								tileX = ix
								tileY = iy
							end
							
							-- find which side
							local extra = 5 -- how far to allow inward for side detection (the ball will go partly into the tile)
							if self.x + self.width/2 <= x + extra and vx > 0 then -- left
								vx = -vx
							elseif self.x - self.width/2 >= x + width - extra and vx < 0 then -- right
								vx = -vx
							end
							
							if self.y + self.height/2 <= y + extra and vy > 0 then -- top
								vy = -vy
							elseif self.y - self.height/2 >= y + height - extra and vy < 0 then -- bottom
								vy = -vy
							end
						end
					end
					
					if tile.tile > 0 then
						tilesLeft = tilesLeft + 1
					end
				end
			end
			
			
			-- set the new angle (in case it changes)
			self.angle = math.atan2(vy, vx)
		end
		
		self.x, self.y = self.x + vx, self.y + vy
		
		if tileX and tileY then
			return tileX, tileY, tilesLeft
		end
	end
end

function Ball:draw()
	local scrnWidth, scrnHeight = love.graphics.getDimensions()
	
	local x, y = (scrnWidth/2 - self.range/2) - self.width/2 + self.x + self.offsetX, (scrnHeight/2 - self.domain/2) - self.height/2 + self.y
	
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', x, y, self.width, self.height)
	love.graphics.setColor(225, 255, 224)
	love.graphics.rectangle('line', x, y, self.width, self.height)
end