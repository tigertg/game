--[[

������

]]


DATA_ExpConfig = {}


local _pramp = {}
-- ˽�б���
local _data = {}

function DATA_ExpConfig:init()
	_data = {}
	_pramp = {}
end


function DATA_ExpConfig:set(data)
	_data = data
end
function DATA_ExpConfig:get_data()
	return _data
end

return DATA_ExpConfig