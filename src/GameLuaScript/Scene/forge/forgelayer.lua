local MAIN, HEROSPLIT, HEROMERGE, HEROLIST, EQUIPSPLIT, EQUIPMERGE, EQUIPLIST, PETSPLIT, PETMERGE, PETLIST, HERODIRECT, POOL = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
local LEFT, RIGHT, TOP, BOTTOM = 1, 2, 3, 4
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
local Pool = requires(IMG_PATH, "GameLuaScript/Scene/forge/poollayer")

--滑动列表每页元素
local PAGENUM = 10

--[[
	副本模块，在首页点击副本按钮进入此模块
]]
local ForgeLayer = {
	layer,
	mainLayer,
	contentLayer,
	state,
	wait,
	onePt,
	mask,
	scroll,
	selectItems,
	data,
	tempMerge,      --融合的结果
	empty,
	curStar,
	curPage,
	maxPage
}

function ForgeLayer:new(params)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()
	this.state = params.state 
	this.curPage = 1
	this.maxPage = 1

	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.layer:addChild(bg)
	

	
	
		
	local close = KNBtn:new(COMMONPATH, {"back_img.png", "back_img_press.png"}, 50, 765, {
		scale = true,
		callback = function()
			if params.closeFun then
				params.closeFun()
			else
				if this.state == MAIN then
					switchScene("home")
				elseif this.state == HEROLIST then
					this.scroll = nil
					this:createSplitLayer("general", "split",this.curStar or 1)
				elseif this.state == EQUIPLIST then
					this.scroll = nil
					this:createSplitLayer("equip", "split", this.curStar or 1)
				elseif this.state == PETLIST then
					this.scroll = nil
					this:createSplitLayer("pet", "split", this.curStar or 1)
				elseif this.state == HERODIRECT then
					this:createMergeLayer("general", (this.curStar - 1) or 1)
				else
					this.tempMerge = nil
					this.selectItems = nil 
					local index
					if this.state < 4 then
						index = 1
					elseif this.state < 6 then
					    index = 2
					elseif this.state < 11 then
						index = 3
					else
						index = 4
					end
					this:createMain(index)
				end
			end
		end
	})
	this.layer:addChild(close:getLayer(), 1)

	this:createMain( params.index or 1)
	return this
end

function ForgeLayer:createMain(index)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	
		
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 240, 425, 0.5, 0.5)
	self.mainLayer:addChild(title)
	
		
	title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
		
	title = display.newSprite(PATH.."title.png")
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	local bg = display.newSprite(SCENECOMMON.."level_bg.png")
	setAnchPos(bg, 240, 590, 0.5)
	self.mainLayer:addChild(bg)
	
	local group = KNRadioGroup:new()
	
	
	local level = {
		"general",
		"equip",
		"pet",
		"pool"
	}
	
	local scroll = KNScrollView:new(40, 585, 390, 150, 10, true)
	local des_scroll 
	des_scroll =  KNScrollView:new(0, 110, 480, 500, 0, true, 1, {
		page_callback = function()
			group:chooseByIndex(des_scroll:getCurIndex())
		end
	})
	
	local btns = {}
	local splitBtns = {}
	for i = 1, #level do
		btns[i] = KNBtn:new(PATH,{level[i].."_icon.png", "select.png"}, 60 + (i - 1) * 200, 605, {
			id = level[i],
			noHide = true,
			upSelect = true,
			parent = scroll,
			selectZOrder = 1,
			other = {PATH..level[i].."_title.png", 22, 5},
			callback = function()
				des_scroll:setIndex(i)
			end
		},group)
		scroll:addChild(btns[i]:getLayer())
		
		local desc , splitBtn = self:createContent(level[i], i)
		des_scroll:addChild(desc)

		splitBtns[i] = splitBtn
	end
	
	scroll:alignCenter()
	scroll:setIndex( index , true)
	
	des_scroll:alignCenter()
	self.mainLayer:addChild(scroll:getLayer())
	self.mainLayer:addChild(des_scroll:getLayer())
	group:chooseByIndex(index)
	des_scroll:setIndex(index, true)	
	self.state = MAIN
	
	self.layer:addChild(self.mainLayer)


	-- 新手引导
	if KNGuide:getStep() == 1501 then
		local range = btns[1]:getRange()
		KNGuide:show( btns[1]:getLayer() , {
			x = range:getMinX(),
			y = range:getMinY(),
			callback = function()
				local range = splitBtns[1]:getRange()
				KNGuide:show( splitBtns[1]:getLayer(),{
					x = range:getMinX(),
					y = range:getMinY(),
				}) 
			end
		})
		
	end

	if KNGuide:getStep() == 1510 then
		local range = btns[2]:getRange()
		KNGuide:show( btns[2]:getLayer() , {
			x = range:getMinX(),
			y = range:getMinY(),
			callback = function()
				local range = splitBtns[1]:getRange()
				KNGuide:show( splitBtns[1]:getLayer(),{
					x = range:getMinX(),
					y = range:getMinY(),
				}) 
			end
		})
		
	end


	if KNGuide:getStep() == 3401 then
		scroll:setIndex( 4 , true)
		des_scroll:setIndex(4, true)
		local range = btns[4]:getRange()
		KNGuide:show( btns[4]:getLayer() , {
			x = range:getMinX(),
			y = range:getMinY(),
			callback = function()
				local range = splitBtns[4]:getRange()
				KNGuide:show( splitBtns[4]:getLayer(),{
					x = range:getMinX(),
					y = range:getMinY(),
				}) 
			end
		})
		
	end
	
end

function ForgeLayer:createContent(kind)
	local layer = display.newLayer()
	
	local bg = display.newSprite(PATH.."small_bg.png")
	setAnchPos(bg, 240, 0, 0.5)
	layer:addChild(bg)
	
	bg = display.newSprite(PATH..kind.."_desc.png")
	setAnchPos(bg, 240, 140, 0.5)
	layer:addChild(bg)

