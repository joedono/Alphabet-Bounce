FULLSCREEN = true;
SCREEN_WIDTH = 1600;
SCREEN_HEIGHT = 900;

KEY_LEFT = "left";
KEY_RIGHT = "right";
KEY_JUMP = "a";
KEY_QUIT = "escape";

GAMEPAD_LEFT = "dpleft";
GAMEPAD_RIGHT = "dpright";
GAMEPAD_UP = "dpup";
GAMEPAD_DOWN = "dpdown";
GAMEPAD_A = "a";
GAMEPAD_B = "b";
GAMEPAD_X = "x";
GAMEPAD_Y = "y";
GAMEPAD_LEFT_STICK = "leftstick";
GAMEPAD_RIGHT_STICK = "rightstick";
GAMEPAD_LEFT_SHOULDER = "leftshoulder";
GAMEPAD_RIGHT_SHOULDER = "rightshoulder";
GAMEPAD_START = "start";
GAMEPAD_QUIT = "back";

GAMEPAD_DEADZONE = 0.75;

WALL_SIZE = 50;
BALL_SIZE = 20;
BALL_SPEED = 300;

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
LETTER_TIMER = 3;

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
  ball.fixture = love.physics.newFixture(ball.body, ball.shape);
  ball.fixture:setRestitution(0.5);
  ball.velocity = 0;

  letter = {};
  letter.x = SCREEN_WIDTH / 2;
  letter.y = 280;
  letter.r = 200;
  letter.visible = false;
  letter.curLetter = "I";

  paused = false;
  displayFont = love.graphics.newFont(500);
  scoreFont = love.graphics.newFont(100);
  score = 0;
  letterTimer = LETTER_TIMER;

  jumpSound = love.audio.newSource("asset/sound/jump.wav", "static");
  pickupSound = love.audio.newSource("asset/sound/pickup.wav", "static");
  love.audio.setVolume(0.1);

  star = love.graphics.newImage("asset/image/star.png");

  system = love.graphics.newParticleSystem(star, 1000);
  system:setPosition(letter.x, letter.y);
  system:setEmissionArea("uniform", letter.r, letter.r);
  system:setTexture(star);
  system:setParticleLifetime(1, 2);
  system:setSpeed(300, 300);
  system:setSpread(math.pi * 2);
  system:setColors(1, 1, 1, 1, 1, 1, 1, 0);
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
    leftPressed = true;
  end

  if key == KEY_RIGHT then
    rightPressed = true;
  end

  if key == KEY_JUMP then
    ball.body:applyLinearImpulse(0, -BALL_SPEED);
    jumpSound:stop();
    jumpSound:play();
  end
end

function love.keyreleased(key, unicode)
  if key == KEY_LEFT then
    leftPressed = false;
  end

  if key == KEY_RIGHT then
    rightPressed = false;
  end
end

function love.gamepadpressed(joystick, button)
  if button == GAMEPAD_QUIT then
    love.event.quit();
  end

  if button == GAMEPAD_LEFT then
    leftPressed = true;
  end

  if button == GAMEPAD_RIGHT then
    rightPressed = true;
  end

  if button == GAMEPAD_A or
    button == GAMEPAD_B or
    button == GAMEPAD_X or 
    button == GAMEPAD_Y or
    button == GAMEPAD_LEFT_STICK or
    button == GAMEPAD_RIGHT_STICK or
    button == GAMEPAD_LEFT_SHOULDER or
    button == GAMEPAD_RIGHT_SHOULDER then
      ball.body:applyLinearImpulse(0, -BALL_SPEED);
      jumpSound:stop();
      jumpSound:play();
  end
end

function love.gamepadreleased(joystick, button)
  if button == GAMEPAD_LEFT then
    leftPressed = false;
  end

  if button == GAMEPAD_RIGHT then
    rightPressed = false;
  end
end

function love.gamepadaxis(joystick, axis, value)
  if axis == "leftx" or axis == "rightx" then
    if math.abs(value) > GAMEPAD_DEADZONE then
      if value < 0 then
        leftPressed = true
      else
        rightPressed = true;
      end
    else
      leftPressed = false;
      rightPressed = false;
    end
  end

  if axis == "triggerleft" and value > GAMEPAD_DEADZONE then -- L2
    ball.body:applyLinearImpulse(0, -BALL_SPEED);
    jumpSound:stop();
    jumpSound:play();
  end

  if axis == "triggerright" and value > GAMEPAD_DEADZONE then -- R2
    ball.body:applyLinearImpulse(0, -BALL_SPEED);
    jumpSound:stop();
    jumpSound:play();
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
  end

  -- Check for letter pickup
  if letter.visible then
    local dx = ball.body:getX() - letter.x;
    local dy = ball.body:getY() - letter.y;
    local distance = math.sqrt (dx * dx + dy * dy);

    if distance <= letter.r then
      letter.visible = false;
      score = score + 1;
      system:emit(1000);
      pickupSound:play();
    end
  end

  ball.velocity = 0;

  if leftPressed then
    ball.velocity = ball.velocity - BALL_SPEED;
  end

  if rightPressed then
    ball.velocity = ball.velocity + BALL_SPEED;
  end

  ball.body:applyForce(ball.velocity, 0);
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
      love.graphics.setColor(0, 1, 1);
      -- love.graphics.circle("line", letter.x, letter.y, letter.r);
      love.graphics.printf(letter.curLetter, 0, 0, SCREEN_WIDTH, "center");
    end

    love.graphics.setColor(math.random(), math.random(), math.random());
    love.graphics.draw(system, 0, 0);

    -- Draw Ball
    love.graphics.setColor(1, 0, 0);
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius());

    -- Draw Ball Line
    local angle = ball.body:getAngle();
    local x1, y1 = ball.body:getWorldCenter()
    local x2 = math.cos(angle) * BALL_SIZE + x1;
    local y2 = math.sin(angle) * BALL_SIZE + y1;
    love.graphics.line(x1, y1, x2, y2);

    -- Draw score
    love.graphics.setColor(1, 1, 1);
    love.graphics.setFont(scoreFont);
    love.graphics.print(score, 50, 40);
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end
