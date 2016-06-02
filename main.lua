local Playback = require("Playback")
local Event = require("Event")
local KShootParser = require("KShootParser")

local parser, chart, playback
local lastevent
local source

function love.load()
  print("")

  parser, chart = KShootParser()
  --love.filesystem.newFile("songs/tests/test1/test1.ksh")
  local file = love.filesystem.newFile("songs/tests/test2/test2.ksh")
  for l in file:lines() do
    parser:parseLine(l)
  end

  --local source = love.audio.newSource("songs/tests/max_burning_blacky/inf.ogg")
  --source:play()

  playback = Playback(chart)
end

function love.update(dt)
  local event = playback:update(dt)
  if event and lastevent ~= event then
    lastevent = event
    for i=1,2 do
      local analogEvent = event.analogEvents[i]
      if analogEvent then
        print(i, analogEvent.value)
      end
    end
  end
  love.event.push("quit")
end

function love.draw()
  love.graphics.setLineWidth(10)

  local scale = 20
  local starttick = playback.tick
  local endtick = playback.tick + (600 / scale)

  for tick = starttick, endtick do
    local event = chart:eventByTick(tick)
    if event then

      love.graphics.setColor(255, 150, 0, 50)
      for i = 1, 2 do
        local effectEvent = event.effectEvents[i]
        if effectEvent then
          if getmetatable(effectEvent)[1] == Event.Short then
            love.graphics.rectangle(
              "fill",
              (i - 1) * 200,
              600 - (event.tick - playback.tick) * scale,
              200,
              10
            )
          elseif getmetatable(effectEvent)[1] == Event.LongUp then
            love.graphics.rectangle(
              "fill",
              (i - 1) * 200,
              600 - (effectEvent.previousEvent.parent.tick - playback.tick) * scale,
              200,
              effectEvent:length() * scale
            )
          end
        end
      end

      love.graphics.setColor(255, 255, 255)
      for i = 1, 4 do
        local beatEvent = event.beatEvents[i]
        if beatEvent then
          if getmetatable(beatEvent)[1] == Event.Short then
            love.graphics.rectangle(
              "fill",
              (i - 1) * 100,
              600 - (event.tick - playback.tick) * scale,
              99,
              10
            )
          elseif getmetatable(beatEvent)[1] == Event.LongDown then
            love.graphics.rectangle(
              "fill",
              (i - 1) * 100,
              600 - (beatEvent.nextEvent.parent.tick - playback.tick) * scale,
              99,
              beatEvent:length() * scale
            )
          end
        end
      end

      for i = 1, 2 do
        local analogEvent = event.analogEvents[i]
        if analogEvent then
          if i == 1 then
            love.graphics.setColor(0, 255, 255, 100)
          else
            love.graphics.setColor(255, 0, 0, 100)
          end

          if analogEvent.nextEvent then
            love.graphics.line(
              analogEvent.nextEvent.value * 400,
              600 - (analogEvent.nextEvent.parent.tick - playback.tick) * scale,
              analogEvent.value * 400,
              600 - (analogEvent.parent.tick - playback.tick) * scale
            )
          elseif analogEvent.previousEvent then
            love.graphics.line(
              analogEvent.previousEvent.value * 400,
              600 - (analogEvent.previousEvent.parent.tick - playback.tick) * scale,
              analogEvent.value * 400,
              600 - (analogEvent.parent.tick - playback.tick) * scale
            )
          end
        end
      end

    end
  end
end
