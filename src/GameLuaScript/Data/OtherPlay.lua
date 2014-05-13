--[[

		在线礼包

]]


DATA_OTHER = {}

--阵法处理
local cur

local _pramp = {}

-- 私有变量
local _data = {}

function DATA_OTHER:init()
	_data = {}
	_pramp = {}
	local cur = nil
end

function DATA_OTHER:set(data)
	_data = data
end

function DATA_OTHER:set_type(name,data)
	_data[name] = data
end

function DATA_OTHER:get(key)
	if key == nil then return _data end

	return _data[key]
end


function DATA_OTHER:getLv()
	return tonumber( _data["base"]["lv"] )
end

--他人背包装备信息
function DATA_OTHER:getBag( ... )

	local result
	if arg[1] == "equip" then result = _data["formation"]["bag_equip"]
	elseif arg[1] == "skill" then result = _data["formation"]["bag_skill"]
	end
	
	for i = 2, arg["n"] do
		if not result then
--			print(arg[i],"字段未找到")
			break
		end
		
		if arg[i] then
			result = result[ arg[i].."" ]
		end
	end
	return result
end








--他人武将装备及技能信息
function DATA_OTHER:getSkillEquipTable( type )
	if type == nil then return _data["formation"]["general_dress"] end 
	return _data["formation"]["general_dress"][type..""]
end








--他人武将数据
function DATA_OTHER:getGeneral(index , type , key)
	index = index .. ""
	if type == nil then return _data["formation"]["general_detail"][index] end

	if type == "gid" then
		type = "id"
	end

	if key then
		return _data["formation"]["general_detail"][index][type][key]
	else
		return _data["formation"]["general_detail"][index][type]
	end
end
function DATA_OTHER:getTable(gid)
	gid = tostring( gid )
	return _data["formation"]["general_detail"][gid]
end











--他人上阵信息
function DATA_OTHER:get_ON(key)
		if key == nil then return _data["formation"]["formation"] end
		return _data["formation"]["formation"][key]
end
function DATA_OTHER:get_lenght()
		local tempData = _data["formation"]["formation"]
		local on = table.getn(tempData["on"])
		local back = table.getn(tempData["back"])
		return (on+back)
end
function DATA_OTHER:set_index(index)--这里取得的是位置，不是英雄id
	_pramp["index"] = index
end
function DATA_OTHER:get_index(i)
	local tempData = _data["formation"]["formation"]
	if i then
		if i <= table.getn( tempData["on"] ) then
			return tempData["on"][i]
		else
			return tempData["back"][i-table.getn( tempData["on"] )]
		end
	else

		if _pramp["index"] <= table.getn( tempData["on"] ) then
			return tempData["on"][(_pramp["index"])]
		else
			return tempData["back"][(_pramp["index"]-table.getn( tempData["on"] ))]
		end
	end
end
--检查对应id是否上阵
function DATA_OTHER:checkIsExist( _id )
	local tempData = _data["formation"]["formation"]
	local isExist = false
	for key , v in pairs( tempData["on"] ) do
		 if v.gid == _id then
		 	return true
		 end
	end
	for key , v in pairs( tempData["back"] ) do
		 if v.gid == _id then
		 	return true
		 end
	end
	return isExist
end

function DATA_OTHER:setCur(id)
	cur = id
end

function DATA_OTHER:getCur()
	return cur
end

return DATA_OTHER