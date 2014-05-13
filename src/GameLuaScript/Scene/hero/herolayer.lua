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
	scroll,
}
local selectIndex = 1
function HeroLayer:new(args)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	args = args or {}
	totalLead = 0

	-- 基础层
	this.baseLayer   = display.newLayer()
	this.selectLayer = display.newLayer()
	this.leftLayer   = display.newLayer()
	this.rightLayer  = display.newLayer()
	this.viewLayer = display.newLayer()
	this.tipLayer = display.newLayer()
	this.tipLayer:setVisible( true )
	
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

	this.viewLayer:addChild( this.leftLayer )
	this.viewLayer:addChild( this.selectLayer )
	this.viewLayer:addChild( this.rightLayer )

	this.baseLayer:addChild( this.viewLayer )
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new("hero" , 0 , {tail_hide = true , title_text = PATH .. "title.png" , closeCallback = args.closeFun })
	this.baseLayer:addChild( this.infoLayer:getLayer() )
	

	-- 显示左侧部分
	this:showHeroList()
	
	-- 显示右侧部分
	local gid = args.gid or 0
	
	if gid then
		gid = tonumber(gid)
		for i = 1 , DATA_Formation:get_ON("count") do
			local hero = DATA_Formation:get_index(i)
			if hero["gid"] == gid then
				selectIndex = i
				break
			end
		end
	end
	
--	if DATA_Formation:get_lenght() > 0 then
--		this.scroll = KNScrollView:new(138, 350, 320, 385, 0,true, 1, {
--			page_callback = function()
--				this:showOneHero(this.scroll:getCurIndex())
--			end
--		})
--		for i = 1, DATA_Formation:get_lenght() do
--			local temp = this:createBasePro(i)
--			this.scroll:addChild(temp, temp)
--		end	
--		this.scroll:alignCenter()
--		this.viewLayer:addChild(this.scroll:getLayer())
--		this:showOneHero(selectIndex)
--	end
	this:createScroll()

	-- “换” 按钮
	local btn = KNBtn:new(COMMONPATH , {"btn_bg.png", "btn_bg_pre.png"} , 370 , 652 , {
		front = PATH .. "huan.png",
		scale = true,
		callback = function()
				this.tipLayer:setVisible( false )
				local list 
				list = SelectList:new("general",self.viewLayer,display.newSprite(COMMONPATH .. "title/hero_text.png"),{
				formation = true, 
				select = DATA_Formation:get_index(selectIndex)["gid"],
				closeCallback = function() this.tipLayer:setVisible( true ) end ,
				optCallback = function()	
					this.tipLayer:setVisible( true )
					if list:getCurItem():getId() ~=  DATA_Formation:get_index(selectIndex)["gid"] then
						--已上阵武将换位
						if DATA_Formation:checkIsExist(list:getCurItem():getId()) then
							local on = DATA_Formation:get("on")
							local back = DATA_Formation:get("back")
							--将选中的元素保存在temp中
							local temp, cur, num
							if selectIndex > 4 then
								num = selectIndex - 4
								temp = back[num]
								cur = back
							else
								num = selectIndex
								temp = on[num]
								cur = on
							end
							
							local _, pos = DATA_Formation:checkIsExist(list:getCurItem():getId())
							
							--上阵元素更换
							if pos > 4 then
								cur[num] = back[pos - 4] 
								back[pos - 4] = temp
							else
								cur[num] = on[pos]
								on[pos] = temp
							end
							
							local onStr, backStr = "", ""
							for i = 1, 4 do
								if on[i] then
									onStr = onStr..on[i].gid..","
								end
								
								if back[i] then
									backStr = backStr..back[i].gid..","
								end
							end
							
							HTTP:call("formation" , "doset",{
								on = onStr,
								back = backStr
							},{success_callback = function()
								switchScene("hero",{gid = list:getCurItem():getId()})
							end })
						else
							--上阵一个武将
							HTTP:call("formation" , "up",{
								pos = selectIndex,
								id = list:getCurItem():getId()	
							},{success_callback = function()
									switchScene("hero",{gid = list:getCurItem():getId()})
							end })
						end
					else
						list:resetCurrent()
					end
				end
			})
			this.baseLayer:addChild(list:getLayer())
			
		end
	})
	this.viewLayer:addChild(btn:getLayer(),1)


	return this.baseLayer 
