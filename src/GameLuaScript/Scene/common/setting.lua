-- 设置界面
local PATH = IMG_PATH .. "image/scene/setting/"
local COMMONPATH = IMG_PATH .. "image/common/"

local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local mask
local SettingLayer = {

}


function SettingLayer:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	local setting_layer = display.newLayer()
    local settingScrollView = KNScrollView:new(10,270,454,330,5,false,0,{
    	priority = -131,
    	})
    --setAnchPos(settingScrollView, 13, 200)


	-- 背景
	local bg = display.newSprite(PATH .. "bg.png")
	setAnchPos(bg , 13 , 200)
	setting_layer:addChild(bg)

	local list_title_bg = display.newSprite(COMMONPATH .. "list_title.png")
	setAnchPos(list_title_bg , 25 , 612)
	setting_layer:addChild(list_title_bg)

	local title = display.newSprite(PATH .. "setting_title.png")
	setAnchPos(title , 170 , 613)
	setting_layer:addChild(title)
	

	local closeBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png" } , display.cx - 75 , 218 , {
		scale = true,
		priority = -130,
		front = COMMONPATH .. "colse_text.png" , 
		callback = function()
			this.layer:removeFromParentAndCleanup()
		end
	}):getLayer()
	setting_layer:addChild(closeBtn)



	-- 音乐
	local music_bg = display.newSprite(COMMONPATH .. "item_bg_high.png")
	setAnchPos(music_bg , 28 , 525)
	--setting_layer:addChild(music_bg)
	settingScrollView:addChild(music_bg)

	local music_title = display.newSprite(PATH .. "music.png")
	setAnchPos(music_title , 10 , 20)
	--setting_layer:addChild(music_title)
	music_bg:addChild(music_title)
	
	
	
	local function createBtn( target )
		if target then target:removeFromParentAndCleanup( true ) end 
		
		local isEffect = audio.isMusicPlaying()
		local musicBtn
		musicBtn = KNBtn:new(COMMONPATH, isEffect and { "btn_bg.png" } or { "btn_bg_grey.png" } , 330 , 20 , {
			front = PATH .. ( isEffect and "opened.png" or "closed.png"),
			priority = -130,
			callback = function()
				if isEffect then
					audio.stopMusic( false )
					audio.disable()
					KNFileManager.updatafile("savefile.txt" , "sound" , "=" , 1)
				else
					KNFileManager.updatafile("savefile.txt" , "sound" , "=" , 0)
					audio.enable()
					if audio.isMusicPlaying() == false then
						audio.playMusic( IMG_PATH .. "sound/background.mp3" , true )
					end
					
				end
				createBtn( musicBtn )
			end
		}):getLayer()
		--setting_layer:addChild(musicBtn)
		music_bg:addChild(musicBtn)
	end
	createBtn()


	-- 音效
	local sound_effect_bg = display.newSprite(COMMONPATH .. "item_bg_high.png")
	setAnchPos(sound_effect_bg , 28 , 441)
	--setting_layer:addChild(sound_effect_bg)
	settingScrollView:addChild(sound_effect_bg)
	
	local sound_effect_title = display.newSprite(PATH .. "sound_effect.png")
	setAnchPos(sound_effect_title , 10 , 20)
	--setting_layer:addChild(sound_effect_title)
	sound_effect_bg:addChild(sound_effect_title)
	
	local function createEffect( target )
		if target then target:removeFromParentAndCleanup( true ) end 
		
		local isPlay = audio.getIsEffect()
		local sound_effectBtn
		sound_effectBtn = KNBtn:new(COMMONPATH, isPlay and { "btn_bg.png" } or { "btn_bg_grey.png" } , 330 , 20 , {
			front = PATH .. ( isPlay and "opened.png" or "closed.png"),
			priority = -130,
			callback = function()
				if isPlay then
					KNFileManager.updatafile("savefile.txt" , "audio" , "=" , 1)
					audio.setIsEffect( false )
					--audio.playSound()
					--audio.setIsEffect( not  isPlay )
					
					createEffect( sound_effectBtn )
				else
					KNFileManager.updatafile("savefile.txt" , "audio" , "=" , 0)
					audio.setIsEffect( true )
					createEffect( sound_effectBtn )
				end
				
				
			end
		}):getLayer()
		--setting_layer:addChild(sound_effectBtn)
		sound_effect_bg:addChild(sound_effectBtn)
	end
	createEffect()
	--小助手
	local cur_mission_step = DATA_Guide:get()
	if (cur_mission_step["map_id"] > 11  or (cur_mission_step["map_id"] == 11  and cur_mission_step["mission_id"] >= 5) ) then
		local aideBtn = KNBtn:new(COMMONPATH , { "item_bg_high.png" } , 28, 0 , {
			parent = settingScrollView , 
			other =  { PATH .. "aide.png" , 10 , 20 } , 
			priority = -130,
			callback = function()
				mask:remove()
				local homeLayer = requires(IMG_PATH,"GameLuaScript/Scene/home/homelayer")
				homeLayer:createAide()
			end
		}):getLayer()
		settingScrollView:addChild(aideBtn)
	end
	

	-- 游戏论坛
