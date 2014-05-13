--[[英雄模块，首页点击英雄图标进入]]

local PATH = IMG_PATH .. "image/scene/bag/"
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local BagItem = requires(IMG_PATH , "GameLuaScript/Scene/common/listitem")--require "GameLuaScript/Scene/bag/bagitem"
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local Config = requires(IMG_PATH,"GameLuaScript/Config/Property")
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
local KNSlider = requires(IMG_PATH, "GameLuaScript/Common/KNSlider")

local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

local PAGEITEMS = 10

local BagLayer = {
	baseLayer,
	layer,
	itemsLayer,
	infoLayer,
	sell,
	group,
	statLayer,  --出售时的统计层
	selectNum,
	total,
	totalValue,
	sellItems,    --选择出售的元素
	maxPage,   --总页数
	curPage,   --当前页数
	keyList,   --背包物品序列
	
}

function BagLayer:new(data)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	
	this.baseLayer = display.newLayer()
    this.layer = display.newLayer()
   	this.sellItems = {}
   	this.total = 0
   	this.maxPage = 1
   	this.curPage = 1
   	this.keyList = {}
   	local data =data or {}

	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	
	local listBg = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(listBg,0,425,0,0.5)
	this.layer:addChild(listBg)



	local bagConfig = {
		{
			"general",
			"tab_hero"
		},
		{
			"equip",
			"tab_equip"
		},
		{
			"skill",
			"tab_skill"
		},
		{
			"pet",
			"tab_pet"
		},
		{
			"prop",
			"tab_props"
		},

	}
	local temp
	local startX,startY = 10,690
	this.group = KNRadioGroup:new()
	for i = 1, #bagConfig do
		temp = KNBtn:new(COMMONPATH.."tab/",{"tab_star_normal.png","tab_star_select.png"},startX,startY,{
			disableWhenChoose = true,
			upSelect = true,
			id = bagConfig[i][1],
			front = {COMMONPATH.."tab/"..bagConfig[i][2].."_normal.png",COMMONPATH.."tab/"..bagConfig[i][2]..".png"},

			callback=
			function()
				--清空出售的数据
				this.selectNum = 0
				this.total = 0
				this.sellItems = {}
				this.sell = false
				this:createStatLayer(bagConfig[i][1])
	
				this:createBag(bagConfig[i][1])
			end
		},this.group)
		this.layer:addChild(temp:getLayer())
		startX = startX + temp:getWidth() + 4
	end
	
	local line = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(line, 6, 685)
	this.layer:addChild(line)

	this:createBag(data.kind or "general", data.offset)


	this.infoLayer = InfoLayer:new(layerName, 0, {title_text = PATH.."bag_text.png", tail_hide = true})

	this.baseLayer:addChild(bg)
	this.baseLayer:addChild(this.layer)
	this.baseLayer:addChild(this.infoLayer:getLayer())
	
	
	return this.baseLayer

end