end
--检查更高级装备
function HeroLayer:checkAdvancedEquip()
	local tempEquipData = DATA_ROLE_SKILL_EQUIP:getTable() 
	local allEquip = clone( DATA_Bag:getTable( "equip" ) )
	local isExist , tagType = false , nil
	local equipSeat = { e1 = "weapon" , e2 = "defender" , e3 = "shoe" , e4 = "jewelry" , }
	local textElement = { weapon = "武器" , defender = "防具" , shoe = "鞋子" , jewelry = "饰品" }
	for i = 1 , 4 do
	
		if not isExist then
			local seatK = "e" .. i
			tagType = equipSeat[ seatK .. "" ]
			--取出当前位已经用装备
			local useEquip , freeEquip , useMin , freeMax = {} , {} , 9999 , 0
			
			for gKey , gV in pairs( tempEquipData ) do
				if gV[ seatK ] then
					useEquip[ gKey.."" ] = allEquip[ gV[ seatK ].id .. "" ]
					allEquip[ gV[ seatK ].id .. "" ] = nil
					
					local curSart = useEquip[ gKey.."" ].star
					useMin =  curSart < useMin and curSart or useMin
				else
					--只要存在空的装备位
					useMin = 0
				end
			end
			--取出当前位未使用的所有装备
			for eK , eV in pairs( allEquip ) do
				if eV.type == tagType then
					freeEquip[eK] = eV
					eV = nil
					local curSart = freeEquip[eK].star
					freeMax =  curSart > freeMax and curSart or freeMax
				end
			end

			if useMin < freeMax then
				isExist = true
				break
			end
			
		end
		
	end
	if isExist then
		KNMsg.getInstance():flashShow( "你的背包中有更高星级的" .. textElement[ tagType ] ..  "哦，赶紧去装备上吧!" )
	end
end
function HeroLayer:createScroll()
	if DATA_Formation:get_lenght() > 0 then
		if self.scroll then
			self.viewLayer:removeChild(self.scroll:getLayer(), true)
		end
		self.scroll = KNScrollView:new(138, 350, 320, 385, 0,true, 1, {
			page_callback = function()
				self:showOneHero(self.scroll:getCurIndex())
			end
		})
		for i = 1, DATA_Formation:get_lenght() do
			local temp = self:createBasePro(i)
			self.scroll:addChild(temp, temp)
		end	
		self.scroll:alignCenter()
		self.viewLayer:addChild(self.scroll:getLayer())
		self:showOneHero(selectIndex)
	end
end
--显示当前是否有需要生机
function HeroLayer:showUpFlag( _id )
	local tipFlag = self:coutUpTip( _id , false )
	if self.tipLayer then
		self.tipLayer:removeFromParentAndCleanup( true )
		self.tipLayer = nil 
		self.tipLayer = display.newLayer()
		self.baseLayer:addChild( self.tipLayer , 20 )
	end
	if tipFlag then
		self.tipLayer:addChild( display.newSprite( PATH .. "tip_bg.png" , 238 , 706 , 0 , 0 )  )
		self.tipLayer:addChild( display.strokeLabel( tipFlag , 252 , 719 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
					dimensions_width = 167 ,
					dimensions_height = 50,
					align = 1
				}) )
	end
