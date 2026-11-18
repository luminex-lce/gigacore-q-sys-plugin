local modelChoices = {}
for modelName, _ in pairs(GigaCoreModels) do
  table.insert(modelChoices, modelName)
end
table.sort(modelChoices)

return {
  {
    Name    = "Model",
    Type    = "enum",
    Choices = modelChoices,
    Value   = "GigaCore 30i",
  },
  {
    Name    = "Dark Mode",
    Type    = "enum",
    Choices = { "Yes", "No" },
    Value   = "Yes",
  },
  -- Periodic REST re-sync (reconcileAll) of every port, PoE, RLinkX, LAG,
  -- group, power and spanning tree state, so a WebSocket notification missed
  -- during the subscription storm heals itself. No 5 s choice: it costs the
  -- switch about 5 points of CPU.
  {
    Name    = "Poll Interval",
    Type    = "enum",
    Choices = { "Off", "15 s", "30 s", "60 s" },
    Value   = "15 s",
  },
}