--	local text = display.newSprite(PATH..kind.."_text.png")
--	setAnchPos(text, 240, 545, 0.5)
--	self.contentLayer:addChild(text)
	local str
	if kind == "general" then
		str = "英雄复英雄，英雄何其多。 我们不仅要英雄多，还要英雄够高级！  炼魂中可炼成将魂，合卡中可合成武将。 "
	elseif kind == "equip" then
		str = "丈八蛇矛?青龙偃月?断金切玉神利器!         刀枪不入雁翎金甲,防御神器亲手打造!               在铁匠铺中可分解、锻造合成装备。 "
	elseif kind == "pet" then
		str = "在幻兽打造系统中，可分解幻兽获得兽魂。 通过兽魂合成，可获得更高级的幻兽哦。"
	else
		str = "在进化池中可以制作进化符 英雄（幻兽）进化符可用于同星级英雄（幻兽）的进化哦"	
	end	
	local text = display.strokeLabel(str, 40, 40, 20,nil,nil,nil,{
		dimensions_width = 400,
		dimensions_height = 100,
	} )
	layer:addChild(text)
	
	local m 
	if kind == "general" then
		m = "soul"
	elseif kind == "equip" then
		m = "equippieces"
	elseif kind == "pet" then
		m = "animalsoul"
	end

	local split
	
	if kind == "pool" then
		split = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 165, 10, {
			front = PATH.."make_fu.png",
			callback = function()		
				local check_result = checkOpened("forge_pool")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				self:createPool()
			end
		})
		layer:addChild(split:getLayer())
	else
		--炼魂
		split = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 50, 10, {
			front = PATH..(kind == "equip" and kind or "general").."_split.png",
			callback = function()
				if kind == "pet" then
					local check_result = checkOpened("forge_pet")
					if check_result ~= true then
						KNMsg:getInstance():flashShow(check_result)
						return
					end
				end

				HTTP:call(m, "get", {}, {
					success_callback = function(data)
						self.curStar = 1
						self.data = data
						self:createSplitLayer(kind, "split", self.curStar)
					end
				})
			end
		})
		layer:addChild(split:getLayer())
		
	
		local merge = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 280, 10, {
			front = PATH..(kind == "equip" and kind or "general").."_merge.png",
			callback = function()
				if kind == "pet" then
					local check_result = checkOpened("forge_pet")
					if check_result ~= true then
						KNMsg:getInstance():flashShow(check_result)
						return
					end
				end

				HTTP:call(m, "get", {}, {
					success_callback = function(data)
						self.data = data
	--					self:createSplitLayer("general", "merge")
						self:createMergeLayer(kind)
					end
				})
			end
		})
		layer:addChild(merge:getLayer())
	end
	
	layer:setContentSize(CCSizeMake(480, 500))
	
	return layer, split
end

