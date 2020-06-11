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
    ["A"] = love.audio.newSource("asset/sound/letters/A.wav", "static"),
    ["B"] = love.audio.newSource("asset/sound/letters/B.wav", "static"),
    ["C"] = love.audio.newSource("asset/sound/letters/C.wav", "static"),
    ["D"] = love.audio.newSource("asset/sound/letters/D.wav", "static"),
    ["E"] = love.audio.newSource("asset/sound/letters/E.wav", "static"),
    ["F"] = love.audio.newSource("asset/sound/letters/F.wav", "static"),
    ["G"] = love.audio.newSource("asset/sound/letters/G.wav", "static"),
    ["H"] = love.audio.newSource("asset/sound/letters/H.wav", "static"),
    ["I"] = love.audio.newSource("asset/sound/letters/I.wav", "static"),
    ["J"] = love.audio.newSource("asset/sound/letters/J.wav", "static"),
    ["K"] = love.audio.newSource("asset/sound/letters/K.wav", "static"),
    ["L"] = love.audio.newSource("asset/sound/letters/L.wav", "static"),
    ["M"] = love.audio.newSource("asset/sound/letters/M.wav", "static"),
    ["N"] = love.audio.newSource("asset/sound/letters/N.wav", "static"),
    ["O"] = love.audio.newSource("asset/sound/letters/O.wav", "static"),
    ["P"] = love.audio.newSource("asset/sound/letters/P.wav", "static"),
    ["Q"] = love.audio.newSource("asset/sound/letters/Q.wav", "static"),
    ["R"] = love.audio.newSource("asset/sound/letters/R.wav", "static"),
    ["S"] = love.audio.newSource("asset/sound/letters/S.wav", "static"),
    ["T"] = love.audio.newSource("asset/sound/letters/T.wav", "static"),
    ["U"] = love.audio.newSource("asset/sound/letters/U.wav", "static"),
    ["V"] = love.audio.newSource("asset/sound/letters/V.wav", "static"),
    ["W"] = love.audio.newSource("asset/sound/letters/W.wav", "static"),
    ["X"] = love.audio.newSource("asset/sound/letters/X.wav", "static"),
    ["Y"] = love.audio.newSource("asset/sound/letters/Y.wav", "static"),
    ["Z"] = love.audio.newSource("asset/sound/letters/Z.wav", "static"),
    ["1"] = love.audio.newSource("asset/sound/letters/1.wav", "static"),
    ["2"] = love.audio.newSource("asset/sound/letters/2.wav", "static"),
    ["3"] = love.audio.newSource("asset/sound/letters/3.wav", "static"),
    ["4"] = love.audio.newSource("asset/sound/letters/4.wav", "static"),
    ["5"] = love.audio.newSource("asset/sound/letters/5.wav", "static"),
    ["6"] = love.audio.newSource("asset/sound/letters/6.wav", "static"),
    ["7"] = love.audio.newSource("asset/sound/letters/7.wav", "static"),
    ["8"] = love.audio.newSource("asset/sound/letters/8.wav", "static"),
    ["9"] = love.audio.newSource("asset/sound/letters/9.wav", "static")
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
    wall.body:setType("kinematic");
    wall.shape = love.physics.newRectangleShape(wallSource.width, wallSource.height);
    wall.fixture = love.physics.newFixture(wall.body, wall.shape);
    wall.type = wallSource.type;

    if wall.type == "Moving" then
      wall.startPos = {
        x = wallSource.properties["StartX"],
        y = wallSource.properties["StartY"]
      };

      wall.endPos = {
        x = wallSource.properties["EndX"],
        y = wallSource.properties["EndY"]
      };

      wall.movingDir = true;
      wall.moveTimer = 0;
    end

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
    player.facing = -1;
  end

  if key == KEY_RIGHT then
    player.rightPressed = true;
    player.facing = 1;
  end

  if key == KEY_JUMP then
    player:jump();
  end

  if key == KEY_FIRE then
    player:toggleFire(true);
  end
end

function love.keyreleased(key, unicode)
  if key == KEY_LEFT then
    player.leftPressed = false;
  end

  if key == KEY_RIGHT then
    player.rightPressed = false;
  end

  if key == KEY_FIRE then
    player:toggleFire(false);
  end
end

function love.gamepadpressed(joystick, button)
  if button == GAMEPAD_QUIT and player.leftPressed then
    love.event.quit();
  end

  if button == GAMEPAD_LEFT then
    player.leftPressed = true;
    player.facing = -1;
  end

  if button == GAMEPAD_RIGHT then
    player.rightPressed = true;
    player.facing = 1;
  end

  if button == GAMEPAD_A or
    button == GAMEPAD_B or
    button == GAMEPAD_LEFT_STICK or
    button == GAMEPAD_RIGHT_STICK or
    button == GAMEPAD_LEFT_SHOULDER or
    button == GAMEPAD_RIGHT_SHOULDER then
      player:jump();
  end

  if button == GAMEPAD_X or
    button == GAMEPAD_Y then
      player:toggleFire(true);
  end
end

function love.gamepadreleased(joystick, button)
  if button == GAMEPAD_LEFT then
    player.leftPressed = false;
  end

  if button == GAMEPAD_RIGHT then
    player.rightPressed = false;
  end

  if button == GAMEPAD_X or
    button == GAMEPAD_Y then
      player:toggleFire(false);
  end
end

function love.gamepadaxis(joystick, axis, value)
  if axis == "leftx" or axis == "rightx" then
    if math.abs(value) > GAMEPAD_DEADZONE then
      player.gamepadVelocity = value * BALL_SPEED;
      if value < 0 then
        player.facing = -1;
      elseif value > 0 then
        player.facing = 1;
      end
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

  moveWalls(dt);
  world:update(dt);
end

function moveWalls(dt)
  for index, wall in pairs(walls) do
    if wall.type == "Moving" then
      wall.moveTimer = wall.moveTimer + dt;

      if wall.moveTimer > WALL_MOVE_TIMER then
        wall.moveTimer = 0;
        wall.moving = not wall.moving;
      end

      local progress = wall.moveTimer / WALL_MOVE_TIMER;
      local x = 0;
      local y = 0;

      if wall.moving then
        x = lerp(wall.startPos.x, wall.endPos.x, progress);
        y = lerp(wall.startPos.y, wall.endPos.y, progress);
      else
        x = lerp(wall.endPos.x, wall.startPos.x, progress);
        y = lerp(wall.endPos.y, wall.startPos.y, progress);
      end

      wall.body:setPosition(x, y);
    end
  end
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
