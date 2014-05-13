DATA_General = {}

local _data = {}
local haveGet = false

function DATA_General:init()
	_data = {}
	haveGet = false
end

function DATA_General:set(data)
	_data = data
end

function DATA_General:insert(data)
	for i , v in pairs(data) do
		local gid = tonumber(i)
		_data[gid] = v
	end
end

function DATA_General:setByKey(index , key , data)
	_data[index][key] = data
end

function DATA_General:get(...)
	local result = _data
	for i = 1, arg["n"] do
		if not result then
			print(arg[i],"字段未找到")
			break
		end
		
		if arg[i] then	
			result = result[arg[i]]
		end
	end
	return result
end

function DATA_General:getTable(gid)
	gid = tonumber(gid)
	return _data[gid]
end

function DATA_General:haveData(index)
	if index then
		if _data[index] then
			return true
		end
	else
		if #_data > 0 then
			return true
		end
	end
	return false
end

function DATA_General:haveGet(value)
	if value == nil then return haveGet end

	haveGet = value
end





return DATA_General