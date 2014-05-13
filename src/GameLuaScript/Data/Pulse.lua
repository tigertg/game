DATA_Pulse = {}
local _data = {}

function DATA_Pulse:init()
	_data = {}
end

function DATA_Pulse:set(data)
	_data = nil
	_data = {}
	_data = data
end

function DATA_Pulse:get_data()
	return _data["result"]
end

return DATA_Pulse