--[[

帐户数据

]]


DATA_Account = {}


-- 私有变量
local _data = {}

function DATA_Account:init()
	_data = {}
end

function DATA_Account:set(data)
	if data["gold"] ~= nil then data["gold"] = tonumber(data["gold"]) end
	if data["silver"] ~= nil then data["silver"] = tonumber(data["silver"]) end

	_data = data
	--dump(data)
end


function DATA_Account:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_Account