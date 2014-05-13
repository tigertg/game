
DATA_UpData = {}


-- 私有变量
local _data = {}

function DATA_UpData:init()
	_data = {}
end

function DATA_UpData:set(data)
	_data = data
end


function DATA_UpData:get()
	return _data
end


function DATA_UpData:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_UpData
