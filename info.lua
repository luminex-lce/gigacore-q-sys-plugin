--[[

  Luminex GigaCore Q-SYS Plugin
  Author: Daniel Minville <daniel.minville@luminexamerica.com>

  To add a new GigaCore model:
    1. Add its name and port count to GigaCoreModels.
       e.g., ["GigaCore 48"] = 48

]]

--------------------------------------------------------------------------------
-- Plugin Constants and Metadata
--------------------------------------------------------------------------------
PluginInfo = {
  Name         = "Luminex~GigaCore",
  Version      = "2.0.0",
  BuildVersion = "0.0.0.0",
  Id           = "a64f9db0-dcfe-4d58-af32-6f1240343e5c",
  Description  = "Monitoring and control for Luminex GigaCore network switches",
  ShowDebug    = true
}

--------------------------------------------------------------------------------
-- SVG assets (base64 strings — inlined from working backup)
--------------------------------------------------------------------------------
local LogoLuminex = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBHZW5lcmF0b3I6IEFkb2JlIElsbHVzdHJhdG9yIDIwLjEuMCwgU1ZHIEV4cG9ydCBQbHVnLUluIC4gU1ZHIFZlcnNpb246IDYuMDAgQnVpbGQgMCkgIC0tPgo8c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IgoJIHZpZXdCb3g9IjAgMCA0MzkuNiAxMzUuNCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgNDM5LjYgMTM1LjQ7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4KPHN0eWxlIHR5cGU9InRleHQvY3NzIj4KCS5zdDB7ZmlsbDojRkZGRkZGO30KCS5zdDF7ZmlsbDojQ0FENDAwO30KPC9zdHlsZT4KPHBhdGggaWQ9IlhNTElEXzcwNV8iIGNsYXNzPSJzdDAiIGQ9Ik0xMTEuMSw3NC45VjMxLjdoMTUuMXY1NUg5Ni40Yy00LjMsMC03LjctMC4zLTEwLTAuOWMtMi4zLTAuNi00LjQtMS44LTYuMi0zLjUKCWMtMy45LTMuNS01LjgtOS4xLTUuOC0xNi44VjMxLjdoMTUuMXYzNS4zYzAsMi41LDAuNiw0LjQsMS45LDUuOGMxLjMsMS40LDMuMSwyLjEsNS4zLDIuMUgxMTEuMXoiLz4KPHBhdGggaWQ9IlhNTElEXzcwM18iIGNsYXNzPSJzdDAiIGQ9Ik0xMzUuNSwzMS43aDU1LjZjNS4xLDAsOC45LDAuNCwxMS41LDEuMWMyLjYsMC43LDQuOCwyLjEsNi42LDRjMy4zLDMuNiw1LDguNiw1LDE0Ljl2MzVoLTE1LjEKCVY1NC4xYzAtMi42LTAuMS00LjUtMC40LTUuNWMtMC4yLTEtMC44LTItMS42LTIuOGMtMS41LTEuNS0zLjktMi4zLTcuMS0yLjNoLTh2NDMuMmgtMTUuMVY0My41aC0xNi4zdjQzLjJoLTE1LjFWMzEuN3oiLz4KPHBhdGggaWQ9IlhNTElEXzcwMV8iIGNsYXNzPSJzdDAiIGQ9Ik0yNDcuNSwzMS43aDI5LjJjNC4zLDAsNy43LDAuMywxMCwwLjljMi4zLDAuNiw0LjQsMS44LDYuMiwzLjVjMy45LDMuNSw1LjgsOS4xLDUuOCwxNi43djMzLjgKCWgtMTUuMVY1MS4xYzAtMi43LTAuNi00LjctMS44LTUuOWMtMS4yLTEuMi0zLjItMS44LTYtMS44aC0xMy4ydjQzLjJoLTE1LjFWMzEuN3oiLz4KPHBhdGggaWQ9IlhNTElEXzY5OV8iIGNsYXNzPSJzdDAiIGQ9Ik0zNTQuNyw1My4zVjY1aC0zMS45YzAuMywzLjYsMS41LDYuMiwzLjUsNy43YzIsMS41LDUuMywyLjMsOS45LDIuM2gxOC41djExLjdoLTIwLjEKCWMtNC40LDAtNy45LTAuNC0xMC43LTEuMmMtMi43LTAuOC01LjMtMi4xLTcuOC00Yy02LjctNS4xLTEwLTEyLjgtMTAtMjNjMC02LjcsMS44LTEyLjUsNS4zLTE3LjRjMi40LTMuNCw1LjMtNS44LDguNy03LjIKCWMzLjQtMS40LDcuOC0yLjIsMTMuMy0yLjJoMjEuMnYxMS43aC0yMC4xYy00LjEsMC03LDAuNy04LjcsMi4xYy0xLjcsMS40LTIuNyw0LTMuMSw3LjdIMzU0Ljd6Ii8+CjxwYXRoIGlkPSJYTUxJRF82OTdfIiBjbGFzcz0ic3QwIiBkPSJNMzgwLjIsNTkuNWwtMTkuOC0yNy44aDE2LjlMMzg4LjksNDhsMTEuMi0xNi4zaDE3LjhsLTIwLjYsMjcuOGwyMC42LDI3LjJoLTE3LjhMMzg4LjksNzEKCWwtMTEuNiwxNS43aC0xNy44TDM4MC4yLDU5LjV6Ii8+CjxwYXRoIGlkPSJYTUxJRF82OTZfIiBjbGFzcz0ic3QxIiBkPSJNMjM0LjYsMTEuN2MtMC43LTAuMi0xLjctMC4yLTIuOS0wLjJoLTguNnY5YzAsMiwwLjYsMy41LDEuNyw0LjVjMC41LDAuNSwxLjIsMC44LDEuOCwwLjkKCWMwLjcsMC4yLDEuNywwLjIsMi45LDAuMmg4LjZ2LTljMC0yLTAuNi0zLjUtMS43LTQuNUMyMzUuOSwxMi4yLDIzNS4zLDExLjksMjM0LjYsMTEuN3oiLz4KPHBhdGggaWQ9IlhNTElEXzY5NV8iIGNsYXNzPSJzdDAiIGQ9Ik02OS4xLDc0LjRjLTAuNS0wLjQtMS4xLTAuNy0xLjctMC44Yy0wLjYtMC4yLTEuNS0wLjItMi43LTAuMmgtMi4xaC01LjhoLTEuNgoJYy03LDAtMTEuOS0wLjYtMTQuNi0xLjljLTIuOC0xLjMtNC40LTMuNi00LjktN2MtMC4zLTEuOC0wLjUtNS4zLTAuNy0xMC43VjE4LjJoLTE2djM1LjVjMCw3LjQsMC41LDEyLjcsMS4zLDE1LjgKCWMyLjIsOC4xLDcuNSwxMy40LDE1LjgsMTUuOGMzLjYsMSw5LjUsMS40LDE3LjUsMS40aDl2MGMwLjEsMCwwLjEsMCwwLjIsMGg3Ljl2LTguM0M3MC43LDc2LjYsNzAuMiw3NS4yLDY5LjEsNzQuNHoiLz4KPHBhdGggaWQ9IlhNTElEXzY5NF8iIGNsYXNzPSJzdDAiIGQ9Ik0yMjguOSwzMS43Yy0yLjEsMC0zLjYsMC42LTQuNiwxLjdjLTAuNSwwLjUtMC44LDEuMi0xLDEuOGMtMC4yLDAuNy0wLjMsMS43LTAuMywyLjl2MS4xdjcuNgoJdjM5LjloMTUuMVY0MC4zdi0xLjF2LTcuNkgyMjguOXoiLz4KPGc+Cgk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMTM2LjksMTE4LjR2LTE0LjhoMWw1LjgsOC44YzEuMiwxLjgsMi4xLDMuMiwyLjgsNC43bDAsMGMtMC4yLTItMC4yLTMuNy0wLjItNnYtNy40aDF2MTQuOGgtMWwtNS43LTguNgoJCWMtMS4xLTEuNy0yLjEtMy4zLTIuOS00LjhsMCwwYzAuMSwxLjgsMC4xLDMuNCwwLjEsNS45djcuNUgxMzYuOXoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0xNjEuMSwxMTFoLTUuOXY2LjVoNi42djAuOWgtNy43di0xNC44aDcuM3YwLjloLTYuM3Y1LjdoNS45VjExMXoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0xNzEsMTA0LjRoLTQuOHYtMC45aDEwLjd2MC45aC00Ljh2MTRIMTcxVjEwNC40eiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTE4NS4yLDExOC40bC0zLjktMTQuOGgxLjFsMi4yLDguNGMwLjUsMS45LDAuOSwzLjcsMS4yLDUuMWgwYzAuMi0xLjQsMC44LTMuMSwxLjQtNS4xbDIuNC04LjRoMWwyLjIsOC4zCgkJYzAuNSwxLjgsMSwzLjcsMS4yLDUuMWgwYzAuMy0xLjYsMC44LTMuMiwxLjMtNS4xbDIuNC04LjNoMS4xbC00LjQsMTQuOGgtMWwtMi4yLTguNWMtMC42LTIuMi0wLjktMy42LTEuMS01aDAKCQljLTAuMiwxLjQtMC43LDIuOC0xLjMsNWwtMi41LDguNUgxODUuMnoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0yMTYuNCwxMTAuOGMwLDUuMi0zLjIsNy44LTYuNiw3LjhjLTMuNywwLTYuNS0yLjktNi41LTcuNWMwLTQuOSwyLjktNy44LDYuNy03LjgKCQlDMjEzLjcsMTAzLjMsMjE2LjQsMTA2LjIsMjE2LjQsMTEwLjh6IE0yMDQuNCwxMTEuMWMwLDMuMywxLjksNi43LDUuNSw2LjdjMy41LDAsNS41LTMuMiw1LjUtNi45YzAtMy4xLTEuNy02LjctNS40LTYuNwoJCUMyMDYuMSwxMDQuMiwyMDQuNCwxMDcuNiwyMDQuNCwxMTEuMXoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0yMjIuMywxMDMuOGMwLjktMC4yLDIuMi0wLjMsMy4yLTAuM2MxLjksMCwzLjIsMC40LDQsMS4zYzAuNiwwLjYsMSwxLjYsMSwyLjZjMCwyLTEuMiwzLjMtMi45LDMuOXYwCgkJYzEuMiwwLjQsMS45LDEuNSwyLjMsMy4xYzAuNSwyLjMsMC44LDMuNCwxLjEsNEgyMzBjLTAuMi0wLjQtMC41LTEuNy0wLjktMy42Yy0wLjUtMi4xLTEuNC0zLjEtMy4zLTMuMmgtMi4zdjYuOGgtMS4xVjEwMy44egoJCSBNMjIzLjQsMTEwLjdoMi40YzIuMywwLDMuOC0xLjMsMy44LTMuMmMwLTIuMy0xLjctMy4yLTQtMy4yYy0xLDAtMS44LDAuMS0yLjEsMC4yVjExMC43eiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTIzNi43LDEwMy41aDEuMXY3LjVoMC4xYzAuNC0wLjYsMC45LTEuMSwxLjMtMS41bDUuMy02aDEuM2wtNS42LDYuM2w2LjIsOC41aC0xLjNsLTUuNi03LjhsLTEuNSwxLjd2Ni4xCgkJaC0xLjFWMTAzLjV6Ii8+Cgk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMjYwLjEsMTAzLjV2MTQuOGgtMS4xdi0xNC44SDI2MC4xeiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTI2NywxMTguNHYtMTQuOGgxbDUuOCw4LjhjMS4yLDEuOCwyLjEsMy4yLDIuOCw0LjdsMCwwYy0wLjItMi0wLjItMy43LTAuMi02di03LjRoMXYxNC44aC0xbC01LjctOC42CgkJYy0xLjEtMS43LTIuMS0zLjMtMi45LTQuOGwwLDBjMC4xLDEuOCwwLjEsMy40LDAuMSw1Ljl2Ny41SDI2N3oiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0yODcuMiwxMDQuNGgtNC44di0wLjloMTAuN3YwLjloLTQuOHYxNGgtMS4xVjEwNC40eiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTMwNC45LDExMWgtNS45djYuNWg2LjZ2MC45aC03Ljd2LTE0LjhoNy4zdjAuOWgtNi4zdjUuN2g1LjlWMTExeiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTMxMS40LDEwMy41aDEuMXYxNGg2LjZ2MC45aC03LjdWMTAzLjV6Ii8+Cgk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMzI0LjYsMTAzLjVoMS4xdjE0aDYuNnYwLjloLTcuN1YxMDMuNXoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0zMzguOCwxMDMuNXYxNC44aC0xLjF2LTE0LjhIMzM4Ljh6Ii8+Cgk8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMzU2LjMsMTE3LjdjLTAuNywwLjMtMi4zLDAuOC00LjMsMC44Yy0yLDAtMy43LTAuNS01LjItMS45Yy0xLjItMS4yLTItMy4yLTItNS42YzAtNC4xLDIuNy03LjYsNy43LTcuNgoJCWMxLjYsMCwyLjksMC40LDMuNSwwLjdsLTAuNCwwLjljLTAuOC0wLjQtMS43LTAuNi0zLjItMC42Yy00LjEsMC02LjYsMi42LTYuNiw2LjdjMCw0LjIsMi40LDYuNyw2LjQsNi43YzEuNiwwLDIuNi0wLjIsMy4xLTAuNQoJCXYtNS4yaC0zLjRWMTExaDQuNVYxMTcuN3oiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0zNjkuNywxMTFoLTUuOXY2LjVoNi42djAuOWgtNy43di0xNC44aDcuM3YwLjloLTYuM3Y1LjdoNS45VjExMXoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0zNzYuMywxMTguNHYtMTQuOGgxbDUuOCw4LjhjMS4yLDEuOCwyLjEsMy4yLDIuOCw0LjdsMCwwYy0wLjItMi0wLjItMy43LTAuMi02di03LjRoMXYxNC44aC0xbC01LjctOC42CgkJYy0xLjEtMS43LTIuMS0zLjMtMi45LTQuOGwwLDBjMC4xLDEuOCwwLjEsMy40LDAuMSw1Ljl2Ny41SDM3Ni4zeiIvPgoJPHBhdGggY2xhc3M9InN0MCIgZD0iTTQwMy43LDExNy44Yy0wLjcsMC40LTIuMiwwLjctNCwwLjdjLTMuNiwwLTctMi4zLTctNy41YzAtNC40LDIuOC03LjcsNy41LTcuN2MxLjksMCwzLDAuNCwzLjQsMC43bC0wLjMsMC45CgkJYy0wLjctMC40LTEuOC0wLjYtMy4xLTAuNmMtNCwwLTYuNCwyLjYtNi40LDYuOWMwLDQsMi4zLDYuNiw2LjMsNi42YzEuMywwLDIuNS0wLjMsMy4zLTAuN0w0MDMuNywxMTcuOHoiLz4KCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik00MTYuNCwxMTFoLTUuOXY2LjVoNi42djAuOWgtNy43di0xNC44aDcuM3YwLjloLTYuM3Y1LjdoNS45VjExMXoiLz4KPC9nPgo8L3N2Zz4K"
--------------------------------------------------------------------------------
-- Per-model chassis SVGs (base64). Used by layout.lua to render each
-- GigaCore as its actual product-chassis artwork.
--------------------------------------------------------------------------------

local LogoPSU = "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA5Ljk3MjcgOS45NjY4Ij48ZyB0cmFuc2Zvcm09Im1hdHJpeCgwLjM3MTAwNTczLDAsMCwtMC4zNzA3ODQ5OSw4LjcyNjAxLDApIj48cGF0aCBmaWxsPSIjNUE2NDc4IiBkPSJtIDAsMCBoIC0yMC4xNiBjIC0xLjg1NCwtMC4wMDYgLTMuMzU0LC0xLjUwNiAtMy4zNiwtMy4zNiB2IC0xNS4xMiBjIDAuMDA2LC0xLjg1NCAxLjUwNiwtMy4zNTQgMy4zNiwtMy4zNiBoIDUuMDQgdiAzLjM2IGggLTUuMDQgdiAxNS4xMiBoIDEuNjggViAtOC40IGggMy4zNiB2IDUuMDQgaCAzLjM2IFYgLTguNCBoIDMuMzYgdiA1LjA0IGggMy4zNiBWIC04LjQgaCAzLjM2IHYgNS4wNCBIIDAgdiAtMTUuMTIgaCAtNS4wNCB2IC0zLjM2IEggMCBjIDEuODU0LDAuMDA2IDMuMzU0LDEuNTA2IDMuMzYsMy4zNiBWIC0zLjM2IEMgMy4zNTQsLTEuNTA2IDEuODU0LC0wLjAwNiAwLDAiLz48L2c+PGcgdHJhbnNmb3JtPSJtYXRyaXgoMC4zNzEwMDU3MywwLDAsLTAuMzcwNzg0OTksNS44NDIyMiw0LjM2MDU1KSI+PHBhdGggZmlsbD0iIzVBNjQ3OCIgZD0ibSAwLDAgaCAtNC4zMzIgbCAtMi43MzQsLTYuNzIgaCAzLjQ0NCBsIC0yLjkyOCwtOC40IDguMTk0LDExLjc2IGggLTMuNTUyIHoiLz48L2c+PC9zdmc+"

