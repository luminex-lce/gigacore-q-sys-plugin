-- Dark mode from property
local darkProp = props["Dark Mode"]
local darkModeValue = (type(darkProp) == "table") and darkProp.Value or darkProp
state.darkMode = (darkModeValue == "Yes")

local modelString    = resolveModel(props)
local portCount      = getPortCount(modelString)
state.portCount      = portCount
state.selectedModel  = modelString  -- design time only; the runtime reads Properties["Model"]

-- Two-row device header (Araneo-style), three columns left-aligned:
--   Col 1: [Status]      / [Firmware]      — narrow, left edge
--   Col 2: [Switch Name] / [Description]   — middle
--   Col 3: [IP/Subnet]   / [MAC]           — right
local function defineCommonDeviceInfo(layout, gfx, theme, lumCenterX, ipSpacing)
  local row1Y, row2Y = 2, 22
  local rowH = 20
  local x0 = 10

  local statusW = 60
  local nameW   = 220
  local infoW   = 220   -- IP+Subnet / MAC width (3rd column)
  local gap     = 10
  local col2X = x0 + statusW + gap
  local col3X = col2X + nameW + gap

  -- Grey badge under the transparent status control. No text placeholders:
  -- Designer keeps the last runtime text offline but drops the runtime fill,
  -- so a placeholder would show through the stale value.
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { x0, row1Y },
    Size         = { statusW, rowH },
    Fill         = theme.badgeOffBg,
    StrokeWidth  = 0,
    CornerRadius = 6,
  }

  layout["Display.Status"] = {
    Style        = "Text",
    Position     = { x0, row1Y },
    Size         = { statusW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    Font         = "Roboto",
    FontSize     = 11,
    TextColor    = { 255, 255, 255 },
    StrokeWidth  = 0,
    CornerRadius = 6,
    HTextAlign   = "Center",
    VTextAlign   = "Center",
    Legend       = "Offline",
  }

  layout["Device.Name"] = {
    Style        = "Indicator",
    Position     = { col2X, row1Y },
    Size         = { nameW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    StrokeColor  = theme.strokeColor,
    StrokeWidth  = 0,
    TextColor    = theme.textColor,
    HTextAlign   = "Left",
    VTextAlign   = "Center",
    FontSize     = 11,
    Font         = "Roboto",
    CornerRadius = 1,
  }

  layout["Device.Description"] = {
    Style        = "Indicator",
    Position     = { col2X, row2Y },
    Size         = { nameW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    StrokeColor  = theme.strokeColor,
    StrokeWidth  = 0,
    TextColor    = theme.textColor,
    HTextAlign   = "Left",
    VTextAlign   = "Center",
    FontSize     = 11,
    Font         = "Roboto",
    CornerRadius = 1,
  }

  layout["Display.IP Info"] = {
    Style        = "Indicator",
    Position     = { col3X, row1Y },
    Size         = { infoW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    StrokeColor  = theme.strokeColor,
    StrokeWidth  = 0,
    TextColor    = theme.textColor,
    FontSize     = 11,
    Font         = "Roboto",
    HTextAlign   = "Left",
    VTextAlign   = "Center",
    CornerRadius = 1,
  }

  layout["Device.MAC Address"] = {
    Style        = "Indicator",
    Position     = { col3X, row2Y },
    Size         = { infoW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    StrokeColor  = theme.strokeColor,
    StrokeWidth  = 0,
    TextColor    = theme.textColor,
    FontSize     = 11,
    Font         = "Roboto",
    HTextAlign   = "Left",
    VTextAlign   = "Center",
    CornerRadius = 1,
  }

  layout["Device.Firmware.Active"] = {
    Style        = "Indicator",
    Position     = { x0, row2Y },
    Size         = { statusW, rowH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    StrokeColor  = theme.strokeColor,
    StrokeWidth  = 0,
    TextColor    = theme.textColor,
    FontSize     = 10,
    Font         = "Roboto",
    HTextAlign   = "Center",
    VTextAlign   = "Center",
    CornerRadius = 1,
  }
end

--------------------------------------------------------------------------------
-- Helper: rounded card (info panel)
--------------------------------------------------------------------------------
local function drawCard(gfx, x, y, w, h, theme)
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { x, y },
    Size         = { w, h },
    Fill         = theme.cardFill,
    StrokeColor  = theme.cardStroke,
    StrokeWidth  = 1,
    CornerRadius = 8,
  }
end

--------------------------------------------------------------------------------
-- Helper: grid background (faint lines every 40px)
--------------------------------------------------------------------------------
local function drawGridBackground(gfx, w, h, theme)
  gfx[#gfx+1] = {
    Type        = "Rectangle",
    Position    = { 0, 0 },
    Size        = { w, h },
    Fill        = theme.pageBg,
    StrokeWidth = 0,
  }
  for x = 0, w, 40 do
    gfx[#gfx+1] = {
      Type        = "Rectangle",
      Position    = { x, 0 },
      Size        = { 1, h },
      Fill        = theme.gridLine,
      StrokeWidth = 0,
    }
  end
  for y = 0, h, 40 do
    gfx[#gfx+1] = {
      Type        = "Rectangle",
      Position    = { 0, y },
      Size        = { w, 1 },
      Fill        = theme.gridLine,
      StrokeWidth = 0,
    }
  end
end

--------------------------------------------------------------------------------
-- Main page: device display block, the web UI chassis box (offline graphic
-- plus one Port.Card button per port), status block, port-settings grid.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Status block: the black "screen" the switch web UI draws right of the
-- chassis. Status dot top-left, RSTP root bridge lines under it, PSU column
-- at the right (PSU1 label, icon, coupling glyph, icon, PSU2 label).
-- The runtime fills the RSTP text controls, pushes a state-tinted PSU icon
-- into PSU.N Icon (Legend IconData, over the grey gfx icon) and the coupling
-- glyph. No text placeholders under the RSTP values: Designer keeps the last
-- runtime text offline, a placeholder would show through it.
--------------------------------------------------------------------------------
-- Flat read-only Button whose Legend carries an IconData SVG (Port.Card N,
-- Chassis.10G N, Querier.Badges). Designer draws a Button's content 2 px
-- inside its box, so the box grows by that inset (the SVG viewBox is the box
-- without it).
local BUTTON_INSET = 2
local function iconButton(layout, name, x, y, w, h)
  layout[name] = {
    Style             = "Button",
    ButtonStyle       = "Toggle",
    ButtonVisualStyle = "Flat",
    Position          = { x - BUTTON_INSET, y - BUTTON_INSET },
    Size              = { w + BUTTON_INSET * 2, h + BUTTON_INSET * 2 },
    IsReadOnly        = true,
    Color             = { 0, 0, 0, 0 },
    OffColor          = { 0, 0, 0, 0 },
    StrokeColor       = { 0, 0, 0, 0 },
    StrokeWidth       = 0,
    Legend            = "",
  }
end

-- The same, clickable (Momentary, not read-only): Port.Card N, zLldp.Panel.
local function clickableIconButton(layout, name, x, y, w, h)
  iconButton(layout, name, x, y, w, h)
  layout[name].ButtonStyle = "Momentary"
  layout[name].IsReadOnly  = nil
end

local function buildStatusBlock(layout, gfx, theme, x, y, h, outlineW)
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { x, y },
    Size         = { STATUS_W, h },
    Fill         = theme.pageBg,
    StrokeColor  = { 255, 255, 255, 255 },
    StrokeWidth  = outlineW,
    CornerRadius = 4,
  }
  local pad   = 5
  local inX   = x + outlineW + pad
  local inY   = y + outlineW + pad
  local inW   = STATUS_W - (outlineW + pad) * 2
  local lineH = 14

  local function text(tx, ty, w, h2, str, color, align, size)
    gfx[#gfx+1] = {
      Type       = "Text",
      Text       = str,
      Position   = { tx, ty },
      Size       = { w, h2 },
      Font       = "Roboto",
      FontSize   = size or 10,
      Color      = color,
      HTextAlign = align or "Left",
      VTextAlign = "Center",
    }
  end
  local function valueBox(name, bx, by, w)
    layout[name] = {
      Style        = "Text",
      Position     = { bx, by },
      Size         = { w, lineH },
      IsReadOnly   = true,
      Color        = { 0, 0, 0, 0 },
      Font         = "Roboto",
      FontSize     = 10,
      TextColor    = theme.textPrimary,
      StrokeWidth  = 0,
      CornerRadius = 1,
      HTextAlign   = "Left",
      VTextAlign   = "Center",
    }
  end
  local function flatButton(name, bx, by, w, h2, extra)
    local entry = {
      Style             = "Button",
      ButtonStyle       = "Momentary",
      ButtonVisualStyle = "Flat",
      Position          = { bx, by },
      Size              = { w, h2 },
      Color             = { 0, 0, 0, 0 },
      OffColor          = { 0, 0, 0, 0 },
      StrokeColor       = { 0, 0, 0, 0 },
      StrokeWidth       = 0,
      Legend            = "",
    }
    for k, v in pairs(extra or {}) do entry[k] = v end
    layout[name] = entry
  end

  -- Status dot (grey placeholder offline; runtime paints green / red pulse)
  local dotD = 7
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { inX, inY + 2 },
    Size         = { dotD, dotD },
    Fill         = theme.badgeOffBg,
    StrokeWidth  = 0,
    CornerRadius = 3,
  }
  flatButton("Display.Status Dot", inX, inY + 2, dotD, dotD, { CornerRadius = 3 })

  -- RSTP lines, left of the PSU column
  local psuColW = 48
  local textW   = inW - psuColW - pad
  local line2   = inY + lineH
  text(inX, line2, textW, lineH, "Root bridge", theme.textMuted)
  valueBox("RSTP.Root Bridge", inX, line2 + lineH, textW)
  local prioW = 44
  text(inX, line2 + lineH * 2, prioW, lineH, "Priority", theme.textMuted)
  valueBox("RSTP.Bridge Priority", inX + prioW, line2 + lineH * 2, textW - prioW)

  -- Querier panel under the Priority line (textW = QUERIER_W at this block
  -- width). Blank until the runtime draws badges.
  iconButton(layout, "Querier.Badges", inX, inY + lineH * 4, QUERIER_W, QUERIER_H)

  -- PSU column: label, icon in a halo ring, coupling glyph, icon, label
  local colX   = inX + inW - psuColW
  local labelH = 12
  local haloD  = 24
  local iconD  = 18
  local glyphH = 14
  local iconX  = colX + math.floor((psuColW - iconD) / 2)
  local cy     = inY
  local function psu(id)
    local labelY = (id == 1) and cy or (cy + haloD)
    local haloY  = (id == 1) and (cy + labelH) or cy
    text(colX, labelY, psuColW, labelH, "PSU" .. id, theme.textPrimary, "Center")
    gfx[#gfx+1] = {
      Type     = "Svg",
      Image    = LogoPSU,
      Position = { iconX, haloY + math.floor((haloD - iconD) / 2) },
      Size     = { iconD, iconD },
    }
    flatButton("PSU." .. id .. " Icon", iconX, haloY + math.floor((haloD - iconD) / 2), iconD, iconD)
  end
  psu(1)
  cy = cy + labelH + haloD
  flatButton("Power.Coupling Glyph", colX, cy, psuColW, glyphH)
  cy = cy + glyphH
  psu(2)
end

local function buildChassisPage(layout, gfx, model, theme)
  local geometry = chassisGeometry(model)
  local blockX, blockY = CHASSIS_X, CHASSIS_Y
  local chassisX, chassisY = blockX + DISPLAY_W + DISPLAY_GAP, CHASSIS_Y
  local svgH = CHASSIS_H

  -- Per-port settings grid below the chassis. Bottom gap matches the top
  -- gap so the page is symmetrically padded; column and row counts come
  -- from gridDimsForModel.
  local topGap    = 6
  local gridY     = chassisY + CHASSIS_H + topGap
  local cols, rows = gridDimsForModel(model)
  local portCount = getPortCount(model)
  local rowH      = GRID_ROW_H
  local pageH     = pageHeightForModel(model)

  gfx[#gfx+1] = {
    Type        = "Groupbox",
    Fill        = theme.groupboxFill,
    StrokeColor = GROUPBOX_STROKE_COLOR,
    StrokeWidth = GROUPBOX_STROKE_WIDTH,
    Position    = GROUPBOX_POSITION,
    Size        = { pageWidthForModel(model), pageH },
  }

  -- Device display block (the web UI's left screen): page-bg fill, 1 px
  -- white outline like the chassis box.
  local outlineW = 1
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { blockX, blockY },
    Size         = { DISPLAY_W, svgH },
    Fill         = theme.pageBg,
    StrokeColor  = { 255, 255, 255, 255 },
    StrokeWidth  = outlineW,
    CornerRadius = 4,
  }
  local scrX, scrY = blockX + outlineW, blockY + outlineW
  local scrW = DISPLAY_W - outlineW * 2

  -- Chassis box as the web UI draws it when not live (generated by
  -- tools/gen_offline_chassis.py); the Port.Card buttons on top carry the
  -- live cards and cover their offline twins.
  gfx[#gfx+1] = {
    Type     = "Svg",
    Image    = CHASSIS_OFFLINE_SVG[model],
    Position = { chassisX, chassisY },
    Size     = { geometry.w, CHASSIS_H },
  }

  -- Status block right of the chassis (the web UI's right-hand screen);
  -- lives inside the 380px right margin.
  buildStatusBlock(layout, gfx, theme, chassisX + geometry.w + STATUS_GAP, blockY, svgH, outlineW)

  -- Screen contents: logo + status badge on the first row, then model,
  -- device name, description, IP, gateway (blank when the switch has none),
  -- firmware + MAC. Only the model line has a static placeholder (the same
  -- text Display.Model shows); the other lines have none because Designer
  -- keeps the last runtime text offline and a placeholder would show through.
  local pad   = 5
  local logoH = 28
  local logoW = math.floor(logoH * 3.3 + 0.5)
  local logoX, logoY = scrX + pad, scrY + pad
  gfx[#gfx+1] = {
    Type     = "Svg",
    Image    = LogoLuminex,
    Position = { logoX, logoY },
    Size     = { logoW, logoH },
  }
  -- Invisible button covering the logo — click triggers /api/identify.
  layout["Identify"] = {
    Style             = "Button",
    ButtonStyle       = "Momentary",
    ButtonVisualStyle = "Flat",
    Position          = { logoX, logoY },
    Size              = { logoW, logoH },
    Color             = { 0, 0, 0, 0 },
    OffColor          = { 0, 0, 0, 0 },
    StrokeColor       = { 0, 0, 0, 0 },
    StrokeWidth       = 0,
    Legend            = "",
  }

  local statusW, statusH = 56, 16
  local statusX = scrX + scrW - pad - statusW
  local statusY = logoY + math.floor((logoH - statusH) / 2)
  gfx[#gfx+1] = {
    Type         = "Rectangle",
    Position     = { statusX, statusY },
    Size         = { statusW, statusH },
    Fill         = theme.badgeOffBg,
    StrokeWidth  = 0,
    CornerRadius = 6,
  }
  layout["Display.Status"] = {
    Style        = "Text",
    Position     = { statusX, statusY },
    Size         = { statusW, statusH },
    IsReadOnly   = true,
    Color        = { 0, 0, 0, 0 },
    Font         = "Roboto",
    FontSize     = 10,
    TextColor    = { 255, 255, 255 },
    StrokeWidth  = 0,
    CornerRadius = 6,
    HTextAlign   = "Center",
    VTextAlign   = "Center",
  }

  local lineH = 14
  local lineX = scrX + pad
  local lineW = scrW - pad * 2
  local line1 = logoY + logoH + 4
  local function screenText(x, y, w, text, color, bold)
    gfx[#gfx+1] = {
      Type       = "Text",
      Text       = text,
      Position   = { x, y },
      Size       = { w, lineH },
      Font       = "Roboto",
      FontSize   = 10,
      Color      = color,
      HTextAlign = "Left",
      VTextAlign = "Center",
      IsBold     = bold or false,
    }
  end
  local function screenBox(name, x, y, w, bold)
    layout[name] = {
      Style        = "Text",
      Position     = { x, y },
      Size         = { w, lineH },
      IsReadOnly   = true,
      Color        = { 0, 0, 0, 0 },
      Font         = "Roboto",
      FontSize     = 10,
      IsBold       = bold or false,
      TextColor    = theme.textPrimary,
      StrokeWidth  = 0,
      CornerRadius = 1,
      HTextAlign   = "Left",
      VTextAlign   = "Center",
    }
  end
  screenText(lineX, line1, lineW, model, theme.textPrimary, true)
  local fwW = 44
  screenBox("Display.Model",      lineX, line1, lineW, true)
  screenBox("Device.Name",        lineX, line1 + lineH, lineW)
  screenBox("Device.Description", lineX, line1 + lineH * 2, lineW)
  screenBox("Display.IP Info",    lineX, line1 + lineH * 3, lineW)
  screenBox("Display.Gateway",    lineX, line1 + lineH * 4, lineW)
  screenBox("Device.Firmware.Active", lineX, line1 + lineH * 5, fwW)
  screenBox("Device.MAC Address", lineX + fwW + 4, line1 + lineH * 5, lineW - fwW - 4)

  -- One IconData Button per port card (Port.Card N) and per 10G frame
  -- (Chassis.10G N). A card box is the card plus CARD_BAR_SPACE on its
  -- MultiLinkX side; a frame box adds FRAME_LABEL_SPACE on the left for the
  -- rotated label.
  for port, card in pairs(geometry.cards) do
    local y = chassisY + card.y
    if cardBarOnTop(card) then y = y - CARD_BAR_SPACE end
    -- Clickable: opens the LLDP neighbor panel.
    clickableIconButton(layout, "Port.Card " .. port, chassisX + card.x, y, card.w, card.h + CARD_BAR_SPACE)
  end
  local frameIndex = 0
  for _, frame in ipairs(geometry.frames) do
    if frame.tenG then
      frameIndex = frameIndex + 1
      iconButton(layout, "Chassis.10G " .. frameIndex, chassisX + frame.x - FRAME_LABEL_SPACE, chassisY + frame.y,
        frame.w + FRAME_LABEL_SPACE, frame.h)
    end
  end

  -- Per-port settings grid below the chassis (columns and rows from
  -- gridDimsForModel): port number, enable toggle, legend TextBox, RLinkX
  -- toggle, PoE toggle, PoE bounce, group cell, speed cell. Ports above the
  -- model's PoE count leave the two PoE cells empty.
  local poeCount   = getPoeCount(model)
  local labelW     = 16
  local enableW    = 20
  local legendW    = gridLegendWidth(model)
  local rlinkxW    = 20
  local poeToggleW = 20
  local poeBounceW = 20
  local groupW     = 68
  local speedW     = 110
  local colPad     = GRID_COL_PAD
  local colW       = GRID_COL_W + legendW - GRID_LEGEND_MIN_W
  local cellH      = 18
  local xStart     = GRID_X_START
  local cSpacing   = colW + colPad

  for p = 1, portCount do
    local col = math.floor((p - 1) / rows)
    local rowI = (p - 1) % rows
    local y = gridY + rowI * rowH
    local x = xStart + col * cSpacing

    local labelX     = x
    local enableX    = labelX + labelW
    local legendX    = enableX + enableW
    local rlinkxX    = legendX + legendW
    local poeToggleX = rlinkxX + rlinkxW
    local poeBounceX = poeToggleX + poeToggleW
    local groupX     = poeBounceX + poeBounceW
    local speedX     = groupX + groupW

    layout["Ports.Port " .. p .. ".Enabled"] = {
      Style             = "Button",
      ButtonStyle       = "Toggle",
      Position          = { enableX, y },
      Size              = { enableW, cellH },
      FontSize          = 9,
      TextColor         = { 255, 255, 255 },
      Color             = { 30, 200, 60 },
      OffColor          = { 0, 0, 0 },
      CornerRadius      = 2,
      HTextAlign        = "Center",
      VTextAlign        = "Center",
      ButtonVisualStyle = "Flat",
      Legend            = "",
    }

    -- Port number is a clickable Button (identifies the port via API).
    layout["Port Identify.Port " .. p] = {
      Style             = "Button",
      ButtonStyle       = "Momentary",
      ButtonVisualStyle = "Flat",
      Position          = { labelX, y },
      Size              = { labelW, cellH },
      Font              = "Roboto",
      FontSize          = 10,
      Legend            = tostring(p),
      TextColor         = theme.textPrimary,
      Color             = { 0, 0, 0, 0 },
      OffColor          = { 0, 0, 0, 0 },
      StrokeColor       = { 0, 0, 0, 0 },
      StrokeWidth       = 0,
    }

    layout["Ports.Port " .. p .. ".Legend"] = {
      Style        = "TextBox",
      Position     = { legendX + 1, y },
      Size         = { legendW - 2, cellH },
      Font         = "Roboto",
      FontSize     = 10,
      HTextAlign   = "Left",
      TextColor    = theme.textPrimary,
      Color        = { 0, 0, 0, 0 },
      StrokeColor  = theme.cardStroke,
      StrokeWidth  = 1,
      CornerRadius = 1,
    }

    layout["Ports.Port " .. p .. ".RLinkX.Enabled"] = {
      Style             = "Button",
      ButtonStyle       = "Toggle",
      Position          = { rlinkxX, y },
      Size              = { rlinkxW, cellH },
      Color             = { 0, 200, 255 },
      CornerRadius      = 2,
      OffColor          = { 40, 40, 40 },
      HTextAlign        = "Center",
      VTextAlign        = "Center",
      ButtonVisualStyle = "Flat",
      Legend            = "",
    }

    if p <= poeCount then
      layout["PoE.Port " .. p .. ".Enabled"] = {
        Style             = "Button",
        ButtonStyle       = "Toggle",
        Position          = { poeToggleX, y },
        Size              = { poeToggleW, cellH },
        Color             = { 0, 0, 0, 0 },
        CornerRadius      = 2,
        ButtonVisualStyle = "Flat",
        Legend            = "",
      }

      layout["PoE.Bounce " .. p] = {
        Style             = "Button",
        ButtonStyle       = "Momentary",
        Position          = { poeBounceX, y },
        Size              = { poeBounceW, cellH },
        Legend            = "↻",
        FontSize          = 10,
        TextColor         = theme.textPrimary,
        Color             = theme.accentCyan,
        OffColor          = theme.buttonOffColor,
        CornerRadius      = 2,
        ButtonVisualStyle = "Flat",
      }
    end

    layout["Port.Group " .. p] = {
      Style             = "Button",
      ButtonStyle       = "Momentary",
      ButtonVisualStyle = "Flat",
      Position          = { groupX, y },
      Size              = { groupW, cellH },
      Font              = "Roboto",
      FontSize          = 10,
      Legend            = "",
      TextColor         = { 255, 255, 255, 255 },
      Color             = { 60, 70, 90, 255 },
      OffColor          = { 60, 70, 90, 255 },
      StrokeColor       = theme.cardStroke,
      StrokeWidth       = 1,
      CornerRadius      = 2,
    }

    layout["Port.Speed Cell " .. p] = {
      Style             = "Button",
      ButtonStyle       = "Momentary",
      ButtonVisualStyle = "Flat",
      Position          = { speedX, y },
      Size              = { speedW, cellH },
      Font              = "Roboto",
      FontSize          = 10,
      Legend            = "",
      TextColor         = { 255, 255, 255, 255 },
      Color             = { 60, 70, 90, 255 },
      OffColor          = { 60, 70, 90, 255 },
      StrokeColor       = theme.cardStroke,
      StrokeWidth       = 1,
      CornerRadius      = 2,
    }
  end

end

--------------------------------------------------------------------------------
-- Groups and Trunks sections (groups | custom groups | trunks | custom
-- trunks): a vertical card list per section that spills into sub-columns
-- after groupsRowsForModel(model) items. Shared by the Groups and Trunks
-- page and the main-page group picker. onSection(index, title, x, labelY,
-- widthPx) fires once per section, onCard(kind, item, x, y) once per card
-- (item = { slot, name, key } or { slot, placeholder = true } for a reserved
-- custom slot the runtime fills later).
--------------------------------------------------------------------------------
local function walkGroupTrunkSections(model, originX, labelY, cardsY, onSection, onCard)
  local rows = groupsRowsForModel(model)
  local sections = {
    { title = "Groups",        kind = "group", items = {} },
    { title = "Custom groups", kind = "group", items = {} },
    { title = "Trunks",        kind = "trunk", items = {} },
    { title = "Custom trunks", kind = "trunk", items = {} },
  }
  for i = 1, 20 do
    local name = state.groupNames[i] or (i == 1 and "Management" or ("Group " .. string.format("%02d", i)))
    sections[1].items[i] = { slot = i, name = name, key = "Group: " .. i }
  end
  for i = 1, CUSTOM_GROUP_SLOTS do
    sections[2].items[i] = { slot = 20 + i, placeholder = true }
  end
  sections[3].items[1] = { slot = 1, name = "ISL", key = "Trunk: 1" }
  for i = 1, CUSTOM_TRUNK_SLOTS do
    sections[4].items[i] = { slot = 1 + i, placeholder = true }
  end

  local cursorX = originX
  for si, s in ipairs(sections) do
    local subCols    = math.max(1, math.ceil(#s.items / rows))
    local sectionWpx = subCols * GT_CARD_W + (subCols - 1) * 4
    onSection(si, s.title, cursorX, labelY, sectionWpx)
    for idx, item in ipairs(s.items) do
      local subCol = math.floor((idx - 1) / rows)
      local rowI   = (idx - 1) % rows
      onCard(s.kind, item, cursorX + subCol * (GT_CARD_W + 4), cardsY + rowI * (GT_CARD_H + GT_GAP_Y))
    end
    cursorX = cursorX + sectionWpx + GT_SECTION_GAP
  end
end

--------------------------------------------------------------------------------
-- Group picker panel (main page). A modal card over the chassis page that
-- lists every group and trunk slot; the runtime paints and shows it when a
-- Port.Group cell is clicked (openGroupPicker in info.lua) and hides it
-- again after a pick. Every control is transparent at layout time (offline
-- look) and IsInvisible from runtime start. The "zPicker" prefix sorts after
-- every other main-page control so the panel renders on top of the grid.
--------------------------------------------------------------------------------
local PICKER_PAD, PICKER_TITLE_H, PICKER_BTN_W = 8, 20, 70

local PICKER_CLEAR = { 0, 0, 0, 0 }

local function pickerButton(layout, name, x, y, w, h)
  layout[name] = {
    Style             = "Button",
    ButtonStyle       = "Momentary",
    ButtonVisualStyle = "Flat",
    Position          = { x, y },
    Size              = { w, h },
    Font              = "Roboto",
    FontSize          = 10,
    Legend            = "",
    TextColor         = { 255, 255, 255 },
    Color             = PICKER_CLEAR,
    OffColor          = PICKER_CLEAR,
    StrokeColor       = PICKER_CLEAR,
    StrokeWidth       = 0,
    CornerRadius      = 3,
    HTextAlign        = "Center",
    VTextAlign        = "Center",
  }
end
local function pickerText(layout, name, x, y, w, h, textColor)
  layout[name] = {
    Style        = "Text",
    Position     = { x, y },
    Size         = { w, h },
    Font         = "Roboto",
    FontSize     = 11,
    IsBold       = true,
    HTextAlign   = "Left",
    VTextAlign   = "Center",
    TextColor    = textColor,
    Color        = PICKER_CLEAR,
    StrokeWidth  = 0,
    IsReadOnly   = true,
    String       = "",
  }
end

local function buildGroupPickerPanel(layout, model, theme)
  local rows   = groupsRowsForModel(model)
  local pageW  = pageWidthForModel(model)
  local panelW = groupsPageWidthForRows(rows) - 2 * GT_MARGIN_X + 2 * PICKER_PAD
  local panelH = PICKER_PAD + PICKER_TITLE_H + 6 + GT_LABEL_H + 6
               + rows * (GT_CARD_H + GT_GAP_Y) - GT_GAP_Y + PICKER_PAD
  local panelX = math.floor((pageW - panelW) / 2 + 0.5)
  local panelY = 10
  pickerButton(layout, "zPicker.Bg", panelX, panelY, panelW, panelH)
  layout["zPicker.Bg"].CornerRadius = 4

  local titleY  = panelY + PICKER_PAD
  local cancelX = panelX + panelW - PICKER_PAD - PICKER_BTN_W
  local noneX   = cancelX - 6 - PICKER_BTN_W
  pickerText(layout, "zPicker.Title", panelX + PICKER_PAD, titleY, noneX - 6 - (panelX + PICKER_PAD), PICKER_TITLE_H, theme.textPrimary)
  pickerButton(layout, "zPicker.None",   noneX,   titleY, PICKER_BTN_W, PICKER_TITLE_H)
  pickerButton(layout, "zPicker.Cancel", cancelX, titleY, PICKER_BTN_W, PICKER_TITLE_H)

  local labelY = titleY + PICKER_TITLE_H + 6
  walkGroupTrunkSections(model, panelX + PICKER_PAD, labelY, labelY + GT_LABEL_H + 6,
    function(si, _title, x, y, w)
      pickerText(layout, "zPicker.Label " .. si, x, y, w, GT_LABEL_H, theme.textMuted)
    end,
    function(kind, item, x, y)
      pickerButton(layout, ((kind == "group") and "zPicker.Group " or "zPicker.Trunk ") .. item.slot, x, y, GT_CARD_W, GT_CARD_H)
    end)
end


--------------------------------------------------------------------------------
-- Speed picker panel (main page). Same mechanics as the group picker: a
-- Port.Speed Cell click makes the runtime paint and show it (openSpeedPicker
-- in info.lua); zSpeed.Item i is SPEED_CHOICES[i], laid out as a 3-column
-- grid of cards under a title row.
--------------------------------------------------------------------------------
local SPEED_PICKER_COLS, SPEED_CARD_W, SPEED_CARD_GAP_X = 3, 130, 6

local function buildSpeedPickerPanel(layout, model, theme)
  local n      = #SPEED_CHOICES
  local rows   = math.ceil(n / SPEED_PICKER_COLS)
  local pageW  = pageWidthForModel(model)
  local panelW = 2 * PICKER_PAD + SPEED_PICKER_COLS * SPEED_CARD_W + (SPEED_PICKER_COLS - 1) * SPEED_CARD_GAP_X
  local panelH = PICKER_PAD + PICKER_TITLE_H + 6 + rows * (GT_CARD_H + GT_GAP_Y) - GT_GAP_Y + PICKER_PAD
  local panelX = math.floor((pageW - panelW) / 2 + 0.5)
  local panelY = 10

  pickerButton(layout, "zSpeed.Bg", panelX, panelY, panelW, panelH)
  layout["zSpeed.Bg"].CornerRadius = 4

  local titleY  = panelY + PICKER_PAD
  local cancelX = panelX + panelW - PICKER_PAD - PICKER_BTN_W
  pickerText(layout, "zSpeed.Title", panelX + PICKER_PAD, titleY, cancelX - 6 - (panelX + PICKER_PAD), PICKER_TITLE_H, theme.textPrimary)
  pickerButton(layout, "zSpeed.Cancel", cancelX, titleY, PICKER_BTN_W, PICKER_TITLE_H)

  local cardsY = titleY + PICKER_TITLE_H + 6
  for i = 1, n do
    local col = (i - 1) % SPEED_PICKER_COLS
    local row = math.floor((i - 1) / SPEED_PICKER_COLS)
    pickerButton(layout, "zSpeed.Item " .. i,
      panelX + PICKER_PAD + col * (SPEED_CARD_W + SPEED_CARD_GAP_X),
      cardsY + row * (GT_CARD_H + GT_GAP_Y), SPEED_CARD_W, GT_CARD_H)
  end
end

--------------------------------------------------------------------------------
-- LLDP neighbor panel (main page): centred under the chassis box, over the
-- port-settings grid; zLldp.Panel carries the panel SVG (lldpPanelSvg), its
-- two buttons sit in the title row's right part. Blank and hidden until the
-- runtime opens it (openLldpPanel in info.lua).
--------------------------------------------------------------------------------
local LLDP_PANEL_BUTTON_W, LLDP_PANEL_BUTTON_H, LLDP_PANEL_PAD = 70, 20, 8

local function buildLldpPanel(layout, model)
  local chassisX = CHASSIS_X + DISPLAY_W + DISPLAY_GAP
  local x = chassisX + math.floor((chassisGeometry(model).w - LLDP_PANEL_W) / 2)
  local y = CHASSIS_Y + CHASSIS_H + 6
  -- Clickable, so a click on the panel never reaches the grid underneath.
  clickableIconButton(layout, "zLldp.Panel", x, y, LLDP_PANEL_W, LLDP_PANEL_H)
  local closeX = x + LLDP_PANEL_W - LLDP_PANEL_PAD - LLDP_PANEL_BUTTON_W
  local buttonY = y + LLDP_PANEL_PAD
  pickerButton(layout, "zLldp.Panel Close", closeX, buttonY, LLDP_PANEL_BUTTON_W, LLDP_PANEL_BUTTON_H)
  pickerButton(layout, "zLldp.Panel To Legend", closeX - 6 - LLDP_PANEL_BUTTON_W, buttonY, LLDP_PANEL_BUTTON_W,
    LLDP_PANEL_BUTTON_H)
end

local function buildControlsPage(layout, gfx, model)
  local theme = getThemeColors()
  buildChassisPage(layout, gfx, model, theme)
  buildGroupPickerPanel(layout, model, theme)
  buildSpeedPickerPanel(layout, model, theme)
  buildLldpPanel(layout, model)
end

--------------------------------------------------------------------------------
-- Configuration page
--------------------------------------------------------------------------------
local function buildConfigurationPage(layout, gfx, props)
  local theme  = getThemeColors()
  -- Match main-page height (computed in buildChassisPage); use
  -- pageHeightForModel so tabs don't resize the window.
  local model = resolveModel(props)
  local totalW = pageWidthForModel(model)
  local totalH = pageHeightForModel(model)

  gfx[#gfx+1] = {
    Type        = "Groupbox",
    Fill        = theme.groupboxFill,
    StrokeColor = { 0, 0, 0 },
    StrokeWidth = 0,
    Position    = { 0, 0 },
    Size        = { totalW, totalH },
  }

  defineCommonDeviceInfo(layout, gfx, theme, 0, 0)

  local labelX = 30
  local inputX = 110
  local rowY   = 90
  local rowGap = 40
  local boxW   = 140
  local boxH   = 24
  local labelW = 70

  local connectX = 270
  local btnW     = 120
  local btnH     = 30

  gfx[#gfx+1] = {
    Type       = "Text",
    Text       = "IP Address",
    Position   = { labelX, rowY + 0 },
    Size       = { labelW, boxH },
    Font       = "Roboto",
    FontSize   = 10,
    Color      = theme.labelGray,
    HTextAlign = "Right",
    VTextAlign = "Center",
  }

  layout["Auth.IP Address"] = {
    Style      = "TextBox",
    Position   = { inputX, rowY + 0 },
    Size       = { boxW, boxH },
    Font       = "Roboto",
    FontSize   = 14,
    HTextAlign = "Center",
    Color      = { 0, 0, 0, 0 },
    TextColor  = { 255, 255, 255 },
  }

  layout["Auth.Connect"] = {
    Legend      = "Connect",
    Style       = "Button",
    ButtonStyle = "Momentary",
    Color       = { 0, 255, 0 },
    OffColor    = theme.buttonOffColor,
    Position    = { connectX, rowY },
    Size        = { btnW, btnH },
    Font        = "Roboto",
    FontSize    = 13,
    HTextAlign  = "Center",
  }

  gfx[#gfx+1] = {
    Type       = "Text",
    Text       = "Username",
    Position   = { labelX, rowY + rowGap },
    Size       = { labelW, boxH },
    Font       = "Roboto",
    FontSize   = 10,
    TextColor  = { 255, 255, 255 },
    Color      = theme.labelGray,
    HTextAlign = "Right",
    VTextAlign = "Center",
  }

  layout["Auth.Username"] = {
    Style      = "TextBox",
    Position   = { inputX, rowY + rowGap },
    Size       = { boxW, boxH },
    Font       = "Roboto",
    FontSize   = 14,
    HTextAlign = "Center",
    Color      = { 0, 0, 0, 0 },
    TextColor  = { 255, 255, 255 },
  }

  layout["Identify"] = {
    Legend      = "Identify",
    Style       = "Button",
    ButtonStyle = "Momentary",
    Color       = { 0, 150, 255 },
    OffColor    = { 30, 30, 30 },
    Position    = { connectX, rowY + rowGap },
    Size        = { btnW, btnH },
    Font        = "Roboto",
    FontSize    = 13,
    HTextAlign  = "Center",
  }

  gfx[#gfx+1] = {
    Type       = "Text",
    Text       = "Password",
    Position   = { labelX, rowY + rowGap * 2 },
    Size       = { labelW, boxH },
    Font       = "Roboto",
    FontSize   = 10,
    Color      = theme.labelGray,
    HTextAlign = "Right",
    VTextAlign = "Center",
  }

  -- Q-SYS has no masked text box for plugins: the password box draws its
  -- text transparent, over Auth.Masked Password (alphabetically before it,
  -- so drawn below), where the runtime writes the bullets.
  layout["Auth.Masked Password"] = {
    Style      = "Text",
    Position   = { inputX, rowY + rowGap * 2 },
    Size       = { boxW, boxH },
    Font       = "Roboto",
    FontSize   = 14,
    HTextAlign = "Center",
    Color      = { 0, 0, 0, 0 },
    TextColor  = { 255, 255, 255 },
    StrokeWidth = 0,
    IsReadOnly = true,
  }

  -- Designer's hover tooltip shows the value of a text box whose PrettyName
  -- is empty: name it so the tooltip shows "Password", not the password.
  layout["Auth.Password"] = {
    Style      = "TextBox",
    PrettyName = "Password",
    Position   = { inputX, rowY + rowGap * 2 },
    Size       = { boxW, boxH },
    Font       = "Roboto",
    FontSize   = 14,
    HTextAlign = "Center",
    Color      = { 0, 0, 0, 0 },
    TextColor  = { 0, 0, 0, 0 },
  }

  layout["Auth.Status"] = {
    Style       = "Text",
    Position    = { connectX, rowY + rowGap * 2 },
    Size        = { btnW, boxH },
    Font        = "Roboto",
    FontSize    = 11,
    TextColor   = { 255, 255, 255 },
    StrokeWidth = 0,
    Color       = { 0, 0, 0, 0 },
    HTextAlign  = "Center",
    VTextAlign  = "Center",
    IsReadOnly  = true,
    Legend      = "Auth.Status",
  }
end

--------------------------------------------------------------------------------
-- Groups and Trunks settings page (Araneo-inspired, sectioned)
--
-- Sections, top to bottom:
--   • Predefined Groups   — 5×4 grid (ids 1..20)
--   • Custom Groups       — row of state.groupList entries with predefined=false
--   • Predefined Trunks   — row of state.trunkList entries with predefined=true
--   • Custom Trunks       — row of state.trunkList entries with predefined=false
--
-- Each card renders via a group_label_N / trunk_label_N text control. The card
-- fill color comes from state.customColors (live API), falling back to the
-- hardcoded GROUP_COLORS palette so a pre-connect view still renders something.
-- Trunk cards get a "◤" overlay in the top-left corner to visually match the
-- chassis-view trunk indicator.
--------------------------------------------------------------------------------
local function buildGroupTrunkSettingsPage(layout, gfx, props)
  local theme = getThemeColors()

  local model = resolveModel(props)
  local pageW, pageH = pageWidthForModel(model), pageHeightForModel(model)

  gfx[#gfx+1] = {
    Type        = "Groupbox",
    Fill        = theme.groupboxFill,
    StrokeColor = GROUPBOX_STROKE_COLOR,
    StrokeWidth = GROUPBOX_STROKE_WIDTH,
    Position    = GROUPBOX_POSITION,
    Size        = { pageW, pageH },
  }

  defineCommonDeviceInfo(layout, gfx, theme, 0, 0)

  -- Compact 4-section layout (left→right): Predefined Groups | Custom
  -- Groups | Predefined Trunks | Custom Trunks. Each section is a vertical
  -- list of small cards that fits within the page's content height.
  local marginX = GT_MARGIN_X
  local topY    = GT_TOP_Y
  local cardW   = GT_CARD_W
  local cardH   = GT_CARD_H
  local labelH  = GT_LABEL_H

  state.groupList    = state.groupList    or {}
  state.trunkList    = state.trunkList    or {}
  state.customColors = state.customColors or {}
  state.groupNames   = state.groupNames   or {}

  local function sectionLabel(x, y, text, widthPx)
    gfx[#gfx+1] = {
      Type       = "Text",
      Text       = text,
      Position   = { x, y },
      Size       = { widthPx, labelH },
      Font       = "Roboto",
      FontSize   = 11,
      Color      = theme.textMuted,
      HTextAlign = "Left",
      VTextAlign = "Center",
      IsBold     = true,
    }
    gfx[#gfx+1] = {
      Type        = "Rectangle",
      Position    = { x, y + labelH + 1 },
      Size        = { widthPx, 1 },
      Fill        = theme.cardStroke,
      StrokeWidth = 0,
    }
  end

  -- placeholder = reserved custom slot: invisible until the runtime fills it
  -- (refreshCustomSlots in info.lua).
  local function placeCard(kind, slot, name, keyForColor, x, y, isTrunk, placeholder)
    local labelName = (kind == "group") and ("group_label_" .. slot) or ("trunk_label_" .. slot)
    local badgeName = (kind == "group") and ("group_id_badge_" .. slot) or ("trunk_id_badge_" .. slot)
    layout[labelName] = {
      Style        = "Text",
      Position     = { x, y },
      Size         = { cardW, cardH },
      IsReadOnly   = true,
      FontSize     = 10,
      Font         = "Roboto",
      Color        = { 0, 0, 0, 0 },   -- transparent offline; runtime paints the group color
      TextColor    = { 255, 255, 255 },
      StrokeWidth  = 0,
      CornerRadius = 3,
      HTextAlign   = "Center",
      VTextAlign   = "Center",
      String       = name or "",
    }
    layout[badgeName] = {
      Style        = "Text",
      Position     = { x + cardW - 14, y + 2 },
      Size         = { 12, 9 },
      FontSize     = 7,
      Font         = "Roboto",
      TextColor    = { 255, 255, 255 },
      Color        = { 0, 0, 0, 0 },   -- transparent offline; runtime paints it
      CornerRadius = 2,
      StrokeWidth  = 0,
      IsReadOnly   = true,
      HTextAlign   = "Center",
      VTextAlign   = "Center",
      String       = placeholder and "" or tostring(slot),
    }
  end

  -- Fixed sections (walkGroupTrunkSections): groups 1..20 and the ISL
  -- trunk always exist; custom groups/trunks only exist on the switch, so
  -- the layout reserves invisible slots (group_label_21.., trunk_label_2..)
  -- that the runtime fills in id order.
  walkGroupTrunkSections(model, marginX, topY, topY + labelH + 6,
    function(_si, title, x, y, w) sectionLabel(x, y, title, w) end,
    function(kind, item, x, y)
      placeCard(kind, item.slot, item.name, item.key, x, y, kind == "trunk", item.placeholder)
    end)
end

--------------------------------------------------------------------------------
-- Neighbors page (LLDP): the device header of Groups and Trunks, the column
-- headers of each block, then per port Lldp.Row N (every cell in one IconData
-- SVG, lldpRowSvg). The runtime fills the rows (refreshLldpRows in info.lua);
-- blank offline.
--------------------------------------------------------------------------------
local function buildNeighborsPage(layout, gfx, props)
  local theme = getThemeColors()
  local model = resolveModel(props)
  local pageW, pageH = pageWidthForModel(model), pageHeightForModel(model)

  gfx[#gfx+1] = {
    Type        = "Groupbox",
    Fill        = theme.groupboxFill,
    StrokeColor = GROUPBOX_STROKE_COLOR,
    StrokeWidth = GROUPBOX_STROKE_WIDTH,
    Position    = GROUPBOX_POSITION,
    Size        = { pageW, pageH },
  }
  defineCommonDeviceInfo(layout, gfx, theme, 0, 0)

  local geometry = neighborsGeometry(model)
  local columns  = neighborsColumns(geometry.blockW, geometry.compact)

  local headers = { { "name", "Neighbor" }, { "device", "Description" }, { "remotePort", "Port" }, { "ip", "IP" } }
  local headerH = 14
  for block = 0, geometry.blocks - 1 do
    local blockX = LLDP_MARGIN_X + block * (geometry.blockW + LLDP_BLOCK_GAP)
    for _, header in ipairs(headers) do
      local column = columns[header[1]]
      if column then
        gfx[#gfx+1] = {
          Type       = "Text",
          Text       = header[2],
          Position   = { blockX + column.x, geometry.rowsY - headerH },
          Size       = { column.w, headerH },
          Font       = "Roboto",
          FontSize   = 10,
          Color      = theme.textMuted,
          HTextAlign = "Left",
          VTextAlign = "Center",
        }
      end
    end
  end

  for port = 1, getPortCount(model) do
    local x, y = neighborsRowPosition(model, port)
    iconButton(layout, "Lldp.Row " .. port, x, y, geometry.blockW, geometry.rowH)
  end
end

-- Q-SYS lists a pin in Control Pins only when its control has a layout
-- entry. Every pin the main page does not place gets a Style "None" entry
-- (hidden, pin kept); the PrettyName pass below files it in its folder.
local function addPinOnlyEntries(layout, props)
  for _, ctl in ipairs(GetControls(props)) do
    if ctl.UserPin == true and layout[ctl.Name] == nil then
      layout[ctl.Name] = { Style = "None", Position = { 0, 0 }, Size = { 1, 1 } }
    end
  end
end

--------------------------------------------------------------------------------
-- Page dispatcher — model-named page falls through to buildControlsPage
--------------------------------------------------------------------------------
local pageBuilders = {
  ["Configuration"] = buildConfigurationPage,
  ["Groups and Trunks"] = buildGroupTrunkSettingsPage,
  ["Neighbors"] = buildNeighborsPage,
}

setmetatable(pageBuilders, {
  __index = function(_, _key)
    return function(layout, gfx, props)
      buildControlsPage(layout, gfx, resolveModel(props))
      addPinOnlyEntries(layout, props)
    end
  end,
})

--------------------------------------------------------------------------------
-- GetControlLayout body
--------------------------------------------------------------------------------
local pages = GetPages(props)
local idx = props["page_index"] and props["page_index"].Value or 1
local pageObj = pages[idx]
local pageName = pageObj and pageObj.name or modelString

local layout = {}
local gfx = {}

local builder = pageBuilders[pageName]
if builder then
  builder(layout, gfx, props)
end

-- Q-SYS trees the Control Pins panel on the `PrettyName` of each layout
-- entry using "~" as the delimiter. Our control Names already carry the
-- API tree with "." (e.g. "PoE.Port 1.Enabled"), so we just swap "." → "~"
-- and assign as PrettyName. Keeps Name unchanged (stable pin ID) while the
-- display in Q-SYS Designer nests into folders: PoE > Port 1 > Enabled, etc.
--
-- Designer's hover tooltip shows the PrettyName. Controls that expose no pin
-- get an empty PrettyName, which shrinks the tooltip to an empty bubble (it
-- cannot be removed from plugin code). Pinned controls keep the "~" tree name.
local noPin = {}
for _, ctl in ipairs(GetControls(props)) do
  if ctl.UserPin == false and (ctl.PinStyle == nil or ctl.PinStyle == "None") then
    noPin[ctl.Name] = true
  end
end
for key, entry in pairs(layout) do
  if type(key) == "string" and type(entry) == "table" and entry.PrettyName == nil then
    if noPin[key] then
      entry.PrettyName = ""
    else
      local pretty = key:gsub("%.", "~")
      if pretty ~= key then entry.PrettyName = pretty end
    end
  end
end

return layout, gfx