if CHANNEL_ID ~= "DK" then
	local feedback_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 357 , {
		parent = settingScrollView , 
		other =  { PATH .. "bbs.png" , 10 , 20 } , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()
			local bbs_url = "http://bbs.szkuniu.com/"
			if CHANNEL_ID == "tmsj" or CHANNEL_ID == "tmsjtest" or CHANNEL_ID == "tmsjios" or CHANNEL_ID == "tmsjIosAppStore" then
				bbs_url = "http://tmsj.szkuniu.com"
			elseif CHANNEL_ID == "appFame" or CHANNEL_ID == "appFameOfficial" then
			    bbs_url = "http://bbs.gao7.com/forum-221-1.html"
			elseif CHANNEL_ID == "uc" then
				bbs_url = "http://bbs.9game.cn/forum-1133-1.html"
			elseif CHANNEL_ID == "uucun" then
				bbs_url = "http://m.uugames.cn"
			elseif CHANNEL_ID == "nearme.gamecenter" or CHANNEL_ID == "gfan" or CHANNEL_ID == "kugou" or CHANNEL_ID == "mi" or CHANNEL_ID == "downjoy" or CHANNEL_ID == "longyin" then
				bbs_url = "http://dhshbbs.ay99.net/"
			end

			if device.platform == "android" then
				UpdataRes:getInstance():openUrl( bbs_url )
			elseif device.platform =="ios" then
       			UpdateDataOC:getInstance():openUrl(bbs_url)
			else	
				local json = requires(IMG_PATH , "GameLuaScript/Network/dkjson")
				local response = io.readfile(IMG_PATH .. "temp_battle.txt")
				response = json.decode( response )

				DATA_Battle:setMod("guide")
				DATA_Battle:setAct("execute")
				DATA_Battle:set( response )
				local function overFun()
					switchScene("home")
				end
				
				switchScene("battle" , { resultCallFun = overFun } )
			end
		end
	}):getLayer()
	--setting_layer:addChild(feedback_bg)
	settingScrollView:addChild(feedback_bg)
end
	
	
	-- 游戏攻略
if CHANNEL_ID ~= "uucun" and CHANNEL_ID ~= "DK" then
	local help_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 273 , {
		parent = settingScrollView , 
		other = { PATH .. "gonglve.png" , 10 , 20 }  , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()
			local bbs_url = "http://bbs.szkuniu.com/forum.php?mod=viewthread&tid=6"
			if CHANNEL_ID == "tmsj" or CHANNEL_ID == "tmsjtest" or CHANNEL_ID == "tmsjios" or CHANNEL_ID == "tmsjIosAppStore" then
				bbs_url = "http://tmsj.szkuniu.com/forum.php?mod=viewthread&tid=1"
			elseif CHANNEL_ID == "appFame" or CHANNEL_ID == "appFameOfficial" then
				bbs_url = "http://bbs.gao7.com/forum-221-1.html"
			elseif CHANNEL_ID == "nearme.gamecenter" or CHANNEL_ID == "gfan" or CHANNEL_ID == "kugou" or CHANNEL_ID == "mi" or CHANNEL_ID == "downjoy" or CHANNEL_ID == "longyin" then
				bbs_url = "http://dhshbbs.ay99.net/default.aspx?g=topics&f=9"
			end

			if device.platform == "android" then
				UpdataRes:getInstance():openUrl( bbs_url )
			elseif device.platform =="ios" then
       			UpdateDataOC:getInstance():openUrl(bbs_url)
       		end
		end
	}):getLayer()
	--setting_layer:addChild(help_bg)
	settingScrollView:addChild(help_bg)
end


-- 更多游戏
if CHANNEL_ID == "uucun" then
	local more_games_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 273 , {
		parent = settingScrollView , 
		other = { PATH .. "more_games.png" , 10 , 20 }  , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()
			local url = "http://ad.plat56.com"

			if device.platform == "android" then
				UpdataRes:getInstance():openUrl( url )
			elseif device.platform =="ios" then
       			UpdateDataOC:getInstance():openUrl(url)
       		end
		end
	}):getLayer()
	settingScrollView:addChild(more_games_bg)
end

