DATA_Shop = {
}
local _data

function DATA_Shop:init()
	_data = nil 
end

function DATA_Shop:set(data)
	if not _data then
		_data = {}
	end
	for i,v in pairs(data) do
		_data[i] = v
	end
end

function DATA_Shop:update(type,key,data)
	_data[type][key] = data
end


function DATA_Shop:getTable(type)
	local table = {}
	for i,v in pairs(_data) do
		if v["tab"] == type then
			table[i] = v
		end
	end
	return table
end

function DATA_Shop:get(index , key)
	if key then
		return _data[index..""][key]
	else
		return _data[index..""]
	end
end

 function DATA_Shop:haveData()
	if not _data then
		return false
	end
	return true
end

function DATA_Shop:count(type)
	return table.nums(DATA_Shop:getTable(type))
end

function DATA_Shop:get_data()
	return _data
end

function DATA_Shop:get_size()
	return table.getn(_data)
end


return DATA_Shop