local boundary = require('boundary')
local wminfo = require('wmiinfo')
local string = require('string')

-- Default params
local source = ""

-- Fetching params
if (boundary.param ~= nil) then
  source = boundary.source or source
end

print("_bevent:Boundary LUA WMI plugin up : version 1.0|t:info|tags:lua,plugin")
local dbcon = nil

local function poll()
	dbcon = wminfo:new()
	dbcon:get_percent_processor_time(function(percent_processor_time)
		dbcon:get_percent_disks_time(function(percent_disks_time)
			dbcon:allocation_available_bytes(function(allocation_available_bytes)
				dbcon:memory_swap_rate(function(memory_swap_rate)
					dbcon:free_disks_space(function(free_disks_space)
						dbcon:network_bytes_received_sent_persec(function(network_bytes)
							dbcon:connections_in_out(function(connections_in_out)
								p(string.format("WMI_PERCENT_PROCESSOR_TIME %s %s", percent_processor_time, source))
								p(string.format("WMI_PERCENT_DISKS_TIME %s %s", percent_disks_time, source))
								p(string.format("WMI_ALLOCATION_AVAILABLE_BYTES %s %s", allocation_available_bytes, source))
								p(string.format("WMI_MEMORY_SWAP_RATE %s %s", memory_swap_rate, source))
								p(string.format("WMI_FREE_DISKS_SPACE %s %s", free_disks_space, source))
								p(string.format("WMI_NETWORK_BYTES_RECEIVED_PERSEC %s %s", network_bytes["received"], source))
								p(string.format("WMI_NETWORK_BYTES_SENT_PERSEC %s %s", network_bytes["sent"], source))
								p(string.format("WMI_CONNECTIONS_ESTABLISHED %s %s", connections_in_out, source))
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end
poll()