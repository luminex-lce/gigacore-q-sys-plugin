-- port_card.lua
-- Web UI port cards drawn as SVG: one IconData SVG per port at runtime, and the
-- static offline chassis graphic built from the same drawing functions (the
-- build-time tool tools/gen_offline_chassis.py calls chassisOfflineSvg).
-- Colors and sizes are the web UI's and do not follow the plugin theme.

local CARD_BORDER_COLOR = "#CED3DD"
CARD_BAR_SPACE = 10             -- room for the MultiLinkX bar on the bar side
FRAME_LABEL_SPACE = 24          -- room for the rotated 10G / speed label
local FRAME_COLOR = "#00FFA1"
local CHASSIS_FILL = "#0B1220"
local FONT = 'font-family="Roboto, Arial, sans-serif"'

local function svgNumber(value)
  return string.format("%g", value)
end

local function rectElement(x, y, width, height, extra)
  return '<rect x="' .. svgNumber(x) .. '" y="' .. svgNumber(y) .. '" width="' .. svgNumber(width)
    .. '" height="' .. svgNumber(height) .. '" ' .. extra .. '/>'
end

-- Baseline that centres digits and capitals on a given y: dominant-baseline
-- is outside SVG Tiny, so the offset is computed (cap height ~0.7 em).
local function baseline(centreY, size)
  return centreY + 0.35 * size
end

-- Bold text centred on (x, centreY).
local function textElement(x, centreY, size, fill, content)
  return '<text x="' .. svgNumber(x) .. '" y="' .. svgNumber(baseline(centreY, size)) .. '" ' .. FONT .. ' font-size="'
    .. size .. '" font-weight="bold" text-anchor="middle" fill="' .. fill .. '">' .. content .. '</text>'
end

local function point(x, y)
  return svgNumber(x) .. "," .. svgNumber(y)
end

local function isFullHeight(kind)
  return kind == "ethercon" or kind == "rfib"
end

-- The MultiLinkX bar sits above etherCON / rfib and ttb cards, below btt
-- cards (card = a chassisGeometry card or a card view).
function cardBarOnTop(card)
  return isFullHeight(card.kind) or card.direction == "ttb"
end

local function numberColor(fill)
  local r, g, b = (fill or ""):match("^#(%x%x)(%x%x)(%x%x)")
  if not r then return "#fff" end
  local luminance = tonumber(r, 16) * 0.299 + tonumber(g, 16) * 0.587 + tonumber(b, 16) * 0.114
  if luminance > 130 then return "#333" end
  return "#fff"
end

-- Card border: all corners rounded on etherCON / rfib, the outer corners only
-- on half-height cards (a ttb / btt pair meets square at the midline).
local function cardOutline(view)
  local style = 'fill="' .. (view.cardFill or "none") .. '" stroke="' .. CARD_BORDER_COLOR .. '" stroke-width="1"'
  local w, h = view.w, view.h
  if isFullHeight(view.kind) then
    return rectElement(0.5, 0.5, w - 1, h - 1, 'rx="4" ' .. style)
  end
  local left, right, top, bottom = 0.5, w - 0.5, 0.5, h - 0.5
  local d
  if view.direction == "ttb" then
    d = "M" .. point(left, bottom) .. " L" .. point(left, top + 4) .. " Q" .. point(left, top) .. " " .. point(left + 4, top)
      .. " L" .. point(right - 4, top) .. " Q" .. point(right, top) .. " " .. point(right, top + 4)
      .. " L" .. point(right, bottom) .. " Z"
  else
    d = "M" .. point(left, top) .. " L" .. point(right, top) .. " L" .. point(right, bottom - 4)
      .. " Q" .. point(right, bottom) .. " " .. point(right - 4, bottom) .. " L" .. point(left + 4, bottom)
      .. " Q" .. point(left, bottom) .. " " .. point(left, bottom - 4) .. " Z"
  end
  return '<path d="' .. d .. '" ' .. style .. '/>'
end

-- Jack and PoE boxes (web UI border-box sizes, card-local px).
local function jackBox(view)
  if isFullHeight(view.kind) then return 14, 44, 32, 20 end
  return 5, (view.direction == "ttb") and 29 or 5, view.w - 10, 20
end

local function poeBox(view)
  if view.kind == "ethercon" then return 24, 58, 12, 10 end
  if view.kind == "rj45" then return (view.w - 12) / 2, (view.direction == "ttb") and 25 or 19, 12, 10 end
  return nil
end

