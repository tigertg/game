DATA_Pet = {}

local _data = {}
local haveGet = false
local fighting

function DATA_Pet:init()
	_data = {}
	haveGet = false
end

function DATA_Pet:set(data)
	_data = data
end

function DATA_Pet:insert(data)
	for i,v in pairs(data) do
		print(type(i))
		_data[i] = v
	end
end



function DATA_Pet:setByKey(index , key , data)
	if data then
		if not _data[index] then
			_data[index] = {}
		end
		_data[index][key] = data 
	else
		_data[index..""] = key
	end
end

function DATA_Pet:setFighting(id)
	 fighting = id
end

function DATA_Pet:getFighting()
	return fighting
end

function DATA_Pet:get(...)
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

function DATA_Pet:haveData(index)
	if index then
		if _data[index..""] then
			return true
		end
	else
		if #_data > 0 then
			return true
		end
	end
	return false
end

function DATA_Pet:getTable()
	return _data
end

function DATA_Pet:haveGet(value)
	if value == nil then return haveGet end

	haveGet = value
end


function DATA_Pet:calcExp(exp_data)
	local data = getConfig("petlvexp")
	local lv_num = 1
	local is_true = true
	local cur_init = 0
	local cur_exp = 0
	local max_exp = 0
	local lv = 1

	while is_true do
		local cur_data = data[(lv_num)..""].exp
		local next_data = data[(lv_num + 1)..""].exp
		local cur = 0

		if lv_num == 1 then
			cur_data = 0
		end

		if exp_data >= cur_data and exp_data < next_data then
			cur_exp = exp_data - cur_data
			max_exp = next_data - cur_data
			lv = lv_num
			is_true = false
		else
			lv_num = lv_num + 1
		end

		if not isset(data , (lv_num + 1) .. "") then
			cur_exp = 1
			max_exp = 1
			lv = lv_num
			is_true = false
		end
	end

	return lv , cur_exp , max_exp
end

return DATA_Pet