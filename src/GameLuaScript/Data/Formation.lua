--[[

阵法数据

]]


DATA_Formation = {}
--当前选中哪个英雄
local cur
local max

local _pramp = {}
-- 私有变量
local _data = {}

function DATA_Formation:init()
	_data = {}
	_pramp = {}
	local cur = nil
end


function DATA_Formation:setConf(maxConf)
	max = maxConf
end

function DATA_Formation:set(data)
	_data = data
end
function DATA_Formation:get_data()
	return _data
end

function DATA_Formation:get(...)
	local result = _data
	for i = 1, arg["n"] do
		if not result then
--			print(arg[i],"字段未找到")
			break
		end
		if arg[i] then
			result = result[arg[i]..""]
		end
	end
	return result
end

function DATA_Formation:get_ON(key)
		if key == nil then return _data end
		return _data[key]
end

function DATA_Formation:get_lenght()
		local on = table.getn(_data["on"])
		local back = table.getn(_data["back"])
		return (on+back)
end

function DATA_Formation:set_index(index)--这里取得的是位置，不是英雄id
	_pramp["index"] = index
end

function DATA_Formation:get_index(i)
	if i then
		if i <= table.getn(_data["on"]) then
			return _data["on"][i]
		else
			return _data["back"][i-table.nums(_data["on"])]
		end
	else

		if _pramp["index"] <= table.getn(_data["on"]) then
			return _data["on"][(_pramp["index"])]
		else
			return _data["back"][(_pramp["index"]-table.getn(_data["on"]))]
		end
	end
end
--检查对应id是否上阵
function DATA_Formation:checkIsExist( _id )
	local isExist = false
	local pos
	for key , v in pairs(_data["on"]) do
		 if v.gid == _id then
			 pos = key
			 isExist = true
			 break
		 end
	end
	for key , v in pairs(_data["back"]) do
		 if v.gid == _id then
			pos = key + 4
			isExist = true
			break
		 end
	end
	return isExist,pos
end

--检查对应cid是否在阵
function DATA_Formation:checkOnByCid(cid)
	local exist
	for k, v in pairs(_data["on"]) do
		if tonumber(v.cid) == tonumber(cid) then
			exist = true
		end
	end	
	
	if not exist then
		for k, v in pairs(_data["back"]) do
			if tonumber(v.cid) == tonumber(cid) then
				exist = true
			end	
		end
	end
	return exist 
end

function DATA_Formation:setCur(id)
	cur = id
end

function DATA_Formation:getCur()
	return cur
end

function DATA_Formation:getMax()
	return max
end

--计算当前综合统帅值
function DATA_Formation:countLead()
	local leadValue = 0
	for key , v in pairs(_data["on"]) do
		leadValue = leadValue + getConfig( "generallead" , getConfig( "general" , v.cid , "star" ) , "lead" )
	end
	for key , v in pairs(_data["back"]) do
		leadValue = leadValue + getConfig( "generallead" , getConfig( "general" , v.cid , "star" ) , "lead" )
	end
	return leadValue
end
return DATA_Formation