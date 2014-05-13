local Prop_Config = requires(IMG_PATH,"GameLuaScript/Config/Prop")--require "GameLuaScript/Config/Prop"
DATA_Bag = {

}
local _data = {}

function DATA_Bag:init()
	_data = {}
end

function DATA_Bag:set(type, data)
	for i,v in pairs(data) do
		if not _data[type] then
			_data[type] = {}
		end
		if v["num"] == 0 then
			_data[type][i] = nil
		else
			_data[type][i] = v
		end
	end
end

function DATA_Bag:update(type,key,data)
	_data[type][key] = data
end


--custom  自定义过滤的字段, noUse此标志为真是只显示空闲的卡牌
function DATA_Bag:getTable(kind,filter, custom, noUse)
	--排除表中已使用，已上阵列的元素
	local function exceptUse(items)
		if noUse then
			for k, v in pairs(items) do
				if kind == "equip" then
					if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(k), kind) then
						items[k] = nil
					end
				elseif kind == "general" or kind == "hero" then
					if DATA_Formation:checkIsExist(tonumber(k)) then
						items[k] = nil
					end
				end
			end
		end
	end
	
	if filter then
		local t = {}
		for i,v in pairs(_data[kind] or {}) do
			if type(filter) == "string" then  --单个过滤
				if custom then
					if v["custom"] == filter then
						t[i] = v
					end
				else
					if v["type"] == filter then
						t[i] = v
					end
				end
			elseif type(filter) == "table" then --多个过滤器
				local match = true
				for sk,sv in pairs(filter) do
					if sk == "star" then  --星级要在配置文件中找
						if getConfig(kind, v["cid"], "star") ~= sv then
							match = false
							break
						end
					else
						if v[sk] ~= sv then
							match = false
							break
						end
					end
				end			
				if match then
					t[i] = v
				end
			end
		end
		exceptUse(t)
		return t
	else
		local t = {}
		if _data[kind] then
			for k, v in pairs(_data[kind]) do
				t[k] = v
			end
		end
		exceptUse(t)
		return t
	end
end

--对背包中的元素进行计数，exceptUse除去已装备的,filter过滤
function DATA_Bag:countItems(kind, exceptUse, filter)
	local result = _data[kind] or {}
	local num = 0
	
	local function isFilter(data)
		local match = true
		if filter then
			for k, v in pairs(filter) do
				if k == "star" then  --星级要在配置文件中找
					if getConfig(kind, data["cid"], "star") ~= v then
						match = false
						break
					end
				else
					if data[k] ~= v then
						match = false
						break
					end
				end
			end
		end
		return match
	end
	
	for k, v in pairs(result) do
		if exceptUse then
			if kind == "equip" then
				if not DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(k), kind) then
					if  isFilter(v) then
						num = num + 1
					end
				end
			elseif kind == "general" or kind == "hero" then
				if not DATA_Formation:checkIsExist(k) then
					if  isFilter(v) then
						num = num + 1
					end
				end
			end
		else
			if isFilter(v) then
				num = num + (v["num"] or 1)
			end
		end
	end
	
	return num
end

function DATA_Bag:get(...)
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

 function DATA_Bag:haveData(id,type)
	if not _data[type] then
		return false
	end
	return true
end

function DATA_Bag:count(type)
	if _data[type] then
		return table.nums(_data[type])
	else
		return 0
	end
end
--获取对应等级传功丹数据及个数
function DATA_Bag:getDrug( level )
	local tempData = self:getTable("prop","transmission")
	local drugNum = 0
	local gather = {}
	for key , v in pairs(tempData) do
		if tostring( v.cid ) == tostring( "1600" .. level ) then
			table.insert( gather , v )
			drugNum = drugNum + v.num
		end
	end
	
	return drugNum , gather 
end
function DATA_Bag:get_data()
	return _data
end

function DATA_Bag:get_size()
	return table.getn(_data)
end

--根据等级取蛋的id
function DATA_Bag:getEgg(level)
	local id
	for i,v in pairs(_data["prop"]) do
		if v["type"] == "petegg" and tostring( Prop_Config[v["cid"]..""]["star"] ) == tostring( level ) then
			id = v["id"]
			break
		end
	end
	return id
end
--获取相同cid技能个数
function DATA_Bag:getSkillCidCount( _id )
	local total = 0
	local idGether ={}
	local _cid = self:get("skill", _id , "cid")
	local _lv = self:get("skill", _id , "lv")
	--遍历所有技能
	for key , v in pairs( self:getTable("skill") ) do
		--等级相同，cid相同
--		if v.cid == _cid and v.lv == _lv and v.id ~= _id then
		if tostring( v.cid ) == tostring( _cid ) and tostring( v.lv ) == tostring( _lv ) then
			local skillKey = { "s1" , "s2" , "s3" }
			local isUser = nil
			--遍历当前上阵武将装备
			local usedEquipData = DATA_ROLE_SKILL_EQUIP:get_data()
			for key1 , value in pairs( usedEquipData ) do 
				--查找当前武将技能位是否使用了当前技能
				for curSeatIndex = 1 , #skillKey do
					if value[ skillKey[curSeatIndex] ] then
						if tostring(v.id) == tostring(value[ skillKey[curSeatIndex] ].id)  and tostring(v.id) ~= tostring( _id ) then
							isUser = v.id
							break
						end
					end
				end
				if isUser then break end
			end
			if not isUser then total = total + 1  idGether[ total ] = v.id end
		end 
	end
	return total , idGether
end
--获取对应等级宠物蛋个数
function DATA_Bag:getEggCount(level)
	local total = 0
	if not isset(_data,"prop") then
		return 0
	end
	for i,v in pairs(_data["prop"]) do
		if v["type"] == "petegg" and getConfig("prop",v["cid"],"star") == level + 2 then
			total = total + v["num"]
		end
	end
	return total
end

function DATA_Bag:getTypeCount(type, filter)
	local total = 0
	if _data[type] then
		for k, v in pairs(_data[type]) do
			if v["cid"] == filter then
				total = total + v["num"]	
			end
		end
	end
	return total
end

--检查 type 是否存在
function DATA_Bag:getTypeNum( type , targetType )
	local isExist = false
	local typeNum = 0
	if not _data[type] then
		return isExist
	end
	
	for k, v in pairs(_data[type]) do
		if v.type == targetType then
			typeNum = typeNum + tonumber(v.num)
			isExist = true
		end
	end
	
	return isExist , typeNum
end
local skill_data = {}
function DATA_Bag:set_skillexp(skillexp)
	skill_data = skillexp
end

function DATA_Bag:get_skillexp()
	return skill_data
end





--根据cid取最先查到的数据
function DATA_Bag:cidByData( _cid , key )
	local type = getCidType( _cid )
	
	local curData = nil
	for key , v in pairs( _data[type] ) do
		if v["cid"] == _cid then
			curData = v
			break
		end
	end
	
	if key then
		return curData[key] or nil
	end
	
	return curData
end
return DATA_Bag