function ForgeLayer:createMergeLayer(kind, index)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	if kind == "general" then
		self.state = HEROMERGE
	elseif kind == "equip" then
		self.state = EQUIPMERGE
	else
		self.state = PETMERGE
	end
	
	local str = (kind == "pet" and "general" or kind)

	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 240, 425, 0.5, 0.5)
	self.layer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
	
		
	title = display.newSprite(PATH..str.."_merge_text.png")
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	
	--底部生成元素栏
	local bottom = display.newSprite(PATH.."bottom.png")
	setAnchPos(bottom, 240, 580, 0.5)
	self.mainLayer:addChild(bottom)
	
	bottom = display.newSprite(PATH..kind.."_split_label.png")
	setAnchPos(bottom, 20, 680)
	self.mainLayer:addChild(bottom)
	
	--在合成页面去炼魂，重新拉取数据
	local btn = KNBtn:new(COMMONPATH, {"btn_ver.png", "btn_ver_pre.png"}, 410, 590, {
		front = PATH..str.."_merge_btn_text.png",
		callback = function()
			local m
			if kind == "general" then
				m = "soul"
			elseif kind == "equip" then
				m = "equippieces"
			else
				m = "animalsoul"
			end
			HTTP:call(m, "get", {}, {
					success_callback = function(data)
						self.curStar = 1
						self.data = data
						self.tempMerge = nil
						self.selectItems = {}
						self:createSplitLayer(kind,"split")
					end
				})
		end
	})
	self.mainLayer:addChild(btn:getLayer())
	
	
	local tempLayer
	local needLabel
	local function createSelect(i)
		if tempLayer then
			self.mainLayer:removeChild(tempLayer, true)
		end
		tempLayer = display.newLayer()
		
		local other = {{PATH..kind.."_split_"..i..".png", 0, -25}}
		local front = PATH..kind.."_icon_"..i..".png"
		local temp = KNBtn:new(SCENECOMMON,{"skill_frame2.png"}, 90, 350, {
			id = i,
			other = other,
			noHide = true,
			front = front,
			priority = -131,
--			text = {6, 18, ccc3(255,255,255), ccp(30,28),nil,15 },
			callback = function()
			
			
			end
		})
		tempLayer:addChild(temp:getLayer())
		local result
		if self.tempMerge then
	
			result = KNBtn:new(nil, {getImageByType(DATA_Bag:get(kind, self.tempMerge, "cid"), "b")}, 0, 0, {
				callback = function()
						local data 
						if kind == "general" then
							data = DATA_General:get(tonumber(self.tempMerge))
						elseif kind == "pet" then
							data = DATA_Bag:get(kind,self.tempMerge)
						elseif kind == "equip" then
							data = DATA_Equip:get(tonumber(self.tempMerge))
						end
						data["id"] = self.tempMerge
--						
						pushScene("detail" , {
						detail = getCidType(data["cid"]),
						data = data
					})
				end
			})	
			if kind == "general" or kind == "pet" then
				setAnchPos(result:getLayer(), 240, 240)
			else
				setAnchPos(result:getLayer(), 280, 300)
			end
			tempLayer:addChild(result:getLayer())
		else
			local str
			if kind ~= "general" then
				if kind == "equip" then
					str = "六个相同星级的碎片可以生成更高一级的装备"
				else
					str = "三个相同星级的兽魂可以生成更高一级的幻兽"
				end
				result = display.strokeLabel(str , 310, 330, 20, ccc3(0x2c, 0, 0), nil, nil, {
					dimensions_width = 100,
					dimensions_height = 120,
				})
				tempLayer:addChild(result)
			end
		end
		
		self.mainLayer:addChild(tempLayer)
	end
	
	local optBtn   			-- 合成按钮
	local chooseGroup = KNRadioGroup:new()
	local needMore
	for i = 1, #self.data do
		local other, front, text

		other = {{PATH..kind.."_split_"..i..".png", 0, -25},{COMMONPATH.."egg_num_bg.png", 50, 50}}
		front = PATH..kind.."_icon_"..i..".png"
		text = {self.data[i]["num"],18, ccc3(255,255,255), ccp(30,28),nil,17 }

		local temp = KNBtn:new(SCENECOMMON,{"skill_frame2.png", "select1.png"}, 55 + (i - 1) * 90, 610, {
			id = i,
			other = other,
			noHide = true,
			front = front,
			priority = -131,
			text = text,
			callback = function()
				if kind == "general" then
					if needMore then
						self.mainLayer:removeChild(needMore, true)
					end
--					needMore = display.newSprite(PATH..kind.."_need_"..(3 * (i + 1)).."_text.png")
					needMore = display.newSprite(PATH..kind.."_need_6_text.png")
					setAnchPos(needMore, 300, 210)
					self.mainLayer:addChild(needMore)
					if needLabel then
						self.mainLayer:removeChild(needLabel , true)
					end
--					needLabel  = display.strokeLabel( (3 * (i + 1)).."个相同星级的将魂可以生成更高一级的英雄~!", 310, 330, 20, ccc3(0x2c, 0, 0), nil, nil, {
					needLabel  = display.strokeLabel("六个相同星级的将魂可以生成更高一级的英雄~!", 310, 330, 20, ccc3(0x2c, 0, 0), nil, nil, {
						dimensions_width = 100,
						dimensions_height = 120,
					})
					self.mainLayer:addChild(needLabel )
				end
				createSelect(i)
			end
		}, chooseGroup)
		self.mainLayer:addChild(temp:getLayer())

		if i == 2 and KNGuide:getStep() == 1518 then
			KNGuide:show(temp:getLayer() , {
				callback = function()
					KNGuide:show(optBtn:getLayer() , {
						remove = true
					})
				end
			})
		end
	end
	
	local smallBg = display.newSprite(IMG_PATH.."image/scene/byexp/text_bg.png")
	setAnchPos(smallBg, 30, 250)
	self.mainLayer:addChild(smallBg)
	
	smallBg = display.newSprite(PATH..kind.."_split_label.png")
	setAnchPos(smallBg, 30, 490)
	self.mainLayer:addChild(smallBg)
	
	
	
	smallBg = display.newSprite(COMMONPATH.."next.png")
	setAnchPos(smallBg, 230, 350)
	self.mainLayer:addChild(smallBg)
	
	
	
	smallBg = display.newSprite(IMG_PATH.."image/scene/byexp/text_bg.png")
	setAnchPos(smallBg, 270, 250)
	self.mainLayer:addChild(smallBg)
	
	smallBg = display.newSprite(PATH..kind.."_merge_label.png")
	setAnchPos(smallBg, 270, 490)
	self.mainLayer:addChild(smallBg)
	
	--这里根据不同的类型生成合卡按钮
	local bx,by, front
	if kind == "general" then
		bx = 50	
		by = 150
		front = PATH.."random_merge.png"
		smallBg = display.newSprite(PATH..kind.."_need_text.png")
		setAnchPos(smallBg, 70, 210)
		self.mainLayer:addChild(smallBg)
	else
		bx = 170
		by = 150
		front = PATH..str.."_merge.png"
		
		smallBg = display.newSprite(PATH..kind.."_need_text.png")
		setAnchPos(smallBg, 70, 260)
		self.mainLayer:addChild(smallBg)
	end
	
	local max = 3
	if kind == "equip" then
		max = 6
	end
	
	optBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, bx, by, {
		front = front,
		callback = function()
			if self.data[chooseGroup:getId()]["num"] < max then
				local tip
				if kind == "general" then
					tip = "对不起，将魂不足无法融合"
				elseif kind == "pet" then
					tip = "对不起，兽魂不足无法融合"
				else
					tip = "对不起，碎片不足无法融合"
				end
				KNMsg.getInstance():flashShow(tip)

				if KNGuide:getStep() == 1508 then
					GLOBAL_INFOLAYER:refreshBtn()
				end
							
				return false
			end

			if isBagFull() then
				return false
			end
			
			self.selectItems = chooseGroup:getId()
			local star = self.selectItems 
			local m
			if kind == "general" then
				m = "soul"
			elseif kind == "equip" then
				m = "equippieces"
			else
				m = "animalsoul"
			end
			
			HTTP:call(m, "fuse", {id = star}, {
					success_callback = function(data, cid)
						self.data = data
						self.tempMerge = cid
						self:createMergeLayer(kind, star)
--						KNMsg.getInstance():flashShow("融合成功，获得"..(star + 1).."星级英雄！~")
						local card_popup = KNCardpopup:new(DATA_Bag:get(kind, cid, "cid") , function()
							if KNGuide:getStep() == 1508 then
								GLOBAL_INFOLAYER:refreshBtn()
							end
						end , {	
							init_x =  100,
							init_y = -50,
							end_x =  100,
							end_y =  -50,})
						display.getRunningScene():addChild(card_popup:play())
					end})
		end
	})
	self.mainLayer:addChild(optBtn:getLayer())
	
	if KNGuide:getStep() == 1507 then
		KNGuide:show( optBtn:getLayer() , {
			remove = true
		}) 
	end		
	
	--定向合卡，只有英雄有
	if kind == "general" then
	
		local directBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 285, 150, {
			front = PATH.."direct_merge.png",
			callback = function()
				if isBagFull() then
					return false
				end
--				if self.data[chooseGroup:getId()]["num"] > 3 * (chooseGroup:getId() + 1) then
					self:directList(chooseGroup:getId() + 1)
--				else
--					KNMsg.getInstance():flashShow("将魂数量不足"..(3 * (chooseGroup:getId() + 1)).."个，无法合成！")
--				end
			end
		})
		self.mainLayer:addChild(directBtn:getLayer())
	end
	
	self.layer:addChild(self.mainLayer)
	
	chooseGroup:chooseByIndex(index or 1, true)
end

