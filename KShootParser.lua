local Parser = require("Parser")
local Event = require("Event")

local KShootParser = require("class")({}, Parser)

function KShootParser:init()
  self.lastBeatEvents = {nil, nil, nil, nil}
  self.lastEffectEvents = {nil, nil}
  self.lastAnalogEvents = {nil, nil}
  self.nextVariableChanges = {}
  self.currentBPM = 120
  return Parser.init(self)
end

function KShootParser:parseLine(line)
  if line == "--" then
    self:handleMeasure()
  end

  local identifier, value = line:match("^([%w_-]+)%=(.+)$") -- identifier=value
  if identifier and value then
    if not self.measure then
      self:handleMetadata(identifier, value)
    else
      self:handleVariableChange(identifier, value)
    end
  end

  local beats, effects, analog = line:match("^([012][012][012][012])%|([012A-Z][012A-Z])%|([a-zA-Z:%-][a-zA-Z:%-])")
  if beats and effects and analog then
    if self.measure then
      self:handleEvent(beats, effects, analog)
    end
  end
end

function KShootParser:handleMeasure()
  if self.measure then
    local bpm = self.currentBPM
    for i, event in ipairs(self.measure) do
      event.tick = math.floor((#self.chart.measures * 64) + (((i - 1) / #self.measure) * 64))
      bpm = event.variableChanges.bpm or bpm
      event.time = event.tick / (bpm / 60) / (64 / 4)
    end

    table.insert(self.chart.measures, self.measure)
  end
  self.measure = {}
end

do
  local _0 = string.byte('0')
  local _9 = string.byte('9')
  local _A = string.byte('A')
  local _Z = string.byte('Z')
  local _a = string.byte('a')

  function KShootParser:getAnalogValue(chr)
    local ord = chr:byte()

    if ord >= _0 and ord <= _9 then -- 0 - 9
      return ord - _0
    elseif ord >= _A and ord <= _Z then -- A - Z
      return (ord - _A) + (_9 - _0 + 1)
    else -- a - z
      return (ord - _a) + (_Z - _A + 1) + (_9 - _0 + 1)
    end
  end
end

function KShootParser:handleEvent(beats, effects, analog)
  local parent = Event.ParentEvent()

  parent.variableChanges = self.nextVariableChanges
  self.nextVariableChanges = {}

  for i = 1, 4 do
    local c = beats:sub(i, i)

    local lastBeatEvent = self.lastBeatEvents[i]
    local nextBeatEvent

    if c == "0" then
      if lastBeatEvent and lastBeatEvent.state == true then
        nextBeatEvent = Event.LongUp(parent, lastBeatEvent)
        lastBeatEvent.nextEvent = nextBeatEvent
      end
    elseif c == "1" then
      nextBeatEvent = Event.Short(parent)
    elseif c == "2" then
      nextBeatEvent = Event.LongDown(parent, nil)
    end

    self.lastBeatEvents[i] = nextBeatEvent
    parent.beatEvents[i] = nextBeatEvent
  end

  for i = 1, 2 do
    local c = effects:sub(i, i)

    local lastEffectEvent = self.lastEffectEvents[i]
    local nextEffectEvent

    if c == "0" then
      if lastEffectEvent and lastEffectEvent.state == true then
        nextEffectEvent = Event.LongUp(parent, lastEffectEvent)
        lastEffectEvent.nextEvent = nextEffectEvent
      end
    elseif c == "2" then
      nextEffectEvent = Event.Short(parent)
    elseif c == "1" then
      nextEffectEvent = Event.LongDown(parent, nil)
    end

    self.lastEffectEvents[i] = nextEffectEvent
    parent.effectEvents[i] = nextEffectEvent
  end

  for i = 1, 2 do
    local c = analog:sub(i, i)

    local lastAnalogEvent = self.lastAnalogEvents[i]
    local nextAnalogEvent

    if c == "-" or c == ":" then
      -- do nothing
    else
      local value = self:getAnalogValue(c) / 50
      nextAnalogEvent = Event.Analog(parent, value, nil, nil)
      if lastAnalogEvent then
        print("end", value)
        nextAnalogEvent.previousEvent = lastAnalogEvent
        lastAnalogEvent.nextEvent = nextAnalogEvent
        lastAnalogEvent.slam = lastAnalogEvent:length() <= 2
        nextAnalogEvent.slam = lastAnalogEvent.slam
        self.lastAnalogEvents[i] = nil
      else
        print("start", value)
        self.lastAnalogEvents[i] = nextAnalogEvent
      end
    end

    parent.analogEvents[i] = nextAnalogEvent
  end

  table.insert(self.measure, parent)
end

do
  local parsers = {
    title = {tostring, {"title"}},
    artist = {tostring, {"artist"}},
    effect = {tostring, {"effector"}},
    jacket = {tostring, {"cover"}},
    illustrator = {tostring, {"illustrator"}},
    difficulty = {tonumber,  {"difficulty"}},
    level = {tonumber, {"level"}},
    m = {function(s) return s:match("([^;]*);([^;]*)") end, {"audio", "fxaudio"}},
    mvol = {tonumber, {"volume"}}
  }

  function KShootParser:handleMetadata(identifier, value)
    if not parsers[identifier] then return end
    local parser, keys = unpack(parsers[identifier])
    local parsed = {parser(value)}

    for i, v in ipairs(parsed) do
      self.chart.metadata[keys[i]] = v
    end
  end
end

do
  local parsers = {
    t = {tonumber, {"bpm"}}
  }

  function KShootParser:handleVariableChange(identifier, value)
    if not parsers[identifier] then return end
    local parser, keys = unpack(parsers[identifier])
    local parsed = {parser(value)}

    for i, v in ipairs(parsed) do
      local k = keys[i]
      self.nextVariableChanges[k] = v

      if self.chart.variables[k] == nil then
        self.chart.variables[k] = v
      end

      if k == "bpm" then
        self.currentBPM = v
      end
    end
  end
end

return KShootParser