-- 多酷 客服电话&QQ
if CHANNEL_ID == "DK" then
	local more_games_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 273 , {
		parent = settingScrollView , 
		other = { PATH .. "dk/qq.png" , 10 , 20 }  , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function() end
	}):getLayer()
	settingScrollView:addChild(more_games_bg)

	local more_games_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 273 , {
		parent = settingScrollView , 
		other = { PATH .. "dk/mobile.png" , 10 , 20 }  , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function() end
	}):getLayer()
	settingScrollView:addChild(more_games_bg)
end


-- 激活码
local help_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 273 , {
	parent = settingScrollView , 
	other = { PATH .. ( "jihuoma.png" ) , 10 , 20 }  , 
	priority = -130,
	upSelect = true,
	parent = settingScrollView,
	callback = function()
		switchScene("uc_jihuoma")
	end
}):getLayer()
settingScrollView:addChild(help_bg)

	

if CHANNEL_ID == "91" then
    -- 91社区
	local center91_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 357 , {
		parent = settingScrollView , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()

			if device.platform =="ios" then
       			LuaCall91PlatForm:getInstance():enter91Center()
			end
		end
	}):getLayer()
	--setting_layer:addChild(feedback_bg)
	settingScrollView:addChild(center91_bg)

	local center91_title = display.newSprite(PATH .. "91Center.png")
	setAnchPos(center91_title , 10 , 20)
	--setting_layer:addChild(feedback_title)
	center91_bg:addChild(center91_title)


    -- 91平台18183BBS
	local BBS18183_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 357 , {
		parent = settingScrollView , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()
			if device.platform =="ios" then
       			LuaCall91PlatForm:getInstance():enter18183BBS()
			end
		end
	}):getLayer()
	--setting_layer:addChild(feedback_bg)
	settingScrollView:addChild(BBS18183_bg)

	local BBS18183_title = display.newSprite(PATH .. "18183BBS.png")
	setAnchPos(BBS18183_title , 10 , 20)
	--setting_layer:addChild(feedback_title)
	BBS18183_bg:addChild(BBS18183_title)


	-- 91用户反馈
	local userFeedBack_bg = KNBtn:new( COMMONPATH , { "item_bg_high.png" } , 28 , 357 , {
		parent = settingScrollView , 
		priority = -130,
		upSelect = true,
		parent = settingScrollView,
		callback = function()
			if device.platform =="ios" then
       			LuaCall91PlatForm:getInstance():userFeedBack()
			end
		end
	}):getLayer()
	--setting_layer:addChild(feedback_bg)
	settingScrollView:addChild(userFeedBack_bg)

	local userFeedBack_title = display.newSprite(PATH .. "userFeedBack.png")
	setAnchPos(userFeedBack_title , 10 , 20)
	--setting_layer:addChild(feedback_title)
	userFeedBack_bg:addChild(userFeedBack_title)
end


if CHANNEL_ID == "game1" or CHANNEL_ID == "uc" or CHANNEL_ID == "test" or CHANNEL_ID == "windows" then
	--领取20级礼包
	local get20lvBtn = KNBtn:new(COMMONPATH , { "item_bg_high.png" } , 28, 0 , {
		parent = settingScrollView , 
		other =   { PATH .. "get_20_lv.png" , 10 , 20 } ,
		priority = -130,
		callback = function()
			if CHANNEL_ID == "uc" then
				HTTP:call("ucactivation", "lvgt20", {} , {success_callback = function()end})	
			else
				HTTP:call("feedback", "lvgt20", {} , {success_callback = function()end})
			end
		end
	}):getLayer()
	settingScrollView:addChild( get20lvBtn )
	
	--领取内测公测 礼包
	local getRank = KNBtn:new(COMMONPATH , { "item_bg_high.png" } , 28, 0 , {
		parent = settingScrollView , 
		other =   { PATH .. "get_rank.png" , 10 , 20 } ,
		priority = -130,
		callback = function()
			if CHANNEL_ID == "uc" then
				HTTP:call("ucactivation", "rank100", {} , {success_callback = function()end})	
			else
				HTTP:call("feedback", "rank100", {} , {success_callback = function()end})
			end
		end
	}):getLayer()
	settingScrollView:addChild( getRank )
end
	