function ForgeLayer:createSplitLayer(kind, func, default)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()
	local max = 3
	if kind == "general" then
		self.state = HEROSPLIT
	elseif kind == "equip" then
		self.state = EQUIPSPLIT
		max = 6
	else
		self.state = PETSPLIT
	end
	
	if kind == "general" then
		--图鉴与组合
		local info = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 20, 690, {
			front = PATH.."info_text.png",
			callback = function()
				self:directList()
			end
		})
		self.mainLayer:addChild(info:getLayer())
		
		local combine = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 380, 690, {
			front = PATH.."combine_text.png",
			callback = function()
				self:createCombine()
			end
		})
		self.mainLayer:addChild(combine:getLayer())
	end
	
	--幻兽与英雄通用的图片
	local str = (kind == "pet" and "general" or kind)
	
		
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 240, 425, 0.5, 0.5)
	self.layer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
	
		
	title = display.newSprite(PATH..str.."_"..func.."_text.png")
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	--底部生成元素栏
	local bottom = display.newSprite(PATH.."bottom.png")
	setAnchPos(bottom, 240, 120, 0.5)
	self.mainLayer:addChild(bottom)
	
	bottom = display.newSprite(PATH..kind.."_"..func.."_label.png")
	setAnchPos(bottom, 20, 220)
	self.mainLayer:addChild(bottom)
	
	--在分解界面去合成,重新拉取炼魂数据
	local splitBtn = KNBtn:new(COMMONPATH, {"btn_ver.png", "btn_ver_pre.png"}, 400, 135, {
		front = PATH..str.."_"..func.."_btn_text.png",
		callback = function()
			local m
			if kind == "general" then
				m = "soul"
			elseif kind == "equip" then
				m = "equippieces"
			else
				m = "animalsoul"
			end
			HTTP:call(m, "get", {}, {
				success_callback = function(data)
					self.selectItems = nil 
					self.data = data
					self:createMergeLayer(kind)
				end
			})
		end
	})
	self.mainLayer:addChild(splitBtn:getLayer())
--	
--	
	local choose = display.newSprite(PATH.."choose_star.png")
	setAnchPos(choose,380, 330)
	self.mainLayer:addChild(choose)
	
	local autoBtn  		-- 自动添加按钮
	local fenjie_btn	-- 分解按钮
	local comboBox
	local group = KNRadioGroup:new()
	local items = {}
	for i = 1, 4 do
		items[i] = KNBtn:new(PATH, {"star"..i..".png", "star_select.png"}, 0, 0, {
			id = i,
			noHide = true,
			callback = function()
				self.curStar = i
				comboBox:setText(i)
				comboBox:autoShow()

				if KNGuide:getStep() == 1514 then
					KNGuide:show( autoBtn:getLayer() , {
						callback = function()
							KNGuide:show( fenjie_btn:getLayer() )
						end
					})
				end
			end
		},group)
	end
	
	comboBox = KNComboBox:new(418, 330, {
		dir = COMMONPATH,
		res = {"small_btn_bg.png", "small_btn_bg_pre.png"},
		front = COMMONPATH.."star.png",
		text = {default or 1, 20, ccc3(0x2c, 0, 0)},
		bg = PATH.."combo_bg.png",
		up = true,
		offset = 15,
		items = items,
		default = default,
		itemsGroup = group,
		popCallback = function()
			if KNGuide:getStep() == 1513 then
				local btn_range = items[2]:getRange()
				KNGuide:show( items[2]:getLayer() , {
					x = btn_range:getMinX(),
					y = btn_range:getMinY(),
				})
			end
		end
	})
	self.mainLayer:addChild(comboBox:getLayer(), 10)
	if KNGuide:getStep() == 1512 then
		KNGuide:show( comboBox:getLayer() )
	end
	
	--自动添加
	autoBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 170, 330, {
		front = PATH.."auto_add.png",
		callback = function()
			local result = self:getItems(kind, comboBox:getCurItem():getId())
			
			--自定义按照等级排序
			local keyList =  getSortList(result, function(l, r)
				local l_lv = DATA_Bag:get(kind, l, "lv") or 1
				l_lv = tonumber(l_lv)

				local r_lv = DATA_Bag:get(kind, r, "lv") or 1
				r_lv = tonumber(r_lv)

				return (l_lv < r_lv)
			end)
			self.selectItems = {}	
			
			local needNum = max - table.nums(self.selectItems)
			for k, v in pairs(keyList) do
				if not table.hasValue(self.selectItems, v) then
					table.insert(self.selectItems, v)
					needNum = needNum - 1
				end
				
				if needNum == 0 then
					self:createSplitLayer(kind, func, comboBox:getCurItem():getId())
					break
				end
				
			end
			
			if needNum > 0 then
				self.selectItems = {}
				self:createSplitLayer(kind, func, comboBox:getCurItem():getId())
				local str
				if kind == "general" then
					str = "英雄"
				elseif kind == "pet" then
					str = "幻兽"
				elseif kind == "equip" then
					str = "装备"
				end
				
				KNMsg.getInstance():flashShow("当前星级"..str.."卡牌不足！~")
			end
		end
	})
	self.mainLayer:addChild(autoBtn:getLayer())
	
	
	--打造元素按钮
	for i = 1, #self.data do
		local other, front, text
	
		if self.data[i]["num"] > 0 then
			other = {{PATH..kind.."_"..func.."_"..i..".png", 0, -25},{COMMONPATH.."egg_num_bg.png", 50, 50}}
			front = PATH..kind.."_icon_"..i..".png"
			text = {self.data[i]["num"],18, ccc3(255,255,255), ccp(30,28),nil,17 }
		else
			other = {PATH..kind.."_"..func.."_"..i..".png", 0, -25}
		end
		
		local temp = KNBtn:new(SCENECOMMON,{"skill_frame2.png"}, 40 + (i - 1) * 90, 150, {
			other = other,
			front = front,
			text = text
		})
			
		self.mainLayer:addChild(temp:getLayer())
		if (i == 1 and KNGuide:getStep() == 1505) or ( i == 2 and KNGuide:getStep() == 1516 ) then
			KNGuide:show( temp:getLayer() , {
				callback = function()
					KNGuide:show( splitBtn:getLayer() )
				end
			}) 
		end
	end
	
	
	local circleBig = display.newSprite(PATH..kind.."_circle_big.png")
	setAnchPos(circleBig)
	
	local outLayer = display.newLayer()
	self.mainLayer:addChild(outLayer)
	
	--外层阵法
	outLayer:addChild(circleBig)
	outLayer:setContentSize(circleBig:getContentSize())
	outLayer:ignoreAnchorPointForPosition(false)
	setAnchPos(outLayer,240, 550, 0.5, 0.5)	
	
	local circleSmall = display.newSprite(PATH..kind.."_circle_small.png")
	setAnchPos(circleSmall,240, 550, 0.5, 0.5)
	self.mainLayer:addChild(circleSmall)
	
	