end
function HeroLayer:showHeroList()
	local layer = display.newLayer()

	local count = DATA_Formation:get_ON("count")
	local init_x = 44
	local margin_y = 75
	local init_y = 655
	local hero , cid , logo , logo_bg , btn , last_y


	-- 显示替补上阵武将
	for i = 1 , count do
		local _init_y = init_y
		if i > 4 then _init_y = init_y - 12 end
		
		hero = DATA_Formation:get_index(i)
		
		cid = DATA_General:get(hero["gid"] , "cid")
		
		logo_bg = display.newSprite(COMMONPATH .. "small_photo_bg.png")
		setAnchPos(logo_bg , init_x , _init_y - (i - 1) * margin_y )
		
		local tipFlag = self:coutUpTip( hero["gid"] )
		btn = KNBtn:new(IMG_PATH .. "image/hero" , {getImageByType(cid , "s" , true)} , init_x + 5 , _init_y - (i - 1) * margin_y + 10 , {
			other = ( tipFlag and { COMMONPATH .. "up_flag.png" , 40 , 0 } or nil )  ,
			id = i,
			scale = true,
			callback = function()
				self.scroll:setIndex(i)
				self:showOneHero( i )
			end
		})

		
		layer:addChild(logo_bg)
		layer:addChild(btn:getLayer())
	end
	
	local Stelle = DATA_Formation:get_ON("conf")
	

	local user_level = DATA_User:get("lv")
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
--						switchScene("lineupList" , { gid = gid , mode = 2 , index = k})
						local list 
						list = SelectList:new("general",self.viewLayer,display.newSprite(COMMONPATH .. "title/hero_text.png"),{formation = true, exceptUse = true, optCallback = function()
							--上阵一个武将
							HTTP:call("formation" , "up",{
								pos = k,
								id = list:getCurItem():getId()	
							},{success_callback = function()
									switchScene("hero")
							end, error_callback = function(data)
								KNMsg.getInstance():flashShow(data.msg)
								list:resetCurrent()
							end })
						end})
						self.baseLayer:addChild(list:getLayer())

						if KNGuide:getStep() == 302 then
							local opt_btn = list:getItems(1):getOptBtn()
							local btn_range = opt_btn:getRange()
							KNGuide:show( opt_btn:getLayer() , {
								remove = true,
								x = btn_range:getMinX(),
								y = btn_range:getMinY(),
								selectList = true,
							})
						end
					end
				})
				layer:addChild(lineup_btn:getLayer())

				if k == 2 and KNGuide:getStep() == 301 then KNGuide:show( lineup_btn:getLayer() ) end
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
	self.scroll:setIndex(index, true)
end

--[[显示一个英雄]]
function HeroLayer:showOneHero(index)
	selectIndex = index

	-- 先清空
	self.rightLayer:removeAllChildrenWithCleanup(true)


	self:selectOne(index)

	local gid = DATA_Formation:get_index(index)["gid"]
	local hero_data = DATA_General:getTable(gid)
	local layer = display.newLayer()
	print(gid)
