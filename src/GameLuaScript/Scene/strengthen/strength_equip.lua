local CREATE,ALL,TIME,STATE,GOLD = 0,1,2,3,4
local PATH = IMG_PATH.."image/scene/strengthen/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
--[[英雄模块，首页点击英雄图标进入]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local ProConfig = requires(IMG_PATH,"GameLuaScript/Config/Property")
local KNSlider = requires(IMG_PATH, "GameLuaScript/Common/KNSlider")
local Money = requires(IMG_PATH, "GameLuaScript/Config/data_equipstrongconfig")
local Value = requires(IMG_PATH, "GameLuaScript/Config/data_equipattr")
local limit = requires(IMG_PATH, "GameLuaScript/Config/equipstrongmax")

local StrengthenLayer = {
	baseLayer,
	layer,
	infoLayer,
	tabGroup,  --标签栏组
	iconGroup, --栏目中子项按钮选择组
	iconScroll, --按钮滑动组件
	timeText,  --需要时间
	fireState, --火焰
	gold,         --升级需要金币
	strenInfo,  --强化的信息显示层
	furnaceLayer, -- 火炉层
	scheduleHandler,
	startTime,
	account,   --当前账户
	slider,
	num ,     --升级数
	money,  --钱数
	next,
	value
	
	
}

function StrengthenLayer:new(param)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	local targetID = param.targetID

	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.num = 1
	local info_layer = InfoLayer:new("strength", 0, {tail_hide = true, title_text = PATH.."strong.png", closeCallback = function()
			popScene()
			if param.main then
				param.main[1]:createLayer(param.main[2], param.main[3])
			end
		 end})


	local bg = display.newSprite(SCENECOMMON.."bg.png")
	local title = display.newSprite(SCENECOMMON.."cbox.png")
	local tabBg = display.newSprite(COMMONPATH.."dark_bg.png")
	local titleBg = display.newSprite(PATH.."stren_title.png")
	local curBg = display.newSprite(PATH.."cur_bg.png")
	local upBg = display.newSprite(PATH.."up_bg.png")
	local next = display.newSprite(COMMONPATH.."next.png")
	
	setAnchPos(bg)
	setAnchPos(title,240,585,0.5)
	setAnchPos(tabBg, 0,425, 0,0.5)
	setAnchPos(titleBg,240,105,0.5)
	setAnchPos(curBg,355,280,0.5)
	setAnchPos(upBg,40,280)
	setAnchPos(next, 230, 310)

	this.layer:addChild(tabBg)
	--创建标签栏
	local tab = {
		{"weapon",10},
		{"defender",100},
		{"shoe",190},
		{"jewelry",280},
	}
	this.tabGroup = KNRadioGroup:new()
	for i,v in pairs(tab) do
		local temp = KNBtn:new(COMMONPATH.."tab/",{"tab_star_normal.png","tab_star_select.png"},v[2],690,{
				id = v[1],
				front = {COMMONPATH.."tab_strength/".."tab_"..v[1].."_normal.png",COMMONPATH.."tab_strength/".."tab_"..v[1]..".png"},
				callback=
				function()
					this.layer:removeChild(this.strenInfo,true)
					this:createTab(v[1])
				end
			},this.tabGroup)
		this.layer:addChild(temp:getLayer())
	end
	this.layer:addChild(titleBg)
	this.layer:addChild(title)
	this.layer:addChild(curBg)
	this.layer:addChild(upBg)
	this.layer:addChild(next)
	
	curBg = display.newSprite(PATH.."cur_text.png")
	setAnchPos(curBg, 80, 340)
	this.layer:addChild(curBg)
	
	curBg = display.newSprite(PATH.."up_text.png")
	setAnchPos(curBg, 320, 340)
	this.layer:addChild(curBg)
	
	curBg = display.newSprite(PATH.."dress_text.png")
	setAnchPos(curBg, 50,550)
	this.layer:addChild(curBg)
	
	local line = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(line, 5, 685)
	this.layer:addChild(line)
	
	

	local strenBtn = KNBtn:new(COMMONPATH,{"btn_bg_red.png", "btn_bg_red_pre.png"},180,110,{
			scale = true,
			front = COMMONPATH.."strengthen.png",
			callback = function()
				if this.iconGroup:getChooseBtn() then
					--temp
					if tonumber(DATA_Account:get("silver")) < this.money then
						KNMsg.getInstance():flashShow("对不起，您的银两不足，无法强化")
						return
					end

					HTTP:call("equip","equipup",{id = this.iconGroup:getId(), uplv = this.num} , {
						success_callback = function()
							KNMsg.getInstance():flashShow("强化成功")
							this.num = 1
							this:createInfo(this.iconGroup:getId())
						end
					})
				else
					KNMsg.getInstance():flashShow("请选择需要强化的装备")
				end
			end
		})
	this.layer:addChild(strenBtn:getLayer())

	-- 新手引导(3次)
	if KNGuide:getStep() == 205 then
		KNGuide:show( strenBtn:getLayer() , {
			callback = function()
				KNGuide:show( strenBtn:getLayer() , {
					callback = function()
						KNGuide:show( strenBtn:getLayer() , {
							callback = function()
								info_layer:refreshBtn()
							end
						})
					end
				})
			end
		})
	end
	

	local rest = display.newSprite(PATH.."rest.png")
	setAnchPos(rest,80,165)
	this.layer:addChild(rest)
	
	local icon = display.newSprite(COMMONPATH.."silver.png")
	setAnchPos(icon,135,165)
	this.layer:addChild(icon)
	
	this.account = display.strokeLabel(DATA_Account:get("silver").."",170,168, 20, 
				ccc3( 0x2c , 0x00 , 0x00 ) , 2 ,
				ccc3( 0x40 , 0x1d , 0x0c ))
	this.layer:addChild(this.account)
	
	local coast = display.newSprite(PATH.."coast.png")
	setAnchPos(coast,250,167)
	this.layer:addChild(coast)
	
	icon = display.newSprite(COMMONPATH.."silver.png")
	setAnchPos(icon,305,165)
	this.layer:addChild(icon)
	
	icon = display.newSprite(COMMONPATH.."circle.png")
	setAnchPos(icon,240,345, 0.5)
	this.layer:addChild(icon)
	
	this.tabGroup:chooseById(DATA_Bag:get("equip",targetID,"type"),true)
	this.iconGroup:chooseById(targetID , true)
--	this:createFurnace(CREATE)
	
--划动强化条	

	
	--增减按钮
	local addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , 365 , 200, {
		scale = true,
		priority = -130,
		callback = function()
			if this.num < 10 then
				this.num = this.num + 1
				this.slider:setValue(this.num)
			end
		end
	})
	
	local minusBtn = KNBtn:new(COMMONPATH,{"next_big.png"} ,80 , 200 ,{
		scale = true,
		priority = -130,
		callback = function()
			if this.num > 1 then
				this.num = this.num - 1
				this.slider:setValue(this.num)
			end
		end
	})
	minusBtn:setFlip(true)
	
	addBtn:getLayer():setScale( 0.9 )
	minusBtn:getLayer():setScale( 0.9 )
	this.layer:addChild(addBtn:getLayer())
	this.layer:addChild(minusBtn:getLayer())
	
	this.baseLayer:addChild(bg)
	this.baseLayer:addChild(info_layer:getLayer(),1)
	this.baseLayer:addChild(this.layer)	
	return this