-- 7 x 7 disabled icon centred in the jack, pushed 2.5 px away from the PoE square.
local function disabledIcon(view, jx, jy, jw, jh)
  local offset = (view.direction == "ttb") and 2.5 or -2.5
  local x = jx + jw / 2 - 3.5
  local y = jy + jh / 2 - 3.5 + offset
  return rectElement(x, y, 7, 7, 'rx="1.5" fill="#FF2D55"')
    .. '<path d="M' .. point(x + 2, y + 2) .. " L" .. point(x + 5, y + 5) .. " M" .. point(x + 5, y + 2)
    .. " L" .. point(x + 2, y + 5) .. '" stroke="#00011F" stroke-width="1" fill="none"/>'
end

-- Araneo port badges: the RSTP role (root / alternate) and the IGMP multicast
-- router port, white-bordered, packed from the left over the number row.
local BADGE_W, BADGE_H = 20, 16
local RSTP_BADGE = {
  root      = { fill = "#a56de2", rx = 3, text = "#000", label = "root" },
  alternate = { fill = "#c6262e", rx = 0, text = "#fff", label = "alt" },
}
local MR_BADGE = { fill = "#000", rx = 3, text = "#fff", label = "MR" }

local function badge(x, centreY, style)
  return rectElement(x + 0.75, centreY - BADGE_H / 2 + 0.75, BADGE_W - 1.5, BADGE_H - 1.5, 'rx="' .. style.rx
      .. '" fill="' .. style.fill .. '" stroke="#fff" stroke-width="1.5"')
    .. textElement(x + BADGE_W / 2, centreY, 8, style.text, style.label)
end

-- Card drawn with its own box at the local origin (no MultiLinkX bar space).
local function portCardBody(view)
  local w, h = view.w, view.h
  local parts = { cardOutline(view) }
  local present = not view.notPresent

  if isFullHeight(view.kind) then
    table.insert(parts, '<circle cx="30" cy="54" r="24.5" fill="' .. (present and "#434342" or "#000")
      .. '" stroke="#fff" stroke-width="1"/>')
    if view.kind == "ethercon" then
      table.insert(parts, rectElement(16.5, 16, 27, 13, 'rx="6.5" fill="#fff"'))
    end
  end

  if present then
    local jx, jy, jw, jh = jackBox(view)
    table.insert(parts, rectElement(jx + 1.5, jy + 1.5, jw - 3, jh - 3, 'fill="' .. view.linkFill .. '" stroke="'
      .. view.jackBorder .. '" stroke-width="3"'))
    if view.enabled == false then
      table.insert(parts, disabledIcon(view, jx, jy, jw, jh))
    end
    local px, py, pw, ph = poeBox(view)
    if px then
      table.insert(parts, rectElement(px + 0.5, py + 0.5, pw - 1, ph - 1, 'fill="' .. view.poeFill .. '" stroke="'
        .. view.poeBorder .. '" stroke-width="1"'))
    end
  end

  local numberY
  if isFullHeight(view.kind) then numberY = 95
  elseif view.direction == "ttb" then numberY = 12
  else numberY = h - 12 end
  table.insert(parts, textElement(w / 2, numberY, 12, numberColor(view.cardFill), tostring(view.number)))

  if view.trunk and present then
    table.insert(parts, '<path d="M1,9 L1,3 Q1,0.5 3.5,0.5 L9.5,0.5 Z" fill="#00011f"/>')
  end

  -- Like Araneo, the badges cover the number (and the trunk triangle on a ttb card).
  local badges = {}
  if RSTP_BADGE[view.rstpRole] then table.insert(badges, RSTP_BADGE[view.rstpRole]) end
  if view.mr then table.insert(badges, MR_BADGE) end
  for slot, style in ipairs(badges) do
    table.insert(parts, badge(1 + (slot - 1) * BADGE_W, numberY, style))
  end

  return table.concat(parts)
end

-- One port card as a standalone SVG: the card plus CARD_BAR_SPACE px on its
-- MultiLinkX side. One SVG unit = one screen pixel.
function portCardSvg(view)
  local w, h = view.w, view.h
  local topBar = cardBarOnTop(view)
  local parts = { '<svg xmlns="http://www.w3.org/2000/svg" width="' .. svgNumber(w) .. '" height="' .. svgNumber(h + CARD_BAR_SPACE)
    .. '" viewBox="0 0 ' .. svgNumber(w) .. " " .. svgNumber(h + CARD_BAR_SPACE) .. '">' }
  if view.mlx then
    table.insert(parts, rectElement(1, topBar and 1 or (h + 5), w - 2, 4, 'rx="2" fill="' .. view.mlx .. '"'))
  end
  if topBar then
    table.insert(parts, '<g transform="translate(0,' .. CARD_BAR_SPACE .. ')">')
  else
    table.insert(parts, '<g>')
  end
  table.insert(parts, portCardBody(view))
  if view.selected then  -- the port shown in the LLDP neighbor panel
    table.insert(parts, rectElement(1, 1, w - 2, h - 2, 'rx="2" fill="none" stroke="#fff" stroke-width="2"'))
  end
  table.insert(parts, '</g></svg>')
  return table.concat(parts)
