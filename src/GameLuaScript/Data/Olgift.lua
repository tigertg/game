--[[

		在线礼包

]]


DATA_Olgift = {}


-- 私有变量
local _data = {}

function DATA_Olgift:init()
	_data = {}
end

function DATA_Olgift:set(data)
	_data = data
end

function DATA_Olgift:set_type(name,data)
	_data[name] = data
	
	local function refreshTime()
		_data["olgift"].sec = _data["olgift"].sec - 1
		if _data["olgift"].sec < 0 then
			Clock:removeTimeFun( "olgift" )
		end
	end
	
	if name == "olgift" then
		if _data[name].sec > 0 then
			if not Clock:getKeyIsExist( "olgift" ) then
				Clock:addTimeFun( "olgift" , refreshTime )
			end 
		else
			if Clock:getKeyIsExist( "olgift" ) then
				Clock:removeTimeFun( "olgift" )
			end 
		end
	end
end


function DATA_Olgift:get(key)
	if key == nil then return _data end

	return _data[key]
end

return DATA_Olgift