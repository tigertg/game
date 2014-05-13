local PATH = IMG_PATH .. "image/scene/hero/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local COMMONPATH = IMG_PATH .. "image/common/"
--[[英雄模块，首页点击英雄图标进入]]
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNBar = requires(IMG_PATH , "GameLuaScript/Common/KNBar")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Property")

local HeroLayer = {
	baseLayer,
	leftLayer,
	rightLayer,
	selectLayer,
	viewLayer,
	infoLayer,
}
local selectIndex = 1
function HeroLayer:new(args)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	args = args or {}

	-- 基础层
	this.baseLayer   = display.newLayer()
	this.selectLayer = display.newLayer()
	this.leftLayer   = display.newLayer()
	this.rightLayer  = display.newLayer()
	this.viewLayer = display.newLayer()

	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild(bg)

	local hero_bg = display.newSprite(PATH .. "hero_bg.png")
	setAnchPos(hero_bg , 130 , 110)
	this.viewLayer:addChild(hero_bg)

	local list_bg = display.newSprite(PATH .. "list_bg.png")
	setAnchPos(list_bg , 13 , 110)
	this.viewLayer:addChild(list_bg)

	


	this.viewLayer:addChild(this.leftLayer)
	this.viewLayer:addChild(this.selectLayer)
	this.viewLayer:addChild(this.rightLayer)

	this.baseLayer:addChild(this.viewLayer)


	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new("hero" , 0 , {tail_hide = true , title_text = PATH .. "other_title.png" , closeCallback = args.closeCallback})
	this.baseLayer:addChild( this.infoLayer:getLayer() )


	-- 显示左侧部分
	this:showHeroList()


	-- 显示右侧部分
	local gid = args.gid or 0
	
	if gid then
		gid = tonumber(gid)
		for i = 1 , DATA_OTHER:get_ON("count") do
			local hero = DATA_OTHER:get_index(i)
			if hero["gid"] == gid then
				selectIndex = i
				break
			end
		end
	end
	
	if DATA_OTHER:get_lenght() > 0 then
		this:showOneHero(selectIndex)
	end


	return this.baseLayer 
end

function HeroLayer:showHeroList()
	local layer = display.newLayer()

	local count = DATA_OTHER:get_ON("count")
	
	local init_x = 44
	local margin_y = 75
	local init_y = 655
	local hero , cid , logo , logo_bg , btn , last_y


	-- 显示替补上阵武将
	for i = 1 , count do
		local _init_y = init_y
		if i > 4 then _init_y = init_y - 12 end
		
		hero = DATA_OTHER:get_index(i)
	
		cid = DATA_OTHER:getGeneral(hero["gid"] , "cid")

		logo_bg = display.newSprite(COMMONPATH .. "small_photo_bg.png")
		setAnchPos(logo_bg , init_x , _init_y - (i - 1) * margin_y )


		btn = KNBtn:new(IMG_PATH .. "image/hero" , {getImageByType(cid , "s" , true)} , init_x + 5 , _init_y - (i - 1) * margin_y + 10 , {
			id = i,
			scale = true,
			callback = function()
				self:showOneHero( i )
			end
		})

		
		layer:addChild(logo_bg)
		layer:addChild(btn:getLayer())
	end
	
	local Stelle = DATA_OTHER:get_ON("conf")
	local user_level = DATA_OTHER:getLv()
	for k , v in pairs(Stelle) do
		k = tonumber(k)
		local _init_y = init_y
		if k > 4 then _init_y = init_y - 12 end

		if k > count then
			if v <= user_level then
				-- 开放的格子
				local lineup_btn = KNBtn:new(COMMONPATH , {"small_photo_bg.png"} , init_x , _init_y - (k - 1) * margin_y , {
					scale = true,
					callback = function()
					end
				})
				layer:addChild(lineup_btn:getLayer())

			else
				-- 未开放的格子
				logo_bg = display.newSprite(COMMONPATH .. "small_photo_bg2.png")
				setAnchPos(logo_bg , init_x , _init_y - (k - 1) * margin_y )
				layer:addChild(logo_bg)
				layer:addChild( display.strokeLabel( v .. "级" , 60 , _init_y - (k - 1) * margin_y + 43, 20 , ccc3( 0x47 , 0x47 , 0x47 ) ) )
				layer:addChild( display.strokeLabel( "开放" , 60 , _init_y - (k - 1) * margin_y + 15, 20 , ccc3( 0x47 , 0x47 , 0x47 ) ) )
			end
		end
	end
	
	-- 显示空格子
	--[[if count < 8 then
		for i = count + 1 , 8 do
			
			logo_bg = display.newSprite(COMMONPATH .. "small_photo_bg2.png")
			setAnchPos(logo_bg , 30 , init_y - (i - 1) * margin_y )
			layer:addChild(logo_bg)
		end
	end
]]

	local left_tips = display.newSprite(PATH .. "main_queue.png")
	setAnchPos(left_tips , 12 , 545 )
	layer:addChild(left_tips)

	local left_tips2 = display.newSprite(PATH .. "sub_queue.png")
	setAnchPos(left_tips2 , 12 , 235 )
	layer:addChild(left_tips2)


	self.leftLayer:addChild( layer )

	return layer