--	outLayer:runAction(CCRepeatForever:create(CCRotateBy:create(0.3,40)))
--	circleSmall:runAction(CCRepeatForever:create(CCRotateBy:create(0.1,-40)))
	
	local items = {}
	local addSoul
	local pos 
	local num
	if kind == "equip" then
		num = 6
		pos = {
			{55, 515},
			{350, 515},
			{125, 650},
			{300, 650},
			{300, 380},
			{125, 380},
		}
	else
		num = 3
		local posCircle = display.newSprite(PATH.."pos_circle.png")
		setAnchPos(posCircle,240, 550, 0.5, 0.5)
		self.mainLayer:addChild(posCircle)
		pos = {
			{210, 630},
			{305, 460},
			{110, 460},
		}
	end
	
	for i = 1, #pos do
		--若 已存在选则的元素
		local front,frontScale, other,text
		if self.selectItems and i <= table.nums(self.selectItems) then 
			front = getImageByType(DATA_Bag:get(kind , self.selectItems[i].."", "cid"),"s")
			frontScale = nil
			if kind ~= "pet" then
				other = {COMMONPATH.."egg_num_bg.png", 50, -8}
				text = {DATA_Bag:get(kind, self.selectItems[i].."", "lv"), 18, ccc3(255,255,255), ccp(28,-30), nil, 17}
			end
		else
			front = SCENECOMMON.."add.png"
			frontScale = {1, 14, -13}
			
		end
			
		local item = KNBtn:new(SCENECOMMON, {"skill_frame1.png","skill_frame1_press.png"}, pos[i][1], pos[i][2], {
			front = front,
			frontScale = frontScale,
			other = other,
			text = text,
			callback =function()
				local star
				if self.selectItems and table.nums(self.selectItems) > 0 then
					 star =  getConfig(kind, DATA_Bag:get(kind, self.selectItems[1], "cid"), "star")
				end
				-- self:createList(kind, func, comboBox:getCurItem():getId(), num)
				self:createList(kind, func, star , num)
			end
		})
		self.mainLayer:addChild(item:getLayer(),2)
		items[i] = item
	end
	
	fenjie_btn = KNBtn:new(PATH,{"btn.png", "btn_pre.png"}, 202, 513, {
		front = PATH..str.."_"..func.."_mid.png",
		callback = function()
		
			if not self.selectItems or table.nums(self.selectItems) < num then
				KNMsg.getInstance():flashShow("请选择"..num.."张同星级的卡牌")
				return false
			end
			
			local function startSplit()
				local star
				star = getConfig(kind, DATA_Bag:get(kind, self.selectItems[1], "cid"), "star")
				if kind == "general" then
					HTTP:call("soul", "dismantling", {star = star , generalid= string.join(self.selectItems,",") }, {
						no_loading = true,
						success_callback = function(data, stone)
							self.data = data
							if stone == 1 then
								KNMsg.getInstance():flashShow("英雄身上的宝石已经自动卸载到背包，宝石等级自动下降一级")
							end
						end
					})
				elseif kind == "equip" then
					HTTP:call("equippieces", "dismantling", {star = star , eid= string.join(self.selectItems,",") }, {
						no_loading = true,
						success_callback = function(data)
							self.data = data
						end
					})
				else
					HTTP:call("animalsoul", "dismantling", {star = star , eid= string.join(self.selectItems,",") }, {
						no_loading = true,
						success_callback = function(data)
							self.data = data
						end
					})
				end
				
				self.mask = KNMask:new({r = 255, g = 255, b = 255, opacity = 0})
				self.mainLayer:addChild(self.mask:getLayer())
				
				circleSmall:runAction(CCEaseExponentialInOut:create(CCRotateBy:create(3,-2160)))
				outLayer:runAction(getSequenceAction(CCEaseExponentialInOut:create(CCRotateBy:create(3,2160)),CCCallFunc:create(
					function()
						for i = 1, #items do
							items[i]:getLayer():runAction(getSequenceAction(CCEaseElasticIn:create(CCMoveTo:create(0.8,ccp(205,518))),CCCallFunc:create(
								function()
									self.mainLayer:removeChild(items[i]:getLayer(),true)
									--这里是按钮聚集到中央后变化成武魂的逻辑
									if not addSoul then
										addSoul = true
										
										local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/skillAction/3904.png", 4 )
										local ani 
										ani = display.playFrames(240, 545, frames, 0.15, {
											onComplete = function()
												self.mainLayer:removeChild(ani, true)
												
												local soul = display.newSprite(PATH..kind.."_icon_"..star..".png")
												setAnchPos(soul, 240, 550, 0.5, 0.5)
												self.mainLayer:addChild(soul)
												
												soul:runAction(getSequenceAction(CCJumpTo:create(0.5,ccp(205, 518),50,2),CCMoveTo:create(0.3,ccp(73 + (star - 1) * 100,183)),CCCallFunc:create(
													function()
														self.selectItems = {}
														 self:createSplitLayer(kind, func, comboBox:getCurItem():getId())
	--													self:createSplitLayer(kind, func)
													end)))
											end
										})
										self.mainLayer:addChild(ani)
									end
								end)))
						end
					end)))
				end
				
				--判断是否有高等级的物品
				local ask = false
				for k, v in pairs(self.selectItems) do
					if tonumber(DATA_Bag:get(kind, v, "lv")) > 1 then
						ask = true
						break
					end
				end
				if ask then
					local str 
					if kind == "general" then
						str = "英雄"
					elseif kind == "equip" then
						str = "装备"
					else
						str = "幻兽"
					end
					KNMsg.getInstance():boxShow("您选择的"..str.."中存在珍贵物品，是否确认分解？ ", {
						confirmFun = function()
							startSplit()	
						end,
						cancelFun = function()
							
						end
					})	
				else
					startSplit()
				end
		end
	})
	self.mainLayer:addChild(fenjie_btn:getLayer())
	
	-- 新手引导
	if KNGuide:getStep() == 1503 then
		KNGuide:show( autoBtn:getLayer() , {
			callback = function()
				KNGuide:show( fenjie_btn:getLayer()) 
			end
		}) 
	end
	
	
	--描述
	local desc = {
		["general"] = {
			"1.三张同星英雄可炼成一个同星将魂。",
			"2.上阵和五星英雄不可炼魂。",
			"3.将魂可融合成更高星级英雄。"
		},
		["equip"] = {
			"1.六张同星装备可炼成一个同星碎片。",
			"2.已穿戴装备和五星装备不可分解。",
			"3.碎片可融合成更高星级装备。"
		},
		["pet"] = {
			"1.三张同星幻兽可炼成一个同星兽魂。",
			"2.已上阵幻兽和五星兽魂不可炼魂。",
			"3.兽魂可融合成更高星级幻兽。"
		}
	}
	
	for i = 1, #desc[kind] do
			local label = display.strokeLabel(desc[kind][i], 130, 340 - 30 * i, 14, ccc3(0xff,0xfb,0xd4))
		self.mainLayer:addChild(label)
	end
	
	self.layer:addChild(self.mainLayer)
