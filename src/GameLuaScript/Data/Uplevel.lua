--[[

		升阶配置

]]


DATA_Uplevel = {}


-- 私有变量
local _data = {}

function DATA_Uplevel:init()
	_data = requires(IMG_PATH , "GameLuaScript/Config/generalstageconfig")
end

function DATA_Uplevel:set(data)
	_data = data
end


function DATA_Uplevel:get(key)
	if key == nil then return _data end

	return _data[key]
end
--是否可以升阶
function DATA_Uplevel:getCanUplv( _id )
	local targetData = DATA_Bag:get( "general" , _id )
	local targetStar = getConfig( "general",  targetData.cid , "star")
	local tragetUpLevelData =_data[ targetStar  .. "" ]	--当前英雄对应的升阶数据
	
	local maxLv = tonumber( tragetUpLevelData.initial_lv + tragetUpLevelData.lvadd*targetData.stage )	--当前阶数最大可升至多少级
	
	local manMax = tonumber( DATA_User:get("lv") ) * 2	--主公等级限制英雄等级数
	
	if tonumber( targetData.lv ) >= manMax then
		return 1 , manMax	--受主公等级限制,当前不可传功
	else
		if tonumber( targetData.lv ) >= maxLv then
			return 2 , maxLv	--已到最大级别数，还可再升级
		else
			return 3 , maxLv	--可以正常传功
		end
	end
end

return DATA_Uplevel