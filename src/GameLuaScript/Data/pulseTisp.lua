DATA_PulseTisp = {}
local _data = {}

function DATA_PulseTisp:init()
	_data = {}
end

function DATA_PulseTisp:set(data)
	_data = nil
	_data = {}
	_data = data
end

function DATA_PulseTisp:get_data()
	return _data
end

return DATA_PulseTisp