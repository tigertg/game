DATA_Mission = {}

local _data
function DATA_Mission:init()
	_data = nil 
end


--index是当索引第几关卡，因为每次只返回当前选择关卡的数据
function DATA_Mission:set(index , data)
	if not _data then
		_data = {}
	end
	_data[index] = data
	_data["map"] = data["map"]
	_data["max"] = data["max"]
	_data["cleanup"] = data["cleanup"]
	_data["cleanusetime"] = data["cleanusetime"]
	_data["current"] = {map_id = data["max"]["map_id"],mission_id = data["max"]["mission_id"]}
end

function DATA_Mission:setByKey(index , key , data)
	if _data and  _data[index] then
		if data then
			_data[index][key] = data
		else
			_data[index] = key
		end
	end
end

function DATA_Mission:setData(...)
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


--function DATA_Mission:get(map, level, key, index)
--	if _data then
--		if index then
--			return _data[map][level][key][index]
--		elseif key then
--			return _data[map][level][key]
--		else
--			return _data[map][level]
--		end
--	else
--		return nil 
--	end
--end

function DATA_Mission:get(...)
	local result = _data
	for i = 1, arg["n"] do
		if not result then
			-- dump(result)
			-- dump(arg)
			-- print(arg[i],"字段未找到")
			break
		end
		
		result = result[arg[i]]
	end
	return result
end

 function DATA_Mission:haveData(index)
	if _data and _data[index] then
		return true
	end
	return false
end

function DATA_Mission:getCount()
	return table.nums(_data["map"])
end

function DATA_Mission:getMapName(index)
	return _data["map"][index..""]
end














local tempCurMissionData 
function DATA_Mission:getCurMissionData()
	return tempCurMissionData
end
--存放放前战斗的mapid 和  missionid	只为配合战斗中跳过按钮
function DATA_Mission:setCurMissionData( params )
	tempCurMissionData = params
end
return DATA_Mission