-- chassis_layout.lua
-- Per-model chassis layout of the switch web UI. A group is { divider = true } or a list of port
-- sets; tenG = true draws the 10G frame when the 10g licence is active,
-- speedLabel is an always-shown speed frame (O26-I).
-- etherCON / rfib sets hold one full-height card; rj45 / sfp / qsfp sets are a
-- column of two half-height cards (first port on top, direction ttb).

CHASSIS_LAYOUT = {
  ["GigaCore 10i"] = {
    { sets = { { connector = "rj45", ports = { 1, 2 } }, { connector = "rj45", ports = { 3, 4 } }, { connector = "rj45", ports = { 5, 6 } }, { connector = "rj45", ports = { 7, 8 } } } },
    { sets = { { connector = "sfp", ports = { 9, 10 } } }, tenG = true },
  },
  ["GigaCore 10t"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } } } },
    { sets = { { connector = "rfib", ports = { 9 } }, { connector = "rfib", ports = { 10 } } }, tenG = true },
    { divider = true },
    { sets = { { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } } } },
  },
  ["GigaCore 10t-IP"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } }, { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } } } },
    { divider = true },
    { sets = { { connector = "rfib", ports = { 9 } }, { connector = "rfib", ports = { 10 } } }, tenG = true },
  },
  ["GigaCore 16i"] = {
    { sets = { { connector = "rj45", ports = { 1, 2 } }, { connector = "rj45", ports = { 3, 4 } }, { connector = "rj45", ports = { 5, 6 } }, { connector = "rj45", ports = { 7, 8 } }, { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } } } },
    { sets = { { connector = "sfp", ports = { 13, 14 } }, { connector = "sfp", ports = { 15, 16 } } }, tenG = true },
  },
  ["GigaCore 16t"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } } } },
    { divider = true },
    { sets = { { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } } } },
    { sets = { { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } }, { connector = "rj45", ports = { 13, 14 } }, { connector = "rj45", ports = { 15, 16 } } } },
  },
  ["GigaCore 16tf"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } }, { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } }, { connector = "ethercon", ports = { 9 } }, { connector = "ethercon", ports = { 10 } }, { connector = "ethercon", ports = { 11 } }, { connector = "ethercon", ports = { 12 } } } },
    { sets = { { connector = "rfib", ports = { 13 } }, { connector = "rfib", ports = { 14 } }, { connector = "rfib", ports = { 15 } }, { connector = "rfib", ports = { 16 } } }, tenG = true },
  },
  ["GigaCore 18t"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } } } },
    { divider = true },
    { sets = { { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } } } },
    { sets = { { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } }, { connector = "rj45", ports = { 13, 14 } }, { connector = "rj45", ports = { 15, 16 } } } },
    { sets = { { connector = "sfp", ports = { 17, 18 } } }, tenG = true },
  },
  ["GigaCore 20t"] = {
    { sets = { { connector = "ethercon", ports = { 1 } }, { connector = "ethercon", ports = { 2 } }, { connector = "ethercon", ports = { 3 } }, { connector = "ethercon", ports = { 4 } } } },
    { divider = true },
    { sets = { { connector = "ethercon", ports = { 5 } }, { connector = "ethercon", ports = { 6 } }, { connector = "ethercon", ports = { 7 } }, { connector = "ethercon", ports = { 8 } } } },
    { sets = { { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } }, { connector = "rj45", ports = { 13, 14 } }, { connector = "rj45", ports = { 15, 16 } } } },
    { sets = { { connector = "sfp", ports = { 17, 18 } }, { connector = "sfp", ports = { 19, 20 } } }, tenG = true },
  },
  ["GigaCore 30i"] = {
    { sets = { { connector = "rj45", ports = { 1, 2 } }, { connector = "rj45", ports = { 3, 4 } }, { connector = "rj45", ports = { 5, 6 } }, { connector = "rj45", ports = { 7, 8 } }, { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } } } },
    { sets = { { connector = "rj45", ports = { 13, 14 } }, { connector = "rj45", ports = { 15, 16 } }, { connector = "rj45", ports = { 17, 18 } }, { connector = "rj45", ports = { 19, 20 } }, { connector = "rj45", ports = { 21, 22 } }, { connector = "rj45", ports = { 23, 24 } } } },
    { sets = { { connector = "sfp", ports = { 25, 26 } }, { connector = "sfp", ports = { 27, 28 } }, { connector = "sfp", ports = { 29, 30 } } }, tenG = true },
  },
  ["GigaCore O26-I"] = {
    { sets = { { connector = "sfp", ports = { 1, 2 } }, { connector = "sfp", ports = { 3, 4 } }, { connector = "sfp", ports = { 5, 6 } }, { connector = "sfp", ports = { 7, 8 } }, { connector = "sfp", ports = { 9, 10 } }, { connector = "sfp", ports = { 11, 12 } }, { connector = "sfp", ports = { 13, 14 } }, { connector = "sfp", ports = { 15, 16 } } } },
    { sets = { { connector = "sfp", ports = { 17, 18 } }, { connector = "sfp", ports = { 19, 20 } } } },
    { sets = { { connector = "sfp", ports = { 21, 22 } }, { connector = "sfp", ports = { 23, 24 } } }, speedLabel = "25G" },
    { sets = { { connector = "qsfp", ports = { 25, 26 } } }, speedLabel = "40G" },
  },
  ["GigaCore S30-I"] = {
    { sets = { { connector = "rj45", ports = { 1, 2 } }, { connector = "rj45", ports = { 3, 4 } }, { connector = "rj45", ports = { 5, 6 } }, { connector = "rj45", ports = { 7, 8 } }, { connector = "rj45", ports = { 9, 10 } }, { connector = "rj45", ports = { 11, 12 } } } },
    { sets = { { connector = "rj45", ports = { 13, 14 } }, { connector = "rj45", ports = { 15, 16 } }, { connector = "rj45", ports = { 17, 18 } }, { connector = "rj45", ports = { 19, 20 } }, { connector = "rj45", ports = { 21, 22 } }, { connector = "rj45", ports = { 23, 24 } } } },
    { sets = { { connector = "sfp", ports = { 25, 26 } }, { connector = "sfp", ports = { 27, 28 } }, { connector = "sfp", ports = { 29, 30 } } } },
  },
}

