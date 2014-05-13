--[[

		游戏公告数据

]]


DATA_Notice = {}


-- 私有变量
local _data = {}

function DATA_Notice:init()
	_data = {}
	_data.isFirst = true
end

function DATA_Notice:set(data)
	_data = data
	_data.isFirst = true
end

function DATA_Notice:getIsFirst()
	if KNGuide:getStep() > 0 then
		--有引导时不弹出公告页面
		_data.isFirst = false
	end
	return _data.isFirst
end
function DATA_Notice:setIsFirst( value )
	_data.isFirst = value or true
end
function DATA_Notice:get(key)
	_data.isFirst = false
	if key == nil then return _data end
	return _data[key]
end


--设置当前可领取取奖励个数
function DATA_Notice:setGetNum( value )
	_data = _data or {}
	_data.getNum = value
end
--获取当前可领取取奖励个数
function DATA_Notice:getGetNum( value )
	return _data.getNum or 0
end


return DATA_Notice