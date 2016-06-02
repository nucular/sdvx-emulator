local Chart = require("Chart")

local Parser = require("class")()

function Parser:init()
  self.chart = Chart()
  self.measure = nil
  return self.chart
end

function Parser:parseFile(f)
  for line in f:lines() do
    self:parseLine(line)
  end
end

function Parser:parseLine(line)
  error("not implemented")
end

return Parser
