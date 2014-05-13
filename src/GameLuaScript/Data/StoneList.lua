DATA_StoneList = {}
local _data = {}
function DATA_StoneList:init()
	_data = {}
end

function DATA_StoneList:get_insert(gid)
	if next(_data) == nil then
		for i = 1,8 do
			_data[i] = {}
		end
	end
	for i = 1,8 do
		if next(_data[i]) == nil then
			_data[i]["gid"] = gid
			break
		end
	end
end

function DATA_StoneList:get_data()
	if next(_data) == nil then
		for i = 1,8 do
			_data[i] = {}
		end
	end
	return _data
end
function DATA_StoneList:get_index(index)
	return _data[index]["gid"]
end

function DATA_StoneList:removeIndex(gid)
	if next(_data) == nil then
		for i = 1,8 do
			_data[i] = {}
		end
	end
	for i = 1,8 do
		if _data[i]["gid"] == gid then
			_data[i] = {}
			break
		end
	end
end

return DATA_StoneList