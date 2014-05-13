--[[

用户数据

]]


DATA_User = {}


-- 私有变量
local _data = {}
local _G_fame = {}
local _percent = {}
function DATA_User:init()
	_data = {}
end

function DATA_User:set(data)
	_data = data
--	dump(data)
end

function DATA_User:set_fame(data)
	_G_fame = data
	--dump(data)
end

function DATA_User:get_fame()
	return _G_fame 
end

function DATA_User:set_percent(data)
	_percent  = data
end

function DATA_User:get_percent()
	return _percent 
end

function DATA_User:setkey(key , data)
	_data[key] = data
end


function DATA_User:get(key)
	if key == nil then return _data end

	return _data[key]
end
--返回当前主公统帅值
function DATA_User:getLead()
	local config = requires(IMG_PATH, "GameLuaScript/Config/User")
	return config[DATA_User:get("lv")]["lead"]
end
return DATA_User