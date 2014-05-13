--[[

帐户数据

]]


DATA_Energy = {}


-- 私有变量
local _data = {}

function DATA_Energy:init()
	_data = {}
end

function DATA_Energy:set(data)
	_data = data
	
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
	
	Clock:addTimeFun( "energy" , refreshTime )
	
end


function DATA_Energy:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_Energy