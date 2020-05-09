require "constants";

last_pressed = "";

function love.load()
  setFullscreen(FULLSCREEN);
  love.mouse.setVisible(false);
  love.graphics.setDefaultFilter("nearest", "nearest");

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

  ball = {};
  ball.body = love.physics.newBody(world, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, "dynamic");
  ball.shape = love.physics.newCircleShape(BALL_SIZE);
  ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1);
	ball.fixture:setRestitution(0.9);

  paused = false;
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
    paused = false;
  else
    paused = true;
  end
end

function love.keypressed(key, unicode)
  if key == KEY_QUIT then
    love.event.quit();
  end
end

function love.gamepadpressed(joystick, button)
  if button == GAMEPAD_QUIT then
    love.event.quit();
  end
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

    -- Draw Walls
    love.graphics.setColor(0, 1, 0);
    love.graphics.polygon("fill", walls.left.body:getWorldPoints(walls.left.shape:getPoints()));
    love.graphics.polygon("fill", walls.right.body:getWorldPoints(walls.right.shape:getPoints()));
    love.graphics.polygon("fill", walls.up.body:getWorldPoints(walls.up.shape:getPoints()));
    love.graphics.polygon("fill", walls.down.body:getWorldPoints(walls.down.shape:getPoints()));

    -- Draw Ball
    love.graphics.setColor(0.47,0,0);
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius());
    love.graphics.setColor(1, 0, 0);
    love.graphics.circle("line", ball.body:getX(), ball.body:getY(), ball.shape:getRadius());

    -- Draw Ball Line
    local angle = ball.body:getAngle();
    local x1, y1 = ball.body:getWorldCenter()
    local x2 = math.cos(angle) * BALL_SIZE + x1;
    local y2 = math.sin(angle) * BALL_SIZE + y1;
    love.graphics.line(x1, y1, x2, y2);
    
    love.graphics.print("Last Pressed: " .. last_pressed, 60, 60);
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end