end

	--每一栏信息
 function StrengthenLayer:createTab(type)
	if self.infoLayer then
		self.layer:removeChild(self.infoLayer,true)
	end
	self.infoLayer = display.newLayer()
	self.iconGroup = KNRadioGroup:new()
	self.iconScroll = KNScrollView:new(60,575,360,100,10,true,0,{turnBtn=COMMONPATH.."next.png"})

	--装备排序规则
	local function equipRule(l, r)
		local lValue = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(l),"equip")
		local rValue = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(r),"equip")
		
		--通过武将的id获取其所在阵位加权处理，第一位权值最大
		_,lValue = DATA_Formation:checkIsExist(tonumber(lValue))
		_,rValue = DATA_Formation:checkIsExist(tonumber(rValue))
		
		lValue = (9 - (lValue or 9)) * 10000
		rValue = (9 - (rValue or 9)) * 10000
		
		--按照星级排序,同星级按等 级排序
		lValue = lValue + DATA_Bag:get("equip", l, "star") * 500 + DATA_Bag:get("equip", l, "lv")
		rValue = rValue + DATA_Bag:get("equip", r, "star") * 500 + DATA_Bag:get("equip", r, "lv")
		
		return lValue > rValue
	end
	
	local items = DATA_Bag:getTable("equip", type)
	local result = getSortList(items, equipRule)
	local pos = 0 --元素所在的位置
	local temp,state
	for i,v in pairs(result) do
		pos = pos + 1
		local p = pos --需要新定义一个变量，记录当前位置

		v = tonumber(v)
		temp = KNBtn:new(SCENECOMMON,{"skill_frame1.png", "select1.png"},0,0,
			{
				id = v,
				upSelect = true ,
				selectZOrder = 12,
				parent = self.iconScroll,
				front = getImageByType(DATA_Bag:get("equip", v, "cid"),"s"),
				noHide = true,
				callback = function()
					self.num = 1
					self:createInfo(v)
					self.iconScroll:scrollTo(v)
				end,
			},self.iconGroup)
		
		self.iconScroll:addChild(temp:getLayer(),temp)
	end

	if pos == 0 then
		self.iconGroup:cancelChoose()
	else
		self.iconGroup:chooseByIndex(1 , true)
	end	
	self.iconScroll:alignCenter()
	self.infoLayer:addChild(self.iconScroll:getLayer())
	self.layer:addChild(self.infoLayer)
