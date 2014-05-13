--[[是物品列表的显示信息，可以传递type来设置显示的元素
	equip,skill,pet,prop,general
]]
local PATH = IMG_PATH.."image/common/"
local KNBtn = requires (IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNCheckBox = requires (IMG_PATH,"GameLuaScript/Common/KNCheckBox")
local Property = requires(IMG_PATH, "GameLuaScript/Config/Property")
local ListItem = {
	layer,
	id,
	optBtn,  --操作按钮
	checkBox,  --选择框
	params,  --传递父组件parent来计算点击的偏移量，iconCallback是点击图按钮的回调，checkBoxOpt,点击复选框的操作
	current   --点击操作按钮时，此标志为真
}

function ListItem:new(type,id,params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.id = id
	this.params = params or {}

	local bg
	if this.params.greyBg then
		bg = display.newSprite(PATH.."item_bg_disable.png")
	else
		 bg = display.newSprite(PATH.."item_bg.png")
	end
	setAnchPos(bg)
		
	local function createItem()	
		local DATA = {}
		if this.params.data then
			for k,v in pairs(this.params.data) do 
				DATA[k] = v
			end
			DATA.get = 
			function(self,t,cid,key) --为了对应bag函数的方法
				if key == "lv" then
					return 1
				end
				return DATA[cid..""][key] 
			end
		else
			DATA = DATA_Bag
		end
		
		local line, scale = 0, 1   --记数，记录物品显示有几行，若多于3行，则需要对星星进行缩放
		--名字与等级的显示，有则虾米示，没有则只显示名字
		local name = getConfig(getCidType(DATA:get(type, id, "cid")), DATA:get(type, id, "cid"), "name")
		local lv = DATA:get(type,id,"lv")

		-- 幻兽需要自己算等级
		if type == "pet" then
			lv = DATA_Pet:calcExp(DATA:get(type,id,"exp"))
		end

		if lv then
			name = name.."       ".."Lv"..lv
		end
--		name = CCLabelTTF:create(name,FONT,18)
--		setAnchPos(name,100,45)
		name = display.strokeLabel(name,90,75,16, ccc3( 0x2c , 0x00 , 0x00 ) )
		this.layer:addChild(name)
		line = line + 1
		
		--显示数量
		local num = DATA_Bag:get(type,id,"num")
		if num then
			local numText = CCLabelTTF:create("数量: "..num,FONT,18)
			numText:setColor(DESCCOLOR)
			setAnchPos(numText,90,25)
			this.layer:addChild(numText)
			line = line + 1
		end
		
		--是否有附加属性
		local append = DATA:get(type,id,"effect")
		local appendValue = DATA:get(type,id,"figure") 
		
		if string.trim(type) == "" then --屏蔽装备的属性信息，只显示两行 
			append = nil
		end

		if append and appendValue then
			local text = CCLabelTTF:create(Property[append]..": +"..appendValue,FONT,18)
			text:setColor(DESCCOLOR)
			setAnchPos(text,90,52)
			this.layer:addChild(text)
			line = line + 1
		else
			if type == "prop" then
				local text = CCLabelTTF:create(getConfig("prop", DATA_Bag:get(type, id, "cid"), "bagdesc"), FONT, 18)
				text:setColor(DESCCOLOR)
				setAnchPos(text,90,52)
				this.layer:addChild(text)
				line = line + 1
			end
		end
		
		--显示星级
		local star = getConfig(type,DATA_Bag:get(type,id,"cid") or id,"star")
		if not star and type == "skill" then --若没有找到配置文件且是技能类型
			star = getConfig("petskill",DATA_Bag:get(type,id,"cid") or id,"star")
		end
		
		if star and type ~= "prop" then
			local starImg, x, y = nil, 90, 0
			if line == 1 then
				y = 35 
			elseif line == 2 then
				y = 25 
			end
			
			for i = 1, star do
				starImg = display.newSprite(COMMONPATH.."star.png")
				starImg:setScale(scale)
				setAnchPos(starImg,x,y)
				this.layer:addChild(starImg)
				x = x + starImg:getContentSize().width * scale + 1
			end	 						 
			
			--等阶
			if (DATA_Bag:get(type, id, "stage") or 0) > 0 then
				local stage = display.newSprite(COMMONPATH.."stage/"..DATA_Bag:get(type, id, "stage")..".png")
				setAnchPos(stage, x, y)
				this.layer:addChild(stage)
			end
		end
		
		if this.params["formation"] then	
			this.layer:addChild( display.strokeLabel( "需统帅力:" .. getConfig( "generallead" , star, "lead" ) , 320 , 8 , 20 , ccc3(0x2c , 0x00 , 0x00 ) ) )
		end
		
--		if this.params["sell"] and (type == "equip" or type == "skill") then
		if this.params["sell"] then
			this:initCheckBox()
		end
		
		if this.params["check"] then
			this:initCheckBox()
		end
		this:initOptBtn(type,id)
		
		this:setState(type)
	end
	
	this.layer:addChild(bg)
	this.layer:setContentSize(bg:getContentSize())
	createItem()
	
	return this
end

function ListItem:getLayer()
	return self.layer
end

function ListItem:initOptBtn(type,id)
	local icon, iconStr
	local btnStr , btnBg

	local cid = DATA_Bag:get(type , id , "cid") or id

	
	iconStr = getImageByType(cid , "s")
	btnBg = {"btn_bg.png", "btn_bg_pre.png"}
	if self.params["optBtnGrey"] then
		btnBg = {"btn_bg_dis.png"}
	end

	if type == "equip" then
		btnStr = "strengthen_small.png" 
	elseif type == "pet" then
		btnStr = self.params["optBtnGrey"] and "fight_small_grey.png" or "fight_small.png"
	elseif type == "skill" then
		btnStr = self.params["optBtnGrey"] and "up_small_grey.png" or "up_small.png"
	elseif type == "general" then
		btnStr = self.params["optBtnGrey"] and "chuangong_small_grey.png" or "chuangong_small.png"
	elseif type == "prop" then
		btnStr = "use_small.png"
	end
--	iconStr = DATA_Bag:get(type,id,"type").."_icon.png"
--	print(DATA_Bag:get(type,id,"type"))
	
	--若有设置按钮图片,则优先使用
	if self.params["btn_opt"] then
		btnStr = self.params["btn_opt"]
	end
	
	local scale
	if self.params["iconCallback"] then
		scale = true
	end
	
	local other, text
	if type == "skill" and DATA_Bag:get("skill", id, "type") == "petskill" then
		other = {IMG_PATH.."image/scene/bag/kind_bg.png", 0, 2}
		text = {"兽",16, ccc3(255,255,255), ccp(-20, 23),nil, 17}
	end
	icon = KNBtn:new(IMG_PATH.."image/scene/common/",{"skill_frame1.png"},15,30,{
		parent = self.params["parent"],
		front = iconStr ,frontScale = {1,0,3}, 
		priority = self.params["priority"],
		scale = scale,
		other = other,
		text = text,
		callback= self.params["iconCallback"]
	})
	self.layer:addChild(icon:getLayer())		

	if not self.params["check"] and not self.params["sell"] then
		self.optBtn = KNBtn:new(PATH , btnBg , 350 , 50 , {
			front = PATH..btnStr,
			parent = self.params["parent"],
			priority = self.params["priority"],
			callback = 
			function() 
				self.current = true
				self.params["optCallback"]()
			end
		})
	self.layer:addChild(self.optBtn:getLayer())
	end
end

function ListItem:initCheckBox()
	self.checkBox = KNCheckBox:new(360,35,{path=PATH,parent = self.params["parent"],checkBoxOpt = self.params["checkBoxOpt"],file={"checkbox_bg.png","checkbox_choose.png","checkbox_lock.png"}})
	self.layer:addChild(self.checkBox:getLayer())
	self.checkBox:check(self.params["checked"])
end


function ListItem:setState(type)
	local state, str
	if type == "equip" then	
		str = DATA_Bag:get("general",DATA_ROLE_SKILL_EQUIP:getRoleId(self.id, type),"name")
		if str then
			state = display.strokeLabel(str.."已装备",330,15,14,ccc3(0x2c,0x00,0x00))
			setAnchPos(state, 430, 15, 1)
			self.layer:addChild(state)
			
			local img = display.newSprite(IMG_PATH.."image/scene/bag/".."equiped.png")
			setAnchPos(img, 250, 20)
			self.layer:addChild(img)
		end
	elseif type == "general" then
		if DATA_Formation:checkIsExist(self.id) then
			if self.params.greyBg then
				state = display.newSprite(COMMONPATH.."lineup_2.png")
			else
				state = display.newSprite(COMMONPATH.."lineup_1.png")
			end
			setAnchPos(state, 250,25)
			self.layer:addChild(state)
		end
	elseif type == "pet" then
		if DATA_Pet:getFighting() == self.id then
			state = display.newSprite(COMMONPATH.."lineup_1.png")
			setAnchPos(state,250,25)
			self.layer:addChild(state)
			if self.params["disableByState"] then
				self.optBtn:setEnable(false)
				self.optBtn:setBg(1,PATH.."btn_bg_dis.png")
				self.optBtn:setBg("front",PATH.."lineup_0_grey.png")
			end
		end
	elseif type == "skill" then
		if DATA_Bag:get(type,self.id,"type") == "generalskill" then
			str = DATA_Bag:get("general",DATA_ROLE_SKILL_EQUIP:getRoleId(self.id, type),"name")
			if str then
				state = display.strokeLabel(str.."已装备",330,15,14,ccc3(0x2c,0x00,0x00))
				self.layer:addChild(state)
				
				local img = display.newSprite(IMG_PATH.."image/scene/bag/".."equiped.png")
				setAnchPos(img, 240, 20)
				self.layer:addChild(img)
			end
		else
			str = DATA_Bag:get("pet",DATA_PetSkillDress:isDress(self.id),"name")		
			if str then
				state = display.strokeLabel(str.."已装备",330,15,14,ccc3(0x00,0x00,0x00))
				self.layer:addChild(state)
				
				local img = display.newSprite(IMG_PATH.."image/scene/bag/".."equiped.png")
				setAnchPos(img, 240, 20)
				self.layer:addChild(img)
			end
		end	
	end
end


function ListItem:getX()
	if self.params["parent"] then
		return self.layer:getPositionX() + self.params["parent"]:getX() + self.params["parent"]:getOffsetX()
		end
	return self.layer:getPositionX()
end

function ListItem:getY()
	if self.params["parent"] then
		return self.layer:getPositionY() + self.params["parent"]:getY() + self.params["parent"]:getOffsetY()
	end
	return self.layer:getPositionY()
end


function ListItem:getWidth()
	return self.layer:getContentSize().width
end

function ListItem:getHeight()
	return self.layer:getContentSize().height
end

function ListItem:isSelect()
	return self.checkBox:isSelect()
end

function ListItem:check(bool)
	self.checkBox:check(bool)
end

function ListItem:isCurrent()
	return self.current
end

function ListItem:resetCurrent()
	self.current = false
end

function ListItem:getId()
	return self.id
end

function ListItem:getOptBtn()
	return self.optBtn
end

function ListItem:getCheckbox()
	return self.checkBox
end

return ListItem