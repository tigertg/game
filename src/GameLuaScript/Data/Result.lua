--[[

	战斗结果 临时存放

]]


DATA_Result = {}


-- 私有变量
local _data = {}

function DATA_Result:init()
	_data = {}
end

function DATA_Result:set(data)
	_data = data
end


function DATA_Result:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_Result