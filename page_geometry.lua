-- page_geometry.lua
-- Page sizes and grid geometry per model: the chassis strip, the port-settings
-- grid and the Groups and Trunks sections. Top-level, so GetControlLayout and
-- the runtime size things the same way.

-- Port-settings grid geometry, shared by the chassis page and the page
-- size helpers. One column = label + enable + legend + rlinkx + poe toggle
-- + poe bounce + group + speed. GRID_COL_W, with the narrowest legend,
-- sets the column count; the legend then takes the width left over.
local GRID_LEGEND_MIN_W = 50
local GRID_LEGEND_MAX_W = 96  -- 16 characters (the API maxLength) in Roboto 10
local GRID_COL_W   = 16 + 20 + GRID_LEGEND_MIN_W + 20 + 20 + 20 + 68 + 110
local GRID_COL_PAD = 6
local GRID_X_START = 12
local GRID_ROW_H   = 22

-- Plugin width per model so that every chassis has the same right-side
-- margin (380px from chassis right edge to plugin right edge). Reserves
-- consistent space for future info controls regardless of chassis width.
-- Chassis strip geometry shared by the page builders: [display block]
-- [web UI chassis box] [status block], all CHASSIS_H tall, starting at
-- CHASSIS_X / _Y.
local CHASSIS_X  = 20
local CHASSIS_Y  = 4
local CHASSIS_H  = 142   -- web UI chassis box (chassisGeometry h)
local DISPLAY_W  = 190   -- device display block (logo, model, status, IP...)
local DISPLAY_GAP = 8    -- display block to chassis box
local STATUS_GAP  = 8    -- chassis box to status block
local STATUS_W    = 210  -- status block (RSTP lines, querier panel, PSU column)

-- The status block keeps a CHASSIS_X margin to the page's right edge, like
-- the display block's on the left.
function pageWidthForModel(model)
  local rightMargin = STATUS_GAP + STATUS_W + CHASSIS_X
  return CHASSIS_X + DISPLAY_W + DISPLAY_GAP + chassisGeometry(model).w + rightMargin
end

-- Grid columns: as many as the page width fits with the GRID_X_START margin
-- kept on the right too; rows: ceil(ports / cols). Ports fill column by
-- column (1..rows down the first column, then the next), so the page stays
-- as short as the width allows.
function gridDimsForModel(model)
  local pageW = pageWidthForModel(model)
  local cols  = math.floor((pageW - GRID_X_START * 2 + GRID_COL_PAD) / (GRID_COL_W + GRID_COL_PAD))
  local pc    = getPortCount(model) or 30
  cols = math.max(1, math.min(cols, pc))
  local rows = math.ceil(pc / cols)
  return cols, rows
end

-- Legend TextBox width: the page width the grid columns leave free on the
-- right, shared between the columns, up to GRID_LEGEND_MAX_W. Neither the
-- page size nor the column count changes.
function gridLegendWidth(model)
  local cols  = gridDimsForModel(model)
  local spare = pageWidthForModel(model) - GRID_X_START * 2 - (cols * GRID_COL_W + (cols - 1) * GRID_COL_PAD)
  return math.min(GRID_LEGEND_MAX_W, GRID_LEGEND_MIN_W + math.floor(spare / cols))
end

-- Groups and Trunks page geometry. Sections sit side by side (groups,
-- custom groups, trunks, custom trunks); each is a vertical list that
-- spills into extra sub-columns. Rows per section = the smallest count that
-- keeps all four sections inside the page width.
local GT_TOP_Y, GT_LABEL_H, GT_CARD_W, GT_CARD_H, GT_GAP_Y, GT_SECTION_GAP, GT_MARGIN_X = 55, 16, 90, 18, 3, 14, 16
local GT_SECTION_ITEMS = { 20, CUSTOM_GROUP_SLOTS, 1, CUSTOM_TRUNK_SLOTS }

function groupsPageWidthForRows(rows)
  local w = GT_MARGIN_X
  for i, n in ipairs(GT_SECTION_ITEMS) do
    local subCols = math.max(1, math.ceil(n / rows))
    w = w + subCols * GT_CARD_W + (subCols - 1) * 4
    if i < #GT_SECTION_ITEMS then w = w + GT_SECTION_GAP end
  end
  return w + GT_MARGIN_X