end

-- View of a card when the design is offline (spec section 7).
function offlineCardView(card, port)
  return {
    kind = card.kind, direction = card.direction, w = card.w, h = card.h, number = port,
    cardFill = nil, enabled = true, notPresent = false,
    linkFill = "#000", jackBorder = CARD_BORDER_COLOR, poeFill = "#d6d7d7", poeBorder = "#d6d7d7",
    trunk = false, mlx = nil, mr = false, rstpRole = nil,
  }
end

local LINK_SLOW_FILL = "#ff6600"
local RLINKX_BORDER = {
  ["non-redundant"] = "#96ffff", ["redundant"] = "#0044ff",
  ["partial-redundant"] = "#ff6600", ["invalid-version"] = "#ff6600",
}
local POE_FILL = {
  enabled = "#f9c440", sourcing = "#ff6600", error = "#c6262E", disabled = "#424242", [""] = "#424242",
}

local MULTILINKX_BAR = { active = "#fff", member = "#cc00cc" }

local function linkFill(linkState)
  if not linkState or linkState == "down" or linkState == "unknown" then return "#000" end
  if linkState:find("^10mbps") or linkState:find("^100mbps") then return LINK_SLOW_FILL end
  return "#9bdb4d"
end

-- View of one live card (web UI port.vue color getters) from the port state;
-- card = chassisGeometry(model).cards[port].
function portCardView(port, card)
  local p = getPortState(port)
  local disabled = p.enabled == false
  local memberOf = p.memberOf
  local color = memberOf and ((state.customColors and state.customColors[memberOf]) or GROUP_COLORS[memberOf])
  local cardFill
  if color then cardFill = disabled and "#2B2B2B" or rgbHex(color) end
  -- Triangle whenever the reported membership is not a resolved group:
  -- trunk, unresolved id or type none (port.vue isTrunk).
  local isTrunk = p.memberOfKnown == true and (memberOf == nil or memberOf:sub(1, 6) == "Trunk:" or color == nil)
  -- RSTP role: the port's own root / alternate, else the role of its LAG (the
  -- API reports a MultiLinkX link's role on the LAG port, 66 and up).
  local rstpRole = p.rstpRole
  local lag = state.lagOf[port] and state.ports[state.lagOf[port]]
  if rstpRole ~= "root" and rstpRole ~= "alternate" and lag then rstpRole = lag.rstpRole end
  return {
    kind = card.kind, direction = card.direction, w = card.w, h = card.h, number = port,
    cardFill = cardFill,
    enabled = not disabled,
    notPresent = card.kind == "rfib" and state.fiberPossible == true and state.fiberActive ~= true,
    linkFill = disabled and "#000" or linkFill(p.linkState),
    jackBorder = disabled and "#505050" or (RLINKX_BORDER[p.rlinkxState] or CARD_BORDER_COLOR),
    poeFill = (p.poe ~= nil and POE_FILL[p.poe]) or "#d6d7d7",
    poeBorder = disabled and "#505050" or ((p.rlinkxEnabled == true) and "#154259" or "#d6d7d7"),
    trunk = isTrunk,
    mlx = MULTILINKX_BAR[p.multilinkx],
    mr = p.mr == true,
    rstpRole = rstpRole,
    selected = state.lldpPanelPort == port,
  }
end

-- Frame and rotated label, with the frame's own box starting FRAME_LABEL_SPACE
-- px from the left.
local function frameBody(frame)
  local labelX, labelY = FRAME_LABEL_SPACE - 10, 18
  return rectElement(FRAME_LABEL_SPACE + 0.5, 0.5, frame.w - 1, frame.h - 1,
      'rx="4" fill="none" stroke="' .. FRAME_COLOR .. '" stroke-width="1"')
    .. '<text x="' .. svgNumber(labelX) .. '" y="' .. svgNumber(baseline(labelY, 10)) .. '" ' .. FONT
    .. ' font-size="10" text-anchor="middle" fill="' .. FRAME_COLOR
    .. '" transform="rotate(-90 ' .. svgNumber(labelX) .. " " .. svgNumber(labelY) .. ')">' .. frame.label .. '</text>'
end

