--[[

	武将技能  和 穿戴装备 数据

]]--
DATA_ROLE_SKILL_EQUIP = {

}
local _data = {}

function DATA_ROLE_SKILL_EQUIP:init()
	_data = {}
end

function DATA_ROLE_SKILL_EQUIP:set( data )
	_data = data
end

--根据装备id获取英雄id判断此装备是否已穿戴,天赋技能不判断
function DATA_ROLE_SKILL_EQUIP:getRoleId(id, type, isCid)
		local roleId 
		for k, v in pairs(_data) do
			for sk, sv in pairs(v) do
				if type == "skill" then
					if string.sub(sk, 1, 1) == "s" and sv[isCid and "cid" or "id"] == id then
						roleId = k
						break
					end
				elseif type == "equip" then
					if string.sub(sk, 1, 1) == "e" and sv[isCid and "cid" or "id"] == id then
						roleId = k
						break
					end
				end
				
			end
			if roleId then
				break
			end
		end
		
	return roleId 
end

--获取id对应英雄是否穿戴eCid的装备
function DATA_ROLE_SKILL_EQUIP:isDress(id, eCid)
	if id then
		if _data[id..""] then
			for k, v in pairs(_data[id..""]) do
				if tonumber(v["cid"]) == tonumber(eCid) then
						return true
					end
			end
		end
	end
	return false
end

function DATA_ROLE_SKILL_EQUIP:update(type,key,data)
	_data[type][key] = data
end
--获取对应id英雄技能装备信息
function DATA_ROLE_SKILL_EQUIP:getIdInfo(id)
	return _data[id..""] or nil
end
function DATA_ROLE_SKILL_EQUIP:getTable(type)
	return type and _data[ type.."" ] or _data
end


function DATA_ROLE_SKILL_EQUIP:get(...)
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

function DATA_ROLE_SKILL_EQUIP:haveData(type)
	if not _data[type] then
		return false
	end
	return true
end

function DATA_ROLE_SKILL_EQUIP:count(type)
	if _data[type] then
		return table.nums(_data[type])
	else
		return 0
	end
end

function DATA_ROLE_SKILL_EQUIP:get_data()
	return _data
end

function DATA_ROLE_SKILL_EQUIP:get_size()
	return table.getn(_data)
end

return DATA_ROLE_SKILL_EQUIP