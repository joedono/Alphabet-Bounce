Letter = Class {
  init = function(self)
    self.x = 0;
    self.y = 0;
    self.r = 50;
    self.color = { 1, 0, 0 };
    self.visible = false;
    self.curLetter = "I";
    self.letterTimer = LETTER_TIMER;

    self.system = love.graphics.newParticleSystem(star, 500);
    self.system:setPosition(self.x, self.y);
    self.system:setEmissionArea("uniform", self.r, self.r);
    self.system:setParticleLifetime(1, 2);
    self.system:setSpeed(10, 300);
    self.system:setSpread(math.pi * 2);
    self.system:setSizes(0.5);
    self.system:setColors(
      0, 1, 1, 1,
      0, 1, 1, 0.75,
      1, 1, 0, 0.5,
      1, 0, 1, 0.25,
      0, 0, 0, 0
    );

    self.displayFont = love.graphics.newFont(100);
  end
}

function Letter:update(dt)
  if self.letterTimer > 0 and not self.visible then
    self.letterTimer = self.letterTimer - dt;
  end

  -- Show new letter
  if self.letterTimer <= 0 then
    local index = math.random(string.len(ALPHABET));
    self.curLetter = string.sub(ALPHABET, index, index);
    self.visible = true;
    self.letterTimer = LETTER_TIMER;
    self.color = { math.random(), math.random(), math.random() };

    local spawn = spawns[math.random(#spawns - 1)];
    self.x = spawn.x;
    self.y = spawn.y;

    self.system:setPosition(self.x, self.y);
  end

  self.system:update(dt);
end

function Letter:tryPickup(playerX, playerY)
  if self.visible then
    local dx = playerX - self.x;
    local dy = playerY - self.y;
    local distance = math.sqrt (dx * dx + dy * dy);
  
    if distance <= self.r then
      self.visible = false;
      self.system:emit(500);
      return true;
    end
  end

  return false;
end

function Letter:draw()
  if self.visible then
    love.graphics.setFont(self.displayFont);
    love.graphics.setColor(self.color);
    love.graphics.printf(self.curLetter, self.x - self.r, self.y - self.r, self.r * 2, "center");
  end

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(self.system, 0, 0);

  -- love.graphics.setColor(1, 1, 1);
  -- love.graphics.circle("line", self.x, self.y, self.r);
end