--	-- 姓名
--	local name = display.strokeLabel( hero_data["name"] , 160 , 692 , 24 , ccc3( 0xac , 0x25 , 0x10 ) )
--	layer:addChild( name )
--	-- 绰号
--	local Config = requires(IMG_PATH , "GameLuaScript/Config/Hero")
--	local config_data = Config[hero_data["cid"]]
--	layer:addChild( display.strokeLabel( config_data["bieming"] or "" , 160 + name:getLabel():getContentSize().width + 10 , 693 , 18 , ccc3( 0xef , 0x7a , 0x1a ) ) )
--
--	-- 经验
--	layer:addChild( KNBar:new("exp_general" , 155 , display.height - 680 , { maxValue = hero_data["lvup_exp"] , curValue = hero_data["cur_exp"] } ) )
--
--	-- 等级
--	local lvNode = display.strokeLabel( "Lv" .. hero_data["lv"] , 353 , 692 , 18 , ccc3( 0xac , 0x25 , 0x10 ) )
--	setAnchPos(lvNode , 353 , 692 , 1 , 0)
--	layer:addChild( lvNode )
--
--
--	-- 属性背景
--	local attr_bg = display.newSprite(PATH .. "attr_bg.png")
--	setAnchPos(attr_bg , 150 , 640 , 0 , 0)
--	layer:addChild( attr_bg )
--
--	-- 属性
--	layer:addChild( display.strokeLabel( "攻" .. hero_data["atk"] , 160 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
--	layer:addChild( display.strokeLabel( "防" .. hero_data["def"] , 215 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
--	layer:addChild( display.strokeLabel( "命" .. hero_data["hp"]  , 270 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
--	layer:addChild( display.strokeLabel( "速" .. hero_data["agi"] , 325 , 652 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
--
--
--	-- 人物大图
--	local big_img_btn = KNBtn:new(IMG_PATH .. "image/hero/" , {getImageByType(hero_data["cid"] , "b" , true)} , 172 , 363 , {
--		upSelect = true,
--		noHide = true,
--		callback = function()
--			pushScene("detail" , {
--				detail = "general",
--				id = hero_data["id"],
--			})
--		end
--	})
--	layer:addChild( big_img_btn:getLayer() )
--	-- 新手引导
--	if KNGuide:getStep() == 2501 then
--		KNGuide:show( big_img_btn:getLayer() , {
--			offset_width = -20,
--			offset_height = -30,
--			offset_x = 5,
--			offset_y = 30
--		})
--	end
--	
--	
--	-- 武将职业标记
--	local jobFlag
--	if tonumber(config_data["role"]) > 0 then
--		jobFlag = display.newSprite(  COMMONPATH .. "job" .. hero_data.role .. ".png" )
--		setAnchPos(jobFlag , 147 , 565 )
--		layer:addChild( jobFlag )
--	end
--
--	
--
--	-- 星级
--	for i = 1 , hero_data["star"] do
--		local star_img = display.newSprite( COMMONPATH .. "star.png" )
--		setAnchPos(star_img , 407 , 590 - (i - 1) * 27)
--		layer:addChild( star_img )
--	end
--
--	-- 天赋
--	layer:addChild( display.strokeLabel( "天赋" , 219 , 352 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
--	for key , v in pairs( hero_data["natural"] ) do
--		local imgPath = PATH .. "tianfu_2.png"
--		
--		for key2 , v2 in pairs( hero_data["active_natural"] ) do
--			 if tostring(v) == tostring(v2) then
--			 	imgPath = PATH .. "tianfu_1.png"
--			 	break
--			 end
--		end
--		
--		local star_img = display.newSprite( imgPath )
--		setAnchPos(star_img , 265 + (key - 1) * 22 , 353 )
--		layer:addChild( star_img )
--	end


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
	--添加升级提示
	self:showUpFlag( hero_data.id )


	
	
	local equip_opened = checkOpened("equip")
	local skill_opened = checkOpened("skill")
	local function createSkillEquipSeat()
		local tempEquipData = DATA_ROLE_SKILL_EQUIP:getTable( hero_data.id ) or {}
		
		local equipSeat = { s2 = "技能" , s3 = "技能" , e1 = "武器" , e2 = "防具" , e3 = "鞋子" , e4 = "饰品" , }
		for key , v in pairs( equipSeat ) do
			--获取对应武将数据 的对应位置数据
			local tempData = tempEquipData[key] or v
			--计算当前处理对像的位置标记
			local indexSeat = ( string.sub(key , 2 , -1) - 1 )
			local equipSeatCell
			if string.sub(key , 1 , 1) == "e" then
				if type(tempData) ~= "string" then
					tempData["lv"] = DATA_Bag:get("equip" , tempData["id"] , "lv")
				end

				--装备位
				local equipX = 150 + 76 * indexSeat
				equipSeatCell = wearEquipCell:new( 
							equipX ,
							180 , 
							tempData , 
							function()
								-- 判断等级开放
								local check_result = checkOpened("equip")
								if check_result ~= true then
									KNMsg:getInstance():flashShow(check_result)
									return
								end
								--详情
								if type( tempData ) ~= "string" then
									local DATA = DATA_Equip
									local type = "equip"
									local detail
									if DATA:haveData(tempData["id"],type) then
										pushScene("detail" , {
											detail = "equip",
											id = tempData["id"],
											heroData = hero_data,
											backCallback = function()
												self:createScroll()
												self:showOneHero(index)
											end
										})
									else
										HTTP:call(type,"get",{
											id = tempData["id"]
										},{
											success_callback = function()
												pushScene("detail" , {
													detail = "equip",
													id = tempData["id"],
													heroData = hero_data,
													backCallback = function()
														self:createScroll()
														self:showOneHero(index)
													end
												})
											end})
									end
								else
									--列表
									local list
									local tempTypeAry = { "weapon" , "defender" , "shoe" , "jewelry" }	--装备四个位置
									local isExsit = DATA_Bag:getTypeNum( "equip" , tempTypeAry[ indexSeat + 1 ] )
									if not isExsit then
										KNMsg.getInstance():flashShow("您还未获得 " .. equipSeat["e" .. indexSeat + 1 ] .."!" )
										return
									end
									
									list = SelectList:new("equip",self.viewLayer,display.newSprite(COMMONPATH .. "title/equip_text.png"),{ btn_opt = "equipment.png",target = true, equipType = tempTypeAry[ indexSeat + 1 ] ,
										y = 85 ,
										showTitle = true , 
										filter = tempTypeAry[indexSeat + 1],
										optCallback = function()
											list:destroy()
											local targetId = list:getCurItem():getId()
											--请求换装备
											HTTP:call("equip" , "dress", {
												gid = hero_data["id"] ,
												eid = targetId ,
												pos = "e" .. indexSeat + 1
											} , {
												success_callback = function()
													--刷新数据
													self:showOneHero( index )

													local equip_info = DATA_Bag:get("equip" , targetId)

													KNMsg:getInstance():flashShow( equip_info["name"] .. "装备成功，" .. Config_Property[equip_info["effect"]] .. "增加" .. equip_info["figure"])
												end
											})		
										end
										})
									self.baseLayer:addChild(list:getLayer())

									-- 新手引导
									if KNGuide:getStep() == 202 then
										local btn = list:getItems(1):getOptBtn()
										local btn_range = btn:getRange()

										KNGuide:show( btn:getLayer() , {
											remove = true,
											x = btn_range:getMinX(),
											y = btn_range:getMinY(),
											selectList = true,
										})
									end
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
									-- 判断等级开放
									local check_result = checkOpened("skill")
									if check_result ~= true then
										KNMsg:getInstance():flashShow(check_result)
										return
									end


									if type( tempData ) ~= "string" then
										--详情
										local DATA = DATA_Bag
										local type = "skill"
										local detail
										if DATA:haveData(tempData["id"] , type) then
											pushScene("detail" , {
												detail = "skill",
												id = tempData["id"],
												heroData = hero_data,
												skillSeat = key.."" , 
											})
										else
											HTTP:call(type , "get" , {
												id = tempData["id"]
											} , {
												success_callback = function()
													pushScene("detail" , {
														detail = "skill",
														id = tempData["id"],
														heroData = hero_data,
														skillSeat = key.."" , 
													})
												end
											})
										end
									else
										--列表
										local isExist = DATA_Bag:getTypeNum( "skill" , "generalskill" )
										if not isExist then
											KNMsg.getInstance():flashShow("您还未获得 英雄技能书！" )
											return
										end
										
										local list
										list = SelectList:new("skill",self.viewLayer,display.newSprite(COMMONPATH .. "title/skill_text.png"),{ btn_opt = "equipment.png",target = true, equipType = "generalskill" , seatID = indexSeat ,
												y = 85 ,
												showTitle = true , 
												filter = "generalskill",
												optCallback = function()
													list:destroy()
													local targetId = list:getCurItem():getId()
													--请求换装备
													HTTP:call("skill" , "dress", 
													{ id = hero_data["id"] ,skill_id = targetId ,  pos = key.."" } ,
													{success_callback= 
													function()
														--刷新数据
														self:showOneHero( index )
													end})		
												end
												})
										self.baseLayer:addChild(list:getLayer())

										-- 新手引导
										
										if KNGuide:getStep() == 702 then
											local btn = list:getItems(1):getOptBtn()
											local btn_range = btn:getRange()

											KNGuide:show( btn:getLayer() , {
												callback = function()
													self.infoLayer:refreshBtn()
												end,
												x = btn_range:getMinX(),
												y = btn_range:getMinY(),
												selectList = true,
											})
										end
									end
							end ,
							layer,
							skill_opened
						)

			end
			layer:addChild( equipSeatCell:getLayer() )

			-- 武器
			if key == "e1" then
				-- 新手引导
				local guide_step = KNGuide:getStep()
				if guide_step == 201 or guide_step == 203 then KNGuide:show( equipSeatCell:getLayer() ) end
				if guide_step == 4001 then
					KNGuide:show( equipSeatCell:getLayer() , {
						remove = true,
						width = 295
					})
				end
			elseif key == "s2" then
				-- 新手引导
				local guide_step = KNGuide:getStep()
				if guide_step == 701 then KNGuide:show( equipSeatCell:getLayer() ) end
			end
		end
	end
	
	createSkillEquipSeat()



--
--	-- “培养” 按钮
--	
--	local btn_img = {"btn_bg_red.png", "btn_bg_red_pre.png"} 
--	local btn_front = PATH.."peiyang.png"
--	if checkOpened("wash") ~= true then
--		btn_img = {"btn_bg_red2.png"}
--		btn_front = IMG_PATH .. "image/scene/hero/peiyang_grey.png"
--	end
--	local btn = KNBtn:new(COMMONPATH , btn_img, 143 , 120 , {
--		front = btn_front,
--		callback = function()
--			-- 判断等级开放
--			local check_result = checkOpened("wash")
--			if check_result ~= true then
--				KNMsg:getInstance():flashShow(check_result)
--				return
--			end
--
--			--HTTP:call("wash" , "get" , {id = hero_data["id"]} , {
--				--success_callback = function()
--					switchScene("culture",gid)
--				--end}
--			--)
--		end
--	})
--	layer:addChild(btn:getLayer())
--
--	-- 新手引导
--	if KNGuide:getStep() == 1101 then KNGuide:show( btn:getLayer() ) end


	-- “筋脉” 按钮
	local btn_img = {"btn_bg_red.png", "btn_bg_red_pre.png"} 
	local btn_front = PATH.."jinmai.png" 
	if checkOpened("pulse") ~= true then
		btn_img = {"btn_bg_red2.png"}
		btn_front = IMG_PATH .. "image/scene/hero/jinmai_grey.png"
	end
	local btn = KNBtn:new(COMMONPATH , btn_img , 207 , 120 , {
		front = btn_front,
		callback = function()
			-- 判断等级开放
			local check_result = checkOpened("pulse")
			if check_result ~= true then
				KNMsg:getInstance():flashShow(check_result)
				return
			end

			HTTP:call("pulse" , "get", { id = gid } , {
				success_callback = function()
					switchScene("pulse",gid)
				end}
			)
		end
	})
	layer:addChild(btn:getLayer())


	self.rightLayer:addChild( layer )

	return layer
end

function HeroLayer:createBasePro(index)
	local gid = DATA_Formation:get_index(index)["gid"]
	local hero_data = DATA_General:getTable(gid)

	local layer = display.newLayer()

	-- 属性背景
	local attr_bg = display.newSprite(PATH .. "attr_bg.png")
	setAnchPos(attr_bg , 0 , 288 , 0 , 0)
	layer:addChild( attr_bg )

	-- 姓名
	local name = display.strokeLabel( hero_data["name"] , 5 , 340 , 24 , DESCCOLOR )
	layer:addChild( name )
	-- 绰号
	local Config = requires(IMG_PATH , "GameLuaScript/Config/Hero")
	local config_data = Config[hero_data["cid"]]
	layer:addChild( display.strokeLabel( config_data["bieming"] or "" , 160 + name:getLabel():getContentSize().width + 10 , 693 , 18 , ccc3( 0xef , 0x7a , 0x1a ) ) )

	-- 经验
	layer:addChild( KNBar:new("exp_general" , 5 , 525 , { maxValue = hero_data["lvup_exp"] , curValue = hero_data["cur_exp"] } ) )

	-- 等级
	local lvNode = display.strokeLabel( "Lv" .. hero_data["lv"] , 353 , 340 , 18 , DESCCOLOR )
	setAnchPos(lvNode , 170 , 340 , 1 , 0)
	layer:addChild( lvNode )



	-- 属性
	layer:addChild( display.strokeLabel( "攻" .. hero_data["atk"] , 5 , 300 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "防" .. hero_data["def"] , 60 , 300 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "命" .. hero_data["hp"]  , 115 , 300 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )
	layer:addChild( display.strokeLabel( "速" .. hero_data["agi"] , 170 , 300 , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) )


	-- 人物大图
	local big_img_btn = KNBtn:new(IMG_PATH .. "image/hero/" , {getImageByType(hero_data["cid"] , "b" , true)} , 12 , 11 , {
		upSelect = true,
		noHide = true,
		parent = self.scroll,
		callback = function()
			
			pushScene("detail" , {
				detail = "general",
				id = hero_data["id"],
			})
		end
	})
	layer:addChild( big_img_btn:getLayer() )
	-- 新手引导
	if KNGuide:getStep() == 2501 then
		KNGuide:show( big_img_btn:getLayer() , {
			offset_width = -20,
			offset_height = -30,
			offset_x = 5,
			offset_y = 30
		})
	end
	
	
	-- 武将职业标记
	local jobFlag
	if tonumber(config_data["role"]) > 0 then
		jobFlag = display.newSprite(  COMMONPATH .. "job" .. hero_data.role .. ".png" )
		setAnchPos(jobFlag , 10 , 213 )
		layer:addChild( jobFlag )
	end

	

	-- 星级
	local y = 238
	for i = 1 , hero_data["star"] do
		local star_img = display.newSprite( COMMONPATH .. "star.png" )
		setAnchPos(star_img , 280 , y)
		layer:addChild( star_img )
		
		y = y - 27
	end
	
	--等阶
	if hero_data["stage"] > 0 then
		local stage = display.newSprite(COMMONPATH.."stage/"..hero_data["stage"]..".png")
		setAnchPos(stage, 280, y - 5)
		layer:addChild(stage)
	end

	-- 天赋
	if hero_data["natural"] and #hero_data["natural"] > 0 then
		layer:addChild( display.strokeLabel( "组合" , 59 , 0 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )
		for key , v in pairs( hero_data["natural"] ) do
			local imgPath = COMMONPATH .. "tianfu_2.png"
			
			if checkActive("general", {nid = v, id = hero_data["id"], cid = hero_data["cid"]}) then
				imgPath = COMMONPATH .. "tianfu_1.png"
			end
			
			local star_img = display.newSprite( imgPath )
			setAnchPos(star_img , 105 + (key - 1) * 22 , 0 )
			layer:addChild( star_img )
		end
	end
	
	local bg = {"btn_grey.png"}
	local front = PATH.."jinhua_grey.png"
	-- 进化按钮
	if hero_data["star"] >= 3 then
		bg = {"btn.png", "btn_pre.png"}
		front = PATH.."jinhua.png"
	end
	local jinhuaBtn = KNBtn:new(PATH,  bg , 270 , 25 , {
		front = front,
		parent = self.scroll,
		callback = function()
			-- 判断等级开放
			local check_result = checkOpened("uplevel")
			if check_result ~= true then
				--KNMsg:getInstance():flashShow(check_result)
				--return
			end
			
			if hero_data["star"] < 3 then
				KNMsg.getInstance():flashShow("三星及三星以上英雄可进化，当前品质英雄最大等级:"..DATA_Uplevel:get(hero_data["star"].."")["initial_lv"].."级")
				return false
			end


			local curHeroData = DATA_General:get( gid ) 
			if curHeroData then
				pushScene("uplevel" , { target = curHeroData } )
			else
				HTTP:call("general" , "get" , {
					id = gid
				} , {
					success_callback = function()
						pushScene("uplevel" , { target = _data } )
					end 
				})
			end
		end
	})
	layer:addChild(jinhuaBtn:getLayer())

	layer:setContentSize(CCSizeMake(320,385))
		
	return layer
end
--升级升阶提示
function HeroLayer:coutUpTip( _id , isName  )
--	1：判断一星英雄达到15级上限。提示”已达到一星的等级上限，请更换英雄“
--    1.1：判断二星英雄达到20级上限。提示”已达到等级上限20级，请更换英雄“
--2：判断三星英雄达到等级上限，提示”“
	
	
	local hero_data = DATA_General:getTable( _id )
	local str = nil
	if hero_data.lv >= ( tonumber( DATA_User:get("lv") ) * 2 ) then
		str = isName and "您的英雄已经达到了主角等级的2倍，无法获得经验值。请提升主角等级。"  or "已经达到了主角等级的2倍，请提升主角等级。"
	else
		local totalLv = getConfig( "generalexp" )
		if hero_data["lv"] >= table.nums( totalLv ) then
			str = isName and "您的英雄" .. hero_data.name .. "已经达到了当前最高等级" or "已经达到了当前最高等级"
		else
			if hero_data["star"] == 1 and hero_data["lv"] >= 15 then
				str = isName and "您的一星英雄 " .. hero_data.name .. " 已达到15级的品阶限制上限，无法获得经验值" or "已达到一星的等级上限，请更换英雄"
			elseif hero_data["star"] == 2 and hero_data["lv"] >= 20 then
				str = isName and "您的二星英雄 " .. hero_data.name .. " 已达到20级的品阶限制上限，无法获得经验值" or "已达到等级上限20级，请更换英雄"
			elseif hero_data["star"] > 2 then
				local starConfige = getConfig( "generalstageconfig" , hero_data["star"] )
				local maxLv = starConfige.initial_lv + starConfige.lvadd * tonumber( hero_data["stage"] )
				if hero_data["lv"] >= maxLv then
					str = isName and "您的" .. hero_data["star"] .. "星英雄".. hero_data["name"] .. "已达到等级上限" .. maxLv .. "级，请进化英雄！" or "已达到等级上限" .. maxLv.. "级，请进化英雄"
				end
			end
		end
	end
	return str
end
return HeroLayer
