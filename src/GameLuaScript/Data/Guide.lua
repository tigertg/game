--[[

新手引导数据

]]


DATA_Guide = {}


-- 私有变量
local _data = {}
local _old = nil

function DATA_Guide:init()
	_data = {}
	_old = nil
end

function DATA_Guide:setStep(data)
	data["map_id"] = data["map_id"] and tonumber(data["map_id"]) or 1
	data["mission_id"] = data["mission_id"] and tonumber(data["mission_id"]) or 1

	if _old == nil then
		_old = data
	else
		_old = _data
	end

	_data = data
end


function DATA_Guide:get(key)
	if key == nil then return _data end

	return _data[key]
end

function DATA_Guide:getOld(key)
	if key == nil then return _old end

	return _old[key]
end

function DATA_Guide:setOld()
	_old = _data
end

return DATA_Guide