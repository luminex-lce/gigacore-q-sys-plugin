-- Controls follow the selected model: per-port controls for its ports, PoE
-- controls for its PoE ports, fan / PSU / case temperature pins for its
-- hardware (MODEL_HARDWARE).
local model     = resolveModel(props)
local portCount = getPortCount(model)
local poeCount  = getPoeCount(model)
local hardware  = getModelHardware(model)

local c = {}

-- Read-only integer pin (API integer leaf), raw value.
local function integerPin(name, min, max)
  c[#c+1] = {
    Name        = name,
    ControlType = "Knob",
    ControlUnit = "Integer",
    Min         = min,
    Max         = max,
    PinStyle    = "Output",
    UserPin     = true,
    IsReadOnly  = true,
  }
end

-- Read-only text pin (API string or enum leaf), raw value.
local function textPin(name)
  c[#c+1] = {
    Name        = name,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "Output",
    UserPin     = true,
    IsReadOnly  = true,
    Value       = "",
  }
end

-- Per-port pins follow the API tree: Ports.Port N.<leaf> (/ports/port/N/<leaf>).
for p = 1, portCount do
  local port = "Ports.Port " .. p .. "."
  textPin(port .. "Link State")
  textPin(port .. "Type")
  integerPin(port .. "Counters.Rx Bit Rate", 0, 100000000000)
  integerPin(port .. "Counters.Tx Bit Rate", 0, 100000000000)
  integerPin(port .. "Counters.Link Flaps", 0, 4294967295)

  -- Web UI port card on the chassis: a flat Button whose Legend carries the
  -- whole card as an IconData SVG (portCardSvg); a click opens the LLDP
  -- neighbor panel.
  c[#c+1] = {
    Name        = "Port.Card " .. p,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }

  -- Grid controls that are pins too: the live value out, a write PUTs it.
  c[#c+1] = {
    Name        = port .. "Enabled",
    ControlType = "Button",
    ButtonType  = "Toggle",
    PinStyle    = "Both",
    UserPin     = true,
  }

  c[#c+1] = {
    Name        = port .. "Legend",
    ControlType = "Text",
    TextBoxType = "Normal",
    PinStyle    = "Both",
    UserPin     = true,
    IsReadOnly  = false,
    Value       = "",
  }

  c[#c+1] = {
    Name        = port .. "RLinkX.Enabled",
    ControlType = "Button",
    ButtonType  = "Toggle",
    PinStyle    = "Both",
    UserPin     = true,
  }

  -- link_speed {mode, speed[]} and member_of {type, id}: one pin per API
  -- object, so one write is one PUT. Link Speed is "<mode> <speed, speed>"
  -- ("auto all", "fixed 100mbps fdx"); Member Of is "group 22", "trunk 1"
  -- or "none".
  c[#c+1] = {
    Name        = port .. "Link Speed",
    ControlType = "Text",
    TextBoxType = "Normal",
    PinStyle    = "Both",
    UserPin     = true,
    Value       = "",
  }

  c[#c+1] = {
    Name        = port .. "Member Of",
    ControlType = "Text",
    TextBoxType = "Normal",
    PinStyle    = "Both",
    UserPin     = true,
    Value       = "",
  }

  -- Speed cell — Button showing the current link speed; click opens the
  -- speed picker panel (zSpeed.* controls below).
  c[#c+1] = {
    Name        = "Port.Speed Cell " .. p,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }

  -- Port group membership cell — Button colored with the group's color,
  -- Legend = friendly group/trunk name. Click opens the group picker panel
  -- (zPicker.* controls below) to reassign the port.
  c[#c+1] = {
    Name        = "Port.Group " .. p,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }

  -- Per-port identify button (the port-number label in the settings grid).
  -- Clicking PUTs /api/port_identify with this port number.
  c[#c+1] = {
    Name        = "Port Identify.Port " .. p,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "Input",
    UserPin     = true,
  }
end

-- PoE controls for the model's PoE ports only (PORT_LAYOUT poe), under the
-- API tree PoE.Port N.<leaf> (/poe/ports/N/<leaf>).
for p = 1, poeCount do
  textPin("PoE.Port " .. p .. ".Indication")

  -- Grid toggle and pin: the live value out, a write PUTs it.
  c[#c+1] = {
    Name        = "PoE.Port " .. p .. ".Enabled",
    ControlType = "Button",
    ButtonType  = "Toggle",
    PinStyle    = "Both",
    UserPin     = true,
  }

  -- Grid button only (off, 3 s, on): not an API field, no pin.
  c[#c+1] = {
    Name        = "PoE.Bounce " .. p,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }
end

-- Group picker panel (main page). Hidden until a Port.Group cell is clicked;
-- items mirror the Groups and Trunks page slots: zPicker.Group 1..20
-- predefined, 21.. custom slots, zPicker.Trunk 1 = ISL, 2.. custom slots.
local function pickerButton(name)
  c[#c+1] = {
    Name        = name,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }
end
local function pickerText(name)
  c[#c+1] = {
    Name        = name,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = "",
  }
end
pickerButton("zPicker.Bg")
pickerText("zPicker.Title")
pickerButton("zPicker.None")
pickerButton("zPicker.Cancel")
for i = 1, 4 do pickerText("zPicker.Label " .. i) end
for i = 1, 20 + CUSTOM_GROUP_SLOTS do pickerButton("zPicker.Group " .. i) end
for i = 1, 1 + CUSTOM_TRUNK_SLOTS do pickerButton("zPicker.Trunk " .. i) end

-- Speed picker panel (main page). Hidden until a Port.Speed Cell is clicked;
-- zSpeed.Item i shows SPEED_CHOICES[i].
pickerButton("zSpeed.Bg")
pickerText("zSpeed.Title")
pickerButton("zSpeed.Cancel")
for i = 1, #SPEED_CHOICES do pickerButton("zSpeed.Item " .. i) end

-- Group labels + ID badges (slots 1..40)
for i = 1, 40 do
  c[#c+1] = {
    Name        = "group_label_" .. i,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = "",
  }
end

for i = 1, 40 do
  c[#c+1] = {
    Name        = "group_id_badge_" .. i,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = "",
  }
end

-- Trunk labels + ID badges (slots 1..10)
for i = 1, 10 do
  c[#c+1] = {
    Name        = "trunk_label_" .. i,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = "",
  }
  c[#c+1] = {
    Name        = "trunk_id_badge_" .. i,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = "",
  }
end

-- Device pins follow the API tree (/device/..., /ip_settings/mode). The
-- display block shows Device.Name, Description, MAC Address and
-- Firmware.Active as they are; formatted lines (model, IP, gateway, status)
-- are internal Display.* controls.
c[#c+1] = {
  Name        = "Device.Name",
  ControlType = "Text",
  TextBoxType = "ReadOnly",
  PinStyle    = "Output",
  UserPin     = true,
  IsReadOnly  = true,
  Value       = "",
  MultiLine   = true,
}

c[#c+1] = {
  Name        = "Device.Description",
  ControlType = "Text",
  TextBoxType = "ReadOnly",
  PinStyle    = "Output",
  UserPin     = true,
  IsReadOnly  = true,
  Value       = "",
  MultiLine   = true,
}

-- Raw /api/device model ("GigaCore30i"); Display.Model shows the model line.
textPin("Device.Model")
textPin("Device.Hostname")
textPin("Device.MAC Address")
textPin("Device.Firmware.Active")
textPin("Device.Actual IP.IP Address")
integerPin("Device.Actual IP.Prefix Length", 0, 32)
textPin("Device.Actual IP.Default Gateway")
textPin("IP Settings.Mode")

-- Identify (PUT /api/identify): the logo on the main page and the
-- Configuration page button.
c[#c+1] = {
  Name        = "Identify",
  ControlType = "Button",
  ButtonType  = "Momentary",
  PinStyle    = "Input",
  UserPin     = true,
}

-- Q-SYS status pin, outside the API (refreshStatus, info.lua): OK connected,
-- Initializing connecting, Missing offline, Fault no IP / auth failure,
-- Compromised on a model mismatch or a PSU / fan not good.
c[#c+1] = {
  Name          = "Status",
  ControlType   = "Indicator",
  IndicatorType = "Status",
  PinStyle      = "Output",
  UserPin       = true,
  IsReadOnly    = true,
}

-- Display block lines, no pin: "GigaCore 30i" or "Switch is <model>"
-- flashing, "<ip>/<prefix> (<mode>)", "Gateway <ip>" (blank on 0.0.0.0),
-- and the Online / Offline badge.
local function displayText(name, value)
  c[#c+1] = {
    Name        = name,
    ControlType = "Text",
    TextBoxType = "ReadOnly",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
    Value       = value or "",
  }
end
displayText("Display.Model")
displayText("Display.IP Info")
displayText("Display.Gateway")
c[#c+1] = {
  Name        = "Display.Status",
  ControlType = "Text",
  TextBoxType = "ReadOnly",
  PinStyle    = "None",
  UserPin     = false,
  IsReadOnly  = false,
  Value       = "Offline",
}

-- Configuration page (connection settings, no pin)
c[#c+1] = {
  Name        = "Auth.IP Address",
  ControlType = "Text",
  TextBoxType = "Normal",
  PinStyle    = "None",
  UserPin     = false,
  Value       = "Enter your IP",
}

c[#c+1] = {
  Name        = "Auth.Username",
  ControlType = "Text",
  TextBoxType = "Normal",
  PinStyle    = "None",
  UserPin     = false,
  Value       = "",
}

c[#c+1] = {
  Name        = "Auth.Password",
  ControlType = "Text",
  PinStyle    = "None",
  UserPin     = false,
  Value       = "",
}