end

function groupsRowsForModel(model)
  local pageW = pageWidthForModel(model)
  for rows = 4, 20 do
    if groupsPageWidthForRows(rows) <= pageW then return rows end
  end
  return 20
end

function groupsPageHeightForModel(model)
  local rows = groupsRowsForModel(model)
  return GT_TOP_Y + GT_LABEL_H + 6 + rows * (GT_CARD_H + GT_GAP_Y) - GT_GAP_Y + 10
end

function chassisPageHeightForModel(model)
  local topGap = 6
  local _cols, rows = gridDimsForModel(model)
  return CHASSIS_Y + CHASSIS_H + topGap + (rows * GRID_ROW_H) + topGap
end

-- Neighbors page (LLDP): the column header row at GT_TOP_Y, then one 18 px
-- row per port, cut into blocks of rows side by side.
local LLDP_ROW_H       = 18
local LLDP_ROWS_Y      = GT_TOP_Y + 14   -- 69
local LLDP_BOTTOM      = 8
local LLDP_MARGIN_X    = 20
local LLDP_BLOCK_GAP   = 20
local LLDP_BLOCK_MIN_W = 400   -- narrowest block (compact: no Description column)
local LLDP_FULL_W      = 500   -- a narrower block drops the Description column
local LLDP_GAP         = 4

-- Smallest block count (1..3) whose rows fit the height the chassis and
-- groups pages already need; when none fits, the most blocks still at least
-- LLDP_BLOCK_MIN_W wide (the page then grows).
function neighborsGeometry(model)
  local pageW = pageWidthForModel(model)
  local available = math.max(chassisPageHeightForModel(model), groupsPageHeightForModel(model))
  local ports = getPortCount(model) or 30
  local chosen
  for blocks = 1, 3 do
    local blockW = math.floor((pageW - 2 * LLDP_MARGIN_X - LLDP_BLOCK_GAP * (blocks - 1)) / blocks)
    if blockW >= LLDP_BLOCK_MIN_W then
      chosen = { blocks = blocks, blockW = blockW, rows = math.ceil(ports / blocks) }
      if LLDP_ROWS_Y + LLDP_ROW_H * chosen.rows + LLDP_BOTTOM <= available then break end
    end
  end
  chosen.compact = chosen.blockW < LLDP_FULL_W
  chosen.rowH    = LLDP_ROW_H
  chosen.rowsY   = LLDP_ROWS_Y
  chosen.height  = LLDP_ROWS_Y + LLDP_ROW_H * chosen.rows + LLDP_BOTTOM
  return chosen
end

-- Row columns, x relative to the block: number, Neighbor, Description (full
-- blocks only), Port, IP, 4 px apart. Neighbor and Description share the
-- slack (45 / 55 %).
function neighborsColumns(blockW, compact)
  local order = compact and { "number", "name", "remotePort", "ip" }
    or { "number", "name", "device", "remotePort", "ip" }
  local widths = { number = 20, remotePort = 40, ip = 95 }
  local slack = blockW - LLDP_GAP * (#order - 1)
    - widths.number - widths.remotePort - widths.ip
  if compact then
    widths.name = slack
  else
    widths.name = math.floor(slack * 0.45)
    widths.device = slack - widths.name
  end
  local columns, x = {}, 0
  for _, key in ipairs(order) do
    columns[key] = { x = x, w = widths[key] }
    x = x + widths[key] + LLDP_GAP
  end
  return columns
end

-- Top-left of port N's row: ports run down a block, then on to the next one.
function neighborsRowPosition(model, port)
  local geometry = neighborsGeometry(model)
  local block = math.floor((port - 1) / geometry.rows)
  return LLDP_MARGIN_X + block * (geometry.blockW + LLDP_BLOCK_GAP),
    geometry.rowsY + ((port - 1) % geometry.rows) * geometry.rowH
end

-- One height for every page of a model so tab switches don't resize the
-- plugin: the tallest of the chassis, groups and neighbors pages.
function pageHeightForModel(model)
  return math.max(chassisPageHeightForModel(model), groupsPageHeightForModel(model),
    neighborsGeometry(model).height)
end
