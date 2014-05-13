local MAIN, LIST = 1, 2
local PATH = IMG_PATH.."image/scene/pvp/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")--require "GameLuaScript/Common/KNRadioGroup"
local KNMask = requires(IMG_PATH, "GameLuaScript/Common/KNMask")
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local RobLayer = {
	baseLayer,
	layer,
	group,
		state,
	curStar
}


function RobLayer:new(params)
	local this = {}
	setmetatable(this, self)
	self.__index = self
	
	params = params or {}
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.state = MAIN
	this.curStar = params.star or 1
	
	local bg = display.newSprite(PATH.."rob_bg.png")
	setAnchPos(bg, 240, 300, 0.5)
	this.layer:addChild(bg)
	
	local layer
	local function createBtn(star)
		if layer then
			this.layer:removeChild(layer, true)
		end
		layer = display.newLayer()
		local items = {
			"general",
			"soul",
			"equip",
			"chip"
		}
		
		for i = 1, #items do
			local text, str
			if i == 2  then
				str = params.data["_G_soul"][star]["num"]
			elseif i == 4 then
				str = params.data["_G_chip"][star]["num"]
			else
--				str = table.nums(DATA_Bag:getTable(items[i], {star = star}))
				str = DATA_Bag:countItems(items[i], true, {star = star})
			end
			local item = KNBtn:new(PATH, {"rob_btn_bg.png", "rob_btn_pre.png"}, 25 + (i - 1) * 115, 125, {
				front = PATH..items[i]..".png",
				other = {COMMONPATH.."have.png", 7, -22},
				text = {str, 20, ccc3(255, 255, 255), ccp(20, -58)},
				callback = function()
					HTTP:call("rob", "getlist", {star = star, type_index = i - 1}, {success_callback = function(data)
						this:creatList(data, star, i - 1)
					end})
				end
			})
			layer:addChild(item:getLayer())

			-- 新手引导
			if items[i] == "general" and KNGuide:getStep() == 3303 then
				KNGuide:show( item:getLayer() , {
					remove = true
				})
			end
		end
		this.layer:addChild(layer)
	end	
	
	local group = KNRadioGroup:new()
	for i = 1, 2 do
		local btn = KNBtn:new(COMMONPATH.."tab/", {"tab_star_normal.png", "tab_star_select.png"},20 + (i - 1) * 95, 240, {
			front = {COMMONPATH.."tab/tab_star"..i..".png", COMMONPATH.."tab/tab_star"..i.."_select.png"},
			callback = function()
				this.curStar = i
				createBtn(i)
			end
		},group)
		this.layer:addChild(btn:getLayer())
	end
	
	group:chooseByIndex(this.curStar, true)
	
	local separator = display.newSprite(COMMONPATH.."tab_line.png")
	setAnchPos(separator, 5, 235)
	this.layer:addChild(separator)
	
	separator = display.newSprite(PATH.."rest_times.png")
	setAnchPos(separator, 260, 245)
	this.layer:addChild(separator)
	
	local times_text = display.strokeLabel(params.data["cur_rob_times"]["2"].."/"..params.data["max_rob_times"]["2"], 420, 245, 20, ccc3(255,255,255))
	this.layer:addChild(times_text)
	
	times_text = display.strokeLabel(params.data["cur_rob_times"]["1"].."/"..params.data["max_rob_times"]["1"], 420, 265, 20, ccc3(255,255,255))
	this.layer:addChild(times_text)
	
	separator = display.newSprite(PATH.."rob_time.png")
	setAnchPos(separator, 40, 705)
	this.layer:addChild(separator)
	
	times_text = display.strokeLabel(params.data["cur_robbed_times"].."/"..params.data["max_robbed_times"], 170, 708, 20, ccc3(255,255,255))
	this.layer:addChild(times_text)
	
	local mask
	local record = KNBtn:new(COMMONPATH, {"long_btn.png", "long_btn_pre.png"}, 350, 695, {
		front = PATH.."rob_record.png",
		callback = function()
		   local recordLayer = display.newLayer()
		   recordLayer:ignoreAnchorPointForPosition(false)
		   setAnchPos(recordLayer, 240, 427, 0.5, 0.5)
		   recordLayer:setScale(0)
		   
		   local bg =  display.newSprite(SCENECOMMON.."rob_msg_bg.png")
		   setAnchPos(bg, 240, 325, 0.5)
		   recordLayer:addChild(bg)
		   
		   local robRecord = KNScrollView:new(40, 330, 200, 310, 20)
		   recordLayer:addChild(robRecord:getLayer())
--		   for k, v in pairs(params.data["rob_message"]) do
		   for i = 1, #params.data["rob_message"] do  
			   local msg = createLabel({str = params.data["rob_message"][#params.data["rob_message"] + 1 - i], color = ccc3(0x34, 0x7bf, 0xbe), width = 200})
			   setAnchPos(msg)
			   robRecord:addChild(msg)
		   end
		   robRecord:alignCenter()
		   
		   local robbedRecord =KNScrollView:new(245,330, 200, 310, 20)
		   recordLayer:addChild(robbedRecord:getLayer())
--		   for k, v in pairs(params.data["robbed_message"]) do
		   for i = 1, #params.data["robbed_message"] do  
   			   local msg = createLabel({str =params.data["robbed_message"][#params.data["robbed_message"] + 1 - i], color = ccc3(0xe7, 0x2a, 0x2a), width = 200})
   			   setAnchPos(msg)
			   robbedRecord:addChild(msg)
		   end
		   robbedRecord:alignCenter()
		   
		   recordLayer:runAction(getSequenceAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1)),CCCallFunc:create(function()
		   
		   end)))
		   
		   
		   mask = KNMask:new({item = recordLayer, click = function(x, y)
			   if CCRectMake(240 - bg:getContentSize().width / 2, 325, bg:getContentSize().width, bg:getContentSize().height):containsPoint(ccp(x, y)) then
			   else
				   recordLayer:runAction(getSequenceAction(CCScaleTo:create(0.3,0),CCCallFunc:create(function()
					-- this.baseLayer:removeChild(mask, true)
					mask:remove()
				   end)))
			   end
		   end})
		   this.baseLayer:addChild(mask:getLayer())
		end	
	})
	this.layer:addChild(record:getLayer())
	
	this.baseLayer:addChild(this.layer)
	return this
end

function RobLayer:getLayer()
	return self.baseLayer
end

--创建排行列表
function RobLayer:creatList(data, star, index)
	if self.layer then
		self.baseLayer:removeChild(self.layer,true)
	end	
	
	self.state = LIST
	self.layer = display.newLayer()
	
	local listTip = display.newSprite(PATH..star.."_star_title.png")
	setAnchPos(listTip, 240, 720, 0.5)
	self.layer:addChild(listTip)
	
	
	local layer = KNScrollView:new(0, 160, 480, 560, 5) 
	
	for i = 1, #data do
		local temp = self:listItem(data[i], layer, star, index, i - 1)
		layer:addChild(temp)
	end
	layer:alignCenter()
	
	self.layer:addChild(layer:getLayer())
	
	local refresh = KNBtn:new(COMMONPATH, {"btn_bg_red.png", "btn_bg_red_pre.png"}, 300, 105, {
		front = COMMONPATH.."refresh_list.png",
		callback = function()
			HTTP:call("rob", "getlist", {star = star, type_index = index }, {success_callback = function(data)
				self:creatList(data,star, index)
			end})
		end
	})
	self.layer:addChild(refresh:getLayer())
	
	self.layer:addChild(createLabel({str = "战斗成功将有极大几率抢夺成功", color = ccc3(255,0,0), size = 18, x = 10, y = 115, width = 400 }))
	
	self.baseLayer:addChild(self.layer)
end



function RobLayer:listItem(data, parent, star, type_index, pos)
	local layer = display.newLayer()
	
	local bg = display.newSprite(COMMONPATH.."item_bg.png")
	setAnchPos(bg)
	layer:addChild(bg)
	
	layer:setContentSize(bg:getContentSize())
	
	local icon = KNBtn:new(COMMONPATH , { "sex" .. data["sex"] .. ".jpg"} , 17 , 35 , {
				front = COMMONPATH.."role_frame.png",
				scale = true , 
				parent = parent,
				callback = function()
					local uid = data["uid"] 
					if not uid  then
						switchScene("userinfo")
					else
						HTTP:call("profile","get",{ touid = uid },{success_callback = 
							function()
								local otherPalyerInfo = requires(IMG_PATH, "GameLuaScript/Scene/common/otherPlayerInfo")
								display.getRunningScene():addChild( otherPalyerInfo:new():getLayer() )
							end})
					end
				end
			}):getLayer()
	layer:addChild(icon)
	
	
	local name = display.strokeLabel(data["name"], 100, 70, 20,nil, nil, nil, {
	})

	layer:addChild(name)
	

	name = display.strokeLabel("战力:"..data["num"], 100, 20, 24,ccc3(0x2c,0x00,0x00))
	layer:addChild(name)
	
	name = display.strokeLabel("Lv:"..data["lv"], 25, 5, 20, ccc3(0x2c, 0, 0))
	layer:addChild(name)
	
	local robBtn = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 350, 40, {
		front = PATH.."rob.png",
		callback =function()
			SOCKET:getInstance("battle"):call("rob" , "execute" , "execute",{star = star, type_index = type_index, index = pos })
		end
	})
	layer:addChild(robBtn:getLayer())
	
	return layer
end

function RobLayer:getState()
	return self.state
end

function RobLayer:getStar()
	return self.curStar
end

return RobLayer