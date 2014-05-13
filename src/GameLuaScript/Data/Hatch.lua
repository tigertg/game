DATA_Hatch = {

}
local _data

function DATA_Hatch:init()
	_data = {}
end

function DATA_Hatch:set(data)
	if not _data then
		_data = {}
	end	
	_data = data
end


function DATA_Hatch:get(type,index,key)
	if index then
		if key then
			return _data[type][index..""][key]
		else
			return _data[type][index..""]
		end
	else
		return _data[type]
	end
end
--更新对应数据
function DATA_Hatch:upData( tempData )
	for key , v in pairs( tempData ) do
		if _data[key] then
			_data[key] = v
		end
	end
end

function DATA_Hatch:getTable()
	return _data
end

 function DATA_Hatch:haveData()
	if not _data then
		return false
	end
	return true
end


return DATA_Hatch