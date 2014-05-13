local PATH = IMG_PATH.."image/scene/forge/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNComboBox = requires(IMG_PATH,"GameLuaScript/Common/KNComboBox")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local Progress = requires(IMG_PATH, "GameLuaScript/Common/KNProgress")
local KNMask = requires(IMG_PATH, "GameLuaScript/Common/KNMask")
local ListItem = requires(IMG_PATH, "GameLuaScript/Scene/common/listitem")
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local CombineCfg = requires(IMG_PATH, "GameLuaScript/Config/Natural")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")
local needConfig = requires(IMG_PATH, "GameLuaScript/Config/evolvepool")
local PoolLayer = {
	layer,
	contentLayer,
	params,
	curType,
	curStar,
	curItem
}

function PoolLayer:new(params)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	this.params = params or {}
	this.curItem = {}
		
	
	local title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	this.layer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	this.layer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 240, 425, 0.5, 0.5)
	this.layer:addChild(title, -1)
		
	title = display.newSprite(PATH.."pool_text.png")
	setAnchPos(title, 245, 765, 0.5)
	this.layer:addChild(title)

	title = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(title, 240, 690, 0.5)
	this.layer:addChild(title)
	
	local kinds = {
		"general",
		"pet"
	}
	
	local group = KNRadioGroup:new()
	for i = 1, #kinds do
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png","tab_star_select.png"},30 + (i - 1) * 90 , 695, {
			front =  {COMMONPATH.."tab/".."tab_"..kinds[i].."_big_normal.png",COMMONPATH.."tab/".."tab_"..kinds[i].."_big_select.png"},
			callback = function()
				this:createContent(kinds[i])
			end
		}, group)
		this.layer:addChild(btn:getLayer(), -1)
	end
	
	group:chooseByIndex(1, true)

	return this
end

