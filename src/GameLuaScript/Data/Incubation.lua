--[[

		孵化数据

]]


DATA_Incubation = {}


-- 私有变量
local _data = {}

function DATA_Incubation:init()
	_data = {}
end

function DATA_Incubation:set(data)
	_data = data
end


function DATA_Incubation:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_Incubation