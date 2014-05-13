--[[物品选择列表，将需要显示的元素全部添加至此列表中]]
local PATH = IMG_PATH.."image/common/"
local ListItem = requires(IMG_PATH, "GameLuaScript/Scene/common/listitem")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local Hero = requires(IMG_PATH, "GameLuaScript/Config/Hero")

local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

--每页的元素个数
local PAGEITEMS = 10

local SelectList = {
	mask,
	baseLayer,
	layer,
	scroll,
	hideLayer,
	params,
	items,
	okBtn,
	contentLayer,
	maxPage,
	curPage
	
}

--[[对选择列表的内容进行设置，
	kind 为显示类型, (equip,skill,general,pet,prop)
	hideLayer 为要隐藏的层，防止在当前显示层还能够点击到下层的按钮
	titleStr 为当前层的标题
	params 中设置其它参数:  btn_opt:元素操作按钮文字图片
						optCallback:操作按钮回调 函数
						okCallback:底部确定按钮的回调 函数
						check :是否是多选框
						checkBoxOpt：复选框回调 函数
						checked：是否已选中	
						--selectedList暂时只用来在宠物融合中使用
						filter:过滤器，用来过滤大类型中的小类型，如道具中的宠物蛋，食物等
						showTitle:是否显示标题
						x,y,位置
]]
function SelectList:new(kind,hideLayer,titleStr,params)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.params = params or {}
	this.items = {}
	this.hideLayer = hideLayer 
	this.curPage = 1
	this.maxPage = 1
	local x, y, anX, anY = 245, 425, 0.5, 0.5 --位置默认居中
	if this.params["x"] then
		x = this.params["x"]
		anX = 0
	end
	
	if this.params["y"] then
		y = this.params["y"]
		anY = 0
	end
--	
	local bg = display.newSprite(PATH.."dark_bg.png")
--	setAnchPos(bg,x,y,anX,anY)
	setAnchPos(bg, 0 , 425, 0, 0.5)
	this.layer:addChild(bg)

	local scrollY,scrollHeight = 150,580 --这是滑动组件的高度与y坐标，若有确定按钮则需要进行调整  
	--没有确定回调 函数则不显示确定按钮
	this.okBtn = nil
	if this.params["okCallback"] then
		scrollY,scrollHeight = 160,570
		this.okBtn = KNBtn:new(PATH,{"btn_bg.png","btn_bg_pre.png"},200,110,{scale = true,
			front = PATH.."ok.png",
			priority = -131,
			callback=
			function()
				this.params["okCallback"]()
			end
		})	
		this.layer:addChild(this.okBtn:getLayer())
	end
	
	this:createContent(kind, this.params, scrollY, scrollHeight)
	
	--这里是将需要隐藏的层传递进来，防止在当前的选择层还能点击到下层的按钮
	if hideLayer then
		hideLayer:setPositionX(480)
	end
	
	this.layer:setTouchEnabled(true)
	
	this.baseLayer:addChild(this.layer)
	
	if this.params["noInfo"] then
	else
		local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
		local infoLayer = InfoLayer:new("list" , 0, {title_text = titleStr, tail_hide = true, priority = -131, closeCallback = function()
			this:destroy()
			if this.params["closeCallback"] then
				this.params["closeCallback"]()
			end
		end})
		this.baseLayer:addChild(infoLayer:getLayer())
	end
	return this
end

function SelectList:getLayer()
--	return self.layer
--	return self.baseLayer
	self.mask = KNMask:new({item = self.baseLayer})
	return self.mask:getLayer()
end

function SelectList:getSelectItems()
	local select = {}
	for i,v in pairs(self.scroll:getItems()) do
		if v:isSelect() then
			select[v:getId()] = v:getId()
		end	
	end
	return select
end

--返回当前要操作的元素
function SelectList:getCurItem()
	for i,v in pairs(self.scroll:getItems()) do
		if v:isCurrent() then
			return v
		end
	end
end

function SelectList:resetCurrent()
	for i,v in pairs(self.scroll:getItems()) do
		if v:isCurrent() then
			v:resetCurrent()
			break
		end
	end
end

function SelectList:destroy()
	self.mask:remove()
	-- self.mask:removeFromParentAndCleanup(true)
	if self.hideLayer then
		setAnchPos(self.hideLayer)
	end
end

function SelectList:getItems(index)
	return self.scroll:getItems(index)
end

function SelectList:getOkBtn()
	return self.okBtn
end

