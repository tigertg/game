DATA_Info = {}
local _data = {}
local talkData = {}
local sourceType = nil	--清息来源
local worldMsg = nil	--世界消息记录
local gangMsg = nil 	--帮派消息记录
local friendMsg = nil 	--私聊消息记录
function DATA_Info:init()
	_data = {}
	_data["gang"] = {}
	_data["gang"].chat = {}
	
	talkData = {}
	talkData["isHide"] = true
	talkData["isMsg"] = false
	talkData["actionObj"] = {}
	
end

function DATA_Info:set(data)
	_data = data
	_data["gang"] = _data["gang"] or {}
	_data["gang"].chat =_data["gang"].chat or {}
end

function DATA_Info:set_type(name,data)
	_data[name] = data
	if name == "friend" then
		local tempData = {}
		--拼合字符
		local function joinStr( tempData )
			local curData = tempData
			local toFrom = true	--我对他说
			local touid = nil
			local himStr = ""
			for i = 1 , #curData do
				if tonumber( curData[i].uid ) ~=  tonumber( DATA_Session:get("uid") ) then
					himStr = curData[i].name
					touid = curData[i].uid
					if curData[i].type == "siliao_2" then
						toFrom = true
					else
						toFrom = false
					end
				end
	
			end
			return toFrom and ( "我对【" .. himStr .."】说:" ) or ( "【" .. himStr .. "】对我说:" ) , touid
		end
		for key , v in pairs( data ) do
			--显示所有聊天记录
			if not v.uid then
				local tempItem , touid = joinStr( v.item )
				table.insert( v.msg , 1 , tempItem )
				tempData[ #tempData + 1 ] = v
				tempData[ #tempData ].uid = touid
				tempData[ #tempData ].template = "#s#" ..  tempData[ #tempData ].template
			end
		end
		_data[name] = tempData
	end
	
end

function DATA_Info:insert(name,data)
	if name == "gang" then
		if table.getn(_data[name].chat) >= 50 then
			table.remove(_data[name].chat,1)
		end
		table.insert(_data[name].chat,data)
		return
	end
	if name == "friend" then
		_data[name] = _data[name] or {}
		local function joinStr( tempData )
			local curData = tempData
			local toFrom = true	--我对他说
			local touid = nil
			local himStr = ""
			for i = 1 , #curData do
				if tonumber( curData[i].uid ) ~=  tonumber( DATA_Session:get("uid") ) then
					himStr = curData[i].name
					touid = curData[i].uid
					if curData[i].type == "siliao_2" then
						toFrom = true
					else
						toFrom = false
					end
				end
	
			end
			return toFrom and ( "我对【" .. himStr .."】说:" ) or ( "【" .. himStr .. "】对我说:" ) , touid
		end
		
		local tempItem , touid = joinStr( data.item )
		table.insert( data.msg , 1 , tempItem )
		data.uid = touid
		data.template = "#s#" ..  data.template
		
	end
	if table.getn(_data[name]) >= 50 then
		table.remove(_data[name],1)
	end
	table.insert(_data[name],data)
end

function DATA_Info:get_type(name)
	return _data[name]
end

function DATA_Info:get_data()
	return _data["result"]
end
--是否打开聊天界面
function DATA_Info:setIsOpen( b )
	talkData["isHide"] = ( b == nil ) and true or b
end
function DATA_Info:getIsOpen( )
	return talkData["isHide"]
end
--是否有新消息
function DATA_Info:setIsMsg( b )

	talkData["isMsg"] = ( b == nil ) and talkData["isMsg"] or b
		
	local function btnAction( obj )
		if not( talkData["isMsg"] and talkData["isHide"]) then	--结束动画
			obj:setFront( IMG_PATH .. "image/scene/chat/talk_flag.png" )
			return
		end
		
		local actions = CCArray:create()
		actions:addObject( CCCallFunc:create( function() transition.scaleTo( obj:getFront() , {time = 0.3 , scale = 1.3 } )  end ) )
		actions:addObject( CCDelayTime:create( 0.3 ) )
		actions:addObject( CCCallFunc:create( function() transition.scaleTo( obj:getFront() , {time = 0.3 , scale = 1 } ) end ) )
		actions:addObject( CCDelayTime:create( 0.3 ) )
		actions:addObject( CCCallFunc:create( function() btnAction(obj) end ) )
		display.getRunningScene():runAction( CCSequence:create( actions ) )
	end
	
	local flagElement = {
				world = "talk_flag3.png" , 	
				gang = "talk_flag2.png" , 	
				friend = "talk_flag4.png" , 	
		}
	if talkData["isMsg"] and talkData["isHide"] then
		for key , v in pairs( talkData["actionObj"] ) do
			v:setFront( IMG_PATH .. "image/scene/chat/" .. flagElement[sourceType] )
--			v:setFront( IMG_PATH .. "image/scene/chat/" .. flagElement[sourceType]( sourceType == "gang" and "talk_flag2.png" or "talk_flag3.png" ) )
			btnAction(v)
		end
	else
		sourceType = worldMsg
		worldMsg = nil
		gangMsg = nil
		friendMsg = nil
		
		for key , v in pairs( talkData["actionObj"] ) do
			if sourceType then
				btnAction(v)
			else
				v:setFront( IMG_PATH .. "image/scene/chat/talk_flag.png" )
			end
		end
	end
end
--设置消息来源
function DATA_Info:msgSource( type )
	
	if type == "world" then worldMsg = true end
	if type == "gang" then gangMsg = true end
	if type == "friend" then friendMsg = true end
	
	sourceType = type
	if sourceType then
		--消息优先级设置
		if friendMsg then
			sourceType = "friend"
		elseif  gangMsg then
			sourceType = "gang"
		elseif worldMsg then
			sourceType = "world"
		end
--		if type == "gang" then sourceType = type end
	else
		sourceType = type
	end
end
--获取消息来源
function DATA_Info:getSourceType()
	return sourceType
end
--做消息展示的按钮
function DATA_Info:addActionBtn( name , btnObj )

	talkData["actionObj"][ name .. "" ] = btnObj
end


return DATA_Info