--------------------------------------------------------------------------------
-- Static Tables / Lookups
--------------------------------------------------------------------------------
-- Per-model port type breakdown. Ports are assumed to be numbered
-- sequentially: ethercon → rj45 → sfp. `poe` = number of ports, counted from
-- port 1, that carry PoE on a PoE unit (licence on the 30i, PoE hardware
-- variant on the others); it drives the grey PoE pips shown offline. Counts
-- from /api/poe/ports of units in the field (2026-11-05); the S30-I
-- was never seen and assumes the 30i's 1-24.
PORT_LAYOUT = {
  ["GigaCore 30i"]    = { ethercon = 0,  rj45 = 24, sfp = 6,  poe = 24 },
  ["GigaCore S30-I"]  = { ethercon = 0,  rj45 = 24, sfp = 6,  poe = 24 },
  ["GigaCore O26-I"]  = { ethercon = 0,  rj45 = 0,  sfp = 26, poe = 0  }, -- 2 QSFP + 4 SFP28 + 20 SFP+
  ["GigaCore 20t"]    = { ethercon = 8,  rj45 = 8,  sfp = 4,  poe = 16 },
  ["GigaCore 18t"]    = { ethercon = 8,  rj45 = 8,  sfp = 2,  poe = 16 },
  ["GigaCore 16t"]    = { ethercon = 8,  rj45 = 8,  sfp = 0,  poe = 16 },
  ["GigaCore 16tf"]   = { ethercon = 12, rj45 = 0,  sfp = 4,  poe = 12 }, -- 13-16: API type sfp, no PoE
  ["GigaCore 16i"]    = { ethercon = 0,  rj45 = 12, sfp = 4,  poe = 12 },
  ["GigaCore 10t"]    = { ethercon = 8,  rj45 = 0,  sfp = 2,  poe = 8  }, -- 9-10: API type sfp, no PoE
  ["GigaCore 10t-IP"] = { ethercon = 8,  rj45 = 0,  sfp = 2,  poe = 8  }, -- 9-10 are rear ethercons, no PoE
  ["GigaCore 10i"]    = { ethercon = 0,  rj45 = 8,  sfp = 2,  poe = 8  },
}

-- Groups and Trunks page: predefined groups 1..20 and trunk 1 (ISL) always
-- exist; custom groups/trunks get reserved slots filled at runtime.
-- Slot controls: group_label_21..(20+CUSTOM_GROUP_SLOTS), trunk_label_2..(1+CUSTOM_TRUNK_SLOTS).
CUSTOM_GROUP_SLOTS = 20
CUSTOM_TRUNK_SLOTS = 8
-- Fill of the Port.Group cell and of the picker's None item when unassigned.
PICKER_UNASSIGNED_HEX = "#3A4256"

-- Build GigaCoreModels (port totals) from PORT_LAYOUT for backward compat.
GigaCoreModels = {}
for model, layout in pairs(PORT_LAYOUT) do
  GigaCoreModels[model] = (layout.ethercon or 0) + (layout.rj45 or 0) + (layout.sfp or 0)
end

function getPortCount(model)
  return GigaCoreModels[model] or 30
end

-- Fans, PSU slots and case temperature sensor per model (largest counts in
-- 1137 support-package api.json records; the S30-I is assumed like the 30i).
-- The fan, PSU and case temperature pins follow these counts.
MODEL_HARDWARE = {
  ["GigaCore 30i"]    = { fans = 3, psus = 2, caseTemp = true },
  ["GigaCore S30-I"]  = { fans = 3, psus = 2, caseTemp = true },
  ["GigaCore O26-I"]  = { fans = 3, psus = 2, caseTemp = true },
  ["GigaCore 20t"]    = { fans = 2, psus = 2, caseTemp = true },
  ["GigaCore 18t"]    = { fans = 2, psus = 2, caseTemp = true },
  ["GigaCore 16t"]    = { fans = 2, psus = 2, caseTemp = true },
  ["GigaCore 16tf"]   = { fans = 2, psus = 2, caseTemp = true },
  ["GigaCore 16i"]    = { fans = 2, psus = 2, caseTemp = true },
  ["GigaCore 10t"]    = { fans = 2, psus = 1, caseTemp = true },
  ["GigaCore 10t-IP"] = { fans = 0, psus = 1, caseTemp = false },
  ["GigaCore 10i"]    = { fans = 1, psus = 1, caseTemp = true },
}

function getModelHardware(model)
  return MODEL_HARDWARE[model] or MODEL_HARDWARE["GigaCore 30i"]
end

function getPoeCount(model)
  local l = PORT_LAYOUT[model]
  return (l and l.poe) or 0
end

function getRJ45Count(model)
  local l = PORT_LAYOUT[model]
  return (l and l.rj45) or 0
end

function getSFPCount(model)
  local l = PORT_LAYOUT[model]
  return (l and l.sfp) or 0
end

-- Resolve the model from the Model property. A value outside the choices
-- (a design saved with an older plugin) falls back to the 30i.
function resolveModel(props)
  local raw = props["Model"]
  local val = (type(raw) == "table") and raw.Value or raw
  if GigaCoreModels[val] then return val end
  return "GigaCore 30i"
end

--------------------------------------------------------------------------------
-- Group colors
--------------------------------------------------------------------------------
GROUP_COLORS = {
  ["Trunk: 1"]  = {153, 153, 153},
  ["Group: 1"]  = { 50,  81, 151},
  ["Group: 2"]  = {232,   0,   0},
  ["Group: 3"]  = { 50, 205,  50},
  ["Group: 4"]  = {  0, 232, 232},
  ["Group: 5"]  = {204,   0, 204},
  ["Group: 6"]  = {255, 130,   0},
  ["Group: 7"]  = {232, 232,   0},
  ["Group: 8"]  = {255,   0, 153},
  ["Group: 9"]  = { 32, 178, 170},
  ["Group: 10"] = {250, 128, 114},
  ["Group: 11"] = {  0,  51, 255},
  ["Group: 12"] = {  0, 128,   0},
  ["Group: 13"] = {187,  85,  85},
  ["Group: 14"] = {139,   0,   0},
  ["Group: 15"] = { 75,   0, 130},
  ["Group: 16"] = {153, 153,   0},
  ["Group: 17"] = {124, 232,   0},
  ["Group: 18"] = {102,   0, 102},
  ["Group: 19"] = { 47,  79,  79},
  ["Group: 20"] = {  0, 102, 204},
}

--------------------------------------------------------------------------------
-- Port speed mappings
--------------------------------------------------------------------------------
SPEED_CHOICES = {
  "Auto",
  "Disabled",
  "10 Gbps",
  "1 Gbps",
  "100 Mbps (Full-duplex)",
  "100 Mbps (Half-duplex)",
  "10 Mbps (Full-duplex)",
  "10 Mbps (Half-duplex)",
}

-- Copper (rj45) ports top out at 1 Gbps; SFP ports offer 10 Gbps only when
-- the "10g" licence is active (see speedChoicesForPort).
SPEED_CHOICES_COPPER = {
  "Auto",
  "Disabled",
  "1 Gbps",
  "100 Mbps (Full-duplex)",
  "100 Mbps (Half-duplex)",
  "10 Mbps (Full-duplex)",
  "10 Mbps (Half-duplex)",
}
SPEED_CHOICES_SFP_10G = { "Auto", "Disabled", "10 Gbps", "1 Gbps" }
SPEED_CHOICES_SFP_1G  = { "Auto", "Disabled", "1 Gbps" }

SPEED_API_MAP = {
  ["10 Gbps"]                = "10gbps fdx",
  ["1 Gbps"]                 = "1gbps fdx",
  ["100 Mbps (Full-duplex)"] = "100mbps fdx",
  ["100 Mbps (Half-duplex)"] = "100mbps hdx",
  ["10 Mbps (Full-duplex)"]  = "10mbps fdx",
  ["10 Mbps (Half-duplex)"]  = "10mbps hdx",
}

SPEED_UI_MAP = {
  ["10gbps fdx"]  = "10 Gbps",
  ["1gbps fdx"]   = "1 Gbps",
  ["100mbps fdx"] = "100 Mbps (Full-duplex)",
  ["100mbps hdx"] = "100 Mbps (Half-duplex)",
  ["10mbps fdx"]  = "10 Mbps (Full-duplex)",
  ["10mbps hdx"]  = "10 Mbps (Half-duplex)",
}

--------------------------------------------------------------------------------
-- Utility / Logging
--------------------------------------------------------------------------------
-- JSON string literal for a Lua string (quotes, backslashes and control
-- characters escaped). The REST PUT bodies are built by hand; see runtime.lua.
function jsonString(s)
  local escaped = tostring(s):gsub('[%c"\\]', function(ch)
    if ch == '"' then return '\\"' end
    if ch == "\\" then return "\\\\" end
    if ch == "\n" then return "\\n" end
    if ch == "\r" then return "\\r" end
    if ch == "\t" then return "\\t" end
    return string.format("\\u%04x", ch:byte())
  end)
  return '"' .. escaped .. '"'
end

function log(m)
  print(tostring(m))
end

--------------------------------------------------------------------------------
-- Layout constants (shared between info.lua and layout.lua)
--------------------------------------------------------------------------------
GROUPBOX_FILL_COLOR    = {12, 21, 42}
GROUPBOX_STROKE_COLOR  = {0, 0, 0}
GROUPBOX_STROKE_WIDTH  = 0
GROUPBOX_POSITION      = {0, 0}
SIDE_MARGIN            = 70
GROUPBOX_EXTRA_PADDING = 5

--------------------------------------------------------------------------------
-- Internal state
--------------------------------------------------------------------------------
state = {
  ws              = nil,
  baseIP          = "",
  currentIP       = "",
  prefixLength    = "",
  ipMode          = "",
  portCount       = 30,
  macAddress      = "",
  firmwareVersion = "",
  groupNames      = {},
  groupMeta       = {},
  customColors    = {},   -- "Group: N" / "Trunk: N" → {r,g,b} (live from API)
  groupList       = {},   -- [{id, name, color, predefined, vid}] ordered as returned
  trunkList       = {},   -- [{id, name, color, predefined}] ordered as returned
  ports           = {},
  darkMode        = false,
  chassis         = nil,  -- chassisGeometry(Properties["Model"]), set by runtime.lua
  cardSvg         = {},   -- port -> last card SVG written to Port.Card N
}

--------------------------------------------------------------------------------
-- Port state model
--------------------------------------------------------------------------------
function getPortState(port)
  state.ports[port] = state.ports[port] or {
    enabled        = true,
    memberOf       = nil,    -- "Group: N" / "Trunk: N", nil for type none
    memberOfKnown  = false,  -- the switch has reported member_of (none included)
    poe            = nil,
    poeEnabled     = nil,
    portType       = nil,    -- raw type ("rj45", "sfp")
    rxBitRate      = nil,    -- counters from GET /api/ports
    txBitRate      = nil,
    linkFlaps      = nil,
    linkState      = nil,    -- raw link_state ("1gbps fdx", "down", ...)
    linkSpeedMode  = nil,    -- raw link_speed mode ("auto", "fixed")
    linkSpeedList  = nil,    -- link_speed speed[] joined with ", " ("all", "1gbps fdx, 100mbps fdx")
    rlinkxState    = nil,    -- raw RLinkX state machine value ("redundant", ...)
    rlinkxEnabled  = nil,    -- per-port RLinkX config flag
    mr             = false,  -- IGMP snooping router port
    rstpRole       = nil,    -- RSTP role ("root", "designated", ...)
    multilinkx     = nil,    -- "active" | "member" | nil (MultiLinkX LAG)
    legend         = nil,    -- legend as the switch reports it, nil until read
    speed          = nil,
    lastValidSpeed = nil,
    speedPending   = false,
  }
  return state.ports[port]
end

--------------------------------------------------------------------------------
-- Pin writers. A control the selected model does not declare (Controls[name]
-- is nil: a port, PoE port, fan or PSU the model lacks) is skipped.
--------------------------------------------------------------------------------
function setPinString(name, value)
  local c = Controls[name]
  if c then c.String = value or "" end
end

function setPinValue(name, number)
  local c = Controls[name]
  local n = tonumber(number)
  if c and n then c.Value = n end
end

function setPinBoolean(name, value)
  local c = Controls[name]
  if c then c.Boolean = (value == true) end
end