end

function ForgeLayer:createList(kind, func, star, max)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.mainLayer = display.newLayer()

	if kind == "general" then	
		self.state = HEROLIST
	elseif kind == "equip" then
		self.state = EQUIPLIST
	else
		self.state = PETLIST
	end
	
	local str = (kind == "pet" and "general" or kind)
	
	if not self.selectItems then
		self.selectItems = {}
	end
		
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 240, 425, 0.5, 0.5)
		self.layer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
	
		
	title = display.newSprite(PATH..str.."_"..func.."_text.png")
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(title, 240, 690, 0.5)
	self.mainLayer:addChild(title)
	
	local first = true
	local result 
	local group = KNRadioGroup:new()
	for i = 1, 4 do
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png", "tab_star_select.png"},20 + (i - 1) * 90, 695, {
			id = i,
			front = {COMMONPATH.."tab/".."tab_star"..i..".png", COMMONPATH.."tab/".."tab_star"..i.."_select.png"},
			callback = function()
				self.curStar = i
				if first then
					first = false
				else
					self.selectItems = {}
				end
				result = self:createScroll(kind,i, max)
			end
			
		},group)
		self.mainLayer:addChild(btn:getLayer(), -1)
	end
	group:chooseByIndex(star or 1, true)
	
	local okBtn = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 280, 105, {
		front = COMMONPATH.."ok.png",
		callback = function()
			if table.nums(self.selectItems) < max then
				KNMsg.getInstance():flashShow("请选则"..max.."张同星级的卡牌")
				return false
			end
			self.scroll = nil
			self:createSplitLayer(kind, func, self.curStar)
		end
	})
	
	local onKey = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 70, 105, {
		front  = COMMONPATH.."onekey.png",
		callback  = function()
			local needNum = max - table.nums(self.selectItems)
			for k, v in pairs(result) do
				if not table.hasValue(self.selectItems,k) then
					table.insert(self.selectItems, k)
					needNum = needNum - 1
				end
				
				if needNum == 0 then
					self:createScroll(kind,group:getId(), max)
					break
				end
			end
			
			--当元素数量不够时
			if needNum > 0 then
				self:createScroll(kind, group:getId(), max)
			end
		end
	})
	
	self.mainLayer:addChild(okBtn:getLayer())
	self.mainLayer:addChild(onKey:getLayer())
	
		
	self.layer:addChild(self.mainLayer)
end

function ForgeLayer:createScroll(kind,level, num)
	if self.scroll then
		self.mainLayer:removeChild(self.scroll:getLayer(),true)
	 end
	 self.scroll = KNScrollView:new(0, 160, 480, 530, 5)
	
	local result = self:getItems(kind, level)
	
	if table.nums(result) > 0 then
		if self.empty then
			self.mainLayer:removeChild(self.empty, true)
			self.empty = nil
		end
		for k, v in pairs(result) do
			--判断是否已选 则
			local checked
			if type(self.selectItems) == "table" and table.nums(self.selectItems) > 0 then
				for sk, sv in pairs(self.selectItems) do
					if sv == k then
						checked = true
						break
					end
				end
			end
			
			local item
			item = ListItem:new(kind, k,{
				parent = self.scroll,
				check = true,
				checked = checked,
				checkBoxOpt = function()
					if item:isSelect() then
						if table.nums(self.selectItems) < num then
							table.insert(self.selectItems, k)
						else
							KNMsg:getInstance():flashShow("最多选择"..num.."张卡牌融合")
							return false
						end
					else
						for sk, sv in pairs(self.selectItems) do
							if sv == k then
								table.remove(self.selectItems,sk)
								break
							end
						end
					end
				end
			})
			self.scroll:addChild(item:getLayer(), item)
		end	 
		self.scroll:alignCenter(true)
		self.mainLayer:addChild(self.scroll:getLayer())
	else
		self.empty = display.newSprite(COMMONPATH.."empty.png")
		setAnchPos(self.empty,240, 425, 0.5,0.5)
		self.mainLayer:addChild(self.empty)
	end
	 
	 return result
end

function ForgeLayer:getItems(kind, star)
		 
	local general = DATA_Bag:get(kind) or {}
	local result = {}
	--筛选满足条件的卡牌，给定星级，且未上阵
	for k, v in pairs(general) do
		if kind == "pet" then
			if getConfig(kind, DATA_Bag:get(kind , k, "cid"), "star") ==  star and 
				DATA_Pet:getFighting() ~= tonumber(k) then
					result[k] = v
			end	
		else	
			local on
			if kind == "equip" then
				on = DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(k),kind)
			else
				on = DATA_Formation:checkIsExist(tonumber(k))
			end
			if getConfig(kind, DATA_Bag:get(kind , k, "cid"), "star") ==  star and 
				not on then 
					result[k] = v
			end
		end
	end
	return result
end

