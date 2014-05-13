--[[

		升阶配置

]]


DATA_IDTYPE = {}

-- 私有变量
local _data = {}

function DATA_IDTYPE:init()
	_data = {}
end

function DATA_IDTYPE:set(data)
	_data = data
end


function DATA_IDTYPE:get(key)
	if key == nil then return _data end

	return _data[key]
end
--获取对应cid的类型
function DATA_IDTYPE:getType( _cid )
	local key = math.floor( _cid/1000 )..""
	return _data[key]
end

return DATA_IDTYPE