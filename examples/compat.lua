local uv = require('uv')

local compat = {}
local t

local function clear_timeout(timer)
  uv.timer_stop(timer)
  uv.close(timer)
end

local function set_timeout(callback, timeout)
  local timer = uv.new_timer()
  local function ontimeout()
	clear_timeout(timer)
    callback(timer)
  end
  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

local function set_interval(callback, interval)
  local timer = uv.new_timer()
  local function ontimeout()
    callback(timer)
  end
  uv.timer_start(timer, interval, interval, ontimeout)
  return timer
end

local clear_interval = clear_timeout

function compat.load(logd)
	logd.config_set = function(key, value)
		if (key == "tick") then
			if t ~= nil then
				clear_interval(t)
			end
			t = set_interval(logd.on_tick, value)
		end
	end
end

return compat