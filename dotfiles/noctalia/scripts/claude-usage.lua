barWidget.define({
  label = "Claude Usage",
  icon = "sparkles",
  description = "Claude plan usage: 5-hour and 7-day windows",
  pickable = false,
  settings = {
    { key = "command", type = "string", label = "Command", default = "~/.local/bin/claude-usage" },
    { key = "interval_minutes", type = "string", label = "Refresh (minutes)", default = "5" },
  },
})

local SEVERITY_COLORS = {
  normal = "on_surface",
  warning = "primary",
  critical = "error",
}

local fetching = false

local function cfg(key, default)
  return barWidget.getConfig(key, default)
end

local function applyResult(text, tooltip, severity)
  local color = SEVERITY_COLORS[severity] or SEVERITY_COLORS.critical
  barWidget.setGlyph("sparkles")
  barWidget.setText(text)
  barWidget.setColor(color)
  barWidget.setGlyphColor(color)
  barWidget.setTooltip(tooltip)
end

local function refresh()
  if fetching then return end
  fetching = true
  noctalia.runAsync(noctalia.expandPath(cfg("command", "~/.local/bin/claude-usage")), function(result)
    fetching = false
    local lines = {}
    for line in string.gmatch(result.stdout or "", "[^\n]+") do
      table.insert(lines, line)
    end
    if #lines < 3 then
      applyResult("Claude ?", "claude-usage failed (exit " .. tostring(result.exitCode) .. ")", "critical")
      return
    end
    applyResult(lines[1], lines[2], lines[3])
  end)
end

applyResult("Claude …", "Loading usage", "normal")
barWidget.setUpdateInterval((tonumber(cfg("interval_minutes", "5")) or 5) * 60 * 1000)
refresh()

function update()
  refresh()
end

function onClick()
  refresh()
end
