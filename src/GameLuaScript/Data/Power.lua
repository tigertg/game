--[[

帐户数据

]]


DATA_Power = {}


-- 私有变量
local _data = {}
--local isFrist = true
function DATA_Power:init()
	_data = {}
end

function DATA_Power:set(data)
	_data = data
	
--	if not isFrist then
--		GLOBAL_INFOLAYER:refreshInfo()
--	end
--	isFrist = false
	if display.getRunningScene().name == "home" then
		GLOBAL_INFOLAYER:refreshInfo()
	end
	local coutTime = 0
	local function refreshTime()
	
		coutTime = coutTime + 1
		
		if coutTime >= tonumber( data.speed ) then
			coutTime = 0
			
			if tonumber(_data.num) < tonumber(_data.max) then
			
				_data.num = _data.num + 1
				GLOBAL_INFOLAYER:refreshInfo()
				
			end
		end
	end
	
	Clock:addTimeFun( "power" , refreshTime )
	
end


function DATA_Power:get(key)
	if key == nil then return _data end

	return _data[key]
end
return DATA_Power