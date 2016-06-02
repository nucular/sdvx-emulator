local Playback = require("class")()

function Playback:init(chart)
  self.chart = chart
  self.tick = 0
  self.time = 0
  self.variables = {}

  for k, v in pairs(chart.variables) do
    self.variables[k] = v
  end
end

function Playback:update(dt)
  local lasttick = self:timeToTick(self.time)
  self.time = self.time + dt
  self.tick = self:timeToTick(self.time)
  return self.chart:eventByTick(self.tick)
end

function Playback:tickToTime(tick)
  return tick / (self.variables.bpm / 60) / (64 / 4)
end

function Playback:timeToTick(time)
  return time * (self.variables.bpm / 60) * (64 / 4)
end

return Playback