function BagLayer:createBag(kind,offset, page)
	if self.itemsLayer then
		self.layer:removeChild(self.itemsLayer,true)
	end

	local optBtnGrey = false
	local btn_opt = nil
	if kind == "equip" then
		-- 判断等级开放
		if checkOpened("equip_strenthen") ~= true then
			optBtnGrey = true
			btn_opt = "strengthen_small_grey.png"
		end
	elseif kind == "general" then
		if checkOpened("byexp") ~= true then
			optBtnGrey = true
			btn_opt = "chuangong_small_grey.png"
		end
	elseif kind == "pet" then
		if checkOpened("pet") ~= true then
			optBtnGrey = true
		end
	end
	
	--物品排序规则
	local function itemSort(l,r) --自定义顺序
		local leftValue, rightValue	 = 0, 0
		local rt, lt = kind, kind
		--下面是跟据类型判断物品的状态，若已上阵或已使用则拥有最高的权值
		if kind == "pet" then
			 if l == DATA_Pet:getFighting().."" then
			 	leftValue = 99999999
			 elseif r == DATA_Pet:getFighting().."" then
			 	rightValue = 99999999
			 end
		elseif kind == "general" then
			if DATA_Formation:checkIsExist(tonumber(l)) then
				leftValue = 99999999
			end
			
			if DATA_Formation:checkIsExist(tonumber(r)) then
				rightValue = 99999999	
			end
		elseif kind == "skill" then
			 lt = DATA_Bag:get(kind, l, "type")
			 rt = DATA_Bag:get(kind, r,"type")
			 
			 if lt == "petskill" then
			 	if DATA_PetSkillDress:isDress(tonumber(l)) then
			 		leftValue = 99999999
			 	end
			 elseif lt == "generalskill" then
				  if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(l)) then
					leftValue = 99999999 
				 end
			 end
			 
			 if rt == "petskill" then
				 if DATA_PetSkillDress:isDress(tonumber(r)) then
			 		rightValue = 99999999
	     	 	 end
			 elseif rt == "generalskill" then
			    if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(r)) then
		    	 	rightValue = 99999999
				end
			 end
		elseif kind == "equip" then
			 if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(l)) then
				leftValue = 99999999 
			 end
			 
		     if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(r)) then
		     	rightValue = 99999999
			 end
		end
		
		leftValue = leftValue + getConfig(lt, DATA_Bag:get(kind, l, "cid"), "star") * 5000000  + DATA_Bag:get(kind, l, "cid") * 500 + (DATA_Bag:get(kind,l,"lv") or 0)
		rightValue = rightValue + getConfig(rt, DATA_Bag:get(kind, r, "cid"), "star") * 5000000 + DATA_Bag:get(kind, r, "cid") * 500 + (DATA_Bag:get(kind,r,"lv") or 0)
		
		return leftValue > rightValue
	end
	
	local function newSort(l, r)
		local lValue, rValue = 0, 0
		if kind == "general" then	
			local lOn, lPos = DATA_Formation:checkIsExist(tonumber(l))
			local rOn, rPos = DATA_Formation:checkIsExist(tonumber(r))
			if lOn then
				lValue = 100000 + (8 - lPos) * 10000
			end
			
			if rOn then
				rValue = 100000 + (8 - rPos) * 10000
			end
			
			lValue = lValue + getConfig(kind, DATA_Bag:get(kind,l,"cid"),"star") * 500 + DATA_Bag:get(kind, l, "lv")
			rValue = rValue + getConfig(kind, DATA_Bag:get(kind,r,"cid"),"star") * 500 + DATA_Bag:get(kind, r, "lv")
		elseif kind == "equip" then
			local typeValue = {
				["weapon"] = 4,
				["defender"] = 3,
				["shoe"] = 2,
				["jewelry"] = 1,
			}
			local lDress = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(l), "equip")
			local rDress = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(r), "equip")
			
			
			if lDress then
				local _, pos = DATA_Formation:checkIsExist(tonumber(lDress))
				lValue = 1000000 + typeValue[DATA_Bag:get(kind, l, "type")] * 100000 + (8 - pos) * 5000
			end	
			
			if rDress then
				local _, pos =  DATA_Formation:checkIsExist(tonumber(rDress))
				rValue = 1000000 + typeValue[DATA_Bag:get(kind, r, "type")] * 100000 +(8 - pos) * 5000
			end
			lValue = lValue + getConfig(kind, DATA_Bag:get(kind,l,"cid"),"star") * 500 + (DATA_Bag:get(kind, l, "lv") or 0)
			rValue = rValue + getConfig(kind, DATA_Bag:get(kind,r,"cid"),"star") * 500 + (DATA_Bag:get(kind, r, "lv") or 0)	
		elseif kind == "skill" then
			local lType = DATA_Bag:get(kind, l, "type")
			local rType = DATA_Bag:get(kind, r, "type")
			
			local function getValue(t, id)
				local value = 0
				if t == "petskill" then
					value = 100000
				else
					local dress = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(id), "skill")
					
					if dress then
						local _, pos =  DATA_Formation:checkIsExist(tonumber(dress))
						value = 1000000  +(8 - pos) * 5000
					end
				end
				return value
			end
			
			lValue = getValue(lType, l)
			rValue = getValue(rType, r)
			
			lValue = lValue + getConfig(lType, DATA_Bag:get(kind,l,"cid"),"star") * 500 + (DATA_Bag:get(kind, l, "lv") or 0)
			rValue = rValue + getConfig(rType, DATA_Bag:get(kind,r,"cid"),"star") * 500 + (DATA_Bag:get(kind, r, "lv") or 0)	
		end
		
		return lValue > rValue
	end
	
	self.itemsLayer = display.newLayer()
	if DATA_Bag:count(kind) > 0 then
		self.curPage = page or 1
		if not self.keyList[kind] then
			self.keyList[kind] = getSortList(DATA_Bag:getTable(kind), newSort)
		end
		self.maxPage = math.ceil(#self.keyList[kind] / PAGEITEMS)
		
		local scroll 
		if self.sell then
			scroll = KNScrollView:new(15,205,450,480,5)
		else
			scroll = KNScrollView:new(15,155,450,530,5)
		end	
		
		--背包每页显示PAGEITEMS定义的元素个数
		local max = #self.keyList[kind] - self.curPage * PAGEITEMS
		if max >= 0 then
			max = self.curPage * PAGEITEMS		
		elseif max < 0 then
			max = (self.curPage - 1) * PAGEITEMS + (PAGEITEMS + max)
		end
		
		for i = (self.curPage - 1) * PAGEITEMS + 1, max  do
			local v = DATA_Bag:get(kind, self.keyList[kind][i])
			if v["type"] == "stonepatch" then
				btn_opt = "hecheng_small.png"
			else
				btn_opt = nil
			end

			-- 按钮变灰
			local set_optBtnGrey = false
			if optBtnGrey ~= true then
				if kind == "skill" then
					local str = nil
					if DATA_Bag:get("skill" , v.id , "type") == "generalskill" then
						str = DATA_Bag:get("general" , DATA_ROLE_SKILL_EQUIP:getRoleId(v.id , "skill") , "name")
					else
						str = DATA_Bag:get("pet" , DATA_PetSkillDress:isDress(v.id) , "name")
					end

					if not str then
						set_optBtnGrey = true
					end
				elseif kind == "pet" then
					if DATA_Pet:getFighting() == v.id then
						set_optBtnGrey = true
					end
				end
			end

			local item
			item = BagItem:new(kind , v["id"] , {
				sell = self.sell,
				parent = scroll,
				optBtnGrey = set_optBtnGrey or optBtnGrey,
				btn_opt = btn_opt,

				iconCallback = function()	--当点击图标按钮后先从全局数据中查找是否存在数据，若没有则请求网络，否则隐藏用户信息栏，显示详细界面
					local DATA = self:getDataFile(kind)
					
					if DATA:haveData(v["id"] , kind) or kind == "pet" then
						pushScene("detail" , {
							detail = kind,
							id = v["id"],
							propOpt = item:getOptBtn():getCallback()
						})
					else
						HTTP:call(kind , "get" , {
							id = v["id"]
						} , {
							success_callback = function()
								pushScene("detail" , {
									detail = kind,
									id = v["id"],
								})
							end
						})
					end
				end,

				checkBoxOpt = function()	--出售时点击复选框的操作
					if item:isSelect() then
						self.sellItems[item:getId()] = item:getId()
						self.total = self.total + DATA_Bag:get(kind,item:getId(),"price") * (DATA_Bag:get(kind, item:getId(), "num") or 1)
					else
						self.sellItems[item:getId()] = nil
						self.total = self.total - DATA_Bag:get(kind,item:getId(),"price") * (DATA_Bag:get(kind, item:getId(), "num") or 1)
					end

					self.totalValue:setString(self.total)
					self.selectNum:setString(table.nums(self.sellItems))
				end,
				optCallback = function()	--点按钮的操作
					if kind == "skill" then
						local str = nil
						if DATA_Bag:get("skill" , item:getId() , "type") == "generalskill" then
							str = DATA_Bag:get("general" , DATA_ROLE_SKILL_EQUIP:getRoleId(item:getId() , "skill") , "name")
						else
							str = DATA_Bag:get("pet" , DATA_PetSkillDress:isDress(item:getId()) , "name")
						end

						if not str then
							KNMsg:getInstance():flashShow("未装备的技能不可升级")
							return
						end
						
						if DATA_Bag:get("skill" , item:getId() , "type") == "generalskill" then
							switchScene("strengthen", {gid = item:getId(),mode = "heroskill",types = 2})
						else
							switchScene("strengthen", {gid = item:getId(),mode = "petplainskill",types = 2})
						end
						
						--[[pushScene("strengthen" , {
							type = "strength_skill" ,
							targetID = item:getId(),
							resumeCallback = function()
								self:createBag(kind,scroll:getOffset())
							end
						})	]]
					elseif kind == "general" then
						-- 判断等级开放
						local check_result = checkOpened("byexp")
						if check_result ~= true then
							KNMsg:getInstance():flashShow(check_result)
							return
						end
			

						local curHeroData = DATA_Bag:get( "general" , item:getId() ) 
						if curHeroData.lv <=1 then
							KNMsg.getInstance():flashShow("一级武将不可做传功者！")
						else
							pushScene("byexp" , { source = curHeroData , backtype = "back_bag"} )	
						end
						
					elseif kind == "equip" then
						-- 判断等级开放
						local check_result = checkOpened("equip_strenthen")
						if check_result ~= true then
							KNMsg:getInstance():flashShow(check_result)
							return
						end
							pushScene("strengthen",{ type = "strength_equip" , targetID = item:getId(), resumeCallback = 
							function()
								self:createBag(kind,scroll:getOffset())	
							end})	
					elseif kind == "pet" then
						-- 判断等级开放
						local check_result = checkOpened("pet")
						if check_result ~= true then
							KNMsg:getInstance():flashShow(check_result)
							return
						end

						if DATA_Pet:getFighting() == item:getId() then
							KNMsg:getInstance():flashShow("该幻兽已出战")
							return
						end

						HTTP:call("pet" , "seton" , {
							id = item:getId()
						} , {
							success_callback = function()
								switchScene("pet")
							end
						})
					elseif kind == "prop"  then
						print(v["type"])
						if v["type"] == "energydrug" or v["type"] == "powerdrug" then                    --主角丹药
							HTTP:call("status", "eat", {id = item:getId()},{success_callback=
							function(data)
								switchScene("bag",{kind = "prop", offset = scroll:getOffset()
								} , function()
									KNMsg.getInstance():flashShow("物品使用成功,"..getConfig("prop", v["cid"], "bagdesc"))
								end)
							end})
						
						elseif v["type"] == "challengebook" then
							HTTP:call("insequip","useshu", {id = item:getId()}, {
							success_callback = function()
							switchScene("bag",{kind = "prop", offset = scroll:getOffset()
								} , function()
									KNMsg.getInstance():flashShow("挑战书已使用，藏宝楼挑战次数增加!")
								end)
							end
							})
						 
						elseif v["type"] == "petegg" then                        --幻兽蛋
							-- 判断等级开放
							local check_result = checkOpened("hatch")
							if check_result ~= true then
								KNMsg:getInstance():flashShow(check_result)
								return
							end
								switchScene("incubation")
						elseif string.find(v["type"],"kit") then                    --锦囊
							if isBagFull() then
								return false
							end
							HTTP:call("bag","usekit",{id = v['id']},{
								success_callback = function(data)
									switchScene("bag", {kind = kind, offset = scroll:getOffset()},
									function()
										local card_popup = KNCardpopup:new(data.cid , function()
											end , {
	--											init_x =  196,
	--											init_y = 211,
	--											end_x =  196,
	--											end_y =  211,
	--											top_tips = display.strokeLabel("锦囊已使用，获得物品:", 0, 0, 20),
											})
											display.getRunningScene():addChild(card_popup:play())
	--									KNMsg.getInstance():flashShow("锦囊已使用，获得物品:"..data.name)
									end)
								end
							})
						elseif v["type"] == "stonepatch" then
							if isBagFull() then
								return false
							end
							
							if DATA_Bag:getTypeCount("prop", DATA_Bag:get("prop", v["id"], "cid"))  >= 5 then
								self:combine("prop", v["id"], scroll)
							else
								KNMsg.getInstance():flashShow("碎片不足，5个以上碎片才可以合成")
							end
						elseif v["type"] == "transmission" then
							-- 判断等级开放
							local check_result = checkOpened("byexp")
							if check_result ~= true then
								KNMsg:getInstance():flashShow(check_result)
								return
							end
							
							switchScene("byexp")
						elseif v["type"] == "stone" then
							-- 判断等级开放
							local check_result = checkOpened("pulse")
							if check_result ~= true then
								KNMsg:getInstance():flashShow(check_result)
								return
							end

							local hero = DATA_Formation:get_index(1)
							if DATA_General:haveGet() then
								HTTP:call("pulse" , "get", { id = hero.gid } , {
									success_callback = function()
										switchScene("pulse" , hero.gid)
									end
								})
							else
								HTTP:call("general" , "get",{} , {
									success_callback = function()
										HTTP:call("pulse" , "get", { id = hero.gid } , {
											success_callback = function()
												switchScene("pulse" , hero.gid)
											end
										})
									end
								})
							end
							
						elseif v["type"] == "vip" then
							HTTP:call("bag", "usevipkit", {id = v["id"]}, {
								success_callback = function(data,func)
									switchScene("bag", {kind = kind, offset = scroll:getOffset()},function()
										func(data)
									end)
								end
							})
						elseif v["type"] == "viptest" then
							HTTP:call("bag", "usev3card", {id = v['id']}, {
								success_callback = function()
									switchScene("bag", {kind = kind, offset = scroll:getOffset()}, function()
										KNMsg.getInstance():flashShow("vip3体验卡使用成功，尊享vip特权3天!~")
									end)
								end
							})
						elseif v["type"] == "zhufu" then
							HTTP:call("bag", "usezhufukit", {id = v["id"]}, {
								success_callback = function(data,func)
									switchScene("bag", {kind = kind, offset = scroll:getOffset()},function()
										func(data)
									end)
								end
							})
						end
					end
				end
			})
			--检查是否有选中的出售元素
			if table.hasValue(self.sellItems, v["id"]) then
				item:check(true)
			end

			scroll:addChild(item:getLayer())
		end

		if offset then
			self.group:chooseById(kind,false)
			scroll:setOffset(offset)
		end
		scroll:alignCenter()
		scroll:effectIn()
		self.itemsLayer:addChild(scroll:getLayer())
		
		--显示物品当前数量
		self.itemsLayer:addChild(createLabel({str = DATA_Bag:count(kind).."/100", x = 400, y = 115, color = ccc3(255, 255,255)}))	
		
		if not self.sell then
			local sellBtn
			sellBtn = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"},15,105,{
			front = PATH.."bag_sell.png",
			scale = true,
			callback = function()
				local cur_tab = self.group:getId()
				if cur_tab == "general" then
					KNMsg.getInstance():flashShow("英雄不可出售")
					return
				end
				if cur_tab == "pet" then
					KNMsg.getInstance():flashShow("幻兽不可出售")
					return
				end

				self.sell = true
				self:createBag(self.group:getId())
				self:createStatLayer(self.group:getId(), newSort)
				sellBtn:showBtn(false)
				sellBtn:setEnable(false)
			end})
			self.itemsLayer:addChild(sellBtn:getLayer())
		end
		
			
		local bg = display.newSprite(COMMONPATH.."page_bg.png")
		setAnchPos(bg,240,110,0.5)
		self.itemsLayer:addChild(bg)
		
		local pageNum = display.strokeLabel(self.curPage.."/"..self.maxPage, 0, 0, 20, ccc3(0xff, 0xfb, 0xd4))
		setAnchPos(pageNum, 240, 115, 0.5)
		self.itemsLayer:addChild(pageNum)
		
		--翻页按钮
		local pre = KNBtn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
			scale = true,
			flipX = true,
			callback = function()
				if self.curPage > 1 then
					self:createBag(kind, offset, self.curPage - 1)
				end
			end
		})
		self.itemsLayer:addChild(pre:getLayer())
		
		local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
			scale = true,
			callback = function()
				if self.curPage < self.maxPage then
					self:createBag(kind, offset, self.curPage + 1)
				end
			end
		})
		self.itemsLayer:addChild(next:getLayer())
		
	else