end

--每件装备的强化信息
function StrengthenLayer:createInfo(id, setText)
	local star = DATA_Bag:get("equip", id, "star")
	local lv = DATA_Bag:get("equip", id, "lv")
	local kind = getConfig("equip", DATA_Bag:get("equip", id, "cid"), "type")
	local init = getConfig("equip", DATA_Bag:get("equip", id, "cid"), "initial")
	
	if self.slider then
		self.layer:removeChild(self.slider, true)
	end


	if self.strenInfo then
		self.layer:removeChild(self.strenInfo,true)
	end
	self.strenInfo = display.newLayer()
	
	local btn = KNBtn:new(SCENECOMMON,{"skill_frame1.png"},210,440,{
		text = {{DATA_Bag:get("equip",id,"name").."  Lv"..DATA_Bag:get("equip",id,"lv"),14,nil,ccp(0,-50)}},
		front = getImageByType(DATA_Bag:get("equip",id,"cid"),"s")
	})
	self.strenInfo:addChild(btn:getLayer())
	
	
	local num = getConfig("equip", DATA_Bag:get("equip", id, "cid"), "star")
	for i = 1, num do
		local star = display.newSprite(COMMONPATH.."star.png")
		star:setScale(0.8)
		setAnchPos(star, 240 - (num * 30 * 0.8) / 2 + (i - 1) * 30 * 0.8 , 390)
		self.strenInfo:addChild(star)
	end
	
	
	local name_str = "无人装备"
	if DATA_ROLE_SKILL_EQUIP:getRoleId(id, "equip") then
		name_str = DATA_Bag:get("general",DATA_ROLE_SKILL_EQUIP:getRoleId(id, "equip"),"name")
	end
	local dressHero = display.strokeLabel(name_str, 140,550,20)
	self.strenInfo:addChild(dressHero)
	
	local cur = display.strokeLabel("Lv"..lv.." "..ProConfig[DATA_Bag:get("equip",id,"effect")]..":+"..DATA_Bag:get("equip",id,"figure"),60,310, 18, 
			ccc3( 0xff , 0xfb , 0xd4 ) , 2 ,
			ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(cur,130, 310, 0.5)
	self.strenInfo:addChild(cur)	
	
	self.next = display.strokeLabel("Lv"..(lv + self.num).." "..ProConfig[DATA_Bag:get("equip",id,"effect")]..":+"..math.round((init + (lv + self.num - 1) * Value[star][kind])) ,280,310, 18, 
			ccc3( 0xff , 0xfb , 0xd4 ) , 2, 
			ccc3( 0x40 , 0x1d , 0x0c ))
	setAnchPos(self.next,360, 310, 0.5)
	self.strenInfo:addChild(self.next)	

	self.money = Money[lv + self.num][star] - Money[tonumber(lv)][star]
	self.value = display.strokeLabel(self.money,340,168, 20, 
				ccc3( 0x2c , 0x00 , 0x00 ) , 2 ,
				ccc3( 0x40 , 0x1d , 0x0c ))
	self.strenInfo:addChild(self.value)
	
	--更新账户信息
	self.account:setString(DATA_Account:get("silver").."")

	self.layer:addChild(self.strenInfo)
		
			--划动条
	self.slider = KNSlider:new( "buy" ,  {
		x = 136 , 
		y = 620, 
		minimum = 1 , 
		maximum = math.min(10,(limit[star]["levmax"] - lv), DATA_User:get("lv") * 2 - DATA_Bag:get("equip", id, "lv"), #Money - DATA_Bag:get("equip", id, "lv") ), 
		value = 1 , 
		callback  = function( _curIndex )
			self.num = _curIndex
			if self.num == 0 then
				self.num = 1
			end
			if self.next and self.value then
				self.next:setString("Lv"..(lv + self.num).." "..ProConfig[DATA_Bag:get("equip",id,"effect")]..":+"..math.round((init + (lv + self.num - 1) * Value[star][kind])))
				self.money = Money[lv + self.num][star] - Money[tonumber(lv)][star]
				self.value:setString(self.money)		
			end
		end,
		priority = -140
	})
	
		
	self.layer:addChild( self.slider )
end

function StrengthenLayer:getLayer()
	return self.baseLayer
end

return StrengthenLayer