--[[

用户数据

]]


DATA_Rank = {}


-- 私有变量
local _data = {}

function DATA_Rank:init()
	_data = {}
end


function DATA_Rank:setKey(key , data)
	_data[key] = data
end


function DATA_Rank:get(...)
	local result = _data
	for i = 1, arg["n"] do
		result = result[arg[i]]
	end
	return result
end

return DATA_Rank