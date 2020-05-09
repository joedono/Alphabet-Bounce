require "constants";

last_pressed = "";

function love.load()
  setFullscreen(FULLSCREEN);
  love.mouse.setVisible(false);
  love.graphics.setDefaultFilter("nearest", "nearest");
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

function love.draw()
  CANVAS:renderTo(function()
    love.graphics.clear();
    love.graphics.setColor(1, 1, 1);
    love.graphics.print("I don't have anything to hide", 10, 10);
    love.graphics.print("Last Pressed: " .. last_pressed, 10, 20);
  end);

  love.graphics.setColor(1, 1, 1);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end

-- Helpers
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
