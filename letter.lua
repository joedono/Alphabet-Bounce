Letter = Class {
  init = function(self)
    self.x = roomWidth / 2;
    self.y = 280;
    self.r = 200;
    self.color = { 1, 0, 0 };
    self.offset = 0;
    self.visible = false;
    self.curLetter = "I";
    self.letterTimer = LETTER_TIMER;

    self.system = love.graphics.newParticleSystem(star, 1000);
    self.system:setPosition(self.x, self.y);
    self.system:setEmissionArea("uniform", self.r, self.r);
    self.system:setParticleLifetime(1, 2);
    self.system:setSpeed(10, 300);
    self.system:setSpread(math.pi * 2);
    self.system:setColors(
      0, 1, 1, 1,
      0, 1, 1, 0.75,
      1, 1, 0, 0.5,
      1, 0, 1, 0.25,
      0, 0, 0, 0
    );

    self.displayFont = love.graphics.newFont(500);
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
    self.offset = math.random(-roomWidth / 3, roomWidth / 3);
    self.color = { math.random(), math.random(), math.random() };
    self.system:setPosition(self.x + self.offset, self.y);
  end

  self.system:update(dt);
end

function Letter:tryPickup(playerX, playerY)
  if self.visible then
    local dx = playerX - self.x - self.offset;
    local dy = playerY - self.y;
    local distance = math.sqrt (dx * dx + dy * dy);
  
    if distance <= self.r then
      self.visible = false;
      self.system:emit(1000);
      return true;
    end
  end

  return false;
end

function Letter:draw()
  if self.visible then
    love.graphics.setFont(self.displayFont);
    love.graphics.setColor(self.color);
    love.graphics.printf(self.curLetter, self.x + self.offset - self.r, 0, self.r * 2, "center");
  end

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(self.system, 0, 0);
end
