-- lldp.lua
-- LLDP neighbors: parsing of /api/lldp/neighbor (GET body or WS notification),
-- the values shown for a neighbor, and the SVGs of the neighbor panel (main
-- page) and of a Neighbors page row. Pure functions; uses port_card.lua's
-- svgNumber, rectElement, baseline and FONT (same chunk). Every SVG is ASCII:
-- text goes through xmlText.

local EM_DASH = "\u{2014}"
local MIDDLE_DOT = "\u{B7}"
local ELLIPSIS = "\u{2026}"

local XML_ESCAPES = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;" }

local function xmlCodePoint(sequence)
  if utf8.len(sequence) == 1 then return "&#" .. utf8.codepoint(sequence) .. ";" end
  return "&#65533;"
end

-- Text for an SVG text node or attribute, ASCII only: & < > " escaped, every
-- non-ASCII character as &#N; (an invalid byte as U+FFFD), control characters
-- as spaces.
function xmlText(s)
  return (tostring(s):gsub("%c", " "):gsub('[&<>"]', XML_ESCAPES)
    :gsub("[\xC2-\xF4][\x80-\xBF]*", xmlCodePoint):gsub("[\x80-\xFF]", "&#65533;"))
end

-- First n characters of a UTF-8 string.
function utf8Cut(s, n)
  local cut = utf8.offset(s, n + 1)
  if cut then return s:sub(1, cut - 1) end
  return s
end

local JSON_ESCAPES = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }

