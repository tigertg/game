--[[

		在线礼包

]]


DATA_Activity = {}


-- 私有变量
local _data = {}

function DATA_Activity:init()
	_data = {}
end

function DATA_Activity:set(data)
	_data = data
end
function DATA_Activity:get(key)
	if key == nil then return _data end

	return _data[key]
end


function DATA_Activity:set_type( data )
	_data[ "type" ] = data.type
	_data[ "list" ] = data.list
	_data[ data.type .. "Data"] = data.data
	
	local function refreshTime()
		if _data[ "wineData" ] then
			_data[ "wineData" ].time.pass = _data[ "wineData" ].time.pass + 1
		else
			Clock:removeTimeFun( "wineClock" )
		end
	end
	
	if _data[ "wineData" ] then
		if not Clock:getKeyIsExist( "wineClock" ) then
			Clock:addTimeFun( "wineClock" , refreshTime )
		end 
	end
	
	
end
--获取对酒时间
function DATA_Activity:getWineInfo()
	local wineData = _data[ "wineData" ].time.config
	local curTime = _data[ "wineData" ].time.pass
	for i = 1 , table.nums( wineData ) do
		local startTime = wineData[i..""].start * 3600
		local endTime = wineData[i.."" ]["end"] * 3600
		
		if curTime > startTime and curTime < endTime then
			--正在领取时间
			if #_data[ "wineData" ].received > 0 then
				for j = 1 , #_data[ "wineData" ].received do
					if _data[ "wineData" ].received[j] == i then
						return "当前时段奖励已经领取" , false
					end
				end
				return "好汉,快来对酒吧！" , true
			else
				return "好汉,快来对酒吧！" , true
			end
		end
		
		if curTime <= startTime then
			local curSurplus = startTime - curTime
			return "距离下次对酒还剩  " .. timeConvert( curSurplus ) , false
		end
		
		if i == 2 then
			--过了第二次对酒时间（加上今天剩余时间，然后加上明天到第一次对酒的开始时间）
			if curTime > endTime then
				local tomorrowTime = wineData["1"].start * 3600 --0点到明天开始的时间
				local curSurplus = 24 * 3600 - curTime
				return "距离下次对酒还剩  " .. timeConvert( tomorrowTime + curSurplus ) , false
			end
		end
	end
	
	return nil , false
end
--删除对酒数据以终止时间
function DATA_Activity:delWineData()
	_data[ "wineData" ] = nil
end
--获取活动列表
function DATA_Activity:getlist(key)
	return _data["list"] or nil
end
--获取当前活动
function DATA_Activity:getCurType()
	return _data["type"] or nil
end
--获取当前活动数据
function DATA_Activity:getCurData()
	return _data[ _data["type"] .. "Data" ] or nil
end


--获取充值奖励倒计时时间
function DATA_Activity:getPayTime()
	if _data[ "paymentData" ].clock then
		_data[ "paymentData" ].clock = _data[ "paymentData" ].clock - 1
	end
	return _data[ "paymentData" ].clock
end

--五星英雄倒计时
function DATA_Activity:getSinglepaymaxDataTime()
	if _data[ "singlepaymaxData" ].clock then
		_data[ "singlepaymaxData" ].clock = _data[ "singlepaymaxData" ].clock - 1
	end
	return _data[ "singlepaymaxData" ].clock
end
--全民福利倒计时
function DATA_Activity:getwelfareDataTime()
	if _data[ "welfareData" ].clock then
		_data[ "welfareData" ].clock = _data[ "welfareData" ].clock - 1
	end
	return _data[ "welfareData" ].clock
end
--超级兑换倒计时
function DATA_Activity:getxchangeDataTime()
	if _data[ "xchangeData" ].clock then
		_data[ "xchangeData" ].clock = _data[ "xchangeData" ].clock - 1
	end
	return _data[ "xchangeData" ].clock
end
--超级兑换倒计时
function DATA_Activity:getlogincountDataTime()
	if _data[ "logincountData" ].clock then
		_data[ "logincountData" ].clock = _data[ "logincountData" ].clock - 1
	end
	return _data[ "logincountData" ].clock
end


return DATA_Activity