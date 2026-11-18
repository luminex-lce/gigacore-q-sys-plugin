state.portCount = getPortCount(resolveModel(Properties))
local pc = state.portCount or 30

state.darkMode = Properties["Dark Mode"].Value ~= "No"
state.chassis = chassisGeometry(resolveModel(Properties))
clearPortCards()

--------------------------------------------------------------------------------
-- IP / connect / identify
--------------------------------------------------------------------------------
-- "Enter your IP" is the field's placeholder value, not an address.
local function connectToSwitch()
  updateAuthStatus("")
  local ip = Controls["Auth.IP Address"].String
  if ip == "" or ip == "Enter your IP" then
    state.baseIP = ""
    SetConnection("noip")
    return
  end
  state.baseIP = ip
  state.reconnectDelay = 5
  SetConnection("connecting")
  openWS(state.baseIP)
end

-- Enter in the IP box connects, same as the Connect button.
if Controls["Auth.IP Address"] then
  Controls["Auth.IP Address"].EventHandler = function(txt)
    state.baseIP = txt.String
    if txt.String ~= "" then connectToSwitch() end
  end
end

-- The password box's text is transparent; Auth.Masked Password, under it,
-- shows one bullet per character. Q-SYS reports the text only on Enter, so
-- the previous bullets stay while typing.
local function refreshMaskedPassword()
  local mask = Controls["Auth.Masked Password"]
  if mask == nil then return end
  local pass = Controls["Auth.Password"] and Controls["Auth.Password"].String or ""
  mask.String = string.rep("\u{2022}", utf8.len(pass) or #pass)
end
refreshMaskedPassword()

-- Enter in the username or password box connects with the new credentials,
-- like Enter in the IP box.
if Controls["Auth.Username"] then
  Controls["Auth.Username"].EventHandler = function()
    connectToSwitch()
  end
end

if Controls["Auth.Password"] then
  Controls["Auth.Password"].EventHandler = function()
    refreshMaskedPassword()
    connectToSwitch()
  end
end

if Controls["Auth.Connect"] then
  Controls["Auth.Connect"].EventHandler = function(btn)
    if btn.Boolean then
      connectToSwitch()
      btn.Boolean = false
    end
  end
end

--------------------------------------------------------------------------------
-- Port enable toggle
--------------------------------------------------------------------------------
for p = 1, pc do
  local ctrl = Controls["Ports.Port " .. p .. ".Enabled"]
  if ctrl then
    ctrl.EventHandler = function()
      local newState = ctrl.Boolean
      HttpClient.Upload {
        Url     = string.format("http://%s/api/ports/port/%d/enabled", state.baseIP, p),
        Method  = "PUT",
        Data    = newState and "true" or "false",
        Headers = MergeTables(
          { ["Content-Type"] = "application/json" },
          getAuthHeaders()
        ),
        EventHandler = function(_tbl, code, _body, _err)
          log("Port " .. p .. " enable set to " .. tostring(newState) .. " | HTTP " .. tostring(code))
        end,
      }
    end
  end
end

--------------------------------------------------------------------------------
-- PoE enable toggle
--------------------------------------------------------------------------------
for p = 1, pc do
  local ctrl = Controls["PoE.Port " .. p .. ".Enabled"]
  if ctrl then
    ctrl.EventHandler = function()
      local newState = ctrl.Boolean
      HttpClient.Upload {
        Url     = string.format("http://%s/api/poe/ports/%d/enabled", state.baseIP, p),
        Method  = "PUT",
        Data    = newState and "true" or "false",
        Headers = MergeTables(
          { ["Content-Type"] = "application/json" },
          getAuthHeaders()
        ),
        EventHandler = function(_tbl, code, _body, _err)
          log("PoE " .. p .. " enabled set to " .. tostring(newState) .. " | HTTP " .. tostring(code))
        end,
      }
    end
  end
end

--------------------------------------------------------------------------------
-- PoE bounce: disable PoE, wait 3s, re-enable
--------------------------------------------------------------------------------
for p = 1, pc do
  local bounceCtrl = Controls["PoE.Bounce " .. p]
  if bounceCtrl then
    bounceCtrl.EventHandler = function(ctrl)
      if not ctrl.Boolean then return end
      local port = p
      local url = string.format("http://%s/api/poe/ports/%d/enabled", state.baseIP, port)

      HttpClient.Upload {
        Url     = url,
        Method  = "PUT",
        Data    = "false",
        Headers = MergeTables(
          { ["Content-Type"] = "application/json" },
          getAuthHeaders()
        ),
        EventHandler = function(_tbl, code, _body, _err)
          log("PoE bounce port " .. port .. " off | HTTP " .. tostring(code))
        end,
      }

      Timer.CallAfter(function()
        HttpClient.Upload {
          Url     = url,
          Method  = "PUT",
          Data    = "true",
          Headers = MergeTables(
            { ["Content-Type"] = "application/json" },
            getAuthHeaders()
          ),
          EventHandler = function(_tbl, code, _body, _err)
            log("PoE bounce port " .. port .. " on | HTTP " .. tostring(code))
          end,
        }
      end, 3)
    end
  end
end

--------------------------------------------------------------------------------
-- Port legend edit
--------------------------------------------------------------------------------
for p = 1, pc do
  local legendCtrl = Controls["Ports.Port " .. p .. ".Legend"]
  if legendCtrl then
    legendCtrl.EventHandler = function(ctrl) putPortLegend(p, ctrl.String) end
  end
end

-- Neighbor panel (main page): a chassis card opens it for its port (the
-- open port's card closes it), Close closes it, -> Legend writes the
-- port's proposed legend.
for p = 1, pc do
  local card = Controls["Port.Card " .. p]
  if card then
    card.EventHandler = function(c)
      if c.Boolean then toggleLldpPanel(p) end
    end
  end
end

-- The panel body catches clicks (nothing to do): the grid under it stays out
-- of reach while it is open.
local panelBody = Controls["zLldp.Panel"]
if panelBody then panelBody.EventHandler = function() end end

local panelClose = Controls["zLldp.Panel Close"]
if panelClose then
  panelClose.EventHandler = function(c)
    if c.Boolean then closeLldpPanel() end
  end
end

local panelLegend = Controls["zLldp.Panel To Legend"]
if panelLegend then
  panelLegend.EventHandler = function(c)
    local port = state.lldpPanelPort
    local neighbor = port and state.lldp[port]
    if c.Boolean and state.connection == "online" and neighbor then
      putPortLegend(port, lldpView(neighbor).legend)
    end
  end
end

--------------------------------------------------------------------------------
-- RLinkX toggle
--------------------------------------------------------------------------------
for p = 1, pc do
  local toggleCtrl = Controls["Ports.Port " .. p .. ".RLinkX.Enabled"]
  if toggleCtrl then
    toggleCtrl.EventHandler = function(ctrl)
      local enabled = ctrl.Boolean
      HttpClient.Upload {
        Url     = string.format("http://%s/api/ports/port/%d/rlinkx", state.baseIP, p),
        Method  = "PUT",
        Data    = '{"enabled":' .. tostring(enabled) .. '}',
        Headers = MergeTables(
          { ["Content-Type"] = "application/json" },
          getAuthHeaders()
        ),
        EventHandler = function(_tbl, _status, _body, _err)
          log("RLinkX PUT port " .. p .. " => " .. tostring(enabled))
        end,
      }
    end
  end
end

--------------------------------------------------------------------------------
-- Link Speed and Member Of pins: one write, one PUT of the whole object.
--------------------------------------------------------------------------------
for p = 1, pc do
  local base = "Ports.Port " .. p .. "."
  local speed = Controls[base .. "Link Speed"]
  if speed then
    speed.EventHandler = function() putPortLinkSpeed(p) end
  end
  local member = Controls[base .. "Member Of"]
  if member then
    member.EventHandler = function() putPortMemberOf(p) end
  end
end

--------------------------------------------------------------------------------
-- Speed cell: opens the speed picker (applyPortSpeed on a pick).
--------------------------------------------------------------------------------
for p = 1, pc do
  local cell = Controls["Port.Speed Cell " .. p]
  if cell then
    cell.EventHandler = function(c)
      if c.Boolean then openSpeedPicker(p) end
    end
  end
end

--------------------------------------------------------------------------------
-- Identify — device-level (logo click, Configuration page button) and per-port
-- (port number click).
--------------------------------------------------------------------------------
local function identifyDevice()
  if state.baseIP == "" then return end
  HttpClient.Upload {
    Url     = string.format("http://%s/api/identify", state.baseIP),
    Method  = "PUT",
    Data    = '{"duration": 9}',
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    EventHandler = function(_tbl, status, _b, err)
      log("Identify device => status: " .. tostring(status) .. ", err: " .. tostring(err))
    end,
  }
end

local function identifyPort(port)
  if state.baseIP == "" then return end
  local payload = string.format('{"duration":9,"port_numbers":[%d]}', port)
  HttpClient.Upload {
    Url     = string.format("http://%s/api/port_identify", state.baseIP),
    Method  = "PUT",
    Data    = payload,
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    EventHandler = function(_tbl, status, _b, err)
      log("Identify port " .. port .. " => status: " .. tostring(status) .. ", err: " .. tostring(err))
    end,
  }
end

local idBtn = Controls["Identify"]
if idBtn then
  idBtn.EventHandler = function(c)
    if c.Boolean then identifyDevice() end
  end
end

for p = 1, pc do
  local b = Controls["Port Identify.Port " .. p]
  if b then
    b.EventHandler = function(c)
      if c.Boolean then identifyPort(p) end
    end
  end
end

--------------------------------------------------------------------------------
-- Group picker (main page): a Port.Group cell opens it, an item PUTs the
-- new membership, Cancel or the backdrop closes it.
--------------------------------------------------------------------------------
closeGroupPicker()
closeSpeedPicker()
closeLldpPanel()

for p = 1, pc do
  local cell = Controls["Port.Group " .. p]
  if cell then
    cell.EventHandler = function(c)
      if c.Boolean then openGroupPicker(p) end
    end
  end
end

for slot = 1, 20 + CUSTOM_GROUP_SLOTS do
  local b = Controls["zPicker.Group " .. slot]
  if b then
    b.EventHandler = function(c)
      local id = state.pickerSlotGroupId and state.pickerSlotGroupId[slot]
      if c.Boolean and id then pickerAssign("group", id) end
    end
  end
end

for slot = 1, 1 + CUSTOM_TRUNK_SLOTS do
  local b = Controls["zPicker.Trunk " .. slot]
  if b then
    b.EventHandler = function(c)
      local id = state.pickerSlotTrunkId and state.pickerSlotTrunkId[slot]
      if c.Boolean and id then pickerAssign("trunk", id) end
    end
  end
end

local noneBtn = Controls["zPicker.None"]
if noneBtn then
  noneBtn.EventHandler = function(c)
    if c.Boolean then pickerAssign("none") end
  end
end

for _, name in ipairs({ "zPicker.Cancel", "zPicker.Bg" }) do
  local b = Controls[name]
  if b then
    b.EventHandler = function(c)
      if c.Boolean then closeGroupPicker() end
    end
  end
end

for i, label in ipairs(SPEED_CHOICES) do
  local b = Controls["zSpeed.Item " .. i]
  if b then
    b.EventHandler = function(c)
      if not c.Boolean then return end
      local port = state.speedPickerPort
      closeSpeedPicker()
      if port then applyPortSpeed(port, label) end
    end
  end
end

for _, name in ipairs({ "zSpeed.Cancel", "zSpeed.Bg" }) do
  local b = Controls[name]
  if b then
    b.EventHandler = function(c)
      if c.Boolean then closeSpeedPicker() end
    end
  end
end

-- Connect at start: a Core reboot or a redeploy reconnects to the saved
-- IP address without a press on Connect (Status Fault when none is set).
connectToSwitch()

log("Enjoy")
