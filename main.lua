Camera = require "lib/hump/camera";
Class = require "lib/hump/class";

require "constants";
require "player";

function love.load()
  setFullscreen(FULLSCREEN);
  love.mouse.setVisible(false);
  love.graphics.setDefaultFilter("nearest", "nearest");
  math.randomseed(os.time());

  love.physics.setMeter(64);
  world = love.physics.newWorld(0, 9.8 * 128, true);

  walls = {};
	
  walls.left = {};
  walls.left.body = love.physics.newBody(world, WALL_SIZE / 2, SCREEN_HEIGHT / 2);
  walls.left.shape = love.physics.newRectangleShape(WALL_SIZE, SCREEN_HEIGHT);
  walls.left.fixture = love.physics.newFixture(walls.left.body, walls.left.shape);

  walls.right = {};
  walls.right.body = love.physics.newBody(world, SCREEN_WIDTH - WALL_SIZE / 2, SCREEN_HEIGHT / 2);
  walls.right.shape = love.physics.newRectangleShape(WALL_SIZE, SCREEN_HEIGHT);
  walls.right.fixture = love.physics.newFixture(walls.right.body, walls.right.shape);

  walls.up = {};
  walls.up.body = love.physics.newBody(world, SCREEN_WIDTH / 2, WALL_SIZE / 2);
  walls.up.shape = love.physics.newRectangleShape(SCREEN_WIDTH, WALL_SIZE);
  walls.up.fixture = love.physics.newFixture(walls.up.body, walls.up.shape);

  walls.down = {};
  walls.down.body = love.physics.newBody(world, SCREEN_WIDTH / 2, SCREEN_HEIGHT - WALL_SIZE / 2);
  walls.down.shape = love.physics.newRectangleShape(SCREEN_WIDTH, WALL_SIZE);
  walls.down.fixture = love.physics.newFixture(walls.down.body, walls.down.shape);

  jumpSound = love.audio.newSource("asset/sound/jump.wav", "static");
  player = Player(world, jumpSound);

  letter = {};
  letter.x = SCREEN_WIDTH / 2;
  letter.y = 280;
  letter.r = 200;
  letter.color = { 1, 0, 0 };
  letter.offset = 0;
  letter.visible = false;
  letter.curLetter = "I";

  paused = false;
  displayFont = love.graphics.newFont(500);
  scoreFont = love.graphics.newFont(100);
  score = 0;
  letterTimer = LETTER_TIMER;

  pickupSound = love.audio.newSource("asset/sound/pickup.wav", "static");
  love.audio.setVolume(0.3);

  star = love.graphics.newImage("asset/image/star.png");

  system = love.graphics.newParticleSystem(star, 1000);
  system:setPosition(letter.x, letter.y);
  system:setEmissionArea("uniform", letter.r, letter.r);
  system:setTexture(star);
  system:setParticleLifetime(1, 2);
  system:setSpeed(300, 300);
  system:setSpread(math.pi * 2);
  system:setColors(
    0, 1, 1, 1,
    0, 1, 1, 0.75,
    1, 1, 0, 0.5,
    1, 0, 1, 0.25,
    0, 0, 0, 0
  );
end

function setFullscreen(fullscreen)
  love.window.setFullscreen(fullscreen);

  CANVAS = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT);

  local w = love.graphics.getWidth();
  local h = love.graphics.getHeight();
  local scaleX = 1;
  local scaleY = 1;

  if fullscreen then
    scaleX = w / SCREEN_WIDTH;
    scaleY = h / SCREEN_HEIGHT;
  end

  CANVAS_SCALE = math.min(scaleX, scaleY);
  CANVAS_OFFSET_X = w / 2 - (SCREEN_WIDTH * CANVAS_SCALE) / 2;
  CANVAS_OFFSET_Y = h / 2 - (SCREEN_HEIGHT * CANVAS_SCALE) / 2;
end

function love.focus(f)
  if not f then
    paused = true;
  else
    paused = false;
  end
end