function ForgeLayer:directList(star)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()
	self.curStar = star
	
	self.state = star and HERODIRECT or HEROLIST 
	
	local title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
	
		
	title = display.newSprite(PATH..(star and "direct_text.png" or "info_title.png"))
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(title, 240, 690, 0.5)
	self.mainLayer:addChild(title)
	
	local group = KNRadioGroup:new()
	for i = 1, star and 1 or 5 do
		local curStar = star and star or i
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png","tab_star_select.png"},10 + (i - 1) * 90 , 695, {
			id = curStar,
			front =  {COMMONPATH.."tab/".."tab_star"..curStar..".png",COMMONPATH.."tab/".."tab_star"..curStar.."_select.png"},
			callback = function()
				self:directScroll(curStar, star and true or false, star and true or false)
			end
		}, group)
		self.mainLayer:addChild(btn:getLayer(), -1)
	end
--	btn:call()
	group:chooseByIndex(1, true)

	self.layer:addChild(self.mainLayer)		
end

function ForgeLayer:directScroll(star, noChoose, except)
	if self.scroll then
		self.mainLayer:removeChild(self.scroll:getLayer(),true)
	 end
	 self.scroll = KNScrollView:new(0, 100, 480, 590, 5)
	 
	 local function createItem(items)
		 local layer = display.newLayer()
		 local bg = display.newSprite(COMMONPATH.."item_bg.png")
		 setAnchPos(bg)
		 layer:setContentSize(bg:getContentSize())
		 layer:addChild(bg)
		 if items then
			 local n = 1
			 for k, v in pairs(items) do
				 local btn = KNBtn:new(SCENECOMMON, {"box.png"}, 10 + 90 * (n - 1), 30, {
					 front = getImageByType(k,"s"),
					 frontScale = {1, -3, 4},
					 scale = true,
			   		parent = self.scroll,
					 text = {v["name"], 20, ccc3(0x2c, 0, 0), ccp(0, -50)},
					 callback = function()
						 local data = v
						 v["cid"] = k
					 	pushScene("detail" , {
							detail = "general",
							toChoose = noChoose,
							chooseCallback = function()
								if getConfig("general", k, "special") == 1 then
									KNMsg.getInstance():flashShow("该英雄为特殊英雄,不能定向合成,只可在VIP礼包或活动获得!")
								else
									HTTP:call("soul","directionalfuse",{g_cid = k},{
										success_callback = function(data, id)
											self.data = data
											self.tempMerge = id
											popScene()
											self:createMergeLayer("general", star - 1)
											local card_popup = KNCardpopup:new(k, function() end , {	
												init_x =  100,
												init_y = -50,
												end_x =  100,
												end_y =  -50,})
												self.mainLayer:runAction(getSequenceAction(CCDelayTime:create(0.1),CCCallFunc:create(function()
												display.getRunningScene():addChild(card_popup:play())
											end)))
										end
									})
								end
							 end,
							data = data})
					 end
				 })
				 layer:addChild(btn:getLayer())
				 n = n + 1
			 end
		else  --特殊英雄提示
			local function colorName(str, x, y)
				return createLabel({str = str, color = ccc3(255, 0, 0), size = 14, x = x, y = y, width = 300})
			end
			
			if CHANNEL_ID == "tmsj" or CHANNEL_ID == "tmsjtest" or CHANNEL_ID == "tmsjios" or CHANNEL_ID == "tmsjIosAppStore" then	
				layer:addChild(colorName("千仞雪、阿呆、唐三、雷翔", 20, 80))
				layer:addChild(createLabel({str = "这四个超5星英雄不可通过定向合成:", size = 14, x =190, y = 80, width = 300}))
				
				layer:addChild(colorName("唐三、雷翔", 20, 50))
				layer:addChild(createLabel({str = "分别可在VIP5、VIP6特权礼包中获得", size = 14, x = 100, y = 50, width = 300}))
				
				layer:addChild(colorName("千仞雪、阿呆", 20, 20))
				layer:addChild(createLabel({str = "可在更高级V特权礼包中获得", size = 14, x = 110, y = 20, width = 300}))
			else
				layer:addChild(colorName("吴用、卢俊义、赵佶、宋江", 20, 80))
				layer:addChild(createLabel({str = "这四个超5星英雄不可通过定向合成:", size = 14, x = 190, y = 80, width = 300}))
				
				layer:addChild(colorName("赵佶、宋江", 20, 50))
				layer:addChild(createLabel({str = "分别可在VIP5、VIP6特权礼包中获得", size = 14, x = 100, y = 50, width = 300}))
				
				layer:addChild(colorName("吴用、卢俊义", 20, 20))
				layer:addChild(createLabel({str = "可在更高级V特权礼包中获得", size = 14, x = 110, y = 20, width = 300}))
			end
			
			local btn = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 320, 8, {
				front = COMMONPATH.."vip_privilege.png",
				callback = function()
					HTTP:call("vip", "get", {},{success_callback = 
					function()
						switchScene("vip")
					end})
				end
			})
			layer:addChild(btn:getLayer())
--			千仞雪、 阿呆、 唐三、雷翔这四个超5星英雄不可通过定向合成:


--			雷翔和唐三分别可在VIP5、VIP6特权礼包中获得

--			 千仞雪和阿呆可在更高级V特权礼包中获得 
		end
		 return layer
	 end
	 
	 local data = getConfigTable("hero", {star = star, special = (except and 0 or nil)})
	 local count = 0
	 local members = {}
	 for k, v in pairs(data) do
		count = count + 1
		members[k] = v
			
		if count % 5 == 0 or count == table.nums(data) then
			self.scroll:addChild(createItem(members))
			members = {}
		end
	 end
	 
	 if except then
		 --创建特殊英雄提示信息
		 self.scroll:addChild(createItem())
	 end
	 self.scroll:alignCenter()
	 
	 self.mainLayer:addChild(self.scroll:getLayer())
end

function ForgeLayer:getLayer()
	return self.layer
end