function PoolLayer:createContent(kind)
	if self.contentLayer then
		self.layer:removeChild(self.contentLayer, true)	
	end
	self.contentLayer = display.newLayer()
	self.curType = kind
	
	local bg = display.newSprite(PATH.."star_bg.png")
	setAnchPos(bg, 240, 620, 0.5)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."pool_tool.png")
	setAnchPos(bg, 240, 200, 0.5)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH..kind.."_pool_tip.png")
	setAnchPos(bg, 240, 580, 0.5)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."add.png")
	setAnchPos(bg, 240, 490, 0.5)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."arrow.png")
	setAnchPos(bg, 240, 370, 0.5)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."use.png")
	setAnchPos(bg, 310, 381)
	self.contentLayer:addChild(bg)
	
	bg = display.newSprite(PATH.."has.png")
	setAnchPos(bg, 310, 215)
	self.contentLayer:addChild(bg)
	
	local str = kind == "general" and "英雄" or "幻兽"
	self.contentLayer:addChild(display.strokeLabel(str.."进化符用于同星级"..str.."的进化", 80, 110, 20 ,ccc3(255,255,255)))
	
	local itemsLayer 
	local function chooseItems()	
		if itemsLayer then
			self.contentLayer:removeChild(itemsLayer, true)
		end
		itemsLayer = display.newLayer()
		local pos = {
			{91, 465, {kind == "general" and "英雄" or "幻兽", 20, ccc3(0x2c, 0, 0), ccp(0,0)}, kind},
			{322, 465, {"道具", 20, ccc3(0x2c, 0, 0), ccp(0,0)}, "prop"},
			{210, 255, {""}, "prop"}
		}	
		local front, text
		for i = 1, #pos do
			if self.curItem[i] then  --已选择了元素
				front = getImageByType(DATA_Bag:get(pos[i][4], self.curItem[i], "cid"), "s")			
				text = {getConfig(pos[i][4], DATA_Bag:get(pos[i][4], self.curItem[i], "cid"), "name")..(DATA_Bag:get(pos[i][4],self.curItem[i],"lv") and " Lv"..DATA_Bag:get(pos[i][4],self.curItem[i],"lv") or ""), 16, ccc3(255,255,255), ccp(0, -70)}
				--显示消耗符文丹的数量
				if i == 2 then
					itemsLayer:addChild(createLabel({x = 360, y = 382, str = needConfig[self.curType][self.curStar]["num"], color = ccc3(255,255,255)}))
				elseif i == 3 then
					itemsLayer:addChild(createLabel({x = 360, y = 215, str = DATA_Bag:countItems("prop", false, {type = (kind == "general" and "hero" or "pet").."jinhuafu", star = self.curStar}), color = ccc3(255,255,255)}))
				end
			else
				text = pos[i][3]
				front = nil
			end
			
			local filter
			filter = {type = pos[i][4] == "prop" and "fuwendan" or nil, star = self.curStar}
			local btn = KNBtn:new(SCENECOMMON, {"skill_frame1.png"}, pos[i][1], pos[i][2], {
				front = front,
				text = text,
				callback = function()
					if i < 3 then
						if i == 2 then
							if self.curItem[1] 	then
								if not self.curItem[2] then
									local str
									if self.curStar == 3 then
										str = "初级符文丹不足，可以通过挑战9-7关卡获得。"
									elseif self.curStar == 4 then
										str = "中级符文丹不足，可以通过挑战10-5关卡获得。"
									else
										str = "高级符文丹不足，可以通过挑战10-14关卡获得。"
									end
									KNMsg.getInstance():flashShow(str)
								end
							else
								KNMsg.getInstance():flashShow("请先选择需要消耗的"..(self.curType == "pet" and "幻兽" or "英雄").."卡牌")
							end
							return
						end
						
						local list
						list = SelectList:new(pos[i][4] , self.contentLayer,display.newSprite(COMMONPATH .. "title/"..(pos[i][4] == "general" and "hero" or pos[i][4]).."_text.png") , {
							btn_opt = "ok.png",
							target = true,
							filter = filter,
							showTitle = true , 
							exceptUse = true,
							optCallback = function()
								list:destroy()
								if i == 1 then
									for k, v in pairs(DATA_Bag:getTable("prop", {type = "fuwendan", star = self.curStar})) do
										self.curItem[2] = k
									end
									
									if tonumber(DATA_Bag:get("prop", self.curItem[2], "num")) < needConfig[self.curType][self.curStar]['num'] then
--										KNMsg.getInstance():flashShow("所需要的符文丹不足，无法融合")
--										self.curItem = {}
--										return 
										self.curItem[2] = nil
									end
									
									self.curItem[3] = nil
									self.curItem[i] = list:getCurItem():getId() 
								elseif i == 2 then
									self.curItem[i] = list:getCurItem():getId() 
								end
								chooseItems()
							end
						})
						self.layer:addChild(list:getLayer())	
					else
						if self.curItem[3] then
							pushScene("detail" , {
									detail = "prop",
									id = self.curItem[3],
									propOpt = function()
										if DATA_General:haveGet() then
											DATA_Formation:set_index(1)
											switchScene("hero",{gid = DATA_Formation:getCur()})
										else
											HTTP:call("general" , "get",{},{success_callback =
												function()
													DATA_General:haveGet(true)
													DATA_Formation:set_index(1)
													switchScene("hero",{gid = DATA_Formation:getCur() })
												end
											})
										end
									end
								})
						end
					end
				end
			})
			itemsLayer:addChild(btn:getLayer())
			
			if self.curItem[i] then
				local star
				local starNum = getConfig(pos[i][4], DATA_Bag:get(pos[i][4], self.curItem[i], "cid"), "star") 
				for j = 1, starNum do
					star = display.newSprite(COMMONPATH .. "star.png")
					star:setScale(0.8)
					setAnchPos(star, star:getContentSize().width * 0.8 * (j - 1) + (pos[i][1] + btn:getWidth() / 2) - (star:getContentSize().width * 0.8 * starNum) / 2, pos[i][2] - star:getContentSize().height - 3 )
					itemsLayer:addChild(star)
				end
			end
		end
		self.contentLayer:addChild(itemsLayer)
	end
	
	--进化符炼制星级选择
	local group = KNRadioGroup:new()
	for i = 1, 3 do
		local starChoose = KNBtn:new(COMMONPATH, {"btn_bg_dis.png", "btn_bg.png"}, 60 + (i - 1) * 140, 630, {
			front = PATH..(i + 2).."_star.png",
			upSelect = true,
			callback = function()
				self.curStar = (i + 2)
				self.curItem = {}
				chooseItems()
			end
		}, group)
		self.contentLayer:addChild(starChoose:getLayer())	
	end
	group:chooseByIndex(1, true)
	
	
	
	local auto = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 65, 365, {
		front = PATH.."auto_add.png" ,
		callback = function()
			local items = DATA_Bag:getTable(self.curType, {star = self.curStar}, nil, true)
			local keyList = getSortList(items, function(l,r)
				return DATA_Bag:get(kind, l, "lv") < DATA_Bag:get(kind, r, "lv")
			end)
			if table.nums(items) > 0 then
				--取一个英雄 数据，后面要调 
				for k, v in pairs(keyList) do
					self.curItem[1] = v
					break
				end
				
				--检查符文丹数量
				for k, v in pairs(DATA_Bag:getTable("prop", {type = "fuwendan", star = self.curStar})) do
					self.curItem[2] = k
				end
							
				if tonumber(DATA_Bag:get("prop", self.curItem[2], "num")) < needConfig[self.curType][self.curStar]['num'] then
--					KNMsg.getInstance():flashShow("所需要的符文丹不足，无法融合")
--					self.curItem = {}
--					return 
					self.curItem[2] = nil
				end
				self.curItem[3] = nil
				chooseItems()
			else
				KNMsg.getInstance():flashShow("没有能炼化的材料卡牌")				
			end
		end
	})
	self.contentLayer:addChild(auto:getLayer())
	
	
	local startBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 140, {
		front = PATH.."start.png",
		callback = function()
			if self.curItem[1] then
				if self.curItem[2] then
					HTTP:call("evolvepool", "merge", {type = self.curType, id = self.curItem[1]}, {
						success_callback = function(id, cid)
							self.curItem = {}
							self.curItem[3] = id
							local card_popup = KNCardpopup:new(cid,function()
								chooseItems()
							end ,
							 {	
								init_x =  0,
								init_y = -150,
								end_x =  0,
								end_y =  -150,})
							display.getRunningScene():addChild(card_popup:play())
						end
					})	
				else
					local str
					if self.curStar == 3 then
						str = "制符失败，初级符文丹不足，可以通过挑战9-7关卡获得。"
					elseif self.curStar == 4 then
						str = "制符失败，中级符文丹不足，可以通过挑战10-5关卡获得。"
					else
						str = "制符失败，高级符文丹不足，可以通过挑战10-14关卡获得。"
					end
					KNMsg.getInstance():flashShow(str)
				end
			else
				KNMsg.getInstance():flashShow("请先选择进化材料!~")
			end
		end
	})
	self.contentLayer:addChild(startBtn:getLayer())


	-- 新手引导
	if KNGuide:getStep() == 3403 then
		KNGuide:show( auto:getLayer() , {
			callback = function()
				KNGuide:show( startBtn:getLayer() , {remove = true})
			end
		})
	end
	
	
	
	self.layer:addChild(self.contentLayer)
end


function PoolLayer:getLayer()
	return self.layer end

return PoolLayer
