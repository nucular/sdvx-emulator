local class = require("class")

local Event = class()

Event.ParentEvent = class({}, Event)
function Event.ParentEvent:init()
  self.tick = 0
  self.beatEvents = {nil, nil, nil, nil}
  self.effectEvents = {nil, nil}
  self.analogEvents = {nil, nil}
  self.variableChanges = {}
end


Event.SubEvent = class({}, Event)
function Event.SubEvent:init(parent)
  self.parent = parent
end


Event.Short = class({}, SubEvent)

Event.LongDown = class({}, SubEvent)
function Event.LongDown:init(parent, next)
  Event.SubEvent.init(self, parent)
  self.state = true
  self.nextEvent = next
end

function Event.LongDown:length()
  return self.nextEvent.parent.tick - self.parent.tick
end


Event.LongUp = class({}, SubEvent)
function Event.LongUp:init(parent, prev)
  Event.SubEvent.init(self, parent)
  self.state = false
  self.previousEvent = prev
end

function Event.LongUp:length()
  return self.parent.tick - self.previousEvent.parent.tick
end


Event.Analog = class({}, SubEvent)
function Event.Analog:init(parent, value, prev, next)
  Event.SubEvent.init(self, parent)
  self.value = value
  self.previousEvent = prev
  self.nextEvent = next
  self.slam = false
end

function Event.Analog:length()
  if self.nextEvent then
    return self.nextEvent.parent.tick - self.parent.tick
  elseif self.previousEvent then
    return self.parent.tick - self.previousEvent.parent.tick
  else
    return 0
  end
end


return Event