-- Every per-port pin from the port state, raw API values.
function renderPortPins(port)
  local p = getPortState(port)
  local base = "Ports.Port " .. port .. "."
  setPinBoolean(base .. "Enabled", p.enabled)
  setPinString(base .. "Link State", p.linkState)
  setPinString(base .. "Type", p.portType)
  setPinBoolean(base .. "RLinkX.Enabled", p.rlinkxEnabled)
  setPinValue(base .. "Counters.Rx Bit Rate", p.rxBitRate)
  setPinValue(base .. "Counters.Tx Bit Rate", p.txBitRate)
  setPinValue(base .. "Counters.Link Flaps", p.linkFlaps)

  -- PoE pins (declared for the model's PoE ports only). The enabled pin
  -- stays off without the PoE licence; an indication of "" is a value.
  local poe = "PoE.Port " .. port .. "."
  setPinBoolean(poe .. "Enabled", state.hasPoe ~= false and p.poeEnabled == true)
  setPinString(poe .. "Indication", p.poe)

  -- One pin per API object: "<mode> <speed, speed>" ("auto all", "fixed
  -- 100mbps fdx"), blank until both fields are known.
  local speedText = ""
  if p.linkSpeedMode and p.linkSpeedList then
    speedText = p.linkSpeedMode .. " " .. p.linkSpeedList
  end
  setPinString(base .. "Link Speed", speedText)

  -- "Group: 22" -> "group 22", "Trunk: 1" -> "trunk 1", reported without a
  -- membership -> "none", never reported -> "".
  local member = ""
  if p.memberOf then
    local word, number = p.memberOf:match("^(%a+): (%d+)$")
    if word then member = word:lower() .. " " .. number end
  elseif p.memberOfKnown then
    member = "none"
  end
  setPinString(base .. "Member Of", member)
end

-- Port state key of a membership ("Group: 22", "Trunk: 1"), nil for none.
function memberOfKey(kind, id)
  if kind == "group" and id then return string.format("Group: %d", id) end
  if kind == "trunk" and id then return string.format("Trunk: %d", id) end
  return nil
end

-- link_speed speed[] array text ('["1gbps fdx","100mbps fdx"]') -> the
-- speed part of the Link Speed pin ("1gbps fdx, 100mbps fdx"); nil stays nil.
function speedListFromArray(arrayText)
  if not arrayText then return nil end
  local tokens = {}
  for token in arrayText:gmatch('"([^"]*)"') do tokens[#tokens + 1] = token end
  return table.concat(tokens, ", ")
end

local function trim(s)
  return (s or ""):match("^%s*(.-)%s*$")
end

-- Written pin text, trimmed and lowercased (every API token is lowercase).
local function pinText(name)
  local c = Controls[name]
  return trim(c and c.String or ""):lower()
end

-- PUT one port object; a rejected write logs the API reason and puts the
-- pin back to the switch's value.
local function putPortObject(port, field, body, onSuccess)
  HttpClient.Upload {
    Url     = string.format("http://%s/api/ports/port/%d/%s", state.baseIP, port, field),
    Method  = "PUT",
    Data    = body,
    Headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders()),
    EventHandler = function(_tbl, code, response, err)
      log("PUT " .. field .. " port " .. port .. " " .. body .. " => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code == 200 then
        if onSuccess then onSuccess() end
        return
      end
      local reason = (type(response) == "string") and response:match('"reason"%s*:%s*"([^"]*)"') or nil
      log(field .. " rejected on port " .. port .. (reason and (": " .. reason) or ""))
      renderPortPins(port)
    end,
  }
end

-- Link Speed pin -> PUT /api/ports/port/N/link_speed. "<mode> <speeds>":
-- the first word is the mode, the rest splits on ",", tokens trimmed, empty
-- ones dropped. Text without a mode and a speed, or a write while offline,
-- puts the pin back. A 200 updates the port state (the WS may lag).
function putPortLinkSpeed(port)
  local text = pinText("Ports.Port " .. port .. ".Link Speed")
  local mode, rest = text:match("^(%a+)%s+(.+)$")
  local tokens, quoted = {}, {}
  for piece in (rest or ""):gmatch("[^,]+") do
    local token = trim(piece)
    if token ~= "" then
      tokens[#tokens + 1] = token
      quoted[#quoted + 1] = jsonString(token)
    end
  end
  if state.baseIP == "" or not mode or #tokens == 0 then
    log("Link Speed not sent on port " .. port .. ": '" .. text .. "'" ..
        (state.baseIP == "" and " (offline)" or ", want '<mode> <speed, speed>'"))
    renderPortPins(port)
    return
  end
  putPortObject(port, "link_speed",
    '{"mode":' .. jsonString(mode) .. ',"speed":[' .. table.concat(quoted, ",") .. ']}',
    function() SetPortLinkSpeedFields(port, mode, table.concat(tokens, ", ")) end)
end

-- Member Of pin -> PUT /api/ports/port/N/member_of: "group 22", "trunk 1"
-- or "none". Other text, or a write while offline, puts the pin back. A 200
-- updates the port state (the WS notification may lag).
function putPortMemberOf(port)
  local text = pinText("Ports.Port " .. port .. ".Member Of")
  local kind, number = text:match("^(%a+)%s*(%d+)$")
  local id = tonumber(number)
  local body
  if text == "none" then
    body = '{"type":"none"}'
  elseif kind == "group" or kind == "trunk" then
    body = string.format('{"type":"%s","id":%d}', kind, id)
  end
  if state.baseIP == "" or not body then
    log("Member Of not sent on port " .. port .. ": '" .. text .. "'" ..
        (state.baseIP == "" and " (offline)" or ", want 'group N', 'trunk N' or 'none'"))
    renderPortPins(port)
    return
  end
  putPortObject(port, "member_of", body, function()
    SetPortMemberOf(port, memberOfKey(kind, id))
  end)
end

-- PUT /api/ports/port/N/legend: the legend pin, "-> Legend" and Fill. A 200
-- updates the port state (the WS notification may lag).
function putPortLegend(port, text)
  putPortObject(port, "legend", jsonString(text), function() SetPortLegend(port, text) end)
end

--------------------------------------------------------------------------------
-- Theme palette (dark + light)
--
-- Futuristic aesthetic inspired by Luminex Araneo. Dark = deep navy with
-- bright cyan accent; light = off-white with navy accents (no pure black).
--------------------------------------------------------------------------------
function getThemeColors()
  if state.darkMode then
    return {
      -- Backgrounds
      pageBg        = { 11, 18, 32 },              -- #0B1220 — page canvas
      gridLine      = { 26, 40, 64, 120 },         -- subtle blue grid
      chassisFill   = { 26, 45, 80, 255 },         -- #1A2D50 — switch body
      chassisStroke = { 90, 140, 200, 180 },
      chassisInner  = { 42, 66, 108, 255 },        -- inner plate under ports

      -- Cards (left temps / right PSU / strips)
      cardFill      = { 22, 34, 58, 245 },
      cardStroke    = { 68, 112, 178, 180 },
      cardTitle     = { 140, 210, 255 },           -- cyan accent for labels

      -- Typography
      textPrimary   = { 232, 240, 252 },           -- soft white
      textMuted     = { 150, 175, 210 },
      textDim       = { 110, 138, 175 },
      accentCyan    = { 120, 200, 255 },           -- #78C8FF primary accent
      accentAmber   = { 255, 178, 56 },
      accentMagenta = { 232, 120, 232 },

      -- Port appearance
      portDefault   = { 36, 56, 92, 255 },         -- unassigned port body
      portText      = { 245, 250, 255 },
      portStroke    = { 90, 130, 180, 220 },
      portOffFill   = { 36, 56, 92, 255 },         -- offline port body (Araneo project mode)
      portOffStroke = { 83, 205, 229, 255 },       -- #53CDE5 cyan outline
      linkUpRing    = { 60, 230, 140, 230 },       -- bright green
      linkDownRing  = { 110, 130, 160, 90 },

      -- Status badges
      badgeOkFg     = { 180, 255, 210 }, badgeOkBg   = { 20, 90, 60, 220 },
      badgeWarnFg   = { 255, 220, 160 }, badgeWarnBg = { 110, 75, 20, 220 },
      badgeErrFg    = { 255, 180, 180 }, badgeErrBg  = { 110, 30, 30, 220 },
      badgeOffFg    = { 160, 175, 200 }, badgeOffBg  = { 36, 48, 70, 220 },

      -- PoE (pip colors)
      poeSourcing   = { 255, 140, 20 },
      poeEnabled    = { 255, 215, 0 },
      poeDisabled   = { 80, 90, 110 },

      -- MR badge (multicast router port)
      mrFill        = { 190, 130, 255 },           -- purple
      mrText        = { 28, 12, 48 },

      -- RLinkX border colors (Araneo-matched)
      rlinkxEnabled  = { 0, 255, 255 },             -- cyan
      rlinkxActive   = { 0, 0, 255 },               -- blue
      rlinkxDisabled = { 204, 209, 219 },           -- light grey
      rlinkxOn       = { 0, 178, 255 },             -- legacy alias (bar)
      rlinkxOff      = { 90, 100, 130 },

      -- Trunk badge (top-left corner triangle)
      trunkBadge    = { 14, 22, 44 },              -- dark navy contrast
    }
  else
    return {
      -- Backgrounds
      pageBg        = { 238, 242, 248 },           -- #EEF2F8 off-white
      gridLine      = { 200, 215, 235, 160 },
      chassisFill   = { 210, 222, 240, 255 },
      chassisStroke = { 130, 160, 200, 200 },
      chassisInner  = { 230, 238, 250, 255 },

      cardFill      = { 255, 255, 255, 245 },
      cardStroke    = { 180, 200, 225, 200 },
      cardTitle     = { 25, 60, 120 },             -- navy label

      textPrimary   = { 28, 46, 78 },
      textMuted     = { 90, 115, 155 },
      textDim       = { 140, 160, 190 },
      accentCyan    = { 25, 110, 200 },
      accentAmber   = { 200, 120, 20 },
      accentMagenta = { 170, 60, 170 },

      portDefault   = { 220, 230, 244, 255 },
      portText      = { 28, 46, 78 },
      portStroke    = { 150, 175, 210, 220 },
      portOffFill   = { 220, 230, 244, 255 },
      portOffStroke = { 25, 110, 200, 255 },
      linkUpRing    = { 36, 180, 100, 240 },
      linkDownRing  = { 170, 185, 205, 150 },

      badgeOkFg     = { 20, 100, 60 },  badgeOkBg   = { 210, 240, 220, 255 },
      badgeWarnFg   = { 145, 85, 20 },  badgeWarnBg = { 255, 230, 190, 255 },
      badgeErrFg    = { 150, 30, 30 },  badgeErrBg  = { 255, 210, 210, 255 },
      badgeOffFg    = { 100, 115, 140 }, badgeOffBg = { 225, 232, 242, 255 },

      poeSourcing   = { 230, 120, 20 },
      poeEnabled    = { 210, 170, 20 },
      poeDisabled   = { 170, 180, 200 },

      mrFill        = { 140, 80, 200 },
      mrText        = { 255, 255, 255 },

      rlinkxEnabled  = { 0, 255, 255 },
      rlinkxActive   = { 0, 0, 255 },
      rlinkxDisabled = { 204, 209, 219 },
      rlinkxOn       = { 20, 130, 200 },
      rlinkxOff     = { 170, 180, 200 },

      trunkBadge    = { 22, 36, 68 },
    }
  end
end

--------------------------------------------------------------------------------
-- Hex helper — converts {r,g,b[,a]} to "#RRGGBB" (alpha dropped for Color)
--------------------------------------------------------------------------------
function rgbHex(c)
  if not c then return "#00000000" end
  return string.format("#%02X%02X%02X", c[1], c[2], c[3])
end

--------------------------------------------------------------------------------
-- Backwards-compat theme keys (still referenced by other page builders).
--------------------------------------------------------------------------------
local _origGetTheme = getThemeColors
function getThemeColors()
  local t = _origGetTheme()
  t.groupboxFill   = t.pageBg
  -- Indicator fill matches the page bg so empty device-info boxes blend in
  -- (backup convention: visually invisible until populated).
  t.indicatorFill  = state.darkMode and { 20, 24, 40, 230 } or { 240, 245, 255, 255 }
  t.strokeColor    = t.cardStroke
  t.textColor      = t.textPrimary
  t.textboxColor   = t.textPrimary
  t.textboxBg      = t.cardFill
  t.buttonColor    = t.accentCyan
  t.buttonAltColor = t.accentCyan
  t.buttonOffColor = t.portDefault
  t.labelGray      = t.textMuted
  -- Port backdrop rectangle — subtle, close to page bg (backup value).
  t.rectangleFill  = state.darkMode and { 30, 40, 60, 220 } or { 240, 245, 255, 255 }
  return t
end

--------------------------------------------------------------------------------
-- Port UI Renderer (UI ONLY)
--------------------------------------------------------------------------------
function renderPortUI(port)
  -- A REST snapshot setting several fields of one port renders it once at
  -- the end (state.renderHeld, see applyPortObject / syncPoePorts).
  if state.renderHeld then return end
  local p = getPortState(port)
  local theme = getThemeColors()
  renderPortPins(port)

  -- Group / trunk color for the Port.Group cell of the port-settings grid.
  -- Live API color preferred, predefined palette fallback, transparent if
  -- unassigned, black on a disabled port.
  local memberOf  = p.memberOf
  local groupColor = (state.customColors and state.customColors[memberOf])
                    or GROUP_COLORS[memberOf]
  local groupHex
  if p.enabled == false then
    groupHex = "#000000"
  else
    groupHex = groupColor and rgbHex(groupColor) or "#00000000"
  end

  -- Port.Group cell — Button colored with group color, Legend = name.
  local groupBtn = Controls["Port.Group " .. port]
  if groupBtn then
    local cellHex = (memberOf and groupHex ~= "#00000000") and groupHex or PICKER_UNASSIGNED_HEX
    groupBtn.Color = cellHex
    pcall(function() groupBtn.OffColor = cellHex end)
    groupBtn.Legend = memberOfDisplayName(memberOf)
  end

  -- Without the PoE licence ("poe" missing from the /api/features active
  -- list) no toggle color and no toggle state (renderPortPins), whatever
  -- /api/poe/ports reports.
  local poeLicensed = state.hasPoe ~= false
  local poeKey = poeLicensed and (p.poe or ""):lower() or ""
  local poeColorMap = {
    sourcing = theme.poeSourcing,
    enabled  = theme.poeEnabled,
    disabled = theme.poeDisabled,
  }

  local poeToggle = Controls["PoE.Port " .. port .. ".Enabled"]
  if poeToggle then
    local c = poeColorMap[poeKey]
    poeToggle.Color  = c and rgbHex(c) or "#00000000"
    poeToggle.Legend = (poeKey == "sourcing") and "⚡" or ""
  end

  -- "Disabled" is a picker choice, not an API speed: a disabled port shows
  -- it here while p.speed keeps the real link_speed for when it comes back.
  local speedCell = Controls["Port.Speed Cell " .. port]
  if speedCell then
    local hex = rgbHex(theme.buttonOffColor)
    speedCell.Legend = (p.enabled == false) and "Disabled" or tostring(p.speed or "")
    speedCell.Color  = hex
    pcall(function() speedCell.OffColor = hex end)
  end

  -- Web UI card on the chassis. Re-encoded only when its SVG changed: the
  -- connect storm calls renderPortUI hundreds of times. Ports without a card
  -- (plugin model smaller than the switch) are skipped.
  local card = state.chassis and state.chassis.cards[port]
  if card then
    local svg = portCardSvg(portCardView(port, card))
    if svg ~= state.cardSvg[port] then
      state.cardSvg[port] = svg
      Controls["Port.Card " .. port].Legend = iconLegend(svg)
    end
  end
end

-- Button Legend that draws an SVG through IconData (no chrome, no text).
function iconLegend(svg)
  return '{"DrawChrome":false,"IconData":"' .. Crypto.Base64Encode(svg) .. '","Legend":""}'
end

-- 10G frames (Chassis.10G N, one per tenG group in layout order): shown while
-- the 10g licence is active. Painted only when that changes (state.tenGShown).
function refreshTenGFrames()
  if not state.chassis or state.tenGShown == state.has10g then return end
  state.tenGShown = state.has10g
  local index = 0
  for _, frame in ipairs(state.chassis.frames) do
    if frame.tenG then
      index = index + 1
      Controls["Chassis.10G " .. index].Legend = state.has10g and iconLegend(tenGFrameSvg(frame)) or ""
    end
  end
end

-- Blank every card and 10G frame so the offline chassis graphic shows: at
-- runtime start (Designer keeps the last runtime Legend, which would show a
-- previous session as current) and when the WebSocket drops (the web UI's
-- not-live look). The next snapshot rewrites them all.
function clearPortCards()
  -- First: closing re-renders the selected card, which the blanking below
  -- then clears.
  closeLldpPanel()
  state.cardSvg = {}
  state.tenGShown = nil
  for port = 1, (state.portCount or 0) do
    Controls["Port.Card " .. port].Legend = ""
  end
  -- Forget the states too: a groups answer landing after a close (in flight,
  -- or the 3 s reconcile) would otherwise redraw them while offline.
  state.querierSvg, state.querierByVid = "", {}
  Controls["Querier.Badges"].Legend = ""
  clearLldp()
  if not state.chassis then return end
  local index = 0
  for _, frame in ipairs(state.chassis.frames) do
    if frame.tenG then
      index = index + 1
      Controls["Chassis.10G " .. index].Legend = ""
    end
  end
end

--------------------------------------------------------------------------------
-- Basic Auth
--------------------------------------------------------------------------------
function MergeTables(a, b)
  local result = {}
  for k, v in pairs(a) do result[k] = v end
  for k, v in pairs(b) do result[k] = v end
  return result
end

function getAuthHeaders()
  local user = Controls["Auth.Username"] and Controls["Auth.Username"].String or ""
  local pass = Controls["Auth.Password"] and Controls["Auth.Password"].String or ""
  if user == "" or pass == "" then return {} end
  local token = Crypto.Base64Encode(user .. ":" .. pass)
  return { ["Authorization"] = "Basic " .. token }
end

--------------------------------------------------------------------------------
-- WebSocket subscriptions
--------------------------------------------------------------------------------
function subscribeAllPorts()
  if not state.ws then return end

  for i = 1, state.portCount do
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/link_state","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/member_of","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/rlinkx","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/rlinkx/ports/%d/state","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/legend","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/enabled","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/ports/port/%d/link_speed","action":"add","method":"changes"}}', i))
  end

  state.ws:Write('{"subscription":{"path":"/device/name","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/hostname","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/description","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/actual_ip/ip_address","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/actual_ip/prefix_length","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/actual_ip/default_gateway","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/ip_settings/mode","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/mac_address","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/device/firmware/active","action":"add","method":"changes"}}')
end

--------------------------------------------------------------------------------
-- System / chassis / RSTP / snooping subscriptions
--------------------------------------------------------------------------------
function subscribeAllSystem()
  if not state.ws then return end

  -- CPU load, CPU and case temperatures
  state.ws:Write('{"subscription":{"path":"/system/cpu_load","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/system/cpu_load_long","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/temperatures/temperature/cpu/current","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/temperatures/temperature/case/current","action":"add","method":"changes"}}')

  -- Fans 1..3 (some models have fewer — extras harmlessly never fire)
  for i = 1, 3 do
    state.ws:Write(string.format('{"subscription":{"path":"/fans/fan/%d/speed","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/fans/fan/%d/state","action":"add","method":"changes"}}', i))
  end

  -- PSUs
  for _, name in ipairs({ "psu1", "psu2" }) do
    state.ws:Write(string.format('{"subscription":{"path":"/power/psus/%s/state","action":"add","method":"changes"}}', name))
    state.ws:Write(string.format('{"subscription":{"path":"/power/psus/%s/power_status","action":"add","method":"changes"}}', name))
    state.ws:Write(string.format('{"subscription":{"path":"/power/psus/%s/power_usage","action":"add","method":"changes"}}', name))
  end
  state.ws:Write('{"subscription":{"path":"/power/coupling/mode","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/power/coupling/state","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/power/total_power_usage","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/power/total_power_max","action":"add","method":"changes"}}')

  -- Switch-wide RLinkX flag
  state.ws:Write('{"subscription":{"path":"/rlinkx/enabled","action":"add","method":"changes"}}')

  -- Spanning tree (default MST instance 0)
  state.ws:Write('{"subscription":{"path":"/spanning_tree/mst/0/bridge_priority","action":"add","method":"changes"}}')
  for i = 1, state.portCount do
    state.ws:Write(string.format('{"subscription":{"path":"/spanning_tree/mst/0/ports/%d/role","action":"add","method":"changes"}}', i))
  end
  state.ws:Write('{"subscription":{"path":"/spanning_tree/mst/0/root_bridge_address","action":"add","method":"changes"}}')
  state.ws:Write('{"subscription":{"path":"/spanning_tree/mst/0/root_bridge_priority","action":"add","method":"changes"}}')

  -- MultiLinkX LAGs: any notification re-reads the whole list (scheduleLagSync)
  state.ws:Write('{"subscription":{"path":"/ports/lags/lag","action":"add","method":"changes"}}')

  -- LLDP neighbors: the answer carries the whole list (handleLldpPath)
  state.ws:Write('{"subscription":{"path":"/lldp/neighbor","action":"add","method":"changes"}}')
end

-- The switch answers a subscription under a group or PoE port that does not
-- exist with an error message, so these two follow the REST answers instead
-- of fixed ranges. Both flags are reset at Connected.

-- PoE paths only on a PoE unit ("poe" active in /api/features) and only for
-- the model's PoE ports. Runs on every features answer: a PoE licence
-- activated later is picked up by the next reconcile.
state.poeSubscribed = state.poeSubscribed or false

function subscribePoePorts()
  if not state.ws or not state.hasPoe or state.poeSubscribed then return end
  state.poeSubscribed = true
  for i = 1, getPoeCount(resolveModel(Properties)) do
    state.ws:Write(string.format('{"subscription":{"path":"/poe/ports/%d/indication","action":"add","method":"changes"}}', i))
    state.ws:Write(string.format('{"subscription":{"path":"/poe/ports/%d/enabled","action":"add","method":"changes"}}', i))
  end
end

-- Name and id notifications for the groups of the last /api/groups answer
-- (renames show live; a new group is picked up by the next reconcile). A
-- group gone from the list is forgotten, so it is subscribed again if it
-- comes back.
state.groupSubscribed = state.groupSubscribed or {}

function subscribeGroups()
  local present = {}
  for _, g in ipairs(state.groupList) do present[g.id] = true end
  for id in pairs(state.groupSubscribed) do
    if not present[id] then state.groupSubscribed[id] = nil end
  end
  if not state.ws then return end
  for _, g in ipairs(state.groupList) do
    if not state.groupSubscribed[g.id] then
      state.groupSubscribed[g.id] = true
      state.ws:Write(string.format('{"subscription":{"path":"/groups/group/%d/name","action":"add","method":"changes"}}', g.id))
      state.ws:Write(string.format('{"subscription":{"path":"/groups/group/%d/group_id","action":"add","method":"changes"}}', g.id))
    end
  end
end

--------------------------------------------------------------------------------
-- Model detection (REST snapshot)
--------------------------------------------------------------------------------
-- The read-only "model" of /api/device has no space ("GigaCore30i") where the
-- plugin's model names have one ("GigaCore 30i"): compare lowercase letters
-- and digits only. ("name" is the user-set device name.)
local function modelKey(s)
  return (s:lower():gsub("[^%w]", ""))
end

function matchModel(raw)
  local wanted = modelKey(raw)
  for name, _ in pairs(GigaCoreModels) do
    if modelKey(name) == wanted then return name end
  end
  return nil
end

-- Display.Model flashes like the Offline badge while the Model property and
-- the switch disagree. One timer, reused across WebSocket reconnects.
local function startModelPulse(ctrl)
  local bright = true
  pcall(function() ctrl.Color = "#C80000" end)
  state.modelPulseTimer = state.modelPulseTimer or Timer.New()
  state.modelPulseTimer.EventHandler = function()
    bright = not bright
    pcall(function() ctrl.Color = bright and "#C80000" or "#800000" end)
  end
  state.modelPulseTimer:Start(0.5)
end

local function stopModelPulse()
  if state.modelPulseTimer then state.modelPulseTimer:Stop() end
end

-- One-shot GET /api/device at connect. Device.Model and Device.Hostname get
-- the raw values; Display.Model shows the switch's model, flashing red when
-- the Model property names another one: the chassis layout is frozen at
-- design time, so the user has to pick the right model in the plugin
-- properties.
function fetchDeviceInfo()
  HttpClient.Get {
    Url     = string.format("http://%s/api/device", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    EventHandler = function(_tbl, code, body, _err)
      if code ~= 200 or not body then return end
      updateGateway(body:match('"default_gateway"%s*:%s*"([^"]*)"'))
      local hostname = body:match('"hostname"%s*:%s*"([^"]*)"')
      if hostname then setPinString("Device.Hostname", hostname) end
      local raw = body:match('"model"%s*:%s*"([^"]+)"')
      if not raw then return end
      setPinString("Device.Model", raw)
      local name = matchModel(raw)
      local selected = resolveModel(Properties)
      local ctrl = Controls["Display.Model"]
      if name == selected then
        stopModelPulse()
        log("Device model detected => " .. name)
        ctrl.String = name
        paintHeaderBox(ctrl)
        state.modelMismatch = nil
        refreshStatus()
        return
      end
      log("WARNING: Model property is set to '" .. selected ..
          "' but the switch reports '" .. raw ..
          "'. Pick the correct model in plugin properties to fix the chassis layout.")
      ctrl.String = "Switch is " .. (name or raw)
      startModelPulse(ctrl)
      state.modelMismatch = ctrl.String
      refreshStatus()
    end,
  }
end

--------------------------------------------------------------------------------
-- Bulk REST reconciliation
--
-- WebSocket subscriptions are the live path, but a notification missed
-- during the subscription storm at connect stays wrong until that value
-- changes again. Nine bulk GETs (reconcileAll) re-apply the state through the
-- same setters the WS handlers use. They run right after connect, again 3 s
-- later, then every Poll Interval.
--------------------------------------------------------------------------------

-- Reconcile GETs still waiting for their answer. Each has a 10 s Timeout and
-- a timeout still calls its handler, so the count always drains. The poll
-- tick and the 3 s follow-up wait for the previous batch (reconcileIfIdle):
-- a slow switch never gets a second batch on top of the first.
state.getsInFlight = state.getsInFlight or 0

local function counted(handler)
  state.getsInFlight = state.getsInFlight + 1
  return function(...)
    state.getsInFlight = state.getsInFlight - 1
    return handler(...)
  end
end

-- Split a JSON array body into its top-level "{...}" elements by walking
-- brace positions with string.find (a per-character loop over a 50 KB body
-- trips Q-SYS's "Max execution limits exceeded"). No braces inside strings
-- in this API.
local function splitJsonObjects(body)
  local objects, depth, start = {}, 0, nil
  local pos = 1
  while true do
    local i = body:find("[{}]", pos)
    if not i then break end
    if body:sub(i, i) == "{" then
      if depth == 0 then start = i end
      depth = depth + 1
    else
      depth = depth - 1
      if depth == 0 and start then
        objects[#objects + 1] = body:sub(start, i)
        start = nil
      end
    end
    pos = i + 1
  end
  return objects
end

-- RLinkX bulk snapshot: /api/rlinkx => {"enabled":..,"ports":[{"port_number":N,"state":"redundant|non-redundant|disabled"},..]}
function syncRlinkxState()
  HttpClient.Get {
    Url     = string.format("http://%s/api/rlinkx", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/rlinkx => HTTP " .. tostring(code) .. " body=" .. type(body) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      -- Top-level "enabled" (switch-wide flag), matched once ports[] is out
      -- of the way.
      local enabled = body:gsub("%b[]", "[]"):match('"enabled"%s*:%s*(%a+)')
      if enabled == "true" or enabled == "false" then SetRlinkxEnabled(enabled == "true") end
      for portNum, stateStr in body:gmatch('"port_number"%s*:%s*(%d+)%s*,%s*"state"%s*:%s*"([^"]+)"') do
        local n = tonumber(portNum)
        if n and n <= (state.portCount or 0) then SetPortRlinkxState(n, stateStr) end
      end
    end),
  }
end

-- Pull nested objects out of one element so top-level scalars can be
-- matched without ambiguity (e.g. "enabled" exists at top level and inside
-- "rlinkx"). Returns the flattened top-level string and a table of nested
-- object strings keyed by field name.
local function splitNested(elem)
  local nested = {}
  local top = elem:gsub('"([%w_]+)"%s*:%s*(%b{})', function(key, obj)
    nested[key] = obj
    return ""
  end)
  return top, nested
end

local function applyPortObject(elem)
  local top, nested = splitNested(elem)
  local port = tonumber(top:match('"port_number"%s*:%s*(%d+)'))
  if not port or port > (state.portCount or 0) then return end
  state.renderHeld = true

  local ptype = top:match('"type"%s*:%s*"(%w+)"')
  if ptype then getPortState(port).portType = ptype end

  local enabled = top:match('"enabled"%s*:%s*(%a+)')
  if enabled then SetPortEnabled(port, enabled == "true") end

  local link = top:match('"link_state"%s*:%s*"([^"]*)"')
  if link then SetPortLinkState(port, link) end

  local legend = lldpJsonString(top, "legend")
  if legend then SetPortLegend(port, legend) end

  if nested.counters then
    local p = getPortState(port)
    p.rxBitRate = tonumber(nested.counters:match('"rx_bit_rate"%s*:%s*(%d+)'))
    p.txBitRate = tonumber(nested.counters:match('"tx_bit_rate"%s*:%s*(%d+)'))
    p.linkFlaps = tonumber(nested.counters:match('"link_flaps"%s*:%s*(%d+)'))
  end

  if nested.member_of then
    local t  = nested.member_of:match('"type"%s*:%s*"([^"]+)"')
    local id = nested.member_of:match('"id"%s*:%s*(%d+)')
    if t == "group" and id then
      SetPortMemberOf(port, "Group: " .. id)
    elseif t == "trunk" and id then
      SetPortMemberOf(port, "Trunk: " .. id)
    elseif t == "none" then
      SetPortMemberOf(port, nil)
    end
  end

  if nested.link_speed then
    local mode  = nested.link_speed:match('"mode"%s*:%s*"([^"]+)"')
    local speed = nested.link_speed:match('"speed"%s*:%s*%[%s*"([^"]+)"')
    if mode == "auto" then
      SetPortSpeed(port, (speed == "all" or not speed) and "Auto" or speed)
    elseif mode == "fixed" and speed then
      SetPortSpeed(port, speed)
    end
    SetPortLinkSpeedFields(port, mode, speedListFromArray(nested.link_speed:match('"speed"%s*:%s*(%b[])')))
  end

  if nested.rlinkx then
    local flag = nested.rlinkx:match('"enabled"%s*:%s*(%a+)')
    if flag == "true" or flag == "false" then SetPortRlinkxEnabled(port, flag == "true") end
  end
  state.renderHeld = false
  renderPortUI(port)
end

function syncAllPorts()
  HttpClient.Get {
    Url     = string.format("http://%s/api/ports", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/ports => HTTP " .. tostring(code) .. " body=" .. type(body) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      local arr = body:match('"port"%s*:%s*(%b[])')
      if not arr then return end
      for _, elem in ipairs(splitJsonObjects(arr)) do applyPortObject(elem) end
    end),
  }
end

function syncPoePorts()
  HttpClient.Get {
    Url     = string.format("http://%s/api/poe/ports", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, _err)
      if code ~= 200 or type(body) ~= "string" then return end
      for _, elem in ipairs(splitJsonObjects(body)) do
        local top = splitNested(elem)
        local port = tonumber(top:match('"port_number"%s*:%s*(%d+)'))
        if port and port <= (state.portCount or 0) then
          state.renderHeld = true
          local enabled = top:match('"enabled"%s*:%s*(%a+)')
          if enabled then SetPortPoeEnabled(port, enabled == "true") end
          local ind = top:match('"indication"%s*:%s*"([^"]*)"')
          if ind then SetPortIndication(port, ind) end
          state.renderHeld = false
          renderPortUI(port)
        end
      end
    end),
  }
end

-- /api/features: "10g" in the active list means the 10 G licence is on,
-- which decides whether SFP ports may be set to 10 Gbps. "poe" in the
-- active list is the PoE licence ("supported" only says it can be bought);
-- without it renderPortUI shows no PoE pip or toggle state. "fiber" in
-- "supported" but not in "active" draws the rfib ports as not present; old
-- firmware (v1.1.0) has no "supported" list.
function syncFeatures()
  HttpClient.Get {
    Url     = string.format("http://%s/api/features", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/features => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      local active = body:match('"active"%s*:%s*(%b[])') or ""
      local supported = body:match('"supported"%s*:%s*(%b[])') or ""
      state.has10g = active:find('"10g"', 1, true) ~= nil
      refreshTenGFrames()
      local before = { state.hasPoe, state.fiberPossible, state.fiberActive }
      state.hasPoe = active:find('"poe"', 1, true) ~= nil
      state.fiberPossible = supported:find('"fiber"', 1, true) ~= nil
      state.fiberActive = active:find('"fiber"', 1, true) ~= nil
      if state.hasPoe ~= before[1] or state.fiberPossible ~= before[2] or state.fiberActive ~= before[3] then
        for port = 1, (state.portCount or 0) do renderPortUI(port) end
      end
      subscribePoePorts()
    end),
  }
end

-- MultiLinkX: /api/ports/lags/lag => [{"port_number":66,"link_state":"up",
-- "members":[25,26],"active_members":[25]},..]. A port in any active_members
-- gets the white bar, a port only in members the magenta one. The API reports
-- a LAG's RSTP role and router-port status on its own port number (66 and
-- up): every member shows them (portCardView, refreshMrPorts), like Araneo.
state.lagOf             = state.lagOf or {}             -- member port -> LAG port number
state.lagMembers        = state.lagMembers or {}        -- LAG port number -> { member ports }
state.lagRoleSubscribed = state.lagRoleSubscribed or {} -- LAG port -> true once its role is subscribed on this socket

function syncLags()
  HttpClient.Get {
    Url     = string.format("http://%s/api/ports/lags/lag", state.baseIP),
    Headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders()),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/ports/lags/lag => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      local roles, lagOf, lagMembers = {}, {}, {}
      for lag in body:gmatch("%b{}") do
        local lagPort = tonumber(lag:match('"port_number"%s*:%s*(%d+)'))
        local members = lag:match('"members"%s*:%s*(%b[])') or ""
        local active  = lag:match('"active_members"%s*:%s*(%b[])') or ""
        if lagPort then lagMembers[lagPort] = {} end
        for n in members:gmatch("%d+") do
          local port = tonumber(n)
          roles[port] = roles[port] or "member"
          if lagPort then
            lagOf[port] = lagPort
            table.insert(lagMembers[lagPort], port)
          end
        end
        for n in active:gmatch("%d+") do roles[tonumber(n)] = "active" end
      end
      local previousLagOf = state.lagOf
      state.lagOf, state.lagMembers = lagOf, lagMembers
      for port = 1, (state.portCount or 0) do
        local p = getPortState(port)
        if p.multilinkx ~= roles[port] or previousLagOf[port] ~= lagOf[port] then
          p.multilinkx = roles[port]
          renderPortUI(port)
        end
      end
      refreshMrPorts()
      subscribeLagRoles()
    end),
  }
end

-- One LAG change arrives as one notification per changed field: the burst
-- re-reads the list once, 0.5 s after its first notification.
function scheduleLagSync()
  if state.lagSyncPending then return end
  state.lagSyncPending = true
  Timer.CallAfter(function()
    state.lagSyncPending = false
    syncLags()
  end, 0.5)
end

--------------------------------------------------------------------------------
-- LLDP neighbors: GET /api/lldp/neighbor in the reconcile, WS /lldp/neighbor
-- (parsing and shown values in lldp.lua).
--------------------------------------------------------------------------------
state.lldp = state.lldp or {}  -- port -> neighbor (lldpParseNeighbors), ports 1..portCount only

function refreshLldpViews()
  refreshLldpRows()
  refreshLldpPanel()
end

-- The whole neighbor list (GET body or subscription answer). A port the
-- model does not have (O26-I lists 32, LAG ports 66 and up) is left out.
function applyLldp(text)
  local lldp = {}
  for port, neighbor in pairs(lldpParseNeighbors(text)) do
    if port <= (state.portCount or 0) then lldp[port] = neighbor end
  end
  state.lldp = lldp
  refreshLldpViews()
end

-- Neighbors page. Rows are redrawn only when their SVG changed (state.lldpSvg).
state.lldpSvg = state.lldpSvg or {}  -- port -> last row SVG written to Lldp.Row N

local function lldpColors()
  local theme = getThemeColors()
  return { fill = rgbHex(theme.cardFill), border = "#CED3DD", text = rgbHex(theme.textPrimary),
    muted = rgbHex(theme.textMuted) }
end

-- Fill of the LLDP text buttons (white text): navy in both themes (the light
-- buttonOffColor is too pale for white text).
local function lldpButtonHex()
  local theme = getThemeColors()
  return rgbHex(state.darkMode and theme.buttonOffColor or theme.textPrimary)
end

-- A text button (-> Legend, Close), shown.
local function showLldpButton(name, label)
  local button = Controls[name]
  local hex = lldpButtonHex()
  button.Legend = label
  button.Color = hex
  pcall(function() button.OffColor = hex end)
  setOverlayVisible(name, true)
end

function refreshLldpRows()
  local model = resolveModel(Properties)
  local geometry = neighborsGeometry(model)
  local columns = neighborsColumns(geometry.blockW, geometry.compact)
  local colors = lldpColors()
  for port = 1, state.portCount do
    local neighbor = state.lldp[port]
    local svg = lldpRowSvg({ port = port, w = geometry.blockW, h = geometry.rowH,
      view = neighbor and lldpView(neighbor) }, colors, columns)
    if state.lldpSvg[port] ~= svg then
      state.lldpSvg[port] = svg
      Controls["Lldp.Row " .. port].Legend = iconLegend(svg)
    end
  end
end

-- Blank the Neighbors page (WS Error / Closed, runtime start) and forget the
-- neighbors, like the cards: Designer keeps the last runtime Legend offline.
function clearLldp()
  state.lldp, state.lldpSvg = {}, {}
  for port = 1, (state.portCount or 0) do
    local row = Controls["Lldp.Row " .. port]
    if row then row.Legend = "" end
  end
end

-- Neighbor panel (main page): opened by a click on a chassis card, over the
-- port-settings grid. The selected card is outlined (portCardView.selected).
-- The buttons' names sort after zLldp.Panel, so they draw on top of it.
local LLDP_PANEL_CONTROLS = { "zLldp.Panel", "zLldp.Panel To Legend", "zLldp.Panel Close" }

function refreshLldpPanel()
  local port = state.lldpPanelPort
  if not port then return end
  local neighbor = state.lldp[port]
  local view = neighbor and lldpView(neighbor)
  local svg = lldpPanelSvg({ port = port, view = view }, lldpColors())
  if svg == state.lldpPanelSvg then return end
  state.lldpPanelSvg = svg
  Controls["zLldp.Panel"].Legend = iconLegend(svg)
  setOverlayVisible("zLldp.Panel", true)
  showLldpButton("zLldp.Panel Close", "Close")
  if view then
    showLldpButton("zLldp.Panel To Legend", "\u{2192} Legend")
  else
    setOverlayVisible("zLldp.Panel To Legend", false)
  end
end

-- Only while online; an open picker closes. The previous and the new
-- selected cards re-render (the card SVG cache skips the others).
function openLldpPanel(port)
  if state.connection ~= "online" then return end
  closeGroupPicker()
  closeSpeedPicker()
  local previous = state.lldpPanelPort
  state.lldpPanelPort, state.lldpPanelSvg = port, nil
  if previous and previous ~= port then renderPortUI(previous) end
  renderPortUI(port)
  refreshLldpPanel()
end

function closeLldpPanel()
  local port = state.lldpPanelPort
  state.lldpPanelPort, state.lldpPanelSvg = nil, nil
  if port then renderPortUI(port) end
  for _, name in ipairs(LLDP_PANEL_CONTROLS) do setOverlayVisible(name, false) end
end

-- A click on the open port's card closes the panel, any other card opens it.
function toggleLldpPanel(port)
  if state.lldpPanelPort == port then
    closeLldpPanel()
  else
    openLldpPanel(port)
  end
end

function syncLldp()
  HttpClient.Get {
    Url     = string.format("http://%s/api/lldp/neighbor", state.baseIP),
    Headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders()),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/lldp/neighbor => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      applyLldp(body)
    end),
  }
end

-- A burst of neighbor notifications re-reads the list once, 0.5 s after its
-- first one.
function scheduleLldpSync()
  if state.lldpSyncPending then return end
  state.lldpSyncPending = true
  Timer.CallAfter(function()
    state.lldpSyncPending = false
    syncLldp()
  end, 0.5)
end

-- /lldp/neighbor: the subscription answer carries the whole list; a TTL
-- refresh (one every few seconds per neighbor) is ignored; anything else (the
-- shape of an added or removed neighbor was never observed) re-reads the list.
function handleLldpPath(path, raw)
  if path ~= "/lldp/neighbor" then return false end
  if raw:match('"notification_type"%s*:%s*"([^"]+)"') == "subscription_response" then
    applyLldp(raw)
  elseif not lldpIsTtlOnly(raw) then
    scheduleLldpSync()
  end
  return true
end

function reconcileAll()
  log("reconcileAll: ws=" .. tostring(state.ws ~= nil) .. " ip=" .. tostring(state.baseIP))
  if not state.ws or state.baseIP == "" then return end
  syncAllPorts()
  syncFeatures()
  syncPoePorts()
  syncRlinkxState()
  syncLags()
  fetchCustomColors()
  syncPowerStatus()
  syncSpanningTree()
  syncLldp()
end

-- The poll tick and the 3 s follow-up; the reconcile at Connected always runs.
function reconcileIfIdle()
  if state.getsInFlight > 0 then
    log("reconcile skipped: " .. state.getsInFlight .. " GETs still in flight")
    return
  end
  reconcileAll()
end

--------------------------------------------------------------------------------
-- Status block snapshots (REST). The WebSocket only reports changes, so a
-- PSU state or root bridge that never changes after connect would otherwise
-- stay blank; these GETs feed the same setters as the WS handlers.
--------------------------------------------------------------------------------
-- /api/power: {"total_power_usage":N,"coupling":{"mode":..,"state":..},
--   "psus":[{"name":"psu1",...,"power_usage":N,...,"state":"good",...},...]}
function syncPowerStatus()
  HttpClient.Get {
    Url     = string.format("http://%s/api/power", state.baseIP),
    Headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders()),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/power => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      local total = body:match('"total_power_usage"%s*:%s*(%d+)')
      if total then SetTotalPower(total) end
      local max = body:match('"total_power_max"%s*:%s*(%d+)')
      if max then SetTotalPowerMax(max) end
      -- psus[] lists only the powered sources: a slot missing from it gets
      -- "" pins and a grey icon, and fewer sources than max_num_psus marks
      -- the single-PSU install that refreshCoupling does not flag.
      local psus = body:match('"psus"%s*:%s*(%b[])') or "[]"
      local maxPsus = tonumber(body:match('"max_num_psus"%s*:%s*(%d+)'))
      local count, seen = 0, {}
      for obj in psus:gmatch("%b{}") do
        count = count + 1
        local id = tonumber(obj:match('"name"%s*:%s*"psu(%d+)"'))
        if id then
          seen[id] = true
          -- "fans":[{...,"state":..}] nests its own "state"; strip nested
          -- arrays and objects before matching the top-level scalars.
          local flat = obj:gsub("%b[]", "[]")
          local usage = flat:match('"power_usage"%s*:%s*(-?%d+)')
          local pstat = flat:match('"state"%s*:%s*"([^"]*)"')
          local power = flat:match('"power_status"%s*:%s*"([^"]*)"')
          if pstat then SetPsuState(id, pstat) end
          if power then SetPsuPowerStatus(id, power) end
          if usage then SetPsuPower(id, usage) end
        end
      end
      for id = 1, 2 do
        if not seen[id] then
          SetPsuState(id, "")
          SetPsuPowerStatus(id, "")
        end
      end
      state.psuMissing = maxPsus ~= nil and count < maxPsus
      local coupling = body:match('"coupling"%s*:%s*(%b{})')
      if coupling then
        local mode  = coupling:match('"mode"%s*:%s*"([^"]+)"')
        local cstat = coupling:match('"state"%s*:%s*"([^"]+)"')
        if cstat then SetCouplingState(cstat) end
        if mode  then SetPowerCoupling(mode) end
      end
    end),
  }
