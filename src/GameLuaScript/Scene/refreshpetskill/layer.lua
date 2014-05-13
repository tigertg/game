local PATH = IMG_PATH .. "image/scene/refreshpetskill/"
local PET_PATH = IMG_PATH .. "image/scene/pet/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
--[[刷新幻兽技能]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local Pet_Config = requires(IMG_PATH,"GameLuaScript/Config/Pet")
local Pet_SkillUpFee = requires(IMG_PATH,"GameLuaScript/Config/petupstagefee")
local Petskill_Config = requires(IMG_PATH,"GameLuaScript/Config/Petskill")
local KNTextField = requires(IMG_PATH,"GameLuaScript/Common/KNTextField")



local refreshLayer = {
	baseLayer,
	viewLayer,
	selectLayer,
	infolayer,
	iconGroup,
	select_sprite,
	skillListLayer,
}

function refreshLayer:new(args)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	args = args or {}
	local pet_id = args.id
	local pet_data = DATA_Bag:get("pet" , pet_id)
	local cid = pet_data.cid
	local config_data = Pet_Config[cid]


	this.baseLayer = display.newLayer()
	this.viewLayer = display.newLayer()


	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.baseLayer:addChild(bg)

	local pet_bg = display.newSprite(COMMONPATH .. "bg_big.png")
	setAnchPos(pet_bg , 18 , 110)
	this.viewLayer:addChild(pet_bg)

	local top_bg = display.newSprite(PATH .. "top_bg.png")
	setAnchPos(top_bg , 28 , 490)
	this.viewLayer:addChild(top_bg)

	local middel_text = display.newSprite(PATH .. "middel_text.png")
	setAnchPos(middel_text , 55 , 455)
	this.viewLayer:addChild(middel_text)

	local bottom_bg = display.newSprite(PATH .. "bottom_bg.png")
	setAnchPos(bottom_bg , 28 , 215)
	this.viewLayer:addChild(bottom_bg)

	local max_skill_star = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
		[5] = 5,
	}
	local middle_label = display.strokeLabel( max_skill_star[config_data.star] , 248 , 456 , 24 , ccc3( 0x2c , 0x00 , 0x00 ) )
	this.viewLayer:addChild(middle_label)


	-- 技能文字
	local tiansheng_bg = display.newSprite(  PET_PATH .. "skill_type_bg.png" )
	this.viewLayer:addChild( tiansheng_bg )
	setAnchPos(tiansheng_bg , 34 , 645 )

	local tiansheng = display.newSprite(  PET_PATH .. "tiansheng.png" )
	this.viewLayer:addChild( tiansheng )
	setAnchPos(tiansheng , 54 , 658 )

	local xuexi_bg = display.newSprite(  PET_PATH .. "skill_type_bg.png" )
	this.viewLayer:addChild( xuexi_bg )
	setAnchPos(xuexi_bg , 34 , 530 )

	local xuexi = display.newSprite(  PET_PATH .. "xuexi.png" )
	this.viewLayer:addChild( xuexi )
	setAnchPos(xuexi , 54 , 543 )

	this.infolayer = InfoLayer:new("refreshpetskill" , 0 , {
		tail_hide = true , 
		title_text = PATH .. "title.png" , 
		closeCallback = function()
			switchScene("pet" , { gid = pet_id })
		end
	})
	this.baseLayer:addChild(this.infolayer:getLayer(),1)
	this.baseLayer:addChild(this.viewLayer)


	this:showList(pet_id , "a1")

	return this.baseLayer 
end


function refreshLayer:showList(pet_id , pos)
	local pet_data = DATA_Bag:get("pet" , pet_id)
	local cid = pet_data.cid
	local config_data = Pet_Config[cid]


	if self.skillListLayer then
		self.baseLayer:removeChild(self.skillListLayer , true)
	end
	self.skillListLayer = display.newLayer()

	-- 显示6个技能格
	local pet_skills = pet_data.skill
	local x, y = 130, 650
	for i = 1 , 6 do
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
			text = { { pet_skill_config.name , 14 , ccc3(0x2c, 0, 0) , ccp(0, -62)} }
		end

		local skill = KNBtn:new(SCENECOMMON, {lock and "skill_frame4.png" or "skill_frame2.png"}, x, y, {
			text = text,
			scale = true,
			front = front,
			callback = function()
				if lock then
					return false
				end

				self:selectOne(pet_id , temp_id)
			end
		})	
		self.skillListLayer:addChild(skill:getLayer())

		-- 显示星级
		if pet_skill_config then
			local star_num = pet_skill_config.star
			local star_init_x = x - 16 + (5 - star_num) * 10
			for i = 1 , star_num do
				local star = display.newSprite(COMMONPATH .. "star.png")
				star:setScale(0.7)
				setAnchPos(star , star_init_x + (i - 1) * 20 , y - 20)
				self.skillListLayer:addChild(star)
			end
		end
		
		x = x + 110
		if i % 3 == 0 then
			x = 130
			y = 535
		end
	end

	self.baseLayer:addChild(self.skillListLayer)

	self:selectOne(pet_id , pos)
