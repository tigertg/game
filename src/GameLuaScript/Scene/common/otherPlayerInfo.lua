-- 其它玩家信息
local PATH = IMG_PATH.."image/scene/userinfo/"
local COMMONPATH = IMG_PATH .. "image/common/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local M = {

}


function M:new( params )
	params = params or {}
	local isFriend = params.isFriend or false
	local addCallBackFun = params.addCallBackFun or function()end
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	this.layer = display.newLayer()
	local content = display.newLayer()
	-- 背景
	local bg = display.newSprite(COMMONPATH .."bg.png")
	setAnchPos(bg , 13 , 200)
	content:addChild(bg)

	local list_title_bg = display.newSprite(COMMONPATH .. "list_title.png")
	setAnchPos(list_title_bg , 25 , 633)
	content:addChild(list_title_bg)

	local title = display.newSprite(COMMONPATH .. "player_info_title.png")
	setAnchPos(title , 138 , 633)
	content:addChild(title)
	
	-- 创建他人基本信息
	local curData = DATA_OTHER:get("base")
	local function createUserLayer()
	
		local userInfoLayer = display.newLayer()
		
		local infoBg = display.newSprite(PATH.."info_bg.png")	
		setAnchPos(infoBg , 245 , 670 , 0.5 , 0.5)
		userInfoLayer:addChild(infoBg)
		
		--玩家头像
		infoBg = display.newSprite(COMMONPATH .."sex" .. curData.sex .. ".jpg")
		setAnchPos( infoBg , 57 , 630 )
		userInfoLayer:addChild(infoBg)
		
		infoBg = display.newSprite(COMMONPATH.."role_frame.png")
		setAnchPos(infoBg,56,627)
		userInfoLayer:addChild(infoBg)
		
		--名称显示
		local text = display.newSprite(PATH.."name.png")
		setAnchPos( text , 130 , 680 )
		userInfoLayer:addChild(text)
		
		if curData.viplv ~= 0 then
			userInfoLayer:addChild( display.newSprite(  IMG_PATH.."image/scene/vip/v" .. curData.viplv .. ".png" , 210 , 680 , 0 , 0 ) )
		end
		text = display.strokeLabel( curData.name , ( curData.viplv ~= 0 and 250 or 210 ) , 678 , 24 , ccc3(0x4a,0x08,0x08) )
		userInfoLayer:addChild(text)
		
		--称号显示
		text = display.newSprite(PATH.."title.png")
		setAnchPos(text,130,635)
		userInfoLayer:addChild(text)
		
		local str = {
					["无"] = "v0.png" , 
					["小有名气"] = "v1.png" , 
					["青云直上"] = "v2.png" , 
					["锋芒毕露"] = "v3.png" , 
					["风华正茂"] = "v4.png" , 
					["声名鹊起"] = "v5.png" , 
					["名声显赫"] = "v6.png" , 
					["中流砥柱"] = "v7.png" , 
					["风云人物"] = "v8.png" , 
					["威震九州"] = "v9.png" , 
					["盖世英雄"] = "v10.png" ,
					}
		
		local curName = "无"
		if curData.rank then
			for i = 1, #getTitle() do
				if tonumber( curData.rank ) > getTitle()[i][1] then
					curName = getTitle()[i][2]
					break
				end
			end
		end
		
		text = display.newSprite( PATH .. str[ curName ] )
		setAnchPos(text, 210, 635)
		userInfoLayer:addChild(text)
		
		local detailBg = display.newSprite( PATH.."other_detail_bg.png" )	
		setAnchPos(detailBg,245,510,0.5,0.5)
		userInfoLayer:addChild(detailBg)
		detailBg:setScaleY(0.9)
		
		local config = requires(IMG_PATH, "GameLuaScript/Config/User")
		local commanderValue = config[curData.lv]["lead"]
		local showElement = {
				{ text = "id" 		, value = curData.touid 	} ,													--玩家id
				{ text = "level" 	, value = curData.lv 	} ,														--玩家等级
				{ text = "exp"		, value = curData.cur_exp.."/"..curData.lvup_exp	} ,							--玩家经验
				{ text = "value"	, value = curData.ability	} ,													--玩家战力
				{ text = "on"		, value = curData[ "formation_count" ].."/" .. curData[ "formation_max" ]	} ,	--上阵武将
				{ text = "commander", value = commanderValue	} ,															--统帅
				{ text = "gang"		, value = curData.alliance	} ,													--帮会
		}
		local addX , addY
		for i = 1 , #showElement do
			local curData = showElement[i]
			if curData.text ~= "" then
				addX = 60 + ( i - 1 ) % 2 * 212
				addY = 560 - math.floor( ( i - 1 ) / 2 ) * 45
				local pathStr = PATH .. curData.text .. ".png"
				if curData.text == "gold" or curData.text == "silver" then
					pathStr = COMMONPATH .. curData.text .. ".png"
				end
				
				userInfoLayer:addChild( display.newSprite( pathStr , addX , addY , 0 , 0  ) )
				addX = addX + 93
				if curData.text == "on" then
					addX = addX + 18
				elseif curData.text == "vip_text" then
					addX = addX + 10
				elseif curData.text == "gold" or curData.text == "silver" then
					addX = addX - 50
				end
				userInfoLayer:addChild( display.strokeLabel(curData.value , addX  , addY , 24 , ccc3( 0xff , 0xfb , 0xd4 ) ) )
			end
		end
		
		setAnchPos(userInfoLayer , 0 , -110)
		return userInfoLayer
	end
	
	content:addChild( createUserLayer() )
	
	
	
	
	--关闭按钮
	local closeBtn = KNBtn:new(IMG_PATH .. "image/scene/chat/", { "close.png"  , "close_press.png" } ,  display.cx + 27 + 163  , 235 + 377  , {
	scale = true,
	priority = -146,
	callback = function()
		this.layer:removeFromParentAndCleanup( true )
	end
	}):getLayer()
	content:addChild(closeBtn)
	
	--添加好友
	local addBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"} ,  display.cx + 27 , 235 , {
	scale = true,
	priority = -146,
	front = PATH .. "add_friend.png" , 
	callback = function()
		if tonumber( curData["touid"] ) ~= tonumber( DATA_Session:get("uid") ) then
			HTTP:call("friends","addfrd",{ id = curData["touid"] },{success_callback = 
						function()
								this.layer:removeFromParentAndCleanup( true )
								addCallBackFun()
						end})
		else
			KNMsg.getInstance():flashShow( "不能添加自己为好友!" )	
		end
		
	end
	})
	addBtn:setEnable( not isFriend )
	content:addChild( addBtn:getLayer() )
		
	--查看阵容
	local seeBtn = KNBtn:new( COMMONPATH , 
		{ "btn_bg_red.png" ,"btn_bg_red_pre.png" } , 
		63 , 
		235 ,
		{
			priority = -146,
			scale = true,
			front = COMMONPATH .. "see_battle_array.png" ,
			callback = 
			function( otherData )
				HTTP:call("profile","getuidformation",{ touid = curData["touid"] },{success_callback = 
					function()
--							this.layer:removeFromParentAndCleanup( true )
							if DATA_OTHER:get_index(1) then
								DATA_OTHER:setCur( DATA_OTHER:get_index(1)["gid"] )
								pushScene("otherHero" , { gid = DATA_OTHER:getCur() , closeCallback = function()  popScene() end})
							else
								KNMsg.getInstance():flashShow( "对方数据异常无法查看" )	
							end
					end})
			end
		}):getLayer()
	content:addChild( seeBtn )
	

	
	

	-- 遮罩
	local mask = KNMask:new({item = content , priority = -145})
	this.layer:addChild( mask:getLayer() )

	
    return this
end

function M:getLayer()
	return self.layer
end

return M