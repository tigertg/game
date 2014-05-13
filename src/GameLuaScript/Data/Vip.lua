--[[

帐户数据

]]


DATA_Vip = {}


-- 私有变量
local _data = {}

function DATA_Vip:init()
	_data = {}
end

function DATA_Vip:set(data)
	_data = data
end

function DATA_Vip:set_type( name , data )
	_data[name .. ""] = data
end

--是否是vip
function DATA_Vip:isVip()
	return _data["viplv"]~= 0
end

function DATA_Vip:get(key)
	if key == nil then return _data end
	return _data[key]
end

return DATA_Vip