--		local text = display.strokeLabel("无", 100, 300, 280, ccc3(0x2c, 0, 0))
		local text = display.newSprite(COMMONPATH.."empty.png")
		setAnchPos(text,240, 425, 0.5,0.5)
		self.itemsLayer:addChild(text)
	end
	self.layer:addChild(self.itemsLayer)
end

function BagLayer:createStatLayer(kind, rule)
	if self.statLayer then
		self.layer:removeChild(self.statLayer,true)
	end

	if self.sell then
		self.statLayer = display.newLayer()
		local countBg = display.newSprite(PATH.."bag_num_bg.png")
		local countText = display.newSprite(PATH.."bag_num_text.png")
		local valueBg = display.newSprite(PATH.."bag_value_bg.png")
		local valueText = display.newSprite(COMMONPATH.."silver.png")
		self.selectNum = CCLabelTTF:create("0",FONT,20)
		self.totalValue = CCLabelTTF:create("0",FONT,20)

		local okBtn = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"},250,0,{scale = true, front = COMMONPATH.."ok.png", callback =
			function()
				HTTP:call("bag","sell",{type = kind,ids = string.join(self.sellItems,",")},{success_callback=
					function()
						self.layer:removeChild(self.statLayer,true)
						self.sell = false
						self.total = 0
						self.sellItems = {}
						self.keyList[kind] = getSortList(DATA_Bag:getTable(kind), rule)
						self:createBag(kind)
					end
				})
			end
			})
		local cancelBtn = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"},340,0,{scale = true,front = COMMONPATH.."cancel.png", callback=
			function()
				self.layer:removeChild(self.statLayer,true)
				self.sell = false
				self.total = 0
				self.sellItems = {}
				self:createBag(self.group:getId())
			end
			})

		setAnchPos(countText,10,10)
		setAnchPos(countBg,55,5)
		setAnchPos(valueText,100,10)
		setAnchPos(valueBg,130,5)
		setAnchPos(self.selectNum,70,10)
		setAnchPos(self.totalValue,150,10)
		setAnchPos(self.statLayer,30,160)

		self.statLayer:addChild(countBg)
		self.statLayer:addChild(valueBg)
		self.statLayer:addChild(countText)
		self.statLayer:addChild(valueText)
		self.statLayer:addChild(okBtn:getLayer())
		self.statLayer:addChild(cancelBtn:getLayer())
		self.statLayer:addChild(self.selectNum)
		self.statLayer:addChild(self.totalValue)

		self.layer:addChild(self.statLayer)
	end
