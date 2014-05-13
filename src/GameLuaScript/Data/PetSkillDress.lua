--[[

	宠物技能数据

]]--
DATA_PetSkillDress = {
}

local _data = {}

function DATA_PetSkillDress:init()
	_data = {}
end

function DATA_PetSkillDress:set( data )
	_data = data
end

function DATA_PetSkillDress:update(type,key,data)
	_data[type][key] = data
end

--获取是哪个宠物装备了技能，返回宠物的id,
function DATA_PetSkillDress:isDress(id)
	local owner
	if _data then
		for k, v in pairs(_data) do
			for sk, sv in pairs(v) do
				if sv["id"] == id then
					owner = k
					break
				end	
			end
			if owner then
				break
			end
		end
	end
	return owner
end



function DATA_PetSkillDress:get(...)
	local result = _data
	for i = 1, arg["n"] do
		result = result[arg[i]..""]
		
		if not result then
--			print(arg[i].."未找到")
			break
		end
	end
	
	return result
end

 function DATA_PetSkillDress:haveData()
	if not _data then
		return false
	end
	return true
end

function DATA_PetSkillDress:count()
	if _data then
		return table.nums(_data)
	else
		return 0
	end
end

--获取宠物对应id对应位信息
function DATA_PetSkillDress:getSeatSkill( id , seat )
	if seat then
		return _data[id..""][seat]
	end
	return _data[id..""]
end

function DATA_PetSkillDress:get_data()
	return _data
end

function DATA_PetSkillDress:get_size()
	return table.getn(_data)
end

function DATA_PetSkillDress:isLock(id, type, pos)
	local lock, num
	local star = DATA_Bag:get("pet", id, "star")
	local stage = DATA_Bag:get("pet", id, "stage")
	
	if star < 3 then
		num = 1
	elseif star < 5 then
		num = 2
	else
		
	end
	if type == "a" then  --主动技
				
	else  --被动技
	
	end
	
	return lock
end


return DATA_PetSkillDress