local CHASSIS_BORDER = 1
local CHASSIS_PADDING = 16
local CHASSIS_HEIGHT = 142
local CARD_TOP = CHASSIS_BORDER + CHASSIS_PADDING
local CARD_HEIGHT = CHASSIS_HEIGHT - 2 * CARD_TOP
local HALF_CARD_HEIGHT = math.floor(CARD_HEIGHT / 2)
local GROUP_GAP = 24
local FRAME_OUTSET = 3
local FULL_CARD_WIDTH = 60
local COLUMN_WIDTH = { rj45 = 44, sfp = 44, qsfp = 57 }

-- Chassis-local geometry (origin = outer top-left of the chassis box) of every
-- card, divider line and speed frame of a model, or nil for an unknown model.
function chassisGeometry(modelName)
  local layout = CHASSIS_LAYOUT[modelName]
  if not layout then return nil end
  local geometry = { h = CHASSIS_HEIGHT, cards = {}, dividers = {}, frames = {} }
  local x = CARD_TOP
  for index, group in ipairs(layout) do
    if index > 1 then x = x + GROUP_GAP end
    if group.divider then
      table.insert(geometry.dividers, { x = x, y = CARD_TOP, h = CARD_HEIGHT })
    else
      local groupX = x
      for _, set in ipairs(group.sets) do
        local kind = set.connector
        if kind == "ethercon" or kind == "rfib" then
          geometry.cards[set.ports[1]] = { x = x, y = CARD_TOP, w = FULL_CARD_WIDTH, h = CARD_HEIGHT,
                                           kind = kind, direction = "btt" }
          x = x + FULL_CARD_WIDTH
        else
          local width = COLUMN_WIDTH[kind]
          geometry.cards[set.ports[1]] = { x = x, y = CARD_TOP, w = width, h = HALF_CARD_HEIGHT,
                                           kind = kind, direction = "ttb" }
          if set.ports[2] then
            geometry.cards[set.ports[2]] = { x = x, y = CARD_TOP + HALF_CARD_HEIGHT, w = width, h = HALF_CARD_HEIGHT,
                                             kind = kind, direction = "btt" }
          end
          x = x + width
        end
      end
      if group.tenG or group.speedLabel then
        table.insert(geometry.frames, {
          x = groupX - FRAME_OUTSET, y = CARD_TOP - FRAME_OUTSET,
          w = x - groupX + 2 * FRAME_OUTSET, h = CARD_HEIGHT + 2 * FRAME_OUTSET,
          label = group.speedLabel or "10G", tenG = group.tenG,
        })
      end
    end
  end
  geometry.w = x + CHASSIS_PADDING + CHASSIS_BORDER
  return geometry
end
