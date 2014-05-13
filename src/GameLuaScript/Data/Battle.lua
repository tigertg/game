--[[

战斗数据

]]


DATA_Battle = {}


-- 私有变量
local _data = {}
local _mod = ""
local _act = ""

function DATA_Battle:init()
	_data = {}
	_mod = ""
	_act = ""
end

function DATA_Battle:set(data)
	_data = data
end


function DATA_Battle:get(key)
	if key == nil then return _data end

	return _data[key]
end


function DATA_Battle:getTurn(turn)
	turn = tostring(turn)	-- 必须转成字符串
	return _data["report"][turn]
end


function DATA_Battle:getStep(turn , step)
	turn = tostring(turn)	-- 必须转成字符串
	if _data["report"][turn] == nil then return nil end

	return _data["report"][turn][step]
end

function DATA_Battle:setMod(mod)
	_mod = mod
end

function DATA_Battle:getMod()
	return _mod
end

function DATA_Battle:setAct(act)
	_act = act
end

function DATA_Battle:getAct()
	return _act
end


--[[清空数据]]
function DATA_Battle:empty()
	_data = {}
end

return DATA_Battle