function tenGFrameSvg(frame)
  local w, h = frame.w + FRAME_LABEL_SPACE, frame.h
  return '<svg xmlns="http://www.w3.org/2000/svg" width="' .. svgNumber(w) .. '" height="' .. svgNumber(h)
    .. '" viewBox="0 0 ' .. svgNumber(w) .. " " .. svgNumber(h) .. '">' .. frameBody(frame) .. '</svg>'
end

-- Querier panel of the status block: a "Querier" title line, then one badge
-- per group this switch is the IGMP querier for, 9 per row on 4 rows (13 px
-- badges in the status block's 145 px text column). Past 36 groups the last
-- slot counts the groups left out.
QUERIER_W = 145
QUERIER_H = 74
local QUERIER_TITLE_H = 14
local QUERIER_BADGE = 13
local QUERIER_PITCH = 15
local QUERIER_PER_ROW = 9
local QUERIER_SLOTS = 36
local QUERIER_NUMBER_SIZE = 8
local QUERIER_OVERFLOW_FILL = "#424242"

local function querierBadge(slot, fill, label)
  local x = ((slot - 1) % QUERIER_PER_ROW) * QUERIER_PITCH
  local y = QUERIER_TITLE_H + math.floor((slot - 1) / QUERIER_PER_ROW) * QUERIER_PITCH
  local half = QUERIER_BADGE / 2
  return rectElement(x, y, QUERIER_BADGE, QUERIER_BADGE, 'rx="3" fill="' .. fill .. '"')
    .. textElement(x + half, y + half, QUERIER_NUMBER_SIZE, numberColor(fill), label)
end

-- groups: array of { id, color = "#RRGGBB" } sorted by id; "" when empty.
function querierBadgesSvg(groups, titleColor)
  if #groups == 0 then return "" end
  local parts = { '<svg xmlns="http://www.w3.org/2000/svg" width="' .. QUERIER_W .. '" height="' .. QUERIER_H
    .. '" viewBox="0 0 ' .. QUERIER_W .. " " .. QUERIER_H .. '">',
    '<text x="0" y="' .. svgNumber(baseline(QUERIER_TITLE_H / 2, 10)) .. '" ' .. FONT .. ' font-size="10" fill="'
      .. titleColor .. '">Querier</text>' }
  local drawn = #groups
  if drawn > QUERIER_SLOTS then drawn = QUERIER_SLOTS - 1 end
  for slot = 1, drawn do
    table.insert(parts, querierBadge(slot, groups[slot].color, tostring(groups[slot].id)))
  end
  if drawn < #groups then
    table.insert(parts, querierBadge(QUERIER_SLOTS, QUERIER_OVERFLOW_FILL, "+" .. (#groups - drawn)))
  end
  table.insert(parts, '</svg>')
  return table.concat(parts)
end

-- Whole chassis box as drawn offline: frame, dividers and always-shown speed
-- frames at full opacity (the graphic stays under the live cards, and the box
-- keeps its dark fill in both themes), every card at 75 % opacity like the
-- web UI when not live.
function chassisOfflineSvg(modelName)
  local geometry = chassisGeometry(modelName)
  if not geometry then return nil end
  local w, h = geometry.w, geometry.h
  local parts = { '<svg xmlns="http://www.w3.org/2000/svg" width="' .. svgNumber(w) .. '" height="' .. svgNumber(h)
    .. '" viewBox="0 0 ' .. svgNumber(w) .. " " .. svgNumber(h) .. '">',
    rectElement(0.5, 0.5, w - 1, h - 1, 'rx="4" fill="' .. CHASSIS_FILL .. '" stroke="#fff" stroke-width="1"') }
  for _, divider in ipairs(geometry.dividers) do
    table.insert(parts, '<line x1="' .. svgNumber(divider.x + 0.5) .. '" y1="' .. svgNumber(divider.y) .. '" x2="'
      .. svgNumber(divider.x + 0.5) .. '" y2="' .. svgNumber(divider.y + divider.h) .. '" stroke="#fff" stroke-width="1"/>')
  end
  for _, frame in ipairs(geometry.frames) do
    if not frame.tenG then
      table.insert(parts, '<g transform="translate(' .. point(frame.x - FRAME_LABEL_SPACE, frame.y) .. ')">'
        .. frameBody(frame) .. '</g>')
    end
  end
  local ports = {}
  for port in pairs(geometry.cards) do table.insert(ports, port) end
  table.sort(ports)
  table.insert(parts, '<g opacity="0.75">')
  for _, port in ipairs(ports) do
    local card = geometry.cards[port]
    table.insert(parts, '<g transform="translate(' .. point(card.x, card.y) .. ')">'
      .. portCardBody(offlineCardView(card, port)) .. '</g>')
  end
  table.insert(parts, '</g></svg>')
  return table.concat(parts)
end