end

--宝石合成
function BagLayer:combine( type , id , scroll )
	self.buyLayer = display.newLayer()
	local baseX = display.cx
	local baseY = display.cy - 28
	
	local bg = display.newSprite(COMMONPATH.."tip_bg.png")
	setAnchPos( bg , baseX - 193 , baseY , 0 , 0 )
	self.buyLayer:addChild(bg)
	
	--物品Icon
	local icon = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , baseX - 148 , baseY + 135 , {  front = getImageByType(DATA_Bag:get(type, id , "cid") , "s") } )
	self.buyLayer:addChild( icon:getLayer() )	
	
	-- 名字
	self.name = display.strokeLabel( DATA_Bag:get(type, id,"name") , baseX - 75 , baseY + 170 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , 2 , ccc3(0x40 , 0x1d , 0x0c ) , { dimensions_width = 130 , dimensions_height = 30 ,align = 0 } )
	self.buyLayer:addChild( self.name )
	
	--购买数量
	local numBg = display.newSprite(PATH.."bag_num_bg.png")
	local num = 1 
	setAnchPos(numBg,baseX + 116 , baseY + 136 , 0 )
	self.buyLayer:addChild(numBg)
	
	--数量文本
	local numText = display.strokeLabel( 1 .. "" , baseX + 116 , baseY + 136 , 20 , ccc3(0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 36 , dimensions_height = 30 ,align = 1 } )
	self.buyLayer:addChild(numText)
	