--组合
function ForgeLayer:createCombine()
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	self.mainLayer = display.newLayer()
	self.curPage = 1
	
	local title = display.newSprite(COMMONPATH.."title_bg.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height)
	self.mainLayer:addChild(title) 
	
	title = display.newSprite(COMMONPATH.."title_tail.png")
	setAnchPos(title, 0, 854 - title:getContentSize().height * 2)
	self.mainLayer:addChild(title) 
	
		
	title = display.newSprite(PATH.."combine_title.png")
	setAnchPos(title, 245, 765, 0.5)
	self.mainLayer:addChild(title)
	
	title = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(title, 240, 690, 0.5)
	self.mainLayer:addChild(title)
	
	local tabs = {
		"atk",
		"def",
		"hp",
		"agi",
		"weapon"
	}
	
	--创建组合列表
	local function combineList(num ,kind)
		if self.scroll then
			self.mainLayer:removeChild(self.scroll:getLayer(), true)
		end
		self.scroll = KNScrollView:new(15,155,450,530,5)
		
		local items = {}
		for pk, pv in pairs(CombineCfg) do
			local data = pv
			local itemStr  
			
			for k, v in pairs(data.result) do
				itemStr = k
			end
			
			if num == 1 then --武将组合
				if data.type == num and kind == itemStr then
					table.insert(items, data)
				end
			else  --装备组合
				if data.type == 2 then
					table.insert(items, data)
				end
			end
		end
		
		table.sort(items, function(l, r)
			local lValue, rValue
			for k, v in pairs(l.result) do
				lValue = v
			end
			
			for k, v in pairs(r.result) do
				rValue = v
			end
			
			if lValue == rValue then
				return #l.condition > #r.condition
			else
				return lValue > rValue
			end
		end)
		
		self.maxPage = math.ceil(#items / PAGENUM)
		local max = #items - self.curPage * PAGENUM 
		if max >= 0 then
			max = PAGENUM * self.curPage
		else
			max = (self.curPage - 1) * PAGENUM + max + PAGENUM
		end
		for i = (self.curPage - 1) * PAGENUM + 1, max do
			 local layer = display.newLayer()
			 local bg = display.newSprite(IMG_PATH.."image/scene/activity_new/item_bg.png")
			 setAnchPos(bg)
			 layer:setContentSize(bg:getContentSize())
			 layer:addChild(bg)
			 
			 bg = display.newSprite(PATH.."combine.png")
			 setAnchPos(bg, 10, 135)
			 layer:addChild(bg)
			 
			 bg = display.newSprite(PATH.."pro_bg.png")
			 setAnchPos(bg, 240, 5, 0.5)
			 layer:addChild(bg)
			 
			 layer:addChild(display.strokeLabel(items[i].name, 80, 135, 20))
			 local desc = display.strokeLabel(items[i].desc, 100, 15, 20, ccc3(255,255,255))
			 setAnchPos(desc, 240, 10, 0.5)
			 layer:addChild(desc)
			 
			 for j = 1, 5 do
				 local frontScale, front, btnBg, name
				 if j <= table.nums(items[i].condition) then
					 frontScale = {1, 0, 3}
					 front = getImageByType(items[i].condition[j], "s")
					 btnBg = {"small_photo_bg.png"}
					 name = {getConfig(getCidType(items[i].condition[j]), items[i].condition[j], "name"), 18, ccc3(0x2c, 0, 0), ccp(0, -45)}
				 else
					 btnBg = {"small_photo_bg2.png"}
				 end
				 local btn = KNBtn:new(COMMONPATH, btnBg, 10 + (j - 1) * 90, 60, {
					 frontScale = frontScale,
					 parent = self.scroll,
					 front = front,
					 text = name,
					 callback = function()
						 local data = getConfig(getCidType(items[i].condition[j]), items[i].condition[j]) 
						 data["cid"] = items[i] .condition[j]
						 if getCidType(items[i].condition[j]) == "equip" then
							 data["figure"] = data["initial"]
							 local properties = {
								 ["weapon"] = "atk",
								 ["defender"] = "def",
								 ["shoe"] = "agi",
								 ["jewelry"] = "hp"
							 }
							 data["effect"] = properties[data["type"]]
						 end
					 	pushScene("detail" , {
							detail = getCidType(items[i].condition[j]),
							toChoose = false,
							data = data})
					 end
				 })
				 layer:addChild(btn:getLayer())
			 end
			 
			 self.scroll:addChild(layer)
		 end
		 self.scroll:alignCenter()
		
		self.mainLayer:addChild(self.scroll:getLayer())
	end
	
	local bg = display.newSprite(COMMONPATH.."page_bg.png")
	setAnchPos(bg,240,110,0.5)
	self.mainLayer:addChild(bg)
	
	local pageNum = display.strokeLabel(self.curPage.."/"..self.maxPage, 0, 0, 20, ccc3(0xff, 0xfb, 0xd4))
	setAnchPos(pageNum, 240, 115, 0.5)
	self.mainLayer:addChild(pageNum)
	
	local group = KNRadioGroup:new()
	for i = 1, #tabs do
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png","tab_star_select.png"},10 + (i - 1) * 90 , 695, {
			id = i,
			front =  {COMMONPATH.."tab/".."tab_"..tabs[i]..".png",COMMONPATH.."tab/".."tab_"..tabs[i].."_select.png"},
			callback = function()
				self.curPage = 1
				combineList(i < 5 and 1 or 2,tabs[i])
				pageNum:setString(self.curPage.."/"..self.maxPage)	
			end
		}, group)
		self.mainLayer:addChild(btn:getLayer(), -1)
	end
	group:chooseByIndex(1, true)

	--翻页按钮
	local pre = KNBtn:new(COMMONPATH,{"next_big.png"}, 150, 100, {
		scale = true,
		flipX = true,
		callback = function()
			if self.curPage > 1 then
				self.curPage = self.curPage - 1
				pageNum:setString(self.curPage.."/"..self.maxPage)	
				combineList(group:getId() < 5 and 1 or 2, tabs[group:getId()])
			end
		end
	})
	self.mainLayer:addChild(pre:getLayer())
	
	local next = KNBtn:new(COMMONPATH,{"next_big.png"}, 285, 100, {
		scale = true,
		callback = function()
			if self.curPage < self.maxPage then
				self.curPage = self.curPage + 1
				pageNum:setString(self.curPage.."/"..self.maxPage)
				combineList(group:getId() < 5 and 1 or 2, tabs[group:getId()])
			end
		end
	})
	self.mainLayer:addChild(next:getLayer())

	self.layer:addChild(self.mainLayer)
end


--进化池
function ForgeLayer:createPool(kind)
	if self.mainLayer then
		self.layer:removeChild(self.mainLayer,true)
	end
	
	self.state = POOL
	self.mainLayer = Pool:new():getLayer()
	
	
	
	self.layer:addChild(self.mainLayer)
end

return ForgeLayer
