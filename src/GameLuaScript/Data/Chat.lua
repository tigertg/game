--[[

聊天

]]


DATA_Chat = {}


-- 私有变量
local _data = {}

-- 最多存储条数
local _max = 20

-- 消息推送数字
local _num = 0

function DATA_Chat:init()
	_data = {}
	_num = 0
end

function DATA_Chat:addData(data)
	table.insert(_data , data)

	if #_data > _max then
		table.remove(_data , 1)
	end
end

function DATA_Chat:getAll()
	return _data
end


function DATA_Chat:getLast()
	if #_data == 0 then return nil end

	return _data[#_data]
end

function DATA_Chat:initNum(data)
	if data["battle"] and data["battle"] > 0 then
		DATA_Chat:setNum(data["battle"])
	end
end

function DATA_Chat:setNum(num)
	_num = tonumber(num)
end

function DATA_Chat:getNum()
	return _num
end

return DATA_Chat