--	if math.floor(DATA_Bag:getTypeCount("prop", DATA_Bag:get(type, id, "cid")) / 5) > 1 then
		--修改数值
		local function changeValue()
			numText:setString(num)
		end
		
		--划动条
		local slider = KNSlider:new( "buy" ,  {
											x = baseX - 106 , 
											y = baseY -53 , 
											minimum = 1 , 
											maximum = math.floor(DATA_Bag:getTypeCount("prop", DATA_Bag:get(type, id, "cid")) / 5), 
											value = 1 , 
											callback  = function( _curIndex ) num =  _curIndex  changeValue() end ,
											priority = -140
											} )
		self.buyLayer:addChild( slider )
		
		--增减按钮
		local addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX + 128 , baseY + 77 , {
			scale = true,
			priority = -130,
			callback = function()
				if num < 99 then
					num = num + 1
					slider:setValue( num )
				end
			end
		})
		
		local minusBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX - 165 , baseY + 77 ,{
			scale = true,
			priority = -130,
			callback = function()
				if num > 1 then
					num = num - 1
					slider:setValue( num )
				end
			end
		})
		minusBtn:setFlip(true)
		
		addBtn:getLayer():setScale( 0.9 )
		minusBtn:getLayer():setScale( 0.9 )
		self.buyLayer:addChild(addBtn:getLayer())
		self.buyLayer:addChild(minusBtn:getLayer())
		

