--[[

阵法数据

]]


DATA_Wash = {}


-- 私有变量
local _data = {}

function DATA_Wash:init()
	_data = {}
end

function DATA_Wash:set(data)
	--dump(data)
	_data = {}
	_data = data
end


function DATA_Wash:get(key)
	--dump(key)
	if key == nil then return _data end

	return _data[key]
end

function DATA_Wash:get_index(key)
	--dump(key)
	if key == nil then return _data end

	return _data["temp"][key]
end

return DATA_Wash