function SelectList:createContent(kind, params, scrollY, scrollHeight)
	if self.contentLayer then
		self.layer:removeChild(self.contentLayer, true)
	end
	self.contentLayer = display.newLayer()
	
	
	self.scroll = KNScrollView:new(0,scrollY,480,scrollHeight,5,false,0)
	local checked
	--
	local usedEquipData = params.equipType == "generalskill" and DATA_ROLE_SKILL_EQUIP:get_data() or DATA_PetSkillDress:get_data()
	
	--根据类型选择对应的元素表，configSkill为所有的配置技能
	local itemsTable, keyList
	if kind == "configSkill" then
		itemsTable = getConfig("skill")
		for k,v in pairs(getConfig("petskill")) do
			itemsTable[k] = v['1']
		end
	else
		itemsTable = DATA_Bag:getTable(kind, params.filter, nil, params.exceptUse)
	end
	
	if table.nums(itemsTable) > 0 then
		--物品排序规则
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
			
		keyList = getSortList(itemsTable, newSort)
		self.maxPage = math.ceil(#keyList / PAGEITEMS)
--		for i,v in tableIterator(itemsTable,newSort) do	
		local max = #keyList - self.curPage * PAGEITEMS
		if max >= 0 then
			max = self.curPage * PAGEITEMS		
		elseif max < 0 then
			max = (self.curPage - 1) * PAGEITEMS + (PAGEITEMS + max)
		end
		
		for i = (self.curPage - 1) * PAGEITEMS + 1, max  do
			local v = itemsTable[keyList[i]]

			local temp,skip 
			if kind == "configSkill" then --若是读取配置表id则不跳过
					temp = ListItem:new("skill",keyList[i],{parent = self.scroll,priority = -131, btn_opt = self.params["btn_opt"],optCallback = self.params["optCallback"],check = self.params["check"],checkBoxOpt = self.params["checkBoxOpt"],checked = checked,data = itemsTable})
					self.scroll:addChild(temp:getLayer(),temp)		
					
			else
				if self.params["selectedList"] then
					if self.params["target"] then   --根据类型来设置要显示哪些元素，如果是目标选择列表，则当前已选中的和将要被消耗的不进行显示，
		--				if self.params["selectedList"]["target"] == v["id"] then
		--					skip = true
		--				else
						if self.params["selectedList"]["source"][v["id"]] then
							skip = true
						end
					else --若是来源选择框，则目标选择框中已选中的元素不进行显示,已上阵的宠物不显示
						if kind == "pet" then  --宠物列表的过滤
							if self.params["selectedList"]["target"] == v["id"] or DATA_Pet:getFighting() == v["id"] then
								skip = true
							end
							if self.params["selectedList"]["source"][v["id"]] then   --根据传递来的已选中的列表设置选中状态
								checked = true
							else
								checked = false
							end
						elseif kind == "skill"  then--技能列表过滤
							--若技能类型不同，或品质不同，或已装备，或已选 择 则不显示
							if getCidType(self.params["selectedList"].target) ~= getCidType(v["cid"]) or 
								getConfig("skill",v["cid"],"star") ~= getConfig("skill",self.params["selectedList"].target,"star") or 
									table.hasValue(self.params["selectedList"].source,v["id"]) then
								skip = true
							end
						end
					end
				end
				
				if kind == "equip" then
					--如果不是对应装备类型则不显示
					if v.type ~= params.equipType then
						 skip = true
					else
	--					--判断是否已经使用装备
	--					local equipKey = { "e1" , "e2" , "e3" , "e4"}
	--					--遍历所有  对应装备位 数据
	--					for key , value in pairs( usedEquipData ) do 
	--						local checkKey = equipKey[params.equipType]
	--						if value[ checkKey ] then
	--							if tostring(i) == tostring(value[ checkKey ].id) then
	--								skip = true
	--								break
	--							end
	--						end
	--					end
					end
				end
				
				if kind == "skill" then
					if params.equipType == "allskill" then--宠物技能和武将技能合集
	--					if v.type ~= "petskill" or v.type ~= "generalskill" then
	--						
	--					end
					else
						--如果不是对应装备类型则不显示
						if v.type ~= params.equipType then
							skip = true
						else
	--						--判断是否已经使用装备
	--						local skillKey = { "s1" , "s2" , "s3" }
	--						--遍历所有  对应装备位 数据
	--						for key , value in pairs( usedEquipData ) do 
	--							for curSeatIndex = 1 , #skillKey do
	--								if value[ skillKey[curSeatIndex] ] then
	--									if tostring(i) == tostring(value[ skillKey[curSeatIndex] ].id) then
	--										skip = true
	--										break
	--									end
	--								end
	--							end
	--						end
						end
					end
					
				end
				
				local btnImg, greyBg,optBtnGrey, formation 				
				if kind == "general" then
					--是上阵选择列表需要特殊处理
					if params.formation then
						formation = true
						 if DATA_Formation:checkIsExist(tonumber(keyList[i])) then
							btnImg = "huan_0.png"
							if params.select == tonumber(keyList[i]) then
								greyBg = true
								btnImg = "huan_1.png"
								optBtnGrey = true				
							end
						else
							btnImg = "lineup_0.png"
						end
					end
--					--传功武将用数据标记
--					if params.generalType  then
--						--传功者 小于必须大于一级
--						if params.generalType == "byexp2" then
--							if tonumber( v.lv ) <= 1 then
--								skip = true
--							end 
--						end
--						--吞噬者 需要满足 等级大于等级 
--						if params.generalType == "uplevel1" then
--							local uplevelConfig = DATA_Uplevel:get()
--							if tonumber( v.lv ) < tonumber( uplevelConfig.from ) + ( v.stage - 1 ) * uplevelConfig.add then
--								skip = true
--							end
--						end
--						
--						--被吞噬者 --限制条件 不在阵上 并且 与吞噬者star相同  
--						if params.generalType == "uplevel2" then
--							--上阵不显示
--							if DATA_Formation:checkIsExist(v.id) then
--								skip = true
--							end
--						end
--					end
				end
				
				if not skip  then
					temp = ListItem:new(kind,v["id"],{
						parent = self.scroll,
						priority = -131,
						petOnDisable = true,
						formation = formation,
						greyBg = greyBg,
						optBtnGrey = optBtnGrey,
						disableByState = self.params["disableByState"],
						btn_opt = btnImg or self.params["btn_opt"],
						optCallback = self.params["optCallback"],
						check = self.params["check"],
						checkBoxOpt = self.params["checkBoxOpt"],
						checked = checked,
						iconCallback = function()
							local DATA = self:getDataFile(kind)
							local detail
							
							if kind == "pet" or DATA:haveData(v["id"] , kind) then
								pushScene("detail" , {
									detail = kind,
									id = v["id"],
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
								end})
							end
						end
					})
					
					self.scroll:addChild(temp:getLayer(),temp)		
				end
			end
		end
		
		--元素添加完
		self.scroll:alignCenter()
		
		if not self.params["noEffect"] then
			self.scroll:effectIn()
		end
		
		self.contentLayer:addChild(self.scroll:getLayer())
		
			
		local bg = display.newSprite(COMMONPATH.."page_bg.png")
		setAnchPos(bg,240,110,0.5)
		self.contentLayer:addChild(bg)
		
		local pageNum = display.strokeLabel(self.curPage.."/"..self.maxPage, 0, 0, 20, ccc3(0xff, 0xfb, 0xd4))
		setAnchPos(pageNum, 240, 115, 0.5)
		self.contentLayer:addChild(pageNum)
		
		if kind == "general" then
			self.contentLayer:addChild( display.strokeLabel( "总统帅力:" .. DATA_User:getLead() .. "\n被占用统帅力:" .. DATA_Formation:countLead() , 20 , 102 , 18 , ccc3( 0xff , 0xfb , 0xd6 ) ) )
		end

		
		--翻页按钮
		local pre = KNBtn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
			priority = -131,
			scale = true,
			flipX = true,
			callback = function()
				if self.curPage > 1 then
					self.curPage = self.curPage - 1
					self:createContent(kind, params, scrollY, scrollHeight)
				end
			end
		})
		self.contentLayer:addChild(pre:getLayer())
		
		local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
			priority = -131,
			scale = true,
			callback = function()
				if self.curPage < self.maxPage then
					self.curPage = self.curPage + 1
					self:createContent(kind, params, scrollY, scrollHeight)
				end
			end
		})
		self.contentLayer:addChild(next:getLayer())
		
	else
		local text = display.newSprite(COMMONPATH.."empty.png")
		setAnchPos(text,240, 425, 0.5,0.5)
		self.contentLayer:addChild(text)
	end	
	
	self.layer:addChild(self.contentLayer)	
end

--跟据类型断需要哪一个全局数据文件,和详细信息类名
function SelectList:getDataFile(kind)
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


return SelectList