-- Bullets shown under the password box (its own text is transparent).
c[#c+1] = {
  Name        = "Auth.Masked Password",
  ControlType = "Indicator",
  IndicatorType = "Text",
  PinStyle    = "None",
  UserPin     = false,
}

c[#c+1] = {
  Name        = "Auth.Status",
  ControlType = "Text",
  TextBoxType = "ReadOnly",
  PinStyle    = "None",
  UserPin     = false,
  Value       = "",
}

c[#c+1] = {
  Name        = "Auth.Connect",
  ControlType = "Button",
  ButtonType  = "Toggle",
  PinStyle    = "None",
  UserPin     = false,
}

-- System, temperatures, fans and power pins (API tree, raw integers: %,
-- degrees C, rpm, mW). Fans, PSU slots and the case sensor follow the model
-- (MODEL_HARDWARE). The ranges hold the API error markers (a Knob clamps
-- its Value): temperature -1000, PSU power_usage -1.
integerPin("System.CPU Load", 0, 100)
integerPin("System.CPU Load Long", 0, 100)
integerPin("Temperatures.CPU.Current", -1000, 150)
if hardware.caseTemp then
  integerPin("Temperatures.Case.Current", -1000, 150)
end
for i = 1, hardware.fans do
  integerPin("Fans.Fan " .. i .. ".Speed", 0, 100000)
end
integerPin("Power.Total Power Usage", 0, 100000000)
integerPin("Power.Total Power Max", 0, 100000000)
textPin("Power.Coupling.Mode")
for i = 1, hardware.psus do
  textPin("Power.PSU " .. i .. ".State")
  textPin("Power.PSU " .. i .. ".Power Status")
  integerPin("Power.PSU " .. i .. ".Power Usage", -1, 100000000)
end

-- Switch-wide RLinkX flag (/rlinkx/enabled), read only.
c[#c+1] = {
  Name        = "RLinkX.Enabled",
  ControlType = "Button",
  ButtonType  = "Toggle",
  PinStyle    = "Output",
  UserPin     = true,
  IsReadOnly  = true,
}

-- RSTP lines of the status block (formatted text, no pin)
c[#c+1] = { Name = "RSTP.Bridge Priority", ControlType = "Text", TextBoxType = "ReadOnly", PinStyle = "None", UserPin = false, Value = "" }
c[#c+1] = { Name = "RSTP.Root Bridge",     ControlType = "Text", TextBoxType = "ReadOnly", PinStyle = "None", UserPin = false, Value = "" }

-- Status block paint targets (right of the chassis, like the switch web UI):
-- PSU icons, coupling glyph, status dot. Internal only, laid out as Buttons.
for _, name in ipairs({ "PSU.1 Icon", "PSU.2 Icon", "Power.Coupling Glyph", "Display.Status Dot" }) do
  c[#c+1] = { Name = name, ControlType = "Text", TextBoxType = "ReadOnly", PinStyle = "None", UserPin = false, Value = "" }
end

-- Querier panel under the RSTP lines: a flat read-only Button whose Legend
-- carries the title and the group badges as one IconData SVG (querierBadgesSvg).
c[#c+1] = {
  Name        = "Querier.Badges",
  ControlType = "Button",
  ButtonType  = "Toggle",
  PinStyle    = "None",
  UserPin     = false,
  IsReadOnly  = true,
}

-- LLDP neighbor panel (main page), opened from a chassis card: the panel SVG
-- (clickable, so a click on it never reaches the grid underneath) and its two
-- buttons, named to sort (and draw) above it.
c[#c+1] = {
  Name        = "zLldp.Panel",
  ControlType = "Button",
  ButtonType  = "Momentary",
  PinStyle    = "None",
  UserPin     = false,
}
for _, name in ipairs({ "zLldp.Panel To Legend", "zLldp.Panel Close" }) do
  c[#c+1] = {
    Name        = name,
    ControlType = "Button",
    ButtonType  = "Momentary",
    PinStyle    = "None",
    UserPin     = false,
  }
end

-- Neighbors page (LLDP): per port a row (one IconData SVG drawing every cell,
-- lldpRowSvg).
for p = 1, portCount do
  c[#c+1] = {
    Name        = "Lldp.Row " .. p,
    ControlType = "Button",
    ButtonType  = "Toggle",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
  }
end

-- 10G frame per tenG group (IconData Button, like Port.Card), shown while the
-- 10g licence is active. Declared for the model with the most tenG groups.
local tenGFrameCount = 0
for _, layout in pairs(CHASSIS_LAYOUT) do
  local count = 0
  for _, group in ipairs(layout) do
    if group.tenG then count = count + 1 end
  end
  if count > tenGFrameCount then tenGFrameCount = count end
end
for i = 1, tenGFrameCount do
  c[#c+1] = {
    Name        = "Chassis.10G " .. i,
    ControlType = "Button",
    ButtonType  = "Toggle",
    PinStyle    = "None",
    UserPin     = false,
    IsReadOnly  = true,
  }
end

return c