-- Value of "key":"..." in a JSON object's text, decoded; nil when the key is
-- absent or its value is not a string. Scans escape to escape, never per
-- character.
function lldpJsonString(object, key)
  local _, valueStart = object:find('"' .. key .. '"%s*:%s*"')
  if not valueStart then return nil end
  local parts, pos = {}, valueStart + 1
  while true do
    local i = object:find('["\\]', pos)
    if not i then return nil end
    parts[#parts + 1] = object:sub(pos, i - 1)
    if object:sub(i, i) == '"' then break end
    local escape = object:sub(i + 1, i + 1)
    if escape == "u" then
      local code = tonumber(object:sub(i + 2, i + 5), 16) or 0xFFFD
      pos = i + 6
      if code >= 0xD800 and code <= 0xDBFF then
        local low = object:match("^\\u(%x%x%x%x)", pos)
        low = low and tonumber(low, 16)
        if low and low >= 0xDC00 and low <= 0xDFFF then
          code = 0x10000 + (code - 0xD800) * 0x400 + (low - 0xDC00)
          pos = pos + 6
        end
      end
      if code >= 0xD800 and code <= 0xDFFF then code = 0xFFFD end
      parts[#parts + 1] = utf8.char(code)
    else
      parts[#parts + 1] = JSON_ESCAPES[escape] or escape
      pos = i + 2
    end
  end
  return table.concat(parts)
end

-- { [port] = neighbor } from a /api/lldp/neighbor array (GET body or WS
-- notification). One chunk per "port_number", up to the next one, so braces
-- inside a string never shift a field; text before the first is ignored. The
-- first neighbor of a port is kept, extra counts the others.
function lldpParseNeighbors(text)
  local starts, pos = {}, 1
  while true do
    local s, e, port = text:find('"port_number"%s*:%s*(%d+)', pos)
    if not s then break end
    starts[#starts + 1] = { at = s, port = tonumber(port) }
    pos = e + 1
  end
  local neighbors = {}
  for i, entry in ipairs(starts) do
    local nextEntry = starts[i + 1]
    local chunk = text:sub(entry.at, nextEntry and (nextEntry.at - 1) or #text)
    local known = neighbors[entry.port]
    if known then
      known.extra = known.extra + 1
    else
      neighbors[entry.port] = {
        chassisId             = lldpJsonString(chunk, "chassis_id") or "",
        chassisIdSubtype      = lldpJsonString(chunk, "chassis_id_subtype") or "",
        sysName               = lldpJsonString(chunk, "sys_name") or "",
        sysDescription        = lldpJsonString(chunk, "sys_description") or "",
        remotePort            = lldpJsonString(chunk, "remote_port") or "",
        remotePortSubtype     = lldpJsonString(chunk, "remote_port_id_subtype") or "",
        remotePortDescription = lldpJsonString(chunk, "remote_port_description") or "",
        mgmtAddress           = lldpJsonString(chunk, "mgmt_address") or "",
        extra                 = 0,
      }
    end
  end
  return neighbors
end

-- Values shown for a neighbor (spec section 4).
function lldpView(neighbor)
  local description = neighbor.sysDescription
  local cut = math.min(description:find(",", 1, true) or #description + 1,
    description:find(" (", 1, true) or #description + 1)
  local model = description:sub(1, cut - 1)
  if cut > #description or model == "" then model = nil end
  local firmware = description:match("%f[%w](v%d+%.%d+%.%d+)")

  local device = EM_DASH
  if model and firmware then
    device = model .. " " .. MIDDLE_DOT .. " " .. firmware
  elseif description ~= "" then
    device = description
  end

  local name = EM_DASH
  if neighbor.sysName ~= "" then
    name = neighbor.sysName
  elseif model and firmware then
    name = model
  elseif neighbor.chassisId ~= "" then
    name = neighbor.chassisId
  end

  local remotePort
  if neighbor.remotePortSubtype == "Local" then
    remotePort = neighbor.remotePort:gsub("^%d+/", "")
  elseif neighbor.remotePortSubtype == "MAC Address" then
    remotePort = neighbor.remotePortDescription
  else
    remotePort = neighbor.remotePort
  end
  if remotePort == "" then remotePort = EM_DASH end

  local remoteNote = neighbor.remotePortDescription
  if remoteNote == "" or remoteNote == remotePort then remoteNote = nil end

  local ip = neighbor.mgmtAddress
  -- 16 characters (the API maxLength); a long name is shortened so the
  -- " p<remote port>" suffix stays.
  local suffix = remotePort:match("^%d+$") and (" p" .. remotePort) or ""
  local legend = utf8Cut(name, 16 - #suffix):gsub("%s+$", "") .. suffix

  return {
    name = name, device = device, remotePort = remotePort, remoteNote = remoteNote,
    ip = ip ~= "" and ip or EM_DASH, ipMuted = ip:lower():sub(1, 5) == "fe80:",
    legend = legend,
    chassisKey = neighbor.chassisIdSubtype == "MAC Address" and "MAC" or "Chassis",
    chassisId = neighbor.chassisId, extra = neighbor.extra, sysName = neighbor.sysName,
  }
end

-- True when a /lldp/neighbor notification only refreshes TTLs: its new_value
-- array holds at least one "ttl" and no key other than port_number / ttl.
function lldpIsTtlOnly(raw)
  local _, open = raw:find('"new_value"%s*:%s*%[')
  if not open then return false end
  local close = raw:find("]", open + 1, true)
  if not close then return false end
  local sawTtl = false
  for key in raw:sub(open + 1, close - 1):gmatch('"([^"]*)"%s*:') do
    if key == "ttl" then
      sawTtl = true
    elseif key ~= "port_number" then
      return false
    end
  end
  return sawTtl
end

-- ~Average Roboto glyph width per px of font size.
local GLYPH_W = 0.56
local GLYPH_W_BOLD = 0.6

-- text cut to the characters that fit width px, with an ellipsis when cut.
local function lldpFit(text, width, glyphWidth)
  local chars = math.floor(width / glyphWidth)
  if (utf8.len(text) or #text) > chars then
    return utf8Cut(text, chars - 1) .. ELLIPSIS
  end
  return text
end

-- Left-aligned text centred vertically on centreY; content already escaped.
local function lldpText(x, centreY, size, fill, content, attributes)
  return '<text x="' .. svgNumber(x) .. '" y="' .. svgNumber(baseline(centreY, size)) .. '" ' .. FONT
    .. ' font-size="' .. size .. '"' .. (attributes or "") .. ' fill="' .. fill .. '">' .. content .. '</text>'
end

local function svgOpen(w, h)
  return '<svg xmlns="http://www.w3.org/2000/svg" width="' .. svgNumber(w) .. '" height="' .. svgNumber(h)
    .. '" viewBox="0 0 ' .. svgNumber(w) .. " " .. svgNumber(h) .. '">'
end

local function nameWithExtra(view)
  if view.extra > 0 then return view.name .. " +" .. view.extra end
  return view.name
end

-- Neighbor panel (main page): title row, then two key / value columns.
LLDP_PANEL_W = 520
LLDP_PANEL_H = 87
local PANEL_BUTTONS_W = 160          -- right part of the title row: -> Legend, Close
local PANEL_ROW_Y = { 40, 56, 72 }   -- row centres
local PANEL_LEFT_KEY_X, PANEL_LEFT_VALUE_X = 8, 76
local PANEL_RIGHT_KEY_X, PANEL_RIGHT_VALUE_X = 270, 320
local PANEL_TITLE_SIZE, PANEL_KEY_SIZE, PANEL_VALUE_SIZE = 11, 10, 11

-- panel = { port, view = lldpView | nil };
-- colors = { fill, border, text, muted }.
function lldpPanelSvg(panel, colors)
  local w, h = LLDP_PANEL_W, LLDP_PANEL_H
  local view = panel.view
  local parts = { svgOpen(w, h),
    rectElement(0.5, 0.5, w - 1, h - 1, 'rx="4" fill="' .. colors.fill .. '" stroke="' .. colors.border
      .. '" stroke-width="1"') }
  local title = "Port " .. panel.port .. " " .. EM_DASH .. " "
    .. (view and nameWithExtra(view) or "no LLDP neighbor")
  table.insert(parts, lldpText(PANEL_LEFT_KEY_X, 18, PANEL_TITLE_SIZE, colors.text,
    xmlText(lldpFit(title, w - PANEL_LEFT_KEY_X - PANEL_BUTTONS_W, PANEL_TITLE_SIZE * GLYPH_W_BOLD)),
    ' font-weight="bold"'))
  if view then
    local leftW = PANEL_RIGHT_KEY_X - PANEL_LEFT_VALUE_X - 8
    local rightW = w - PANEL_RIGHT_VALUE_X - 8
    local valueGlyph = PANEL_VALUE_SIZE * GLYPH_W
    local function key(x, row, label)
      table.insert(parts, lldpText(x, PANEL_ROW_Y[row], PANEL_KEY_SIZE, colors.muted, label))
    end
    local function value(x, row, text, width, fill)
      table.insert(parts, lldpText(x, PANEL_ROW_Y[row], PANEL_VALUE_SIZE, fill or colors.text,
        xmlText(lldpFit(text, width, valueGlyph))))
    end
    local remote = view.remotePort
    if view.remoteNote then remote = remote .. '  "' .. view.remoteNote .. '"' end
    key(PANEL_LEFT_KEY_X, 1, "Description")
    value(PANEL_LEFT_VALUE_X, 1, view.device, leftW)
    key(PANEL_LEFT_KEY_X, 2, "Port")
    value(PANEL_LEFT_VALUE_X, 2, remote, leftW)
    key(PANEL_LEFT_KEY_X, 3, "IP")
    value(PANEL_LEFT_VALUE_X, 3, view.ip, leftW, view.ipMuted and colors.muted or nil)
    key(PANEL_RIGHT_KEY_X, 1, view.chassisKey)
    value(PANEL_RIGHT_VALUE_X, 1, view.chassisId ~= "" and view.chassisId or EM_DASH, rightW)
  end
  table.insert(parts, "</svg>")
  return table.concat(parts)
end

local ROW_SIZE = 10

-- One Neighbors page row: row = { port, w, h, view = lldpView | nil };
-- columns = { number, name, device | nil, remotePort, ip }, each { x, w }
-- relative to the row.
function lldpRowSvg(row, colors, columns)
  local view = row.view
  local centre = row.h / 2
  local glyph = ROW_SIZE * GLYPH_W
  local parts = { svgOpen(row.w, row.h) }
  local number = columns.number
  table.insert(parts, lldpText(number.x + number.w, centre, ROW_SIZE, view and colors.text or colors.muted,
    tostring(row.port), ' font-weight="bold" text-anchor="end"'))
  local function cell(column, text, fill)
    table.insert(parts, lldpText(column.x, centre, ROW_SIZE, fill, xmlText(lldpFit(text, column.w, glyph))))
  end
  if not view then
    cell(columns.name, EM_DASH, colors.muted)
  else
    cell(columns.name, nameWithExtra(view), colors.text)
    if columns.device then cell(columns.device, view.device, colors.text) end
    cell(columns.remotePort, view.remotePort, colors.text)
    cell(columns.ip, view.ip, view.ipMuted and colors.muted or colors.text)
  end
  table.insert(parts, "</svg>")
  return table.concat(parts)
end