--	end

	
	local mask = KNMask:new( {item = self.buyLayer } )
	--确定，取消按钮
	local ok = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"}, baseX - 134 , baseY + 28 ,{
		front = COMMONPATH.."hecheng_small.png" ,
		scale = true,
		priority = -130,
		callback = function()
			HTTP:call("pulse", "merge", {num = num , id = id}, {
				success_callback = function()
					switchScene("bag",{kind = "prop"
								} , function()
									KNMsg.getInstance():flashShow("宝石已合成")
								end)
				end
			})
		end
	})
	local cancel = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"} , baseX + 54 , baseY + 28 ,{front = COMMONPATH.."cancel.png",scale = true,priority = -130,callback=
		function()
			mask:remove()
			-- self.baseLayer:removeChild(mask:getLayer(),true)
		end})
	self.buyLayer:addChild(ok:getLayer())
	self.buyLayer:addChild(cancel:getLayer())
	

	self.baseLayer:addChild(mask:getLayer())
end

--跟据类型断需要哪一个全局数据文件,和详细信息类名
function BagLayer:getDataFile(kind)
	local data
	if kind == "equip" then
		data = DATA_Equip
	elseif kind == "skill" then
		data = DATA_Bag
	elseif kind == "pet" then
		data = DATA_Pet
	elseif kind == "prop" then
		data = DATA_Bag 
	elseif kind == "general" then
		data = DATA_General
	end
	return data
end
return BagLayer