end

   
--宠物信息界面 
function refreshLayer:selectOne( pet_id , id )
	if self.selectLayer then
		self.baseLayer:removeChild(self.selectLayer , true)
	end
	self.selectLayer = display.newLayer()

	if self.select_sprite == nil then
		self.select_sprite = display.newSprite(COMMONPATH .. "select1.png")
		self.baseLayer:addChild(self.select_sprite)
	end
	local pos_s = {
		["a1"] = {119 , 640},
		["a2"] = {229 , 640},
		["a3"] = {339 , 640},
		["p1"] = {119 , 525},
		["p2"] = {229 , 525},
		["p3"] = {339 , 525},
	}
	setAnchPos(self.select_sprite , pos_s[id][1] , pos_s[id][2])

	local pet_data = DATA_Bag:get("pet" , pet_id)
	local pet_skills = pet_data.skill
	local pet_skill_cid = pet_skills[id]
	local cid = pet_data.cid
	local config_data = Pet_Config[cid]
	self:showOneSkill(pet_skill_cid , 83 , 370 , pet_data.lv)

	-- 显示按钮
	local btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png" , "btn_bg_red_pre.png"}, 168 , 138 , {
		scale = true,
		front = PATH .. "refresh_btn.png",
		callback = function()
			HTTP:call("pet" , "rand_skill" , {
				target = pet_id,
				pos = id
			} , {
				success_callback = function(d)
					local rand_data = d.tmp

					self:randOne(pet_id , id , pet_skill_cid , rand_data.skill_cid , pet_data.lv)
				end
			})
		end
	})	
	self.selectLayer:addChild(btn:getLayer())

	-- 显示黄金
	local gold_sprite = display.newSprite(COMMONPATH .. "gold.png")
	setAnchPos(gold_sprite , 320 , 148)
	self.selectLayer:addChild(gold_sprite)

	local star = config_data.star
	local gold = Pet_SkillUpFee[star .. ""]
	local gold_label = display.strokeLabel( gold , 356 , 150 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
	self.selectLayer:addChild(gold_label)
	
	self.baseLayer:addChild(self.selectLayer)
end


function refreshLayer:randOne(pet_id , pos , old_cid , new_cid , pet_lv)
	if self.selectLayer then
		self.baseLayer:removeChild(self.selectLayer , true)
	end
	self.selectLayer = display.newLayer()


	self:showOneSkill(old_cid , 83 , 370 , pet_lv)
	self:showOneSkill(new_cid , 323 , 370 , pet_lv)

	-- 显示按钮
	local cancel_btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png" , "btn_bg_red_pre.png"}, 60 , 138 , {
		scale = true,
		front = COMMONPATH .. "cancel.png",
		callback = function()
			self:selectOne(pet_id , pos)
		end
	})	
	self.selectLayer:addChild(cancel_btn:getLayer())

	-- 显示按钮
	local save_btn = KNBtn:new(COMMONPATH, {"btn_bg_red.png" , "btn_bg_red_pre.png"}, 280 , 138 , {
		scale = true,
		front = COMMONPATH .. "save.png",
		callback = function()
			HTTP:call("pet" , "save_skill" , {
				target = pet_id,
				pos = pos
			} , {
				success_callback = function(d)
					self:showList(pet_id , pos)
				end
			})
		end
	})	
	self.selectLayer:addChild(save_btn:getLayer())

	-- 搞一个遮罩层，让用只能点按钮
	local maskLayer = PlayerGuide:createSprite()
	maskLayer:show(440 , 330 , ccp(20 , 120) , 0 , function()
		
	end , function()
		KNMsg.getInstance():flashShow("请先保存或者取消技能刷新结果")
	end)
	self.selectLayer:addChild(maskLayer)


	
	self.baseLayer:addChild(self.selectLayer)
end

function refreshLayer:showOneSkill( cid , x , y , pet_lv )
	local pet_skill_config = getConfig("petskill" , cid .. "" )
	local front = getImageByType(cid , "s")
	local text = { { pet_skill_config.name , 14 , ccc3(0x2c, 0, 0) , ccp(0, -62)} }

	local skill = KNBtn:new(SCENECOMMON, {"skill_frame2.png"} , x , y , {
		text = text,
		front = front,
	})	
	self.selectLayer:addChild(skill:getLayer())

	-- 显示星级
	if pet_skill_config then
		local star_num = pet_skill_config.star
		local star_init_x = x - 16 + (5 - star_num) * 10
		for i = 1 , star_num do
			local star = display.newSprite(COMMONPATH .. "star.png")
			star:setScale(0.7)
			setAnchPos(star , star_init_x + (i - 1) * 20 , y - 20)
			self.selectLayer:addChild(star)
		end
	end

	
	--[[
	local desc_label = display.strokeLabel( pet_skill_config[pet_stage .. ""]["desc"] , x - 40 , y - 150 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , {
		dimensions_width = 155 ,
		dimensions_height = 95,
		align = 0
	})
	]]
	-- self.selectLayer:addChild(desc_label)
	local skill_lv = math.floor(pet_lv / 10) + 1
	local desc_label = KNTextField:create({
		str = pet_skill_config[skill_lv .. ""]["desc"],
		width = 155,
		size = 16,
	})



	local scroll = KNScrollView:new( x - 40 , y - 145 , 155 , 95 , 1 , false )
	scroll:addChild( desc_label )
	scroll:alignCenter()
	self.selectLayer:addChild( scroll:getLayer() )
end

return refreshLayer