end

-- /api/spanning_tree/mst/0: bridge_priority, bridge_address,
-- root_bridge_address, root_bridge_priority (+ a "ports" array we skip).
function syncSpanningTree()
  HttpClient.Get {
    Url     = string.format("http://%s/api/spanning_tree/mst/0", state.baseIP),
    Headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders()),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/spanning_tree/mst/0 => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      local flat = body:gsub("%b[]", "[]")
      local pri      = flat:match('"bridge_priority"%s*:%s*(%d+)')
      local addr     = flat:match('"bridge_address"%s*:%s*"([^"]+)"')
      local rootAddr = flat:match('"root_bridge_address"%s*:%s*"([^"]+)"')
      local rootPri  = flat:match('"root_bridge_priority"%s*:%s*(%d+)')
      if pri      then SetBridgePriority(pri) end
      if addr     then SetBridgeAddress(addr) end
      if rootPri  then SetRootBridgePriority(rootPri) end
      if rootAddr then SetRootBridgeAddress(rootAddr) end
      local ports = body:match('"ports"%s*:%s*(%b[])')
      if not ports then return end
      for obj in ports:gmatch("%b{}") do
        local n    = obj:match('"port_number"%s*:%s*(%d+)')
        local role = obj:match('"role"%s*:%s*"([^"]+)"')
        if n and role then SetPortRstpRole(tonumber(n), role) end
      end
    end),
  }
