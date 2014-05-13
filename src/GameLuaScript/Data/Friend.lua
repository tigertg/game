--[[

		在线礼包

]]


DATA_Friend = {}


-- 私有变量
local _data = {}

function DATA_Friend:init()
	_data = {}
end

function DATA_Friend:set(data)
	_data = data
end
function DATA_Friend:get(key)
	if key == nil then return _data end
	return _data[key]
end


function DATA_Friend:set_type( data )
	_data[ "type" ] = data.type
	_data[ "list" ] = data.list
	_data[ data.type .. "Data"] = data.data
end

return DATA_Friend