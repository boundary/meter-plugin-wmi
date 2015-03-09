--------------------------------------------------------------------------
-- Module to extract WMI Process Information for Boundary Lua WMI Plugin
--
-- Author: Yegor Dia
-- Email: yegordia at gmail.com
--
--------------------------------------------------------------------------

local object = require('core').Object
local io = require('io')
local ffi = require('ffi')
local os = require('os')
local string = require('string')
local table = require('table')

local function callIfNotNil(callback, ...)
    if callback ~= nil then
        callback(...)
    end
end

function string:split( inSplitPattern, outResults )
	if not outResults then
		outResults = { }
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	while theSplitStart do
		table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	end
	table.insert( outResults, string.sub( self, theStart ) )
	return outResults
end

function string:remove_spaces( outResults )
	return string.gsub(self, "%s+", "")
end

local WMIInfo = object:extend()

--[[ Initialize WMIInfo with  parameters
]]
function WMIInfo:initialize()
	if (ffi.os == "Windows") then
		self.currentObject = 'get-wmiobject'
		return self
	end
	error("WMIInfo available only for Windows-based OS")
end


--[[ Execute WMI Query
]]
function WMIInfo:execute(query)
	local cmd = string.format("powershell %s %s", self.currentObject, query)
	local f = io.popen(cmd, 'r')
	local content = {}
	
	for line in f:lines() do
		line = string.gsub(line, '^%s+', '')
		line = string.gsub(line, '%s+$', '')
		line = string.gsub(line, '[\n\r]+', ' ')
		if (string.len(line) > 1) then
			table.insert(content, line)
		end
	end
	f:close()
	  
	return content
end


--[[ tets function
]]
function WMIInfo:test(callback)	
	callIfNotNil(callback, self:execute('win32_bios'))
end

--[[ Function to get percentage of the time the processor is busy doing non-idle threads
]]
function WMIInfo:get_percent_processor_time(callback)
	local cmd = "-query 'select PercentProcessorTime from Win32_PerfFormattedData_PerfOS_Processor'"
	local result = self:execute(cmd)
	
	local percentage = 0
	for index, line in ipairs(result) do
		if (string.find(line, "PercentProcessorTime") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			percentage = percentage + tonumber(line)
		end
	end
	if (percentage > 100) then
		percentage = 100
	end
	
	callIfNotNil(callback, percentage)
end


--[[ Function to get percentage of the time the selected physical disks are busy servicing read or write requests
]]
function WMIInfo:get_percent_disks_time(callback)
	local cmd = "-query 'select PercentDiskTime from Win32_PerfFormattedData_PerfDisk_PhysicalDisk'"
	local result = self:execute(cmd)
	
	local percentage = 0
	for index, line in ipairs(result) do
		if (string.find(line, "PercentDiskTime") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			percentage = percentage + tonumber(line)
		end
	end
	if (percentage > 100) then
		percentage = 100
	end
	
	callIfNotNil(callback, percentage)
end


--[[ Function to get amount of memory immediately available for allocation to a process or for system use
]]
function WMIInfo:allocation_available_bytes(callback)
	local cmd = "-query 'select AvailableBytes from Win32_PerfFormattedData_PerfOS_Memory'"
	local result = self:execute(cmd)
	
	local bytes = 0
	for index, line in ipairs(result) do
		if (string.find(line, "AvailableBytes") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			bytes = bytes + tonumber(line)
		end
	end
	
	callIfNotNil(callback, bytes)
end


--[[ Function to get high rate of memory operations involving disk swap are symptoms of memory shortage and affects system performance
]]
function WMIInfo:memory_swap_rate(callback)
	local cmd = "-query 'select PagesPersec from Win32_PerfFormattedData_PerfOS_Memory'"
	local result = self:execute(cmd)
	
	local rate = 0
	for index, line in ipairs(result) do
		if (string.find(line, "PagesPersec") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			rate = rate + tonumber(line)
		end
	end
	
	callIfNotNil(callback, rate)
end


--[[ Function to get free space, it is the available storage space in bytes on the specified logical disk
]]
function WMIInfo:free_disks_space(callback)
	local cmd = "-query 'select FreeSpace from Win32_LogicalDisk'"
	local result = self:execute(cmd)
	
	local bytes = 0
	for index, line in ipairs(result) do
		if (string.find(line, "FreeSpace") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			if (string.len(line) > 1) then -- could be virtual nil freespace
				bytes = bytes + tonumber(line)
			end
		end
	end
	
	callIfNotNil(callback, bytes)
end


--[[ Function to get free space, it is the available storage space in bytes on the specified logical disk
]]
function WMIInfo:network_bytes_received_sent_persec(callback)
	local cmd = "-query 'select BytesReceivedPersec, BytesSentPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface'"
	local result = self:execute(cmd)
	
	local bytes_received = 0
	local bytes_sent = 0
	for index, line in ipairs(result) do
		if (string.find(line, "BytesReceivedPersec") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			if (string.len(line) > 1) then -- could be virtual nil
				bytes_received = bytes_received + tonumber(line)
			end
		end
		
		if (string.find(line, "BytesSentPersec") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			if (string.len(line) > 1) then -- could be virtual nil
				bytes_sent = bytes_sent + tonumber(line)
			end
		end
		
	end
	
	callIfNotNil(callback, {received=bytes_received, sent=bytes_sent})
end


--[[ Function to get current number of Established connections, inbound and outbound
]]
function WMIInfo:connections_in_out(callback)
	local cmd = "-query 'select ConnectionsEstablished from Win32_PerfFormattedData_Tcpip_TCPv4'"
	local result = self:execute(cmd)
	
	local connections = 0
	for index, line in ipairs(result) do
		if (string.find(line, "ConnectionsEstablished") ~= nil) then
			line = line:split(":")
			line = line[2]:remove_spaces()
			if (string.len(line) > 1) then -- could be virtual nil
				connections = connections + tonumber(line)
			end
		end
	end
	
	callIfNotNil(callback, connections)
end

return WMIInfo