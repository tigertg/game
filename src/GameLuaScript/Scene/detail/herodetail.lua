local PATH = IMG_PATH .. "image/scene/detail/"
local HEROPATH = IMG_PATH .. "image/scene/hero/"
local HERO_PATH = IMG_PATH .. "image/hero/"
local COMMONPATH = IMG_PATH .. "image/common/"
local KNBar = requires(IMG_PATH , "GameLuaScript/Common/KNBar")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config = requires(IMG_PATH , "GameLuaScript/Config/Hero")
local equipConfig = requires(IMG_PATH , "GameLuaScript/Config/Equip")
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
--[[英雄详情]]
local HeroDetail = {
	viewLayer,
	layer,
	params
}


function HeroDetail:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	

	this.layer = display.newLayer()
	this.viewLayer = display.newLayer()
	setAnchPos( this.viewLayer , 0 , -10)
	this.params = params or {}
	
	local isOther =  params.isOther or false	--是否是他人信息展示
	
	local gid = 0
	local _data = {}
	if params.id ~= nil then
		gid = params.id
		_data = isOther and DATA_OTHER:getGeneral( gid ) or DATA_General:get(gid)
	elseif params.data ~= nil then
		_data = params.data
		gid = _data["id"]
	end

	gid = tonumber(gid)

	local cid = tostring(_data["cid"])
	local config_data = Config[cid]
	
	local bg_big = display.newSprite(COMMONPATH .. "bg_big.png")
	local bg = display.newSprite(PATH .. "bg.png")


	local big_icon = display.newSprite(getImageByType(cid , "b"))
	local name_label = display.strokeLabel( config_data["name"] , 65 , 695 , 24 ,DESCCOLOR )
	local nickname_label = display.strokeLabel( config_data["bieming"] or "" , 145 , 690 , 20 , ccc3( 0xef , 0x7a , 0x1a ) )
	
	_data["lv"] = _data["lv"] or 1
	local lv_label = display.strokeLabel( "Lv" .. _data["lv"] , 230 , 695 , 18 , DESCCOLOR )

	
	_data["cur_exp"] = _data["cur_exp"] or 0
	_data["lvup_exp"] = _data["lvup_exp"] or _data["cur_exp"] + 1
	local exp_bar = KNBar:new("exp_general" , 62 , 173 , {
		maxValue = _data["lvup_exp"],
		curValue = _data["cur_exp"],
	})
	exp_bar:setIsShowText(false)



	-- 武将职业标记
	local jobFlag = nil
	if tonumber(config_data["role"]) > 0 then
		jobFlag = display.newSprite(  COMMONPATH .. "job" .. config_data["role"] .. ".png" )
	end

	--个人信息
	local title = display.newSprite(PATH .. "hero_info.png")
	local atk_label = display.strokeLabel( "攻 " .. (_data["atk"] or getConfig("general", cid, "atk_c")) , 355 , 657 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
	local def_label = display.strokeLabel( "防 " .. (_data["def"] or getConfig("general", cid, "def_c")) , 355 , 620 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
	local hp_label = display.strokeLabel(  "命 " .. (_data["hp"] or  getConfig("general", cid, "hp_c"))  , 355 , 585 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
	local agi_label = display.strokeLabel( "敏 " .. (_data["agi"] or  getConfig("general", cid, "agi_c")) , 355 , 549 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )



	setAnchPos(bg_big , 18 , 118)
	setAnchPos(bg , 33 , 348)
	setAnchPos(big_icon , 45 , 390)
	setAnchPos(title , 345 , 698)
	



	
	if jobFlag ~= nil then setAnchPos(jobFlag , 50 , 590 ) end


	this.layer:addChild(bg_big, -10)
	this.viewLayer:addChild(bg)
	
	local hero_info_bg = KNBtn:new( PATH , {"hero_info_bg.png"} , 340 , 497 ,
			{ 	
			callback  = function()
				if params.id == nil then
					KNMsg.getInstance():flashShow("没有更多属性信息")
					return 
				end
				HTTP:call("general" , "get_attr",{ target = DATA_Session:get("uid") , id =_data.id },{success_callback = 
				function(tempData)
					local additionLayer = requires( IMG_PATH , "GameLuaScript/Scene/common/additioninfo" )
					additionLayer:new( { data = tempData } )
				end })
				
				
			end	}):getLayer()
	this.viewLayer:addChild(hero_info_bg)
	this.viewLayer:addChild( display.strokeLabel( "更多<<" , 355 , 513 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
	
	this.viewLayer:addChild(big_icon)
	this.viewLayer:addChild(name_label)
	this.viewLayer:addChild(nickname_label)
	this.viewLayer:addChild(lv_label)
	this.viewLayer:addChild(exp_bar)
	this.viewLayer:addChild(atk_label)
	this.viewLayer:addChild(def_label)
	this.viewLayer:addChild(hp_label)
	this.viewLayer:addChild(agi_label)
	this.viewLayer:addChild(title)
	
	local starConfige = getConfig( "generalstageconfig" , _data["star"] )
	local maxLv = starConfige.initial_lv + starConfige.lvadd * tonumber( _data["stage"] )	
	local str = "当前英雄最高等级为".. maxLv .. "级" .. ( _data["star"] > 2 and "-可进化" or "")
	this.viewLayer:addChild( display.strokeLabel( str , 38 , 368 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 300 ,
					dimensions_height = 25,
					align = 1
				}) )
	
	if jobFlag ~= nil then this.viewLayer:addChild(jobFlag) end
	
	
	
	--天生技能
	local tiansheng_jineng = display.newSprite(PATH .. "tiansheng_jineng.png")
	setAnchPos(tiansheng_jineng , 360 , 435)
 	this.viewLayer:addChild(tiansheng_jineng)
 	
	local skillCid = _data["skill_k"]
	local skillIcon = KNBtn:new(SCENECOMMON ,
		{"skill_frame1.png"} ,
		367 ,
		367 , 
		{ 
			scale = true ,
			front = getImageByType(skillCid , "s") , 
			text = { getConfig("skill" , skillCid , "name") , 16  , ccc3( 0x2c , 0x00 , 0x00 ) , {x = 0 , y = -45 } } , 
			callback  = function()
				--详情
				local skill_data = getConfig("skill" , skillCid)
				skill_data["cid"] = skillCid

				pushScene("detail" , {
					detail = "skill",
					data = skill_data,
				})
			end	
		 }
		)
 	this.viewLayer:addChild( skillIcon:getLayer() )
	


	-- 人物图像天赋技能 组合 说明
	local tianfu_label
	local y = 285
	local tianfu = display.newSprite(PATH .. "group_title.png")
	local tianfu_bg = display.newSprite(PATH .. "effect_bg.png")
	setAnchPos(tianfu_bg , 40 , 308)
	setAnchPos(tianfu , 45 , 312)
	this.viewLayer:addChild(tianfu_bg)
	this.viewLayer:addChild(tianfu)
		
	if _data["natural"] and #_data["natural"] > 0 then
		--组合个数
		local groupNum = display.strokeLabel( "( " .. #_data["natural"] .. " )" , 90 , 312 , 16 )
		this.viewLayer:addChild(groupNum)
		
		--文字生成
		local function createText( flag , _str, active )
			local tempLayer = display.newLayer()
			local size = 18
			local length = math.ceil( string.len( tostring( _str ) ) / 48 )
			setAnchPos( flag, 0, 2 )
			tempLayer:addChild(flag)

			local infoText, line = createLabel({str = _str, color = ccc3(0x2c, 0, 0), width = 365, size = 18})				
			setAnchPos( infoText, 20, -(line - 1) * 24)
			if active then
				infoText:setColor(ccc3(255, 0, 0))
			end
			tempLayer:addChild( infoText )
							
			tempLayer:setContentSize(  CCSize( 280 , length * (size + 4) ) )
			
			return tempLayer, line
		end
		--生成显示信息
		local function createInfo( index, active )
			local naturalConfig = requires(IMG_PATH , "GameLuaScript/Config/Natural")
			local record = naturalConfig[ index ]
--				type1 => '将领同时上阵'2 => '装备宝物坐骑'
			local curRecordStr = ""
			curRecordStr = record.name .. "：" .. ( record.type == 1 and "与" or "穿戴" )
			local names = {}
			for j = 1 , #record.condition do
 				if record.type == 1 then
 					if tostring( record.condition[j] ) ~= tostring( _data.cid ) then
	 					names[#names + 1] = Config[ record.condition[j] .. "" ].star .. "星" .. Config[ record.condition[j] .. "" ].name
 					end
				else
					if getCidType(record.condition[j]) == "equip" then
						names[#names + 1] = equipConfig[ record.condition[j] .. "" ].star .. "星" .. equipConfig[ record.condition[j] .. "" ].name
					end
				end

			end
			curRecordStr = curRecordStr .. string.join( names , "、" )
			curRecordStr = curRecordStr .. ( record.type == 1 and "齐上阵" or "" ) .. "，" .. record[ "desc" ].."    "--最终加空格，防止结尾是类似25%（省去25%刚好一行）这样的不换行显示
			--标记			
			local flagSp
			local flagPath = COMMONPATH .. "tianfu_2.png"
			if active then
				flagPath = COMMONPATH.."tianfu_1.png"
			end
			
			flagSp = display.newSprite( flagPath )
			
			return createText( flagSp , curRecordStr, active )
		end
		
		for key , v in pairs( _data["natural"] ) do
			local active
			if checkActive("general", {nid = v, id = gid, cid = cid}) then
				active = true
			end
			local natural, line = createInfo(tostring( v ), active)
			setAnchPos(natural, 40, y)
			this.viewLayer:addChild(natural)
			y = y - line * 25
			
		end
	else
		local label = createLabel({str = "三星（包括三星）以上英雄才有组合加成 ", color = ccc3(0x2c, 0, 0), width = 410})
		y =  y - label:getContentSize().height - 10
		setAnchPos(label , 40 , y + 25)
		this.viewLayer:addChild(label)
	end
	
	local tianfu_bg = display.newSprite(PATH .. "effect_bg.png")
	setAnchPos(tianfu_bg , 40 , y- 8)
	this.viewLayer:addChild(tianfu_bg)
	
	tianfu_bg = display.newSprite(PATH.."desc.png")
	setAnchPos(tianfu_bg, 42, y - 4)
	this.viewLayer:addChild(tianfu_bg)
	
	local label = createLabel({str = config_data["desc"], color = ccc3(0x2c, 0, 0), width = 410})
	setAnchPos(label , 40 , y - label:getContentSize().height - 10)
	this.viewLayer:addChild(label)
	
	-- 英雄星星
	local temp
	local y = 615
	for i = 1, config_data["star"] do
		temp = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(temp , 303 , y)
		this.viewLayer:addChild(temp)
		y = y - 32
	end

	-- 传功按钮
	if gid ~= 0 then
	
		--等阶
		local stageNum = DATA_Bag:get("general", gid, "stage")
		if stageNum > 0 then
			local stage = display.newSprite(COMMONPATH.."stage/"..stageNum..".png")
			setAnchPos(stage, 303, y - 5)
			this.viewLayer:addChild(stage)
		end
		
		local btn_bg = {"btn_bg_red.png","btn_bg_red_pre.png"}
		local btn_front = COMMONPATH .. "chuangong.png"
		if checkOpened("byexp") ~= true then
			btn_bg ={"btn_bg_red2.png" } 
			btn_front = COMMONPATH .. "chuangong_grey.png"
		end
		local useBtn = KNBtn:new(COMMONPATH, btn_bg , 70 , 130 , {
			scale = true,
			front = btn_front,
			callback = function()
				if gid == 0 then
					KNMsg.getInstance():flashShow("该英雄不可传功")
					return
				end

				-- 判断等级开放
				local check_result = checkOpened("byexp")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				
				

				local curHeroData = DATA_Bag:get( "general" , _data.id ) 
				
				if curHeroData.lv <=1 then
						KNMsg.getInstance():flashShow("一级武将不可做传功者！")
				else
						pushScene("byexp" , { source = curHeroData , backtype = "back_hero"} )	
				end
			end
		}):getLayer()
		this.layer:addChild(useBtn)
		useBtn:setVisible( not isOther )

		-- 升阶 按钮
		local btn_bg = {"btn_bg_red.png","btn_bg_red_pre.png"}
		local btn_front = COMMONPATH .. "uppet.png"
		if checkOpened("uplevel") ~= true or tonumber(getConfig("general",cid, "star")) < 3 then
			btn_bg = {"btn_bg_red2.png"}
			btn_front = COMMONPATH .. "uppet_grey.png"
		end
		local useBtn = KNBtn:new(COMMONPATH,  btn_bg  , 270 , 130 , {
			scale = true,
			front = btn_front,
			callback = function()
				if gid == 0 then
					KNMsg.getInstance():flashShow("该英雄不可升阶")
					return
				end

				-- 判断等级开放
				local check_result = checkOpened("uplevel")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				
				if tonumber(getConfig("general", cid, "star")) < 3 then
					KNMsg.getInstance():flashShow("该品质英雄不能进化,最高等级上限为"..DATA_Uplevel:get(getConfig("general", cid, "star").."")["initial_lv"].."级")
					return false
				end


				local curHeroData = DATA_General:get( gid ) 
				if curHeroData then
					pushScene("uplevel" , { target = curHeroData } )
--					switchScene("uplevel" , { target = curHeroData } )
				else
					HTTP:call("general" , "get" , 
							{ id = _data.id } ,
							{success_callback =
								function()
	--								local curHeroData = DATA_General:get( "general" , _data.id ) 
									pushScene("uplevel" , { target = _data } )
--									switchScene("uplevel" , { target = _data } )
								end 
								} )
				end
				
			end
		})
		this.layer:addChild(useBtn:getLayer())
		useBtn:getLayer():setVisible( not isOther )

		-- 新手引导
		if KNGuide:getStep() == 2502 then
			local btn_range = useBtn:getRange()

			KNGuide:show( useBtn:getLayer() , {
				remove = true,
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
			})
		end
	end
	
	
	--确定
	if params.toChoose then
		local okBtn = KNBtn:new(COMMONPATH,  {"btn_bg_red.png", "btn_bg_red_pre.png"}  , 160 , 130 , {
			front = COMMONPATH.."ok.png",
			callback = function()
				if params.chooseCallback then
					params.chooseCallback()
				else
					popScene()
				end
			end
		})
		this.layer:addChild(okBtn:getLayer())
	end
	
 	this.viewLayer:setContentSize(CCSize(480, 740))
 	this.viewLayer:ignoreAnchorPointForPosition(false)
 	setAnchPos(this.viewLayer)
 	
	local scroll = KNScrollView:new( 0 , 175 , 480 , 570 , 2 )
	scroll:addChild(this.viewLayer)
	scroll:alignCenter()
	
	this.layer:addChild( scroll:getLayer() )
	return this
end


function HeroDetail:getLayer()
	return self.layer
end

function HeroDetail:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()
	if self.params["parent"] then
		x = x + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		y = y + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end
return HeroDetail
