--[[

		帮派数据

]]


DATA_Gang = {}


-- 私有变量
local _data = {}

function DATA_Gang:init()
	_data = {}
end

function DATA_Gang:set(data)
	_data = data
---list属性
---         "chieftains_name" = "tyc"			帮主
---         "chieftains_uid"  = "12705"			帮主uid
---         "count"           = 1				帮派当前人数			
---         "count_max"       = 20				帮派最大数
---         "funds"           = 0				资金
---         "id"              = "51"			帮派ID
---         "lv"              = 1				帮派等级
---         "name"            = "cc"			帮派名称
---         "notice"          = ""				公告内容
---         "rtime"           = 1374202908		自己入帮时间
---         "state"           = 1				自动加入申请为1      需申核后加入的为0
---         "sum_ability"     = 797				帮派战斗力
---         "time"            = "1374202908"	建帮派时间
---         "tribute"         = 0				帮贡
---         "userstate"       = 100				100 => '帮主' , 95 => '副帮主' , 90 => '堂主' , 0 => '帮众'
---         "usertribute"     = 0				帮威
---         "usertribute_v"   = 0				可用帮威
--         
--      成员信息
---     "info" = {						
---         1 = {
---             "ability" = 797					成员战力
---             "name"    = "tyc"				成员名称
---             "sex"     = "1"					成员性别
---             "silver"  = 0					成员总共捐献的银两
---             "state"   = 100					成员权限
---             "index"   = 0					成员同权限索引
---             "time"    = 1374202908			员成入职时间
---             "lv"    = 12					员成入等级
---             "title"   = "帮主"				成员头衔
---             "tribute" = 0					成员帮贡(帮威)
---             "uid"     = "12705"				成员uid
---         }
end
function DATA_Gang:get(key)
	if key == nil then return _data end
	
	return _data[key]
end

function DATA_Gang:set_type( type , data)
	_data[ type .. "" ] = data
end

--是否加入帮派
function DATA_Gang:isJoinGang()
	return ( table.nums( _data.list ) == 0 ) 
end
--返回申请的帮派列表
function DATA_Gang:getApply()
	return _data.apply or nil 
end

return DATA_Gang