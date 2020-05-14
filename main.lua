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

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
LETTER_TIMER = 3;

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

  ball = {};
  ball.body = love.physics.newBody(world, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, "dynamic");
  ball.shape = love.physics.newCircleShape(BALL_SIZE);
  ball.fixture = love.physics.newFixture(ball.body, ball.shape);
  ball.fixture:setRestitution(0.6);
  ball.velocity = 0;
  ball.gamepadVelocity = 0;

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
  hudFont = love.graphics.newFont(12);
  score = 0;
  letterTimer = LETTER_TIMER;

  jumpSound = love.audio.newSource("asset/sound/jump.wav", "static");
  jumpSound:setVolume(0.3);
  pickupSounds = {
    ["A"] = love.audio.newSource("asset/sound/A.wav", "static"),
    ["B"] = love.audio.newSource("asset/sound/B.wav", "static"),
    ["C"] = love.audio.newSource("asset/sound/C.wav", "static"),
    ["D"] = love.audio.newSource("asset/sound/D.wav", "static"),
    ["E"] = love.audio.newSource("asset/sound/E.wav", "static"),
    ["F"] = love.audio.newSource("asset/sound/F.wav", "static"),
    ["G"] = love.audio.newSource("asset/sound/G.wav", "static"),
    ["H"] = love.audio.newSource("asset/sound/H.wav", "static"),
    ["I"] = love.audio.newSource("asset/sound/I.wav", "static"),
    ["J"] = love.audio.newSource("asset/sound/J.wav", "static"),
    ["K"] = love.audio.newSource("asset/sound/K.wav", "static"),
    ["L"] = love.audio.newSource("asset/sound/L.wav", "static"),
    ["M"] = love.audio.newSource("asset/sound/M.wav", "static"),
    ["N"] = love.audio.newSource("asset/sound/N.wav", "static"),
    ["O"] = love.audio.newSource("asset/sound/O.wav", "static"),
    ["P"] = love.audio.newSource("asset/sound/P.wav", "static"),
    ["Q"] = love.audio.newSource("asset/sound/Q.wav", "static"),
    ["R"] = love.audio.newSource("asset/sound/R.wav", "static"),
    ["S"] = love.audio.newSource("asset/sound/S.wav", "static"),
    ["T"] = love.audio.newSource("asset/sound/T.wav", "static"),
    ["U"] = love.audio.newSource("asset/sound/U.wav", "static"),
    ["V"] = love.audio.newSource("asset/sound/V.wav", "static"),
    ["W"] = love.audio.newSource("asset/sound/W.wav", "static"),
    ["X"] = love.audio.newSource("asset/sound/X.wav", "static"),
    ["Y"] = love.audio.newSource("asset/sound/Y.wav", "static"),
    ["Z"] = love.audio.newSource("asset/sound/Z.wav", "static"),
    ["1"] = love.audio.newSource("asset/sound/1.wav", "static"),
    ["2"] = love.audio.newSource("asset/sound/2.wav", "static"),
    ["3"] = love.audio.newSource("asset/sound/3.wav", "static"),
    ["4"] = love.audio.newSource("asset/sound/4.wav", "static"),
    ["5"] = love.audio.newSource("asset/sound/5.wav", "static"),
    ["6"] = love.audio.newSource("asset/sound/6.wav", "static"),
    ["7"] = love.audio.newSource("asset/sound/7.wav", "static"),
    ["8"] = love.audio.newSource("asset/sound/8.wav", "static"),
    ["9"] = love.audio.newSource("asset/sound/9.wav", "static")
  };

  star = love.graphics.newImage("asset/image/star.png");

  axisValue = 0;

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
  if button == GAMEPAD_QUIT and leftPressed then
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
      ball.gamepadVelocity = value * BALL_SPEED;
    else
      ball.gamepadVelocity = 0;
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
    letter.offset = math.random(-SCREEN_WIDTH / 3, SCREEN_WIDTH / 3);
    letter.color = { math.random(), math.random(), math.random() };
    system:setPosition(letter.x + letter.offset, letter.y);
  end

  -- Check for letter pickup
  if letter.visible then
    local dx = ball.body:getX() - letter.x - letter.offset;
    local dy = ball.body:getY() - letter.y;
    local distance = math.sqrt (dx * dx + dy * dy);

    if distance <= letter.r then
      letter.visible = false;
      score = score + 1;
      system:emit(1000);
      pickupSounds[letter.curLetter]:play();
    end
  end

  ball.velocity = 0;

  if leftPressed then
    ball.velocity = ball.velocity - BALL_SPEED;
  end

  if rightPressed then
    ball.velocity = ball.velocity + BALL_SPEED;
  end

  if not leftPressed and not rightPressed then
    ball.velocity = ball.gamepadVelocity;
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
      love.graphics.setColor(letter.color);
      love.graphics.printf(letter.curLetter, letter.offset, 0, SCREEN_WIDTH, "center");
    end

    love.graphics.setColor(1, 1, 1);
    love.graphics.draw(system, 0, 0);

    -- Draw Ball
    love.graphics.setColor(1, 0, 0);
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius());

    love.graphics.setColor(1, 1, 1);
    if leftPressed then
      love.graphics.circle("fill", 10, 10, 5);
    end

    if rightPressed then
      love.graphics.circle("fill", 20, 10, 5);
    end
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end
