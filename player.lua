Player = Class {
  init = function(self, world, star)
    self.body = love.physics.newBody(world, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, "dynamic");
    self.shape = love.physics.newCircleShape(BALL_SIZE);
    self.fixture = love.physics.newFixture(self.body, self.shape);
    self.fixture:setRestitution(0.3);
    self.velocity = 0;
    self.gamepadVelocity = 0;

    self.leftPressed = false;
    self.rightPressed = false;

    self.jumpSound = love.audio.newSource("asset/sound/jump.wav", "static");
    self.jumpSound:setVolume(0.3);

    self.jumpSystem = love.graphics.newParticleSystem(star, 500);
    self.jumpSystem:setParticleLifetime(0.3, 0.5);
    self.jumpSystem:setSpeed(100, 300);
    self.jumpSystem:setSpread(math.pi * 2);
    self.jumpSystem:setSizes(0.6);
    self.jumpSystem:setColors(
      1, 1, 0, 1,
      1, 0, 0, 0
    );
  end
}

function Player:jump()
  self.body:applyLinearImpulse(0, -BALL_SPEED * 3 / 2);
  self.jumpSound:stop();
  self.jumpSound:play();

  self.jumpSystem:setPosition(self.body:getX(), self.body:getY() + self.shape:getRadius());
  self.jumpSystem:emit(100);
end

function Player:update(dt)
  self.velocity = 0;

  if self.leftPressed then
    self.velocity = self.velocity - BALL_SPEED;
  end

  if self.rightPressed then
    self.velocity = self.velocity + BALL_SPEED;
  end

  if not self.leftPressed and not self.rightPressed then
    self.velocity = self.gamepadVelocity;
  end

  self.body:applyForce(self.velocity, 0);
  self.jumpSystem:update(dt);
end

function Player:draw()
  love.graphics.setColor(1, 0, 0);
  love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius());

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(self.jumpSystem, 0, 0);
end

function Player:drawDebug()
  love.graphics.setColor(1, 1, 1);
  if self.leftPressed then
    love.graphics.circle("fill", 10, 10, 5);
  end

  if self.rightPressed then
    love.graphics.circle("fill", 20, 10, 5);
  end
end
