Class = require "lib/hump/class";
Vector = require "lib/hump/vector";

require "lib/general";

require "config/constants";
require "player";
require "letter";

function love.load()
  setFullscreen(FULLSCREEN);
  love.mouse.setVisible(false);
  love.graphics.setDefaultFilter("nearest", "nearest");
  math.randomseed(os.time());

  love.physics.setMeter(32);
  world = love.physics.newWorld(0, 9.8 * 128, true);

  local source = love.filesystem.load("config/room.lua")();
  roomWidth = source.width * source.tilewidth;
  roomHeight = source.height * source.tileheight;
  loadWalls(source);
  loadSpawns(source);

  paused = false;
  hudFont = love.graphics.newFont(12);
  score = 0;

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

  player = Player(world, star);
  letter = Letter(star);
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

function loadWalls(source)
  walls = {};
  local wallsSource;
  for index, layer in pairs(source.layers) do
    if layer.name == "Walls" then
      wallsSource = layer.objects;
    end
  end

  for index, wallSource in pairs(wallsSource) do
    local wall = {};
    wall.body = love.physics.newBody(world, wallSource.x + wallSource.width / 2, wallSource.y + wallSource.height / 2);
    wall.shape = love.physics.newRectangleShape(wallSource.width, wallSource.height);
    wall.fixture = love.physics.newFixture(wall.body, wall.shape);
    table.insert(walls, wall);
  end
end

function loadSpawns(source)
  spawns = {};
  local spawnsSource;
  for index, layer in pairs(source.layers) do
    if layer.name == "Spawns" then
      spawnsSource = layer.objects;
    end
  end

  for index, spawnSource in pairs(spawnsSource) do
    local spawn = {
      x = spawnSource.x,
      y = spawnSource.y
    };

    table.insert(spawns, spawn);
  end
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
      player.gamepadVelocity = value * BALL_SPEED;
    else
      player.gamepadVelocity = 0;
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

  letter:update(dt);
  player:update(dt);

  if letter:tryPickup(player.body:getX(), player.body:getY()) then
    score = score + 1;
    pickupSounds[letter.curLetter]:play();
  end

  world:update(dt);
end

function love.draw()
  CANVAS:renderTo(function()
    love.graphics.clear();
    love.graphics.setColor(1, 1, 1);

    -- Draw Walls
    love.graphics.setColor(0, 1, 0);
    for index, wall in pairs(walls) do
      love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()));
		end

    letter:draw();
    player:draw(letter);

    player:drawDebug();
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end