end

--[[选择态]]
function HeroLayer:selectOne(index)
	local margin_y = 75
	local init_y = 651

	if index > 4 then init_y = init_y - 12 end

	if self.selectLayer:getChildrenCount() == 0 then
		-- local layer = display.newLayer()

		local select_img = display.newSprite(SCENECOMMON .. "select1.png" )
		setAnchPos(select_img , 0 , 0 , 0 , 0)

		self.selectLayer:addChild( select_img )
		setAnchPos(self.selectLayer , 35 , init_y - (index - 1) * margin_y)
	else
		setAnchPos(self.selectLayer , 35 , init_y - (index - 1) * margin_y)
	end
end

--[[显示一个英雄]]
function HeroLayer:showOneHero(index)
	selectIndex = index

	-- 先清空
	self.rightLayer:removeAllChildrenWithCleanup(true)


	self:selectOne(index)

	local gid = DATA_OTHER:get_index(index)["gid"]
	local hero_data = DATA_OTHER:getTable(gid)
	local layer = display.newLayer()

	-- 姓名
	local name = display.strokeLabel( hero_data["name"] , 160 , 692 , 24 , ccc3( 0xac , 0x25 , 0x10 ) )
	layer:addChild( name )
	-- 绰号
	local Config = requires(IMG_PATH , "GameLuaScript/Config/Hero")
	local config_data = Config[hero_data["cid"]]
	layer:addChild( display.strokeLabel( config_data["bieming"] or "" , 160 + name:getLabel():getContentSize().width + 10 , 693 , 18 , ccc3( 0xef , 0x7a , 0x1a ) ) )

	-- 经验
	layer:addChild( KNBar:new("exp_general" , 155 , display.height - 680 , { maxValue = hero_data["lvup_exp"] , curValue = hero_data["cur_exp"] } ) )

	-- 等级
	local lvNode = display.strokeLabel( "Lv" .. hero_data["lv"] , 353 , 692 , 18 , ccc3( 0xac , 0x25 , 0x10 ) )
	setAnchPos(lvNode , 353 , 692 , 1 , 0)
	layer:addChild( lvNode )
	
	-- 属性背景
	local attr_bg = display.newSprite(PATH .. "attr_bg.png")
	setAnchPos(attr_bg , 150 , 640 , 0 , 0)
	layer:addChild( attr_bg )

	-- 属性
	layer:addChild( display.strokeLabel( "攻" .. hero_data["atk"] , 160 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "防" .. hero_data["def"] , 215 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "命" .. hero_data["hp"]  , 270 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "速" .. hero_data["agi"] , 325 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )

	-- 人物大图
	local big_img_btn = KNBtn:new(IMG_PATH .. "image/hero/" , {getImageByType(hero_data["cid"] , "b" , true)} , 172 , 363 , {
		upSelect = true,
		noHide = true,
		callback = function()
--			pushScene("detail" , {
--				detail = "general",
--				id = hero_data["id"],
--				isOther = true
--			})
		end
	})
	layer:addChild( big_img_btn:getLayer() )
	
	
	-- 武将职业标记
	local jobFlag
	if tonumber(config_data["role"]) > 0 then
		jobFlag = display.newSprite(  COMMONPATH .. "job" .. hero_data.role .. ".png" )
		setAnchPos(jobFlag , 147 , 565 )
		layer:addChild( jobFlag )
	end

	

	-- 星级
	local countNum = 0 
	for i = 1 , hero_data["star"] do
		local star_img = display.newSprite( COMMONPATH .. "star.png" )
		setAnchPos(star_img , 407 , 590 - (i - 1) * 27)
		layer:addChild( star_img )
		countNum = countNum + 1
	end
	
	--等阶
	countNum = countNum + 1
	if hero_data["stage"] > 0 then
		local stage = display.newSprite(COMMONPATH.."stage/"..hero_data["stage"]..".png")
		setAnchPos(stage, 407, 590 - (countNum - 1) * 27 )
		layer:addChild(stage)
	end

	-- 天赋
	layer:addChild( display.strokeLabel( "天赋" , 219 , 352 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
	if hero_data["natural"] and hero_data["active_natural"]  then
		for key , v in pairs( hero_data["natural"] ) do
			local imgPath = COMMONPATH .. "tianfu_2.png"
			
			for key2 , v2 in pairs( hero_data["active_natural"] ) do
				 if tostring(v) == tostring(v2) then
				 	imgPath = COMMONPATH .. "tianfu_1.png"
				 	break
				 end
			end
			
			local star_img = display.newSprite( imgPath )
			setAnchPos(star_img , 265 + (key - 1) * 22 , 353 )
			layer:addChild( star_img )
		end
	end


	-- 技能文字
	local tiansheng_bg = display.newSprite(  PATH .. "skill_type_bg.png" )
	layer:addChild( tiansheng_bg )
	setAnchPos(tiansheng_bg , 135 , 268 )

	local tiansheng = display.newSprite(  PATH .. "tiansheng.png" )
	layer:addChild( tiansheng )
	setAnchPos(tiansheng , 145 , 285 )

	local xuexi_bg = display.newSprite(  PATH .. "skill_type_bg.png" )
	layer:addChild( xuexi_bg )
	setAnchPos(xuexi_bg , 255 , 268 )

	local xuexi = display.newSprite(  PATH .. "xuexi.png" )
	layer:addChild( xuexi )
	setAnchPos(xuexi , 265 , 285 )


	local wearEquipCell = requires(IMG_PATH , "GameLuaScript/Scene/hero/wearEquipCell")
	-- 天生技能
	local skillConfig = requires(IMG_PATH , "GameLuaScript/Config/Skill")
	local tempData = {
		cid = hero_data["skill_k"],
		id = 0,
		lv = hero_data["skill_lv"],
	}
	local equipSeatCell = wearEquipCell:new( 
		180 ,
		265 , 
		tempData , 
		function()
			--详情
			local skill_data = getConfig("skill" , hero_data["skill_k"])
			skill_data["cid"] = hero_data["skill_k"]
			skill_data["lv"] = hero_data["skill_lv"]

			pushScene("detail" , {
				detail = "skill",
				data = skill_data,
				heroData = hero_data,
				skillSeat = 1, 
			})
		end ,
		layer
	)
	layer:addChild( equipSeatCell:getLayer() )
	


	
	
	local equip_opened = checkOpened("equip")
	local skill_opened = checkOpened("skill")
	local function createSkillEquipSeat()
		local tempEquipData = DATA_OTHER:getSkillEquipTable( hero_data.id ) or {}
		
		local equipSeat = { s2 = "技能" , s3 = "技能" , e1 = "武器" , e2 = "防具" , e3 = "鞋子" , e4 = "饰品" , }
		for key , v in pairs( equipSeat ) do
			--获取对应武将数据 的对应位置数据
			local tempData = tempEquipData[key] or v
			--计算当前处理对像的位置标记
			local indexSeat = ( string.sub(key , 2 , -1) - 1 )
			local equipSeatCell
			if string.sub(key , 1 , 1) == "e" then
				if type(tempData) ~= "string" then
					tempData["lv"] = DATA_OTHER:getBag( "equip" , tempData["id"] , "lv")
				end
				--装备位
				local equipX = 150 + 76 * indexSeat
				equipSeatCell = wearEquipCell:new( 
							equipX ,
							180 , 
							tempData , 
							function()
								--详情
								if type( tempData ) ~= "string" then
									pushScene("detail" , {
										detail = "equip",
										id = tempData["id"],
										heroData = hero_data,
										isOther = true
									})
								end
							end ,
							layer,
							equip_opened
						)
			else
				--技能位
				local skillX = 226 + 76 * indexSeat
				equipSeatCell = wearEquipCell:new( 
							skillX ,
							265 , 
							tempData , 
								function()
									if type( tempData ) ~= "string" then
										pushScene("detail" , {
											detail = "skill",
											id = tempData["id"],
											heroData = hero_data,
											skillSeat = key.."" , 
											isOther = true
										})
									end
							end ,
							layer,
							skill_opened
						)

			end
			layer:addChild( equipSeatCell:getLayer() )
		end
	end
	
	createSkillEquipSeat()


	self.rightLayer:addChild( layer )

	return layer
end

return HeroLayer
