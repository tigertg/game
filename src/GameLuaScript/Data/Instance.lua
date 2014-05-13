DATA_Instance = {

}
local _data


function DATA_Instance:init()
	_data = {}
end

function DATA_Instance:set(...)
	local result = _data
	for i = 1, arg["n"] do 
		if i == arg["n"] - 1 then
			result[arg[i]] = arg[i + 1]
			break
		else
			if not result[arg[i]] then
				result[arg[i]] = {}
			end
			result = result[arg[i]]
		end 
	end
end


function DATA_Instance:setPetFb(type, key, data)
	if data then
		if not _data["pet"][type] then
			_data["pet"][type] = {}
		end
		_data["pet"][type][key] = data
		
	else
		_data["pet"][type] = key
	end
end

function DATA_Instance:addPetArray(key, pos, data)
	if not _data["pet"][key] then
		_data["pet"][key] = {[pos] = {}}
	elseif not _data["pet"][key][pos] then
		_data["pet"][key][pos] = {}
	end
	
	for i = 1, #data do 
		table.insert(_data["pet"][key][pos], data[i])
	end
end

function DATA_Instance:removePet(key, n)
	if _data["pet"][key] then
		for i = 1, n do
			table.remove(_data["pet"][key], i)
		end
	end
end

function DATA_Instance:clearMessage()
	_data["pet"]["message"] = nil
end

function DATA_Instance:get(...)
	local result = _data
	for i = 1, arg["n"] do
		result = result[arg[i]]
		if not result then
--			print(arg[i].."在table中未找到")
			break
		end
	end
	return result
end

local curEquipData
--存放当前忠义堂关卡位置
function DATA_Instance:setCurEquipData( params )
	curEquipData = params
end
function DATA_Instance:getCurEquipData()
	return curEquipData
end



return DATA_Instance