-- Entity Class


FLYSPEED = 500
HIT_DELAY = 50

Entity = {	x = 1375,
		  	y = 295,
		  	x_vel = 0,
			y_vel = 0,

		  	h = 32,
		  	w = 22,
			img = nil,

			standing = false,
			relativepos = 0,
			onslope = "false",

			state = "" ,

			isHit = false,
			hit_timer = HIT_DELAY,
			life = 1
		}

entities = {}


local _newImage = love.graphics.newImage
function love.graphics.newImage(...)
	local img = _newImage(...)
	img:setFilter('nearest','nearest')
	return img
end

function SummonEntities()
	-- Spawn new Entities
	for i = 1,3 do
		local newEntity = Entity:new{	
					x = 1005 + i * 33, y = 295, 	x_vel = 0, y_vel = 0, 
					h = 32, w = 22, img = nil, 
					standing = false, relativepos = 0, onslope = "false", state = "" 
		}
		--newEntity = { x = 1105 + i * 100, y = 205, x_vel = SPEED, y_vel = 0, h = 32, w = 22, health = HEALTH}
		table.insert(entities, newEntity)
	end
end

function Entity:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Entity:checkXcollisions( x_col )
	-- returns array of tiles intersecting {x = , y = }
	local tiles = {} 	 -- array of tiles
	local layer = map.tl["Ground"]
	local ychecking_pos = {self.y-self.h/2+1, self.y+self.h/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(x_col / map.tileWidth)
		local tileY = math.floor(ychecking_pos[i] / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end

	return tiles
end

function Entity:checkYcollisions( y_col )
	-- returns array of tiles intersecting {x = , y = }
	local tiles = {} 	 -- array of tiles
	local layer = map.tl["Ground"]
	local xchecking_pos = {self.x-self.w/2+1, self.x+self.w/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(xchecking_pos[i] / map.tileWidth)
		local tileY = math.floor(y_col / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end


	if self.standing then -- standing
		y_col = y_col - 1 
		for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(xchecking_pos[i] / map.tileWidth)
		local tileY = math.floor(y_col / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end
	end

	return tiles
end

function Entity:stepXentity( nextX ) 
	local x_col -- coordinate of the forward-facing edge
	if self.x_vel > 0 then -- facing right
		x_col = nextX + self.w/2
	elseif self.x_vel < 0 then  -- facing left
		x_col = nextX - self.w/2
	end

	local intersecting_tiles = self:checkXcollisions(x_col)

	-- Check which obstacle is the closest (in this case they are all at the same distance)
	local distX = nextX - self.x

	for i, tile in ipairs(intersecting_tiles) do
		--print("tile - x: " .. tile.x .. " , y: " .. tile.y .. " , y0: " .. tostring(tile.y0) .. " , y1: " .. tostring(tile.y1))
		if self.onslope == "right" then 
			if self.x_vel > 0 and tile.y0 <= tile.y1 and (tile.y*map.tileHeight+tile.y0) < self.y then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 == tile.y1 and (tile.x+1)*map.tileWidth < self.x then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end
		elseif self.onslope == "left" then 
			if self.x_vel > 0 and tile.y0 == tile.y1 and (tile.x)*map.tileWidth > self.x  then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 >= tile.y1 and (tile.y*map.tileHeight+tile.y0) < self.y then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end	
		else 	
			if self.x_vel > 0 and tile.y0 <= tile.y1 then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 >= tile.y1 then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end
		end

	end

	return distX
end

function Entity:stepYentity( nextY )
	local y_col -- coordinate of the forward-facing edge

	if self.y_vel < 0 then -- facing up
		y_col = nextY - self.h/2
	else 				  -- facing down
		y_col = nextY + self.h/2
	end

	local intersecting_tiles = self:checkYcollisions(y_col)

	-- Check which obstacle is the closest (in this case they are all at the same distance)
	local distY = nextY-self.y
	local distTempY = 0
	local stoplooking = false

	for i, tile in ipairs(intersecting_tiles) do
		--print("tile - x: " .. tile.x .. " , y: " .. tile.y .. " , y0: " .. tostring(tile.y0) .. " , y1: " .. tostring(tile.y1))
		if self.y_vel >= 0 then -- facing down 

			local slopepos

			if self.x < (tile.x*map.tileWidth) then 
				slopepos = math.min(tile.y0,tile.y1)+tile.y0
			elseif self.x > ((tile.x+1)*map.tileWidth) then
				slopepos = math.min(tile.y0,tile.y1)+tile.y1
			else
				if tile.y1 > tile.y0 then -- slope descending to the right
					slopepos = math.min(tile.y0,tile.y1)+(tile.y1-tile.y0)*self.relativepos/32
				else
					slopepos = math.min(tile.y0,tile.y1)+(tile.y0-tile.y1)*(32-self.relativepos)/32
				end
				
				stoplooking = true -- Consider slope on which the player is
				distY = (tile.y*map.tileHeight + slopepos) - (self.y + self.h/2)

			end

			if not(stoplooking) then
				distY = math.min(distY, (tile.y*map.tileHeight + slopepos)- (self.y + self.h/2) )
			end

		else  -- facing up
			if math.abs(distY) > math.abs((tile.y+1)*map.tileHeight - (self.y - self.h/2)) then
				distY = (tile.y+1)*map.tileHeight - (self.y - self.h/2) 
			end
		end
	end

	-- Je sais pas trop d'ou vient ce bug. Si on enleve cette ligne, le player est teleporté sur la slope quand il descend dessus
	if self.y_vel > 0 and distY > nextY-self.y then 
		distY = nextY-self.y
	end
	--distY = 0

	if distY == 0 then -- no y movement
		if self.y_vel > 0 then -- facing down
			self:collide("floor")
		else -- facing up
			self:collide("ceiling")
		end
	end

	return distY
	
end

function Entity:checkAmmocollisions( x_col, y_col ) -- Check if collides with collectible ammos on map
	-- returns array of tiles intersecting {x = , y = }
	local tiles = {} 	 -- array of tiles
	local layer = map.tl["Ammo"]
	local ychecking_pos = {self.y-self.h/2+1, self.y+self.h/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(x_col / map.tileWidth)
		local tileY = math.floor(ychecking_pos[i] / map.tileHeight)

		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			layer.tileData:set(tileX, tileY,nil)
			table.insert(tiles, mytile)
		end
	end

	local xchecking_pos = {self.x-self.w/2+1, self.x+self.w/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(xchecking_pos[i] / map.tileWidth)
		local tileY = math.floor(y_col / map.tileHeight)

		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			tile.properties["visible"] = false
			layer.tileData:set(tileX, tileY,nil)
			table.insert(tiles, mytile)
		end
	end 

	return tiles
end

function Entity:checkSpikecollisions( x_col, y_col ) -- check if collides with a spike
	-- returns array of tiles intersecting {x = , y = }
	local tiles = {} 	 -- array of tiles
	local layer = map.tl["Spike"]
	local ychecking_pos = {self.y-self.h/2+1, self.y+self.h/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(x_col / map.tileWidth)
		local tileY = math.floor(ychecking_pos[i] / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end

	local xchecking_pos = {self.x-self.w/2+1, self.x+self.w/2-1}

	for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(xchecking_pos[i] / map.tileWidth)
		local tileY = math.floor(y_col / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end


	if self.standing then -- standing
		y_col = y_col - 1 
		for i = 1,2,1 do -- check for all ychecking_pos (here size = 2)
		local tileX = math.floor(xchecking_pos[i] / map.tileWidth)
		local tileY = math.floor(y_col / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		if not(tile==nil) then
			local mytile = {x = tileX, y = tileY, y0 = tile.properties["y0"], y1 = tile.properties["y1"]}
			table.insert(tiles, mytile)
		end
	end
	end

	return tiles
end


function Entity:collide(event)
	if event == "floor" then
		self.y_vel = 0
		self.standing = true
	end
	if event == "ceiling" then
		self.y_vel = 0
	end
end

function Entity:getState()
	local tempState = ""
	if self.standing then
		if self.x_vel > 0 then
			tempState = "right"
		elseif self.x_vel < 0 then
			tempState = "left"
		else
			tempState = "stand"
		end
	end

	if self.y_vel > 0 then
		tempState = "fall"
	elseif self.y_vel < 0 then
		tempState = "jump"
	end
	
	return tempState
end

function Entity:checkifOnslope( )
	local layer = map.tl["Ground"]

	local tileX = math.floor(self.x / map.tileWidth)
	local tileY = math.floor((self.y+self.h/2) / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	if not(tile==nil) then
		if (tile.properties["y0"] > tile.properties["y1"]) then
			self.onslope = "right"
		elseif (tile.properties["y0"] < tile.properties["y1"]) then
			self.onslope = "left"	
		else 
			self.onslope = "false"
		end
	else 
		self.onslope = "false"	
	end
end

function checkCollide(x,y) -- Check collision with ground
	local layer = map.tl["Ground"]

	local tileX = math.floor(x / map.tileWidth)
	local tileY = math.floor(y/ map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	if not(tile==nil) then
		return true
	else 
		return false
	end
end

function Point_Rectangle_CollisionCheck(x1,y1, x2,y2,w2,h2)
	local check
	if x1 > (x2 - w2/2) and  x1 < (x2 + w2/2) and y1 > (y2 - h2/2) and  y1 < (y2 + h2/2) then
		check = true
	else
		check = false
	end
	return check
end

function Entity:update(dt)

	self:checkifOnslope()
	self.state = self:getState()

	self.y_vel = self.y_vel + (world.gravity * dt)
	self.y_vel = math.min(self.y_vel,FLYSPEED)

	local nextY = self.y + (self.y_vel*dt)
	local nextX = self.x + (self.x_vel*dt)
	
	if not(self.x_vel == 0) then
		self.x = self.x + self:stepX(nextX)
	end

	self.relativepos = self.x % 32
	self.y = self.y + self:stepY(nextY)


end

function  Entity:draw( )

	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h)
	love.graphics.setColor(255,255,255)

end

function updateEntities(dt)
	for i, entity in ipairs(entities) do
		entity:update(dt)
	end
end

function drawEntities()
	for i, entity in ipairs(entities) do
		entity:draw()
	end
end

