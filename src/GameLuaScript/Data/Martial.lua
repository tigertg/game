--[[

阵法数据

]]


DATA_Martial = {}


local _pramp = {}
-- 私有变量
local _data = {}

function DATA_Martial:init()
	_data = {}
	_pramp = {}
end


function DATA_Martial:set(data)
	_data = data
end
function DATA_Martial:get_data()
	return _data
end

function DATA_Martial:get(type,key)
	return _data[type][key]
end

function DATA_Martial:get_ON(key)
		if key == nil then return _data end
		return _data[key]
end


return DATA_Martial