if CHANNEL_ID == "game1" or CHANNEL_ID == "test" or CHANNEL_ID == "windows" then
	--领取充值返三倍黄金
	local getGold = KNBtn:new(COMMONPATH , { "item_bg_high.png" } , 28, 0 , {
		parent = settingScrollView , 
		other =   { PATH .. "get_gold.png" , 10 , 20 } ,
		priority = -130,
		callback = function()
			local function showGold( tempData )
				tempData = tempData or {}
				
				local popLayer = display.newLayer()
				local popmask
				popLayer:addChild( display.newSprite( COMMONPATH .. "tip_bg.png" , display.cx , 336 , 0.5 , 0 ) )
				popLayer:addChild( display.newSprite( PATH .. "get_gold_tip.png" , display.cx , 505 , 0.5 , 0 ) )
				popLayer:addChild( display.newSprite( PATH .. "today_get.png" , display.cx , 443 , 0.5 , 0 ) )
				--之前充值了多少
				popLayer:addChild( display.strokeLabel( tempData.paygold , 255 , 540, 18 , ccc3(0x2c, 0x00, 0x00 ), nil, nil, {
					dimensions_width = 50,
					dimensions_height = 20 ,
					align = 1,
				}) )
				--总计可领
				popLayer:addChild( display.strokeLabel( tonumber(tempData.paygold) * 3 , 50 , 508, 18 , ccc3(0x2c, 0x00, 0x00 ), nil, nil, {
					dimensions_width = 67,
					dimensions_height = 20 ,
					align = 1,
				}) )
				--每天可领
				popLayer:addChild( display.strokeLabel( tempData.onceback , 322 , 508, 18 , ccc3(0x2c, 0x00, 0x00 ), nil, nil, {
					dimensions_width = 67,
					dimensions_height = 20 ,
					align = 1,
				}) )
				--今天可领
				popLayer:addChild( display.strokeLabel( tempData.onceback , 180 , 448, 18 , ccc3(0x2c, 0x00, 0x00 ), nil, nil, {
					dimensions_width = 50,
					dimensions_height = 20 ,
					align = 1,
				}) )
				--还能领取多少次
				popLayer:addChild( display.strokeLabel( tempData.remain , 375 , 448, 18 , ccc3(0x2c, 0x00, 0x00 ), nil, nil, {
					dimensions_width = 25,
					dimensions_height = 20 ,
					align = 1,
				}) )
				
				popLayer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, 77 , 361 , {
											front = COMMONPATH .. "get.png" ,
											priority = -131,
											callback = 
											function()
												HTTP:call("feedback", "pay", {} , {success_callback = function() popmask:remove()  end})
											end}):getLayer())
				popLayer:addChild( KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"}, 267 , 361 , {
											front = COMMONPATH .. "cancel.png" ,
											priority = -131,
											callback = 
											function()
												popmask:remove()
											end}):getLayer())
									
				setAnchPos( popLayer , 0 , display.height )
				transition.moveTo(  popLayer , { time = 0.3 , y = 0 , easing = "BACKOUT" })
				popmask = KNMask:new( { item = popLayer , priority = -131 } )
				this.layer:addChild( popmask:getLayer() )
			end
			HTTP:call("feedback", "get_pay", {} , {success_callback = function(tempData) showGold( tempData ) end})
		end
	}):getLayer()
	settingScrollView:addChild( getGold )
end


if CHANNEL_ID == "game1" or CHANNEL_ID == "tmsj" or CHANNEL_ID == "tmsjtest" or CHANNEL_ID == "tmsjios" or CHANNEL_ID == "tmsjIosAppStore" or CHANNEL_ID == "test" or CHANNEL_ID == "windows" then
	--修改密码
	local passwordBtn = KNBtn:new(COMMONPATH , { "item_bg_high.png" } , 28, 0 , {
		parent = settingScrollView , 
		other =   { PATH .. "password.png" , 10 , 20 } ,
		priority = -130,
		callback = function()
			local url = CONFIG_HOST .. "/html.php?m=security&a=password&server_id=" .. DATA_Session:get("server_id") .. "&sid=" .. DATA_Session:get("sid") .. "&uid=" .. DATA_Session:get("uid") .. "&channel=" .. CHANNEL_ID .. "&channel_group=" .. CHANNEL_GROUP
			if device.platform == "android" then
				UpdataRes:getInstance():openUrl( url )
			elseif device.platform =="ios" then
       			UpdateDataOC:getInstance():openUrl(url)
       		else
       			KNMsg.getInstance():flashShow("手机才能使用该功能")
       		end
		end
	}):getLayer()
	settingScrollView:addChild( passwordBtn )
end
	
	

    setting_layer:addChild(settingScrollView:getLayer())
    settingScrollView:alignCenter()

	-- 遮罩
	setAnchPos( setting_layer , 0 , -display.height )
	transition.moveTo(  setting_layer , { time = 0.5 , y = 0 , easing = "SINEOUT" })
	
	mask = KNMask:new({item = setting_layer})
	this.layer:addChild( mask:getLayer() )
	

	
	

	
    return this
end


function SettingLayer:getLayer()
	return self.layer
end


return SettingLayer