function love.keypressed(key, unicode)
  if key == KEY_QUIT then
    love.event.quit();
  end

  if key == KEY_LEFT then
    player.leftPressed = true;
  end

  if key == KEY_RIGHT then
    player.rightPressed = true;
  end

  if key == KEY_JUMP then
    player:jump();
  end
end

function love.keyreleased(key, unicode)
  if key == KEY_LEFT then
    player.leftPressed = false;
  end

  if key == KEY_RIGHT then
    player.rightPressed = false;
  end
end

function love.gamepadpressed(joystick, button)
  if button == GAMEPAD_QUIT and leftPressed then
    love.event.quit();
  end

  if button == GAMEPAD_LEFT then
    player.leftPressed = true;
  end

  if button == GAMEPAD_RIGHT then
    player.rightPressed = true;
  end

  if button == GAMEPAD_A or
    button == GAMEPAD_B or
    button == GAMEPAD_X or 
    button == GAMEPAD_Y or
    button == GAMEPAD_LEFT_STICK or
    button == GAMEPAD_RIGHT_STICK or
    button == GAMEPAD_LEFT_SHOULDER or
    button == GAMEPAD_RIGHT_SHOULDER then
      player:jump();
  end
end

function love.gamepadreleased(joystick, button)
  if button == GAMEPAD_LEFT then
    player.leftPressed = false;
  end

  if button == GAMEPAD_RIGHT then
    player.rightPressed = false;
  end
end

function love.gamepadaxis(joystick, axis, value)
  if axis == "leftx" or axis == "rightx" then
    if math.abs(value) > GAMEPAD_DEADZONE then
      if value < 0 then
        player.leftPressed = true
      else
        player.rightPressed = true;
      end
    else
      player.leftPressed = false;
      player.rightPressed = false;
    end
  end

  if axis == "triggerleft" and value > GAMEPAD_DEADZONE then -- L2
    player:jump();
  end

  if axis == "triggerright" and value > GAMEPAD_DEADZONE then -- R2
    player:jump();
  end
end

function love.update(dt)
  if paused then
    return;
  end

  -- Run letterTimer
  if letterTimer > 0 and not letter.visible then
    letterTimer = letterTimer - dt;
  end

  -- Show new letter
  if letterTimer <= 0 then
    local index = math.random(string.len(ALPHABET));
    letter.curLetter = string.sub(ALPHABET, index, index);
    letter.visible = true;
    letterTimer = LETTER_TIMER;
    letter.offset = math.random(-SCREEN_WIDTH / 3, SCREEN_WIDTH / 3);
    letter.color = { math.random(), math.random(), math.random() };
    system:setPosition(letter.x + letter.offset, letter.y);
  end

  -- Check for letter pickup
  if letter.visible then
    local dx = player.body:getX() - letter.x - letter.offset;
    local dy = player.body:getY() - letter.y;
    local distance = math.sqrt (dx * dx + dy * dy);

    if distance <= letter.r then
      letter.visible = false;
      score = score + 1;
      system:emit(1000);
      pickupSound:play();
    end
  end

  player:update(dt);

  system:update(dt);
  world:update(dt);
end

function love.draw()
  CANVAS:renderTo(function()
    love.graphics.clear();
    love.graphics.setColor(1, 1, 1);

    -- Draw Walls
    love.graphics.setColor(0, 1, 0);
    love.graphics.polygon("fill", walls.left.body:getWorldPoints(walls.left.shape:getPoints()));
    love.graphics.polygon("fill", walls.right.body:getWorldPoints(walls.right.shape:getPoints()));
    love.graphics.polygon("fill", walls.up.body:getWorldPoints(walls.up.shape:getPoints()));
    love.graphics.polygon("fill", walls.down.body:getWorldPoints(walls.down.shape:getPoints()));

    -- Draw Letter
    if letter.visible then
      love.graphics.setFont(displayFont);
      love.graphics.setColor(letter.color);
      love.graphics.printf(letter.curLetter, letter.offset, 0, SCREEN_WIDTH, "center");
    end

    love.graphics.setColor(1, 1, 1);
    love.graphics.draw(system, 0, 0);

    -- Draw Ball
    player:draw();
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end