end

-- A design saved with the former "5 s" choice polls every 15 s.
function pollIntervalSeconds()
  local secs = tonumber(Properties["Poll Interval"].Value:match("(%d+)")) or 0   -- "Off" => 0
  if secs > 0 and secs < 15 then return 15 end
  return secs
end

function startPollTimer()
  stopPollTimer()
  local secs = pollIntervalSeconds()
  log("poll interval: " .. secs .. " s")
  if secs <= 0 then return end
  state.pollTimer = Timer.New()
  state.pollTimer.EventHandler = function() reconcileIfIdle() end
  state.pollTimer:Start(secs)
end

function stopPollTimer()
  if state.pollTimer then
    state.pollTimer:Stop()
    state.pollTimer = nil
  end
end

--------------------------------------------------------------------------------
-- Custom group / trunk color sync (REST snapshot)
--   /api/groups and /api/trunks return color as "#RRGGBB" per entry.
--   Populates state.customColors so renderPortUI can resolve any memberOf
--   — predefined or user-defined — to its live color.
--------------------------------------------------------------------------------
local function parseHexColor(hex)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  if r and g and b then return { r, g, b } end
end

local function parseBool(s)
  return s == "true"
end

function fetchCustomColors()
  log("fetchCustomColors: GET /api/groups + /api/trunks on " .. tostring(state.baseIP))
  -- Groups
  HttpClient.Get {
    Url     = string.format("http://%s/api/groups", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/groups => HTTP " .. tostring(code) .. " body=" .. type(body) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      state.groupList = {}
      -- Split the body into per-group segments by locating each
      -- '"group_id":' marker; each segment ends where the next marker
      -- begins (or at end-of-body for the last). Each segment contains
      -- that group's top-level fields (name, color, predefined) before
      -- its nested IGMP/AVB/boundary_clock objects — so simple regex
      -- matches within the segment reliably extract them.
      local positions = {}
      for pos in body:gmatch('()"group_id"%s*:') do
        positions[#positions + 1] = pos
      end
      for i, start in ipairs(positions) do
        local finish = (positions[i + 1] or (#body + 1)) - 1
        local chunk = body:sub(start, finish)
        local gid   = chunk:match('"group_id"%s*:%s*(%d+)')
        local name  = chunk:match('"name"%s*:%s*"([^"]*)"')
        local color = chunk:match('"color"%s*:%s*"(#%x+)"')
        local pre   = chunk:match('"predefined"%s*:%s*(%a+)')
        local vid   = tonumber(chunk:match('"vid"%s*:%s*(%d+)'))
        if gid and color then
          local rgb = parseHexColor(color)
          if rgb then
            local key = "Group: " .. gid
            state.customColors[key] = rgb
            state.groupList[#state.groupList + 1] = {
              id = tonumber(gid),
              name = name or "",
              color = rgb,
              predefined = (pre == "true"),
              vid = vid,
            }
          end
        end
      end
      local ids = {}
      for _, g in ipairs(state.groupList) do ids[#ids+1] = tostring(g.id) end
      log("fetchCustomColors groups parsed (" .. #state.groupList .. "): " .. table.concat(ids, ","))
      for p = 1, state.portCount do renderPortUI(p) end
      for _, g in ipairs(state.groupList) do
        state.groupNames[g.id] = g.name
        SetGroupLabel(g.id, g.name)
      end
      refreshCustomSlots()
      updatePortGroupChoices()
      subscribeGroups()
      subscribeVlanStates()
      refreshQuerierBadges()
    end),
  }

  -- Trunks
  HttpClient.Get {
    Url     = string.format("http://%s/api/trunks", state.baseIP),
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    Timeout = 10,
    EventHandler = counted(function(_tbl, code, body, err)
      log("GET /api/trunks => HTTP " .. tostring(code) .. " body=" .. type(body) .. " " .. tostring(err or ""))
      if code ~= 200 or type(body) ~= "string" then return end
      state.trunkList = {}
      -- Per-trunk segment split by "trunk_id" marker (same approach as
      -- groups above — robust against nested objects in the payload).
      local positions = {}
      for pos in body:gmatch('()"trunk_id"%s*:') do
        positions[#positions + 1] = pos
      end
      for i, start in ipairs(positions) do
        local finish = (positions[i + 1] or (#body + 1)) - 1
        local chunk = body:sub(start, finish)
        local tid   = chunk:match('"trunk_id"%s*:%s*(%d+)')
        local name  = chunk:match('"name"%s*:%s*"([^"]*)"')
        local color = chunk:match('"color"%s*:%s*"(#%x+)"')
        local pre   = chunk:match('"predefined"%s*:%s*(%a+)')
        if tid and color then
          local rgb = parseHexColor(color)
          if rgb then
            local key = "Trunk: " .. tid
            state.customColors[key] = rgb
            state.trunkList[#state.trunkList + 1] = {
              id = tonumber(tid),
              name = name or "",
              color = rgb,
              predefined = (pre == "true"),
            }
          end
        end
      end
      local tids = {}
      for _, t in ipairs(state.trunkList) do tids[#tids+1] = tostring(t.id) end
      log("fetchCustomColors trunks parsed (" .. #state.trunkList .. "): " .. table.concat(tids, ","))
      state.trunkNames = state.trunkNames or {}
      for _, t in ipairs(state.trunkList) do
        state.trunkNames[t.id] = t.name
        SetTrunkLabel(t.id, t.name)
      end
      for p = 1, state.portCount do renderPortUI(p) end
      refreshCustomSlots()
      updatePortGroupChoices()
    end),
  }
end

-- Build the Port.Group ComboBox choices from the live group/trunk lists and
-- assign them to every port's control. Choice strings are formatted as
-- "Group N (name)" / "Trunk N (name)" with "(unassigned)" as a no-op option.
function updatePortGroupChoices()
  local choices = { "(unassigned)" }
  for _, g in ipairs(state.groupList or {}) do
    choices[#choices + 1] = string.format("Group %d (%s)", g.id, g.name or "")
  end
  for _, t in ipairs(state.trunkList or {}) do
    choices[#choices + 1] = string.format("Trunk %d (%s)", t.id, t.name or "")
  end
  for p = 1, state.portCount do
    local c = Controls["Port.Group " .. p]
    if c then c.Choices = choices end
  end
end

-- Resolve a memberOf token ("Group: N" / "Trunk: N") to the friendly
-- name. Prefers state.groupNames / state.trunkNames (kept in sync by both
-- the REST snapshot and WS /groups/group/N/name notifications), then
-- falls back to "Group N" / "Trunk N".
function memberOfDisplayName(memberOf)
  if not memberOf or memberOf == "" then return "" end
  local kind, id = memberOf:match("^(%a+):%s*(%d+)$")
  if not kind or not id then return memberOf end
  local idNum = tonumber(id)
  local map = (kind == "Group") and state.groupNames or state.trunkNames
  local nm = map and map[idNum]
  if nm and nm ~= "" then return nm end
  return string.format("%s %d", kind, idNum)
end

--------------------------------------------------------------------------------
-- WebSocket lifecycle
--------------------------------------------------------------------------------
-- Reconnect backoff: 5 s, doubled after every attempt up to 60 s. Every
-- connect replays the whole subscription burst and two reconciles (~70 % CPU
-- on a 30i when looped every 5 s), so a switch that accepts the socket and
-- drops it is not hammered. A connection that holds 60 s (Connected) and the
-- Connect button (connectToSwitch) bring it back to 5 s.
state.reconnectDelay = state.reconnectDelay or 5

function scheduleReconnect()
  if state.reconnectTimer then return end
  local delay = state.reconnectDelay
  state.reconnectDelay = math.min(delay * 2, 60)
  state.reconnectTimer = Timer.New()
  state.reconnectTimer.EventHandler = function()
    state.reconnectTimer:Stop()
    state.reconnectTimer = nil
    if state.baseIP and state.baseIP ~= "" then openWS(state.baseIP) end
  end
  state.reconnectTimer:Start(delay)
end

function openWS(ip)
  state.baseIP = ip

  if state.reconnectTimer then
    state.reconnectTimer:Stop()
    state.reconnectTimer = nil
  end
  if state.ws then
    local old = state.ws
    state.ws = nil
    pcall(function() old:Close() end)
  end

  state.ws = WebSocket.New()
  local thisWs = state.ws

  state.ws.Connected = function()
    log("WebSocket Connected")
    -- The subscription burst, /api/device and /api/power refill these.
    state.modelMismatch, state.psuStates, state.fanStates = nil, {}, {}
    -- A new socket has no VLAN subscriptions; /api/groups writes them again.
    -- The redraws blank a previous switch's querier and MR badges (an IP change
    -- supersedes the old socket without its Closed, so clearPortCards did not run).
    state.querierByVid, state.routerPortsByVid, state.vlanSubscribed = {}, {}, {}
    state.lagRoleSubscribed, state.groupSubscribed, state.poeSubscribed = {}, {}, false
    refreshQuerierBadges()
    refreshMrPorts()
    -- Same reason for the neighbors: Fill or -> Legend must never write a
    -- previous switch's neighbor to this one (the subscription answer refills).
    closeLldpPanel()
    clearLldp()
    SetConnection("online")
    local ok, err = pcall(function()
      updateAuthStatus("Authenticated", "#00A000")
      subscribeAllPorts()
      subscribeAllSystem()
      SetDeviceStatus("online")
      fetchDeviceInfo()
    end)
    if not ok then log("Connected handler error (subscriptions): " .. tostring(err)) end
    -- The follow-up reconcile and the backoff reset belong to this socket:
    -- skipped once it has closed or been superseded.
    local function stillOnline() return state.ws == thisWs and state.connection == "online" end
    ok, err = pcall(function()
      reconcileAll()
      Timer.CallAfter(function() if stillOnline() then reconcileIfIdle() end end, 3)
      Timer.CallAfter(function() if stillOnline() then state.reconnectDelay = 5 end end, 60)
      startPollTimer()
    end)
    if not ok then log("Connected handler error (reconcile): " .. tostring(err)) end
  end

  state.ws.Data = function(_, data)
    if state.verboseWs then log("Data: " .. tostring(data)) end
    if data:find('"api_notification"') then
      parseNotification(data)
    end
  end

  state.ws.Error = function(_, err)
    if state.ws ~= thisWs then return end  -- superseded socket
    log("WebSocket Error: " .. (err or "none"))
    stopPollTimer()
    if err and err:find("unauthorized") then
      updateAuthStatus("Auth failed", "#C80000")
      SetConnection("unauthorized")
    else
      SetConnection("offline")
    end
    SetDeviceStatus("offline")
    clearPortCards()
    scheduleReconnect()
  end

  state.ws.Closed = function()
    if state.ws ~= thisWs then return end  -- superseded socket
    log("WebSocket Closed")
    stopPollTimer()
    -- A close after an auth failure keeps the Fault.
    if state.connection ~= "unauthorized" then SetConnection("offline") end
    SetDeviceStatus("offline")
    clearPortCards()
    scheduleReconnect()
  end

  local user = Controls["Auth.Username"] and Controls["Auth.Username"].String or ""
  local pass = Controls["Auth.Password"] and Controls["Auth.Password"].String or ""
  local headers = {}
  if user ~= "" and pass ~= "" then
    local token = Crypto.Base64Encode(user .. ":" .. pass)
    headers["Authorization"] = "Basic " .. token
  end

  log("Connecting => ws://" .. ip .. "/api/ws on port 80")
  state.ws:Connect("ws", ip, "api/ws", 80, nil, headers)
end

--------------------------------------------------------------------------------
-- Device info formatting
--------------------------------------------------------------------------------
-- Display.Model is transparent at layout time so its static offline
-- placeholder (the model name) shows through. Paint it opaque when live
-- data lands so it covers the placeholder. The other device-info boxes have
-- no placeholder and stay transparent.
function paintHeaderBox(ctrl)
  local theme = getThemeColors()
  pcall(function() ctrl.Color = rgbHex(theme.pageBg) end)
end

-- Display line "<ip>/<prefix> (<mode>)"; the raw values are the
-- Device.Actual IP.* and IP Settings.Mode pins (handleDevicePath).
function updateIPinfo()
  local ip   = (state.currentIP    ~= "" and state.currentIP)    or "???"
  local pref = (state.prefixLength ~= "" and state.prefixLength) or "??"
  local mode = (state.ipMode       ~= "" and state.ipMode)       or "???"
  local combined = string.format("%s/%s (%s)", ip, pref, mode)
  if Controls["Display.IP Info"] then
    Controls["Display.IP Info"].String = combined
  end
end

-- Device.Actual IP.Default Gateway gets the raw value (0.0.0.0 included).
-- The display line stays blank while the switch has no gateway, which the
-- API reports as 0.0.0.0.
function updateGateway(ip)
  if not ip then return end
  setPinString("Device.Actual IP.Default Gateway", ip)
  local ctrl = Controls["Display.Gateway"]
  if not ctrl then return end
  ctrl.String = (ip ~= "" and ip ~= "0.0.0.0") and ("Gateway " .. ip) or ""
end

-- Single line: the boxes are one row tall, a wrapped second line was cut.
function formatDeviceName(rawName)
  return rawName
end

function formatDeviceDesc(rawDesc)
  return rawDesc
end

-- MAC and firmware boxes are the pins: blank until known.
function updateMac_Firmware()
  for name, value in pairs({ ["Device.MAC Address"]     = state.macAddress,
                             ["Device.Firmware.Active"] = state.firmwareVersion }) do
    local ctrl = Controls[name]
    if ctrl then ctrl.String = value or "" end
  end
end

function updateAuthStatus(text, color)
  local ctrl = Controls["Auth.Status"]
  if not ctrl then return end
  ctrl.String = text
  ctrl.Color  = (text ~= "") and (color or "#800000") or "#00000000"
end

--------------------------------------------------------------------------------
-- Group layout helpers (data-driven — called from WS handlers)
--------------------------------------------------------------------------------
function layoutGroupBlock(index)
  local baseX, baseY = 0, 0
  local paddingX, paddingY = 10, 10
  local blockW, blockH = 100, 50
  local gridCols = 4

  if index <= 20 then
    local col = (index - 1) % gridCols
    local row = math.floor((index - 1) / gridCols)
    return baseX + col * (blockW + paddingX),
           baseY + row * (blockH + paddingY)
  else
    local colOffset = index - 21
    return baseX + gridCols * (blockW + paddingX) + colOffset * (blockW + paddingX),
           baseY
  end
end

function createGroupLayout()
  for groupId = 1, 20 do
    if state.groupMeta and state.groupMeta[groupId] then
      local _x, _y = layoutGroupBlock(groupId)
    end
  end
end

--------------------------------------------------------------------------------
-- WebSocket notification parser
--------------------------------------------------------------------------------
function extractPath(raw)   return raw:match('"path"%s*:%s*"([^"]+)"') end
function extractString(raw) return raw:match('"new_value"%s*:%s*"([^"]+)"') end
function extractNumber(raw) return raw:match('"new_value"%s*:%s*(%d+)') end
function extractSignedNumber(raw) return raw:match('"new_value"%s*:%s*(-?%d+)') end
function extractBool(raw)   return raw:match('"new_value"%s*:%s*(%a+)') end

function handleDevicePath(path, raw)
  if path == "/device/name" then
    local v = extractString(raw)
    if v and Controls["Device.Name"] then
      Controls["Device.Name"].String = formatDeviceName(v)
    end
    return true
  end

  if path == "/device/description" then
    local v = extractString(raw)
    if v and Controls["Device.Description"] then
      Controls["Device.Description"].String = formatDeviceDesc(v)
    end
    return true
  end

  if path == "/device/mac_address" then
    local v = extractString(raw)
    if v then state.macAddress = v; updateMac_Firmware() end
    return true
  end

  if path == "/device/firmware/active" then
    local v = extractString(raw)
    if v then state.firmwareVersion = v; updateMac_Firmware() end
    return true
  end

  if path == "/device/hostname" then
    local v = raw:match('"new_value"%s*:%s*"([^"]*)"')
    if v then setPinString("Device.Hostname", v) end
    return true
  end

  if path == "/device/actual_ip/ip_address" then
    local v = extractString(raw)
    if v then
      state.currentIP = v
      setPinString("Device.Actual IP.IP Address", v)
      updateIPinfo()
    end
    return true
  end

  if path == "/device/actual_ip/prefix_length" then
    local v = extractNumber(raw)
    if v then
      state.prefixLength = v
      setPinValue("Device.Actual IP.Prefix Length", v)
      updateIPinfo()
    end
    return true
  end

  if path == "/device/actual_ip/default_gateway" then
    updateGateway(extractString(raw))
    return true
  end

  if path == "/ip_settings/mode" then
    local v = extractString(raw)
    if v then
      state.ipMode = v
      setPinString("IP Settings.Mode", v)
      updateIPinfo()
    end
    return true
  end

  return false
end

function handleGroupPath(path, raw)
  local gid, field = path:match("^/groups/group/(%d+)/(.+)$")
  if not gid then return false end
  gid = tonumber(gid)

  if field == "name" then
    local name = extractString(raw)
    if name then
      state.groupNames = state.groupNames or {}
      state.groupNames[gid] = name
      SetGroupLabel(gid, name)
      -- Refresh every port row so the Group display shows the new name.
      for p = 1, (state.portCount or 0) do renderPortUI(p) end
    end
    return true
  end

  if field == "group_id" then
    local v = extractNumber(raw)
    if v then
      state.groupMeta = state.groupMeta or {}
      state.groupMeta[gid] = state.groupMeta[gid] or {}
      state.groupMeta[gid].id = tonumber(v)

      updateGroupUI(gid)
      SetGroupLabel(gid, state.groupNames[gid] or ("Group " .. gid))
      createGroupLayout()
    end
    return true
  end

  return false
end

function handlePortPath(path, raw)
  local port = path:match("/ports/port/(%d+)/")
              or path:match("/poe/ports/(%d+)/")
              or path:match("/rlinkx/ports/(%d+)/")
  if not port then return false end
  port = tonumber(port)

  if path == ("/ports/port/" .. port .. "/enabled") then
    local v = extractBool(raw)
    if v then SetPortEnabled(port, v == "true") end
    return true
  end

  if path == ("/ports/port/" .. port .. "/legend") then
    -- Decoded (quotes, backslashes); an emptied legend ("") lands too.
    local v = lldpJsonString(raw, "new_value")
    if v then SetPortLegend(port, v) end
    return true
  end

  if path == ("/ports/port/" .. port .. "/link_state") then
    local v = extractString(raw)
    if v then SetPortLinkState(port, v) end
    return true
  end

  if path == ("/ports/port/" .. port .. "/member_of") then
    local obj = raw:match('"new_value"%s*:%s*{(.-)}')
    if obj then
      local t  = obj:match('"type"%s*:%s*"([^"]+)"')
      local id = obj:match('"id"%s*:%s*(%d+)')
      if t and id then
        SetPortMemberOf(port, t == "trunk" and ("Trunk: " .. id) or ("Group: " .. id))
      elseif t == "none" then
        SetPortMemberOf(port, nil)
      end
    else
      local v = extractString(raw)
      if v then SetPortMemberOf(port, v) end
    end
    return true
  end

  if path == ("/poe/ports/" .. port .. "/indication") then
    -- "" is a real value (web UI: same grey as disabled), unlike extractString.
    local v = raw:match('"new_value"%s*:%s*"([^"]*)"')
    if v then SetPortIndication(port, v) end
    return true
  end

  if path == ("/poe/ports/" .. port .. "/enabled") then
    local v = extractBool(raw)
    if v then SetPortPoeEnabled(port, v == "true") end
    return true
  end

  if path == ("/ports/port/" .. port .. "/rlinkx") then
    -- Per-port config: {"enabled": true/false}. We only learn disabled vs
    -- enabled here; the "active" (redundant) state comes from /rlinkx/ports/N/state.
    local obj = raw:match('"new_value"%s*:%s*{(.-)}')
    if obj then
      SetPortRlinkxEnabled(port, obj:match('"enabled"%s*:%s*(%a+)') == "true")
    end
    return true
  end

  if path == ("/rlinkx/ports/" .. port .. "/state") then
    -- State machine values: disabled, non-redundant, redundant,
    -- partial-redundant, invalid-version
    local v = extractString(raw)
    if v then SetPortRlinkxState(port, v) end
    return true
  end

  if path:find("/link_speed") then
    -- new_value is {"mode":..,"speed":[..]}, {"speed":[..]} when only the
    -- speed changed, a bare "fixed" on the /link_speed/mode sub-path or a
    -- bare [..] on /link_speed/speed. The Link Speed pins take each field
    -- as it comes; the displayed label depends on the speed alone ("all" =
    -- Auto).
    local mode, list
    if path:find("/link_speed/mode$") then
      mode = raw:match('"new_value"%s*:%s*"([^"]*)"')
    elseif path:find("/link_speed/speed$") then
      list = speedListFromArray(raw:match('"new_value"%s*:%s*(%b[])'))
    else
      local obj = raw:match('"new_value"%s*:%s*(%b{})')
      if obj then
        mode = obj:match('"mode"%s*:%s*"([^"]*)"')
        list = speedListFromArray(obj:match('"speed"%s*:%s*(%b[])'))
      end
    end
    if mode or list then SetPortLinkSpeedFields(port, mode, list) end

    local speed = raw:match('"speed"%s*:%s*%[%s*"([^"]+)"')
    if not speed and path:find("/link_speed/speed$") then
      speed = raw:match('"new_value"%s*:%s*%[%s*"([^"]+)"')
    end
    if speed then
      SetPortSpeed(port, (speed == "all") and "Auto" or speed)
    end
    return true
  end

  return false
end

function parseNotification(raw)
  if state.verboseWs then log("parseNotification => " .. raw) end
  local path = extractPath(raw)
  if not path then return end
  if handleDevicePath(path, raw)       then return end
  if handleGroupPath(path, raw)        then return end
  if handleLldpPath(path, raw)         then return end
  if path:find("^/ports/lags/lag")     then scheduleLagSync() return end
  if handlePortPath(path, raw)         then return end
  if handleSystemPath(path, raw)       then return end
  if handleFanPath(path, raw)          then return end
  if handlePowerPath(path, raw)        then return end
  if handleSpanningTreePath(path, raw) then return end
  if handleSnoopingPath(path, raw)     then return end
end

--------------------------------------------------------------------------------
-- Port state setters (STATE → UI)
--------------------------------------------------------------------------------
-- Raw link_state ("1gbps fdx", "100mbps hdx", "down", "unknown").
function SetPortLinkState(port, raw)
  getPortState(port).linkState = raw
  renderPortUI(port)
end

function SetPortEnabled(port, enabled)
  getPortState(port).enabled = enabled
  renderPortUI(port)
end

function SetPortMemberOf(port, textVal)
  local p = getPortState(port)
  p.memberOf = textVal
  p.memberOfKnown = true
  renderPortUI(port)
end

function SetPortIndication(port, textVal)
  getPortState(port).poe = textVal
  renderPortUI(port)
end

-- RLinkX state machine value (/rlinkx/ports/N/state, GET /api/rlinkx):
-- disabled, non-redundant, redundant, partial-redundant, invalid-version.
-- The card's jack border shows it; it does not change the enabled pin.
function SetPortRlinkxState(port, raw)
  getPortState(port).rlinkxState = raw
  renderPortUI(port)
end

-- Per-port RLinkX config flag (/ports/port/N/rlinkx, GET /api/ports), the
-- Ports.Port N.RLinkX.Enabled pin.
function SetPortRlinkxEnabled(port, enabled)
  getPortState(port).rlinkxEnabled = enabled
  renderPortUI(port)
end

function SetPortLegend(port, value)
  getPortState(port).legend = value
  setPinString("Ports.Port " .. port .. ".Legend", value)
end

-- Raw link_speed fields for the Link Speed pins; nil leaves a field as is.
function SetPortLinkSpeedFields(port, mode, speedList)
  local p = getPortState(port)
  if mode then p.linkSpeedMode = mode end
  if speedList then p.linkSpeedList = speedList end
  renderPortUI(port)
end

function SetPortSpeed(port, label)
  local p = getPortState(port)
  p.speed          = SPEED_UI_MAP[label] or label
  p.lastValidSpeed = p.speed
  p.speedPending   = false
  renderPortUI(port)
end

function SetPortPoeEnabled(port, enabled)
  getPortState(port).poeEnabled = enabled
  renderPortUI(port)
end

--------------------------------------------------------------------------------
-- System / chassis setters
--------------------------------------------------------------------------------
local function setCtrlString(name, value)
  local c = Controls[name]
  if c then c.String = value end
end

local function setCtrlColor(name, color)
  local c = Controls[name]
  if c then c.Color = color end
end

-- Raw integer pins (degrees C, rpm, %, mW); a sensor, fan or PSU slot the
-- model lacks has no control and is skipped.
function SetCaseTemp(v)
  setPinValue("Temperatures.Case.Current", v)
end

function SetCpuTemp(v)
  setPinValue("Temperatures.CPU.Current", v)
end

function SetFanSpeed(id, v)
  setPinValue("Fans.Fan " .. id .. ".Speed", v)
end

-- PSU icon tinted by state, as the switch web UI draws it. The color lives
-- in the SVG itself, pushed through the Button Legend as EzSVG does
-- ({DrawChrome=false, IconData=<base64 svg>}). Same paths as LogoPSU (the
-- grey offline placeholder drawn under the control), no background, no
-- clip-path: Designer rendered the Inkscape export's clipped paths as a
-- plain dark square, and runtime StrokeColor writes never showed.
local PSU_ICON_COLORS = {
  good = "#00C800", ok = "#00C800", redundant = "#00C800",
  warning = "#E6B400", absent = "#5A6478", [""] = "#5A6478",
}

local function psuIconSvg(color)
  return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 9.9727 9.9668\"><g transform=\"matrix(0.37100573,0,0,-0.37078499,8.72601,0)\"><path fill=\"" .. color .. "\" d=\"m 0,0 h -20.16 c -1.854,-0.006 -3.354,-1.506 -3.36,-3.36 v -15.12 c 0.006,-1.854 1.506,-3.354 3.36,-3.36 h 5.04 v 3.36 h -5.04 v 15.12 h 1.68 V -8.4 h 3.36 v 5.04 h 3.36 V -8.4 h 3.36 v 5.04 h 3.36 V -8.4 h 3.36 v 5.04 H 0 v -15.12 h -5.04 v -3.36 H 0 c 1.854,0.006 3.354,1.506 3.36,3.36 V -3.36 C 3.354,-1.506 1.854,-0.006 0,0\"/></g><g transform=\"matrix(0.37100573,0,0,-0.37078499,5.84222,4.36055)\"><path fill=\"" .. color .. "\" d=\"m 0,0 h -4.332 l -2.734,-6.72 h 3.444 l -2.928,-8.4 8.194,11.76 h -3.552 z\"/></g></svg>"
end

-- PSU state (good / warning / error / invalid, "" for an empty slot): the
-- pin and the status-block icon tint. power_status is a separate pin and
-- does not touch the icon.
function SetPsuState(id, value)
  setPinString("Power.PSU " .. id .. ".State", value)
  state.psuStates[id] = value
  refreshStatus()
  local icon = Controls["PSU." .. id .. " Icon"]
  if not icon then return end
  local svg = psuIconSvg(PSU_ICON_COLORS[value or ""] or "#DC2828")
  icon.Legend = '{"DrawChrome":false,"IconData":"' .. Crypto.Base64Encode(svg) .. '","Legend":""}'
end

function SetPsuPowerStatus(id, value)
  setPinString("Power.PSU " .. id .. ".Power Status", value)
end

function SetPsuPower(id, milliwatts)
  setPinValue("Power.PSU " .. id .. ".Power Usage", milliwatts)
end

function SetTotalPower(milliwatts)
  setPinValue("Power.Total Power Usage", milliwatts)
end

function SetTotalPowerMax(milliwatts)
  setPinValue("Power.Total Power Max", milliwatts)
end

-- Switch-wide RLinkX flag (/rlinkx/enabled, GET /api/rlinkx).
function SetRlinkxEnabled(value)
  setPinBoolean("RLinkX.Enabled", value)
end

-- Coupling indicator between the two PSU icons, as the switch web UI draws
-- it: "▼▲" in redundant mode, "⊕" in shared mode, the glyph itself colored
-- by the coupling state (green good, amber warning, red otherwise, the PSU
-- icon palette) on the screen background. Drawn as an SVG through the Button
-- Legend like the PSU icons; the viewBox is the 48 x 14 box minus the 2 px
-- Button inset. With a PSU slot empty (state.psuMissing, from /api/power) the
-- switch reports "No redundancy because only 1 PSU is powered" as a coupling
-- warning; the plugin keeps that one green.
state.couplingMode  = state.couplingMode  or ""
state.couplingState = state.couplingState or "good"
state.psuMissing    = state.psuMissing    or false

local function couplingGlyphSvg(mode, color)
  local body
  if mode == "redundant" then
    body = '<path d="M13,1 H21 L17,9 Z" fill="' .. color .. '"/><path d="M23,9 H31 L27,1 Z" fill="' .. color .. '"/>'
  elseif mode == "shared" then
    body = '<circle cx="22" cy="5" r="4" fill="none" stroke="' .. color .. '" stroke-width="1.5"/>'
      .. '<path d="M18,5 H26 M22,1 V9" stroke="' .. color .. '" stroke-width="1.5"/>'
  else
    return nil
  end
  return '<svg xmlns="http://www.w3.org/2000/svg" width="44" height="10" viewBox="0 0 44 10">' .. body .. '</svg>'
end

local function refreshCoupling()
  local c = Controls["Power.Coupling Glyph"]
  if not c then return end
  local color = "#DC2828"
  if state.couplingState == "good" or state.psuMissing then color = PSU_ICON_COLORS.good
  elseif state.couplingState == "warning" then color = PSU_ICON_COLORS.warning
  end
  local svg = couplingGlyphSvg(state.couplingMode, color)
  c.Legend = svg and iconLegend(svg) or ""
end

function SetPowerCoupling(mode)
  state.couplingMode = mode or ""
  setPinString("Power.Coupling.Mode", state.couplingMode)
  refreshCoupling()
end

function SetCouplingState(status)
  state.couplingState = status or "good"
  refreshCoupling()
end

-- CPU load averaged over 3 s (cpu_load) and 30 s (cpu_load_long), in %.
function SetCpuLoad(v)
  setPinValue("System.CPU Load", v)
end

function SetCpuLoadLong(v)
  setPinValue("System.CPU Load Long", v)
end

function SetBridgePriority(v)
  setCtrlString("RSTP.Bridge Priority", tostring(v))
end

state.bridgeAddr     = state.bridgeAddr     or ""
state.rootBridgeAddr = state.rootBridgeAddr or ""
state.rootBridgePri  = state.rootBridgePri  or ""

-- "this switch" when the root bridge address is our own bridge address
-- (REST-only field, never changes), otherwise "<mac> (<priority>)".
local function refreshRootBridge()
  if state.rootBridgeAddr == "" and state.rootBridgePri == "" then return end
  if state.bridgeAddr ~= "" and state.rootBridgeAddr == state.bridgeAddr then
    setCtrlString("RSTP.Root Bridge", "this switch")
  else
    local addr = state.rootBridgeAddr ~= "" and state.rootBridgeAddr or "??"
    local pri  = state.rootBridgePri  ~= "" and state.rootBridgePri  or "?"
    setCtrlString("RSTP.Root Bridge", string.format("%s (%s)", addr, pri))
  end
end

function SetBridgeAddress(addr)
  state.bridgeAddr = addr or ""
  refreshRootBridge()
end

function SetRootBridgeAddress(addr)
  state.rootBridgeAddr = addr or ""
  refreshRootBridge()
end

function SetRootBridgePriority(pri)
  state.rootBridgePri = tostring(pri or "")
  refreshRootBridge()
end

-- RSTP role per port; "root" and "alternate" are drawn as the Araneo "root" /
-- "alt" badges inside the port card (portCardView rstpRole). A LAG port's
-- role (66 and up) is drawn on its members.
function SetPortRstpRole(port, role)
  local p = getPortState(port)
  if p.rstpRole == role then return end
  p.rstpRole = role
  renderPortUI(port)
  for _, member in ipairs(state.lagMembers[port] or {}) do renderPortUI(member) end
end

-- The per-port role subscriptions cover the chassis ports only: each LAG port
-- from /api/ports/lags/lag gets its own, once per socket.
function subscribeLagRoles()
  if not state.ws then return end
  for lagPort in pairs(state.lagMembers) do
    if not state.lagRoleSubscribed[lagPort] then
      state.lagRoleSubscribed[lagPort] = true
      state.ws:Write(string.format(
        '{"subscription":{"path":"/spanning_tree/mst/0/ports/%d/role","action":"add","method":"changes"}}', lagPort))
    end
  end
end

-- IGMP snooping router ports: like Araneo, a port is MR when it, or the LAG
-- it is a member of, is a router port in any group VLAN
-- (state.routerPortsByVid, one WS subscription per vid); the MR badge is
-- drawn inside the port card.
function refreshMrPorts()
  local routerPorts = {}
  for _, ports in pairs(state.routerPortsByVid) do
    for _, port in ipairs(ports) do routerPorts[port] = true end
  end
  for port = 1, state.portCount do
    local p = getPortState(port)
    local lag = state.lagOf[port]
    local mr = routerPorts[port] == true or (lag ~= nil and routerPorts[lag] == true)
    if p.mr ~= mr then
      p.mr = mr
      renderPortUI(port)
    end
  end
end

--------------------------------------------------------------------------------
-- WS path handlers for system/power/fans/spanning_tree/snooping
--------------------------------------------------------------------------------
-- Temperatures can be negative: matched with a sign. The case temperature
-- comes from the case sensor only (/system/temperature/current is the CPU's).
function handleSystemPath(path, raw)
  if path == "/system/cpu_load" then
    local v = extractNumber(raw); if v then SetCpuLoad(v) end
    return true
  end
  if path == "/system/cpu_load_long" then
    local v = extractNumber(raw); if v then SetCpuLoadLong(v) end
    return true
  end
  if path == "/temperatures/temperature/case/current" then
    local v = extractSignedNumber(raw); if v then SetCaseTemp(v) end
    return true
  end
  if path == "/temperatures/temperature/cpu/current" then
    local v = extractSignedNumber(raw); if v then SetCpuTemp(v) end
    return true
  end
  if path == "/rlinkx/enabled" then
    local v = extractBool(raw)
    if v == "true" or v == "false" then SetRlinkxEnabled(v == "true") end
    return true
  end
  return false
end

function handleFanPath(path, raw)
  local id = path:match("^/fans/fan/(%d+)/speed$")
  if id then
    local v = extractNumber(raw); if v then SetFanSpeed(tonumber(id), v) end
    return true
  end
  local id2 = path:match("^/fans/fan/(%d+)/state$")
  if id2 then
    local v = extractString(raw); if v then SetFanState(tonumber(id2), v) end
    return true
  end
  return false
end

function handlePowerPath(path, raw)
  if path == "/power/coupling/mode" then
    local v = extractString(raw); if v then SetPowerCoupling(v) end
    return true
  end
  if path == "/power/coupling/state" then
    local v = extractString(raw); if v then SetCouplingState(v) end
    return true
  end
  if path == "/power/total_power_usage" then
    local v = extractNumber(raw); if v then SetTotalPower(v) end
    return true
  end
  if path == "/power/total_power_max" then
    local v = extractNumber(raw); if v then SetTotalPowerMax(v) end
    return true
  end
  local psu, field = path:match("^/power/psus/(psu%d+)/(.+)$")
  if not psu then return false end
  local id = tonumber(psu:match("(%d+)"))
  if field == "state" then
    local v = extractString(raw); if v then SetPsuState(id, v) end
    return true
  end
  if field == "power_status" then
    local v = extractString(raw); if v then SetPsuPowerStatus(id, v) end
    return true
  end
  if field == "power_usage" then
    -- -1 is the API error marker
    local v = extractSignedNumber(raw); if v then SetPsuPower(id, v) end
    return true
  end
  return false
end

function handleSpanningTreePath(path, raw)
  if path == "/spanning_tree/mst/0/bridge_priority" then
    local v = extractNumber(raw); if v then SetBridgePriority(v) end
    return true
  end
  if path == "/spanning_tree/mst/0/root_bridge_address" then
    local v = extractString(raw); if v then SetRootBridgeAddress(v) end
    return true
  end
  if path == "/spanning_tree/mst/0/root_bridge_priority" then
    local v = extractNumber(raw); if v then SetRootBridgePriority(v) end
    return true
  end
  local port = path:match("^/spanning_tree/mst/0/ports/(%d+)/role$")
  if port then
    local v = extractString(raw); if v then SetPortRstpRole(tonumber(port), v) end
    return true
  end
  return false
end

function handleSnoopingPath(path, raw)
  local routerVid = path:match("^/snooping/vlan/(%d+)/router_ports$")
  if routerVid then
    -- new_value is an array: "new_value":[3,5,7]
    local arr = raw:match('"new_value"%s*:%s*%[(.-)%]')
    local ports = {}
    if arr then
      for n in arr:gmatch("%d+") do ports[#ports+1] = tonumber(n) end
    end
    state.routerPortsByVid[tonumber(routerVid)] = ports
    refreshMrPorts()
    return true
  end
  local vid = path:match("^/snooping/vlan/(%d+)/igmp_querier_state$")
  if vid then
    local v = extractString(raw); if v then SetQuerierState(tonumber(vid), v) end
    return true
  end
  return false
end

--------------------------------------------------------------------------------
-- Device status (with offline pulse)
--------------------------------------------------------------------------------
offlinePulseTimer = nil
pulseOn = false

-- The badge in the left display block and the dot in the right status
-- block (as on the switch web UI) share one color.
local function paintDeviceStatus(color)
  local badge = Controls["Display.Status"]
  if badge then badge.Color = color end
  local dot = Controls["Display.Status Dot"]
  if dot then
    dot.Color = color
    pcall(function() dot.OffColor = color end)
  end
end

function SetDeviceStatus(status)
  local ctrl = Controls["Display.Status"]
  if not ctrl then return end

  if status == "online" then
    if offlinePulseTimer then
      offlinePulseTimer:Stop()
      offlinePulseTimer = nil
    end
    pulseOn = false
    ctrl.String = "Online"
    paintDeviceStatus("#00C800")
  elseif status == "offline" then
    ctrl.String = "Offline"
    if not offlinePulseTimer then
      offlinePulseTimer = Timer.New()
      offlinePulseTimer.EventHandler = function()
        pulseOn = not pulseOn
        paintDeviceStatus(pulseOn and "#C80000" or "#800000")
      end
      offlinePulseTimer:Start(0.5)
    end
  end
end

--------------------------------------------------------------------------------
-- Querier panel (status block, under the RSTP lines): one badge per group this
-- switch is the active IGMP querier for. The state comes only from the WS
-- subscription /snooping/vlan/<vid>/igmp_querier_state, one per group vid
-- learned from /api/groups (it answers with the current value at once). The
-- same vids carry the MR subscriptions /snooping/vlan/<vid>/router_ports.
--------------------------------------------------------------------------------
state.querierByVid     = state.querierByVid or {}      -- vid -> disabled | querier | non-querier
state.routerPortsByVid = state.routerPortsByVid or {}  -- vid -> { router port numbers }
state.vlanSubscribed   = state.vlanSubscribed or {}    -- vid -> true once subscribed on this socket
state.querierSvg       = state.querierSvg or ""        -- last SVG written to Querier.Badges

-- A vid no group uses any more is forgotten (its VLAN is gone, and the switch
-- may drop the subscription with it): a vid that comes back is subscribed
-- again and shows no stale state.
function subscribeVlanStates()
  local used = {}
  for _, g in ipairs(state.groupList) do
    if g.vid then used[g.vid] = true end
  end
  for vid in pairs(state.vlanSubscribed) do
    if not used[vid] then state.vlanSubscribed[vid] = nil end
  end
  for vid in pairs(state.querierByVid) do
    if not used[vid] then state.querierByVid[vid] = nil end
  end
  local forgotRouterPorts = false
  for vid in pairs(state.routerPortsByVid) do
    if not used[vid] then
      state.routerPortsByVid[vid] = nil
      forgotRouterPorts = true
    end
  end
  if forgotRouterPorts then refreshMrPorts() end
  if not state.ws then return end
  for _, g in ipairs(state.groupList) do
    if g.vid and not state.vlanSubscribed[g.vid] then
      state.vlanSubscribed[g.vid] = true
      state.ws:Write(string.format(
        '{"subscription":{"path":"/snooping/vlan/%d/igmp_querier_state","action":"add","method":"changes"}}', g.vid))
      state.ws:Write(string.format(
        '{"subscription":{"path":"/snooping/vlan/%d/router_ports","action":"add","method":"changes"}}', g.vid))
    end
  end
end

-- The subscription answers arrive one vid at a time: one redraw per burst.
function SetQuerierState(vid, value)
  state.querierByVid[vid] = value
  if state.querierRefreshPending then return end
  state.querierRefreshPending = true
  Timer.CallAfter(function()
    state.querierRefreshPending = false
    refreshQuerierBadges()
  end, 0.2)
end

function refreshQuerierBadges()
  local list = {}
  for _, g in ipairs(state.groupList) do
    if g.vid and state.querierByVid[g.vid] == "querier" then
      list[#list + 1] = { id = g.id, color = rgbHex(g.color) }
    end
  end
  table.sort(list, function(a, b) return a.id < b.id end)
  local svg = querierBadgesSvg(list, rgbHex(getThemeColors().textMuted))
  if svg == state.querierSvg then return end
  state.querierSvg = svg
  Controls["Querier.Badges"].Legend = svg == "" and "" or iconLegend(svg)
end

--------------------------------------------------------------------------------
-- Status pin: the Q-SYS status indicator (outside the API), wireable to a
-- Monitoring Proxy or a Status Combiner. state.connection is noip,
-- connecting, online, offline or unauthorized; once online, a model mismatch
-- or a PSU / fan not good makes it Compromised. Reconnect attempts keep the
-- offline / unauthorized state (no flapping through Initializing).
--------------------------------------------------------------------------------
local STATUS_VALUES = { ok = 0, compromised = 1, fault = 2, missing = 4, initializing = 5 }

-- state.modelMismatch: "Switch is <model>" while the Model property differs.
state.connection = state.connection or "noip"
state.psuStates  = state.psuStates or {}
state.fanStates  = state.fanStates or {}

function refreshStatus()
  local ctrl = Controls["Status"]
  if not ctrl then return end
  local kind, text
  if state.connection == "noip" then
    kind, text = "fault", "No IP address"
  elseif state.connection == "unauthorized" then
    kind, text = "fault", "Authentication failed"
  elseif state.connection == "connecting" then
    kind, text = "initializing", "Connecting"
  elseif state.connection == "offline" then
    kind, text = "missing", "Offline"
  else
    local problems = {}
    if state.modelMismatch then problems[#problems + 1] = state.modelMismatch end
    for id = 1, 2 do
      local value = state.psuStates[id]
      if value and value ~= "" and value ~= "good" then
        problems[#problems + 1] = "PSU " .. id .. " " .. value
      end
    end
    for id = 1, 3 do
      local value = state.fanStates[id]
      if value and value ~= "" and value ~= "good" then
        problems[#problems + 1] = "Fan " .. id .. " " .. value
      end
    end
    if #problems > 0 then
      kind, text = "compromised", table.concat(problems, ", ")
    else
      kind, text = "ok", "Connected"
    end
  end
  ctrl.Value  = STATUS_VALUES[kind]
  ctrl.String = text
end

function SetConnection(connection)
  state.connection = connection
  refreshStatus()
end

function SetFanState(id, value)
  state.fanStates[id] = value
  refreshStatus()
end

--------------------------------------------------------------------------------
-- Group label (color + badge)
--------------------------------------------------------------------------------
-- Custom groups (id > 20) and custom trunks (id > 1) live in reserved slots
-- assigned in id order by refreshCustomSlots(). state.customGroupSlot /
-- state.customTrunkSlot map id → slot control index.
function groupSlotFor(groupId)
  if groupId <= 20 then return groupId end
  return state.customGroupSlot and state.customGroupSlot[groupId]
end

function trunkSlotFor(trunkId)
  if trunkId == 1 then return 1 end
  return state.customTrunkSlot and state.customTrunkSlot[trunkId]
end

function refreshCustomSlots()
  state.customGroupSlot = {}
  state.customTrunkSlot = {}

  local customs = {}
  for _, g in ipairs(state.groupList or {}) do
    if g.id and not g.predefined then customs[#customs + 1] = g end
  end
  table.sort(customs, function(a, b) return a.id < b.id end)
  for i = 1, CUSTOM_GROUP_SLOTS do
    local slot  = 20 + i
    local ctrl  = Controls["group_label_" .. slot]
    local badge = Controls["group_id_badge_" .. slot]
    local g = customs[i]
    if g then
      state.customGroupSlot[g.id] = slot
      if ctrl then
        ctrl.String = g.name or ""
        ctrl.Color  = rgbHex(g.color)
        pcall(function() ctrl.IsInvisible = false end)
      end
      if badge then
        badge.String = tostring(g.id)
        badge.Color  = "#1A2238"
        pcall(function() badge.IsInvisible = false end)
      end
    else
      if ctrl then
        ctrl.String = ""
        ctrl.Color  = "#00000000"
        pcall(function() ctrl.IsInvisible = true end)
      end
      if badge then
        badge.String = ""
        badge.Color  = "#00000000"
        pcall(function() badge.IsInvisible = true end)
      end
    end
  end

  local trunks = {}
  for _, t in ipairs(state.trunkList or {}) do
    if t.id and not t.predefined then trunks[#trunks + 1] = t end
  end
  table.sort(trunks, function(a, b) return a.id < b.id end)
  for i = 1, CUSTOM_TRUNK_SLOTS do
    local slot  = 1 + i
    local ctrl  = Controls["trunk_label_" .. slot]
    local badge = Controls["trunk_id_badge_" .. slot]
    local t = trunks[i]
    if t then
      state.customTrunkSlot[t.id] = slot
      if ctrl then
        ctrl.String = t.name or ""
        ctrl.Color  = rgbHex(t.color)
        pcall(function() ctrl.IsInvisible = false end)
      end
      if badge then
        badge.String = tostring(t.id)
        badge.Color  = "#1A2238"
        pcall(function() badge.IsInvisible = false end)
      end
    else
      if ctrl then
        ctrl.String = ""
        ctrl.Color  = "#00000000"
        pcall(function() ctrl.IsInvisible = true end)
      end
      if badge then
        badge.String = ""
        badge.Color  = "#00000000"
        pcall(function() badge.IsInvisible = true end)
      end
    end
  end
end

function SetGroupLabel(groupId, name)
  local slot = groupSlotFor(groupId)
  if not slot then return end  -- custom group not placed yet; refreshCustomSlots will
  local ctrl = Controls["group_label_" .. slot]
  if not ctrl then return end

  ctrl.String = name

  local key = "Group: " .. groupId
  local color = (state.customColors and state.customColors[key]) or GROUP_COLORS[key]
  if color then
    ctrl.Color = rgbHex(color)
  else
    ctrl.Color = "#00000000"
  end

  local badgeCtrl = Controls["group_id_badge_" .. slot]
  if badgeCtrl then
    badgeCtrl.String = tostring(groupId)
    badgeCtrl.Color  = "#1A2238"
  end
end

function SetTrunkLabel(trunkId, name)
  local slot = trunkSlotFor(trunkId)
  if not slot then return end
  local ctrl = Controls["trunk_label_" .. slot]
  if not ctrl then return end

  ctrl.String = name

  local key = "Trunk: " .. trunkId
  local color = state.customColors and state.customColors[key]
  if color then
    ctrl.Color = rgbHex(color)
  else
    ctrl.Color = "#00000000"
  end

  local badgeCtrl = Controls["trunk_id_badge_" .. slot]
  if badgeCtrl then
    badgeCtrl.String = tostring(trunkId)
    badgeCtrl.Color  = "#1A2238"
  end
end

function updateGroupUI(groupId)
  -- Controls repaint themselves when their properties change; nothing to do.
end

--------------------------------------------------------------------------------
-- Group picker panel (main page): opened by a Port.Group cell click, lists
-- every group and trunk slot (the same slots as the Groups and Trunks page)
-- and PUTs the pick to /api/ports/port/N/member_of. The zPicker.* controls
-- are declared in controls.lua and placed by buildGroupPickerPanel
-- (layout.lua); everything here runs at runtime only.
--------------------------------------------------------------------------------
PICKER_SECTION_TITLES = { "Groups", "Custom groups", "Trunks", "Custom trunks" }

local function pickerControlNames()
  local names = { "zPicker.Bg", "zPicker.Title", "zPicker.None", "zPicker.Cancel" }
  for i = 1, #PICKER_SECTION_TITLES do names[#names + 1] = "zPicker.Label " .. i end
  for i = 1, 20 + CUSTOM_GROUP_SLOTS do names[#names + 1] = "zPicker.Group " .. i end
  for i = 1, 1 + CUSTOM_TRUNK_SLOTS do names[#names + 1] = "zPicker.Trunk " .. i end
  return names
end

-- Pickers, LLDP buttons. Hiding also blanks the control: Designer keeps the
-- last runtime Legend and String when the design goes offline but resets
-- IsInvisible, so any leftover text would paint over the page through the
-- transparent button.
function setOverlayVisible(name, visible)
  local ctrl = Controls[name]
  if not ctrl then return end
  pcall(function() ctrl.IsInvisible = not visible end)
  if not visible then
    pcall(function() ctrl.Legend = "" end)
    pcall(function() ctrl.String = "" end)
    pcall(function() ctrl.Color = "#00000000" end)
    pcall(function() ctrl.OffColor = "#00000000" end)
  end
end

function closeGroupPicker()
  state.pickerPort = nil
  for _, name in ipairs(pickerControlNames()) do setOverlayVisible(name, false) end
end

-- One picker button: Legend = name (check mark on the port's current
-- membership), fill = the group/trunk color.
local function paintPickerItem(name, label, hex, isCurrent)
  local ctrl = Controls[name]
  if not ctrl then return end
  ctrl.Legend = isCurrent and (label .. " ✓") or label
  ctrl.Color  = hex
  pcall(function() ctrl.OffColor = hex end)
  setOverlayVisible(name, true)
end

local function memberColorHex(key)
  local color = (state.customColors and state.customColors[key]) or GROUP_COLORS[key]
  return color and rgbHex(color) or PICKER_UNASSIGNED_HEX
end

function openGroupPicker(port)
  if state.baseIP == "" then return end
  closeLldpPanel()
  state.pickerPort = port
  local current = getPortState(port).memberOf
  local theme   = getThemeColors()

  -- slot → id for every section (custom sections: inverse of refreshCustomSlots)
  state.pickerSlotGroupId = {}
  state.pickerSlotTrunkId = {}
  for i = 1, 20 do state.pickerSlotGroupId[i] = i end
  for id, slot in pairs(state.customGroupSlot or {}) do state.pickerSlotGroupId[slot] = id end
  state.pickerSlotTrunkId[1] = 1
  for id, slot in pairs(state.customTrunkSlot or {}) do state.pickerSlotTrunkId[slot] = id end

  paintPickerItem("zPicker.Bg", "", rgbHex(theme.cardFill), false)
  local title = Controls["zPicker.Title"]
  if title then
    title.String = string.format("Port %d: assign to a group or trunk", port)
    setOverlayVisible("zPicker.Title", true)
  end
  for i, text in ipairs(PICKER_SECTION_TITLES) do
    local lbl = Controls["zPicker.Label " .. i]
    if lbl then
      lbl.String = text
      setOverlayVisible("zPicker.Label " .. i, true)
    end
  end
  paintPickerItem("zPicker.None",   "None",   PICKER_UNASSIGNED_HEX, current == nil)
  paintPickerItem("zPicker.Cancel", "Cancel", rgbHex(theme.buttonOffColor), false)

  for slot = 1, 20 + CUSTOM_GROUP_SLOTS do
    local id, name = state.pickerSlotGroupId[slot], "zPicker.Group " .. slot
    if id then
      local key = "Group: " .. id
      paintPickerItem(name, memberOfDisplayName(key), memberColorHex(key), current == key)
    else
      setOverlayVisible(name, false)
    end
  end
  for slot = 1, 1 + CUSTOM_TRUNK_SLOTS do
    local id, name = state.pickerSlotTrunkId[slot], "zPicker.Trunk " .. slot
    if id then
      local key = "Trunk: " .. id
      paintPickerItem(name, memberOfDisplayName(key), memberColorHex(key), current == key)
    else
      setOverlayVisible(name, false)
    end
  end
end

-- kind = "group" | "trunk" | "none". Closes the panel, PUTs the new
-- membership and applies it locally on HTTP 200 (the WS member_of
-- notification and the REST reconcile confirm it afterwards).
function pickerAssign(kind, id)
  local port = state.pickerPort
  closeGroupPicker()
  if not port or state.baseIP == "" then return end
  local body = (kind == "none") and '{"type":"none"}'
            or string.format('{"type":"%s","id":%d}', kind, id)
  HttpClient.Upload {
    Url     = string.format("http://%s/api/ports/port/%d/member_of", state.baseIP, port),
    Method  = "PUT",
    Data    = body,
    Headers = MergeTables(
      { ["Content-Type"] = "application/json" },
      getAuthHeaders()
    ),
    EventHandler = function(_tbl, code, _body, err)
      log("PUT member_of port " .. port .. " " .. body .. " => HTTP " .. tostring(code) .. " " .. tostring(err or ""))
      if code == 200 then SetPortMemberOf(port, memberOfKey(kind, id)) end
    end,
  }
end


--------------------------------------------------------------------------------
-- Speed picker (main page). A Port.Speed Cell click opens a modal card that
-- lists SPEED_CHOICES; a pick calls applyPortSpeed. zSpeed.* controls are declared in
-- controls.lua and placed by buildSpeedPickerPanel (layout.lua).
--------------------------------------------------------------------------------
local function speedPickerControlNames()
  local names = { "zSpeed.Bg", "zSpeed.Title", "zSpeed.Cancel" }
  for i = 1, #SPEED_CHOICES do names[#names + 1] = "zSpeed.Item " .. i end
  return names
end

function closeSpeedPicker()
  state.speedPickerPort = nil
  for _, name in ipairs(speedPickerControlNames()) do setOverlayVisible(name, false) end
end

-- Speeds offered for a port. Unknown type (no /api/ports snapshot yet)
-- offers everything; the API rejects what the port cannot do.
function speedChoicesForPort(port)
  local ptype = getPortState(port).portType
  if ptype == "rj45" then return SPEED_CHOICES_COPPER end
  if ptype == "sfp" then return state.has10g and SPEED_CHOICES_SFP_10G or SPEED_CHOICES_SFP_1G end
  return SPEED_CHOICES
end

function openSpeedPicker(port)
  if state.baseIP == "" then return end
  closeLldpPanel()
  state.speedPickerPort = port
  local pstate  = getPortState(port)
  local current = (pstate.enabled == false) and "Disabled" or pstate.speed
  local theme   = getThemeColors()
  local allowed = {}
  for _, label in ipairs(speedChoicesForPort(port)) do allowed[label] = true end

  paintPickerItem("zSpeed.Bg", "", rgbHex(theme.cardFill), false)
  local title = Controls["zSpeed.Title"]
  if title then
    title.String = string.format("Port %d: link speed", port)
    setOverlayVisible("zSpeed.Title", true)
  end
  paintPickerItem("zSpeed.Cancel", "Cancel", rgbHex(theme.buttonOffColor), false)
  for i, label in ipairs(SPEED_CHOICES) do
    local name = "zSpeed.Item " .. i
    if allowed[label] then
      local isCurrent = (label == current)
      paintPickerItem(name, label,
        rgbHex(isCurrent and theme.accentCyan or theme.buttonOffColor), isCurrent)
    else
      setOverlayVisible(name, false)
    end
  end
end

-- Apply a SPEED_CHOICES label to a port. "Disabled" turns the port off;
-- anything else turns it on, then PUTs link_speed. WS confirms the new
-- speed via SetPortSpeed; a rejected PUT rolls back to the last known value.
function applyPortSpeed(port, label)
  if state.baseIP == "" then return end
  local pstate  = getPortState(port)
  local headers = MergeTables({ ["Content-Type"] = "application/json" }, getAuthHeaders())

  if label == "Disabled" then
    HttpClient.Upload {
      Url     = string.format("http://%s/api/ports/port/%d/enabled", state.baseIP, port),
      Method  = "PUT",
      Data    = "false",
      Headers = headers,
      EventHandler = function(_tbl, status, _body, err)
        log("Disabled port " .. port .. " => status: " .. tostring(status) .. ", err: " .. tostring(err))
      end,
    }
    return
  end

  -- Ensure the port is enabled before setting the speed
  HttpClient.Upload {
    Url     = string.format("http://%s/api/ports/port/%d/enabled", state.baseIP, port),
    Method  = "PUT",
    Data    = "true",
    Headers = headers,
    EventHandler = function(_tbl, status, _body, err)
      log("Enabled port " .. port .. " => status: " .. tostring(status) .. ", err: " .. tostring(err))
    end,
  }

  pstate.speedPending = true
  renderPortUI(port)

  local apiSpeed = SPEED_API_MAP[label]
  local payload
  if label == "Auto" then
    payload = '{"mode":"auto","speed":["all"]}'
  elseif apiSpeed == "1gbps fdx" then
    payload = '{"mode":"auto","speed":["1gbps fdx"]}'
  else
    payload = string.format('{"mode":"fixed","speed":["%s"]}', apiSpeed or label)
  end

  HttpClient.Upload {
    Url     = string.format("http://%s/api/ports/port/%d/link_speed", state.baseIP, port),
    Method  = "PUT",
    Data    = payload,
    Headers = headers,
    EventHandler = function(_tbl, status, body, err)
      log("Set link_speed on port " .. port .. " => " .. payload ..
          " | status: " .. tostring(status) .. ", err: " .. tostring(err))
      if status ~= 200 then
        local reason = (type(body) == "string") and body:match('"reason"%s*:%s*"([^"]*)"') or nil
        log("Link speed rejected on port " .. port .. (reason and (": " .. reason) or ""))
        pstate.speedPending = false
        if pstate.lastValidSpeed then
          pstate.speed = pstate.lastValidSpeed
        end
        renderPortUI(port)
        -- Flash the cell amber for 3 s, then repaint the real value.
        local cell = Controls["Port.Speed Cell " .. port]
        if cell then
          local amber = rgbHex(getThemeColors().accentAmber)
          cell.Legend = "Rejected"
          cell.Color  = amber
          pcall(function() cell.OffColor = amber end)
          Timer.CallAfter(function() renderPortUI(port) end, 3)
        end
      end
      -- On success WS confirms via SetPortSpeed()
    end,
  }
end

--------------------------------------------------------------------------------
-- Q-SYS tile appearance
--------------------------------------------------------------------------------
function GetColor(props)
  return { 15, 58, 83 }
end

function GetPrettyName(props)
  return PluginInfo.Name .. " v" .. PluginInfo.Version
end

-- SVG logos are referenced from layout.lua — expose them as globals
_G.LogoLuminex = LogoLuminex
_G.LogoPSU     = LogoPSU
