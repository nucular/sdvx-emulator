local Chart = require("class")()

function Chart:init()
  self.metadata = {
    title = "",
    artist = "",
    effector = "",
    cover = "",
    illustrator = "",
    difficulty = 1,
    level = 1,
    audio = "",
    fxaudio = "",
    volume = 100,
    bpm = "120"
  }
  self.variables = {
    bpm = 120
  }

  self.measures = {}
end

function Chart:tickToMeasure(tick)
  return math.ceil(tick / 64)
end

function Chart:tickToMeasureOffset(tick, measurelength)
  return math.ceil(((tick % 64) / 64) * measurelength)
end

function Chart:eventByTick(tick)
  local measure = self.measures[self:tickToMeasure(tick)]
  if measure then
    return measure[self:tickToMeasureOffset(tick, #measure)]
  end
end

return Chart
