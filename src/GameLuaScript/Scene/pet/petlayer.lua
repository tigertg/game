local PATH = IMG_PATH .. "image/scene/pet/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
--[[英雄模块，首页点击英雄图标进入]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local petInfo = requires(IMG_PATH,"GameLuaScript/Scene/pet/petinfo")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local wearEquipCell = requires(IMG_PATH , "GameLuaScript/Scene/hero/wearEquipCell")
local Pet_Config = requires(IMG_PATH,"GameLuaScript/Config/Pet")
local Config_PetStage = requires(IMG_PATH , "GameLuaScript/Config/petstageconfig")

local PetLayer = {
	baseLayer,
	layer,
	infolayer,
	chooseLayer,
	petinfoLayer,
	iconGroup,
	hatch_btn,
}

function PetLayer:new(args)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	args = args or {}


	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.chooseLayer = display.newLayer()


	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild(bg)

	local pet_bg = display.newSprite(PATH .. "pet_bg.png")
	setAnchPos(pet_bg , 15 , 120)
	this.viewLayer:addChild(pet_bg)

	--宠物排序规则	
	local function petSort(l,r) --自定义顺序
		local sortValueL = 0
		local sortValueR = 0
		--若是上阵宠物，其权值最大 
		if l == DATA_Pet:getFighting()..""	then
			sortValueL = sortValueL + 999
		elseif r == DATA_Pet:getFighting().."" then
			sortValueR = sortValueR + 999
		else
		--首先按照星级排序，然后再加等级
			local starL = getConfig("pet",DATA_Bag:get("pet",l,"cid"),"star")
			local starR	= getConfig("pet",DATA_Bag:get("pet",r,"cid"),"star")
			sortValueL = sortValueL + starL
			sortValueR = sortValueR + starR
		end
			
		return sortValueL > sortValueR
	end


	this.infolayer = InfoLayer:new("pet" , 0 , {tail_hide = true , title_text = PATH .. "title.png"})
	
    --宠物选择按钮
    local function createChoose()
	    --这里根据排序规则生成键值的序列
	    local choose_index = 1
	    local keyList = getSortList(DATA_Bag:get("pet"),petSort)
    	local scroll = KNScrollView:new( 10 , 123 , 100 , 520 , 3)
    	local detailScroll 
    	detailScroll = KNScrollView:new(120, 370, 325, 400, 0, true, 1, {
	    	page_callback = function()
			    this.iconGroup:chooseByIndex(detailScroll:getCurIndex())
			    scroll:setIndex(detailScroll:getCurIndex(), true)
			    this:createInfo(this.iconGroup:getId())
	    	end
    	})

    	
    	
		this.iconGroup = KNRadioGroup:new()
		local state
		local x , y = 25 , 630
		for i = 1 , DATA_Bag:count("pet")  do
			local front , disable , bg
			local other = {}
			local temp_pet_info = DATA_Bag:get("pet" , keyList[i])

			if i <= DATA_Bag:count("pet") then
				front = getImageByType(temp_pet_info["cid"] , "s")
				disable = false
				bg = "small_photo_bg.png"
				if DATA_Pet:getFighting() == temp_pet_info["id"] then --判断是否是上阵宠物
					other[#other + 1] = {PATH .. "pet_state_fighting.png" , -10 , 40}
				end
				
			else
				bg = "small_photo_bg2.png"
				disable = true
			end

			other[#other + 1] = { COMMONPATH .. "equip_lv_bg.png" , 45 , 55 }
			
			-- 计算等级信息
			local lv , cur_exp , max_exp = DATA_Pet:calcExp(temp_pet_info.exp)
			local textData = {lv , 16 , ccc3( 0xff , 0xff , 0xff ) , { x = 25 , y = 30	} , nil , 20 }
			local temp
			temp = KNBtn:new(COMMONPATH , {bg,"select1.png"} , x , y  , {
				id = temp_pet_info["id"],
				front = front,
				noHide = true,
				frontScale = { 1 , 0 , 5 },
				parent = scroll,
				selectOffset = { 0 , 1 },
				selectZOrder = 15,
				other = other,
				disable = disable,
				upSelect = true,
				text = textData,
				callback = function()
					detailScroll:setIndex(i)
					this:createInfo(temp:getId())
				end,
			} , this.iconGroup)
			scroll:addChild(temp:getLayer() , temp)


			if args.gid and temp_pet_info["id"] == args.gid then
				choose_index = i
				this.iconGroup:chooseByIndex(choose_index)
				detailScroll:setIndex(choose_index, true, 0)
			end
		end
		scroll:alignCenter()

		this.layer:addChild(this.chooseLayer)
		
		this.layer:addChild(scroll:getLayer())


		-- 新手引导
		local guide_step = KNGuide:getStep()
		if guide_step == 402 then
			local btn = scroll:getItems(1)
			local btn_range = btn:getRange()

			KNGuide:show( btn:getLayer() , {
				mask_clickable = true,
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
				selectList = true,
				callback = function()
					KNGuide:show( this.hatch_btn:getLayer() )
				end
			})
		end
		
		--这里是滑动的宠物界面local pet
		for i = 1 , DATA_Bag:count("pet")  do
			local temp_pet_info = DATA_Bag:get("pet" , keyList[i])
			
			local pet = petInfo:new(0 , 0 , 325 , 355 , { id = temp_pet_info["id"], parent = detailScroll})
			detailScroll:addChild(pet:getLayer(), pet)
		end
		detailScroll:alignCenter()
		this.layer:addChild(detailScroll:getLayer())
    end
	
	
	if DATA_Bag:count("pet") > 0 then
		createChoose()
		this:createInfo(args.gid or this.iconGroup:getId())
	end
	this.layer:addChild(this:createProps())
	
	this.baseLayer:addChild(this.infolayer:getLayer(),1)
	this.viewLayer:addChild(this.layer)
	this.baseLayer:addChild(this.viewLayer)	
	return this.baseLayer 
end


   
--宠物信息界面 
function PetLayer:createInfo( id )
	if self.petinfoLayer then
		self.layer:removeChild(self.petinfoLayer,true)
	end
	self.petinfoLayer = display.newLayer()


	local pet_data = DATA_Bag:get("pet", id)
	local cid = pet_data.cid
	local config_data = Pet_Config[cid]
	
	
	-- 技能文字
	local tiansheng_bg = display.newSprite(  PATH .. "skill_type_bg.png" )
	self.petinfoLayer:addChild( tiansheng_bg )
	setAnchPos(tiansheng_bg , 108 , 295 )

	local tiansheng = display.newSprite(  PATH .. "tiansheng.png" )
	self.petinfoLayer:addChild( tiansheng )
	setAnchPos(tiansheng , 128 , 308 )

	local xuexi_bg = display.newSprite(  PATH .. "skill_type_bg.png" )
	self.petinfoLayer:addChild( xuexi_bg )
	setAnchPos(xuexi_bg , 108 , 200 )

	local xuexi = display.newSprite(  PATH .. "xuexi.png" )
	self.petinfoLayer:addChild( xuexi )
	setAnchPos(xuexi , 128 , 213 )
	
	local conf = config_data.star + 10 * DATA_Bag:get("pet", id, "stage")
	
	local skills_stars = {
		[1] = 1,
		[2] = 3,
		[3] = 4,
		[4] = 2,
		[5] = 4,
		[6] = 5,
	}

	local skill_lv  = math.floor(pet_data.lv / 10) + 1
	local pet_skills = pet_data.skill
	local x, y = 190, 300
	for i = 1, 6 do
		local num = i <= 3 and i or i - 3 
		local kind = i <= 3 and "a" or "p"
		local temp_id = kind .. num
		local pet_skill_cid = pet_skills[temp_id]
		local lock
		local text , front
		local pet_skill_config

		if not isset(pet_skills , temp_id) then
			lock = true
		else
			pet_skill_config = getConfig("petskill" , pet_skill_cid .. "" )
			front = getImageByType(pet_skill_cid , "s")
			text = { { pet_skill_config.name , 14 , ccc3(0x2c, 0, 0) , ccp(0, -45)} }
		end

		local skill = KNBtn:new(SCENECOMMON, {lock and "skill_frame4.png" or "skill_frame2.png"}, x, y, {
			text = text,
			scale = true,
			front = front,
			callback = function()
				if lock then
					KNMsg.getInstance():flashShow("需" .. skills_stars[i] .. "星及以上幻兽才能开启此技能位")
					return false
				end

				local skill_data = pet_skill_config
				skill_data["cid"] = pet_skill_cid
				skill_data["id"] = id
				skill_data["stage"] = pet_data.stage

				pushScene("detail" , {
					detail = "petskill",
					data = skill_data,
					pet_data = pet_data,
				})
			end
		})	
		self.petinfoLayer:addChild(skill:getLayer())

		-- 技能等级
		if not lock then
			local lv_bg_png = "skill_lv_bg.png"
			local lv_bg_x = x + 49
			local lv_bg_y = y + 52

			local lv_bg = display.newSprite(COMMONPATH .. lv_bg_png)
			setAnchPos(lv_bg , lv_bg_x , lv_bg_y)
			self.petinfoLayer:addChild(lv_bg , 10)

			local lv = CCLabelTTF:create(skill_lv , FONT , 16)
			lv:setColor( ccc3( 0xff , 0xff , 0xff ) )
			setAnchPos(lv , lv_bg_x + 11 , lv_bg_y + 2 , 0.5)
			self.petinfoLayer:addChild(lv , 11)
		end

		
		x = x + skill:getWidth() * 1.4
		if i % 3 == 0 then
			x = 190
			y = 205
		end
	end


	-- 操作按钮
	if DATA_Bag:count("pet") > 0 then
		local btn_img = {"btn_bg_red.png", "btn_bg_red_pre.png"}
		local btn_front = COMMONPATH .. "uppet.png" 
		local stage = DATA_Bag:get("pet", id, "stage")
		local btn = KNBtn:new(COMMONPATH , btn_img , 130 , 135 , {
			front = btn_front,
			callback = function()
				if config_data["star"] < 3 then
					KNMsg.getInstance():flashShow("只有三星以上幻兽能进化")
					return false
				elseif not isset(Config_PetStage , tostring(stage + 1)) then
					KNMsg.getInstance():flashShow("幻兽已进化到最高阶")
					return false
				end
				switchScene("petupdata",self.iconGroup:getId())
			end
		})	
		self.petinfoLayer:addChild(btn:getLayer())

		-- 新手引导
		if KNGuide:getStep() == 1201 then KNGuide:show( btn:getLayer() ) end


		-- 出战
		local btn_img = {"btn_bg_red.png","btn_bg_red_pre.png"}
		local btn_front = COMMONPATH .. "fight.png"
		if DATA_Pet:getFighting() == id then
			btn_img = {"btn_bg_red2.png"}
			btn_front = COMMONPATH .. "fight_grey.png"
		end
		local btn = KNBtn:new(COMMONPATH , btn_img , 280 , 135 , {
			scale = true,
			front = btn_front,
			callback = function() 
				if DATA_Pet:getFighting() == id then
					KNMsg.getInstance():flashShow("该幻兽已出战")
					return
				end

				HTTP:call("pet" , "seton" , {
					id = id
				} , {
					success_callback = function()
						switchScene("pet")
					end
				})
			end
		})	
		self.petinfoLayer:addChild(btn:getLayer())
		
		-- 新手引导
		if KNGuide:getStep() == 401 then KNGuide:show( btn:getLayer() ) end
	end

--
--
--
--	local wearEquipCell = requires(IMG_PATH , "GameLuaScript/Scene/hero/wearEquipCell")
--	-- 天生技能
--	local skillConfig = requires(IMG_PATH , "GameLuaScript/Config/Skill")
--	local tempData = {
--		cid = pet_data["skill_k"],
--		id = 0,
--		lv = pet_data["skill_lv"],
--	}
--	local equipSeatCell = wearEquipCell:new( 
--		360 ,
--		505 , 
--		tempData , 
--		function()
--			--详情
--			local skill_data = getConfig("petskill" , pet_data["skill_k"])
--			skill_data["cid"] = pet_data["skill_k"]
--			skill_data["lv"] = pet_data["skill_lv"]
--
--			pushScene("detail" , {
--				detail = "skill",
--				data = skill_data,
--				skillSeat = 1,
--				defaultSkill = true,
--			})
--		end ,
--		layer
--	)
--	self.petinfoLayer:addChild( equipSeatCell:getLayer() )
--
--	local skillConfig = requires(IMG_PATH, "GameLuaScript/Config/PetSkill")[ tempData.cid.."" ][tempData.lv..""]
--	--生成技能名称
--	local skill_name = CCLabelTTF:create(skillConfig.name , FONT , 18)
--	skill_name:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )
--	setAnchPos(skill_name , 393 , 482 , 0.5)
--
--	self.petinfoLayer:addChild( skill_name )
--	
--
--	
--	local skill_opened = checkOpened("skill")
--	for i = 1, 2 do
--		local tempData = petSkillInfo["s"..( i + 1 ) ] or "技能"
--		--技能位
--		local equipSeatCell
--		local skillX = 335 - 105 * (i - 1)
--		local equipSeatCell = wearEquipCell:new( 
--					skillX ,
--					200 , 
--					tempData , 
--					function()
--						-- 判断等级开放
--						local check_result = checkOpened("skill")
--						if check_result ~= true then
--							KNMsg:getInstance():flashShow(check_result)
--							return
--						end
--									
--						if type( tempData ) ~= "string" then
--							--详情
--							local DATA = DATA_Bag
--							local type = "skill"
--							local detail
--							if DATA:haveData(tempData["id"] , type) then
--								pushScene("detail" , {
--									detail = "skill",
--									id = tempData["id"],
--									petID = id , 
--									skillSeat = "s".. ( i + 1 ).. "" , 
--								})
--							else
--								HTTP:call(type , "get" , {
--									id = tempData["id"]
--								} , {
--									success_callback = function()
--										pushScene("detail" , {
--											detail = "skill",
--											id = tempData["id"],
--											petID = id , 
--											skillSeat = "s".. ( i + 1 ).. "" , 
--										})
--									end
--								})
--							end
--						else
--							--列表
--							local list
--							list = SelectList:new("skill",self.viewLayer,display.newSprite(COMMONPATH.."title/skill_text.png"),{ btn_opt = "ok.png",target = true, equipType = "petskill" , seatID = i + 1 ,
--									y = 85 ,
--									showTitle = true , 
--									optCallback = function()
--										list:destroy()
--										local targetId = list:getCurItem():getId()
--										--请求换更换宠物技能
--										HTTP:call("skill" , "petskill_dress" , {
--											id = id ,
--											skill_id = targetId ,
--											pos = "s"..( i + 1 )
--										} , {
--											success_callback = function()
--												--刷新数据
--												switchScene("pet")
--											end
--										})
--									end
--									})
--							self.baseLayer:addChild(list:getLayer() , 2)
--						end
--					end ,
--					layer,
--					skill_opened
--				)
--		self.petinfoLayer:addChild(equipSeatCell:getLayer())
--		
--		if tempData.cid  then
--			local skillConfig = requires(IMG_PATH, "GameLuaScript/Config/PetSkill")[ tempData.cid.."" ][tempData.lv..""]
--			--生成技能名称
--			local skill_name = CCLabelTTF:create(skillConfig.name , FONT , 18)
--			skill_name:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )
--			setAnchPos(skill_name , 393 , skillX - 23 , 0.5)
--
--			self.petinfoLayer:addChild( skill_name )
--		end
--	end
	
	self.layer:addChild(self.petinfoLayer)
end
	
function PetLayer:createProps()
	local props = display.newLayer()
	local path = PATH	
	--宠物按钮的操作，


	-- 孵化
	local btn_img = {"hatch.png"}
	if checkOpened("hatch") ~= true then
		btn_img = {"hatch_grey.png"}
	end
	local btn = KNBtn:new(PATH , btn_img , 10 , 643 , {
		callback = function()
			-- 判断等级开
			local check_result = checkOpened("hatch")
			if check_result ~= true then
				KNMsg:getInstance():flashShow(check_result)
				return
			end

			switchScene("incubation")
		end
	})
	props:addChild(btn:getLayer())

	self.hatch_btn = btn

	return props
end
return PetLayer