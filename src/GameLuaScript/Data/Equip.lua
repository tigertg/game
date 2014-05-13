DATA_Equip = {
	haveGet,   
}

local _data = {}

function DATA_Equip:init()
	_data = {}
end

function DATA_Equip:set(data)
	_data = data
end

function DATA_Equip:insert(data)
	for i,v in pairs(data) do
		table.insert(_data,i,v)
	end
end

function DATA_Equip:setByKey(index , key , data)
	_data[index][key] = data
end

function DATA_Equip:get(...)
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

function DATA_Equip:haveData(index)
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



return DATA_Equip