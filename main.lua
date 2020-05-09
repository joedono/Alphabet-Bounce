require "constants";

last_pressed = "";

function love.load()
  setFullscreen(FULLSCREEN);
  love.mouse.setVisible(false);
  love.graphics.setDefaultFilter("nearest", "nearest");

  love.physics.setMeter(64);
  world = love.physics.newWorld(0, 9.8*64, true);

  createWalls();
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

function createWalls()
  walls = {};

  local ground = {};
  ground.body = love.physics.newBody(world, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 25);
  ground.shape = love.physics.newRectangleShape(SCREEN_WIDTH, 50);
  ground.fixture = love.physics.newFixture(ground.body, ground.shape);
  table.insert(walls, ground);

  local wallLeft = {};
  wallLeft.body = love.physics.newBody(world, 25, SCREEN_HEIGHT / 2);
  wallLeft.shape = love.physics.newRectangleShape(50, SCREEN_HEIGHT);
  wallLeft.fixture = love.physics.newFixture(wallLeft.body, wallLeft.shape);
  table.insert(walls, wallLeft);

  local wallRight = {};
  wallRight.body = love.physics.newBody(world, SCREEN_WIDTH - 25, SCREEN_HEIGHT / 2);
  wallRight.shape = love.physics.newRectangleShape(50, SCREEN_HEIGHT);
  wallRight.fixture = love.physics.newFixture(wallRight.body, wallRight.shape);
  table.insert(walls, wallRight);

  local ceiling = {};
  ceiling.body = love.physics.newBody(world, SCREEN_WIDTH / 2, 25);
  ceiling.shape = love.physics.newRectangleShape(SCREEN_WIDTH, 50);
  ceiling.fixture = love.physics.newFixture(ceiling.body, ceiling.shape);
  table.insert(walls, ceiling);
end

function love.keypressed(key, unicode)
  if key == KEY_QUIT then
    love.event.quit();
  end

  last_pressed = key;
end

function love.gamepadpressed(joystick, button)
  if button == GAMEPAD_QUIT then
    love.event.quit();
  end

  last_pressed = button;
end

function love.gamepadaxis(joystick, axis, value)
  if axis == "leftx" then
    -- X Movement
  end

  if axis == "lefty" then
    -- Y Movement
  end

  if axis == "rightx" then
    -- X Camera
  end

  if axis == "righty" then
    -- Y Camera
  end

  if axis == "triggerleft" then -- L2
    if value > GAMEPAD_DEADZONE then
      -- Move
    else
      -- Stop
    end
  end

  if axis == "triggerright" then -- R2
    if value > GAMEPAD_DEADZONE then
      -- Move
    else
      -- Stop
    end
  end
end

function love.update(dt)
  world:update(dt);
end

function love.draw()
  CANVAS:renderTo(function()
    love.graphics.clear();
    love.graphics.setColor(1, 1, 1);

    drawWalls();
    
    love.graphics.print("Last Pressed: " .. last_pressed, 10, 10);
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end

function drawWalls()
  love.graphics.setColor(0, 1, 0);

  for index, wall in pairs(walls) do
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	end
end
