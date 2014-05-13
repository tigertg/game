--[[商城]]

local PATH = IMG_PATH.."image/scene/shop/"
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
local KNSlider = requires(IMG_PATH, "GameLuaScript/Common/KNSlider")
local KNRadioGroup = requires(IMG_PATH, "GameLuaScript/Common/KNRadioGroup")
local ShopItem = requires(IMG_PATH,"GameLuaScript/Scene/shop/shopitem")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local SCENECOMMON = IMG_PATH .. "image/scene/common/"

local ShopLayer = {
	baseLayer,
	layer,
	itemsLayer,
	infoLayer,
	group,
	buyLayer,
	moneyLayer,
}

function ShopLayer:new(layerName)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	this.moneyLayer = nil
	this.baseLayer = display.newLayer()
    this.layer = display.newLayer()
	
	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.layer:addChild(bg)

	local bagConfig
	if CHANNEL_ID ~= "cmge" then
		bagConfig = {
		--[[
			{
				"kit",
				"tab_kit.png",
				"tab_kit_big.png",
			},
		]]
			{
				"recover",
				"tab_recover.png",
				"tab_recover_big.png",
			},
			{
				"other",
				"tab_other.png",
				"tab_other_big.png",
			},
		}
	else
		bagConfig = {
			{
				"recover",
				"tab_recover.png",
				"tab_recover_big.png",
			},
			{
				"other",
				"tab_other.png",
				"tab_other_big.png",
			},
		}
	end

	local goVip = KNBtn:new( COMMONPATH , { "long_btn.png" ,"long_btn_pre.png"} , 355 , 700 ,
	{
		front = IMG_PATH .. "image/scene/vip/vip_p.png",
		callback = 
		function()
			HTTP:call("vip", "get", {},{success_callback = 
			function()
				switchScene("vip")
			end})
		end
	}):getLayer()
	this.layer:addChild( goVip )
	
	
	local temp
	local startX , startY = 10 , 690
	this.group = KNRadioGroup:new()
	for i = 1, #bagConfig do
		temp = KNBtn:new(COMMONPATH .. "tab" , { "tab_star_normal.png" , "tab_star_select.png" } , startX , startY , {
			front = { COMMONPATH .. "tab_shop/" .. bagConfig[i][2] , COMMONPATH .. "tab_shop/" .. bagConfig[i][3]},
			disableWhenChoose = true,
			id = bagConfig[i][1],
			callback = function()
				if DATA_Shop:haveData() then
					this:createBag(bagConfig[i][1])
				else
					HTTP:call("shop","get",{},{success_callback=
					function()
						this:createBag(bagConfig[i][1])
					end
					})
				end
			end
		} , this.group)

		this.layer:addChild(temp:getLayer())
		startX = startX + temp:getWidth() + 4
	end

	local line = display.newSprite(COMMONPATH .. "tab_line.png")
	setAnchPos(line , 6 , 685)
	this.layer:addChild(line)


	-- 充值按钮
	local charge_btn = KNBtn:new(COMMONPATH , {"btn_bg_red.png" , "btn_bg_red_pre.png"} , 25 , 103 , {
		front = SCENECOMMON .. "navigation/na_charge_big.png",
		scale = true,
		callback = function()
			switchScene("pay")
		end,
	})
	this.layer:addChild(charge_btn:getLayer())

	this:refreshMoney()


	this:createBag(bagConfig[1][1])

	
	this.infoLayer = InfoLayer:new(layerName , 0 , {tail_hide = true , title_text = PATH .. "title.png"})

	this.baseLayer:addChild(this.layer)
	this.baseLayer:addChild(this.infoLayer:getLayer(),1)
	return this.baseLayer
end

function ShopLayer:refreshMoney()
	if self.moneyLayer ~= nil then
		self.layer:removeChild(self.moneyLayer , true)
	end

	self.moneyLayer = display.newLayer()

	-- 金钱
	self.moneyLayer:addChild( display.newSprite(SCENECOMMON .. "navigation/money_bg.png" , 246 , 125) )
	self.moneyLayer:addChild( display.newSprite(SCENECOMMON .. "navigation/money_bg.png" , 375 , 125) )
	self.moneyLayer:addChild( display.newSprite(COMMONPATH.."gold.png" , 202 , 125) )
	self.moneyLayer:addChild( display.newSprite(COMMONPATH.."silver.png" , 331 , 125) )
	
	self.moneyLayer:addChild( display.strokeLabel(DATA_Account:get("gold") , 220 , 114 , 18 , ccc3(255 , 251 , 212) , 2 ) )
	self.moneyLayer:addChild( display.strokeLabel(DATA_Account:get("silver") , 350 , 114 , 18 , ccc3(255 , 251 , 212) , 2 ) )

	self.layer:addChild(self.moneyLayer)
end



function ShopLayer:createBag(type)
	if self.itemsLayer then
		self.layer:removeChild(self.itemsLayer,true)
	end
	
	local itemsNum = DATA_Shop:count(type)
	if itemsNum <= 0 then return end


	self.itemsLayer = display.newLayer()
	local perpage = 5
	local x , y = 15 , 572

	local scroll = KNScrollView:new(15 , 155 , 450 , 530 , 5)
	local items = DATA_Shop:getTable(type)
	local keyList = getSortList(items, function(l, r)
		return getConfig("prop", items[l].cid, "star") < getConfig("prop", items[r].cid, "star") 
	end)
	for i , v in pairs(keyList) do  --循环初始化当前选中类型的类型的背包显示
		local info = items[v]
		local item = ShopItem:new(type , v["id"] , {
			index = v,
			parent = scroll,
			iconCallback = function()
				--当点击图标按钮后先从全局数据中查找是否存在数据，若没有则请求网络，否则隐藏用户信息栏，显示详细界面
				local detail_type = getCidType(info["cid"])
				local data = getConfig( detail_type , info["cid"] )
				data["cid"] = info["cid"]

				pushScene("detail" , {
					detail = detail_type,
					shopBuyFun = function()
						if getConfig("prop", info["cid"], "type") == "vip" then
							if not countGold(info.price) then
								return
							else
								HTTP:call("shop" , "buy" , {
									id = info["id"],
									num = 1 
								} , {
									success_callback = function()
										KNMsg.getInstance():flashShow("购买成功")
										self:refreshMoney()
									end
								})
							end
						else
							popScene()
							self:buy(type , info["id"] , v)
						end
					end ,
					data = data,
				})
			end,

			optCallback = function()
				if getConfig("prop", info["cid"], "type") == "vip" then
					if not countGold(info.price) then
						return
					else
						HTTP:call("shop" , "buy" , {
							id = info["id"],
							num = 1 
						} , {
							success_callback = function()
								KNMsg.getInstance():flashShow("购买成功")
								self:refreshMoney()
							end
						})
					end
				else
					self:buy(type , info["id"] , v)
				end
			end
		})

		-- item:setPos(x , y)
		-- self.itemsLayer:addChild(item:getLayer())

		-- y = y - item:getHeight() - 8

		scroll:addChild(item:getLayer())
	end

	scroll:alignCenter()
	scroll:effectIn()
	self.itemsLayer:addChild(scroll:getLayer())

	--页数显示及翻页按钮-背包道具计数
	--[[
	local bg = display.newSprite(COMMONPATH .. "page_bg.png")
	setAnchPos(bg , display.cx , 114 , 0.5)	
	
	local max = CCLabelTTF:create(self.curPage.."/"..math.ceil(itemsNum / perpage),FONT,20)
	setAnchPos(max , display.cx , 120 , 0.5)
	
	local next = KNBtn:new(COMMONPATH,{"next_big.png"} , 288 , 107 , {
		scale = true ,
		callback = function()
			if self.curPage < math.ceil(itemsNum / perpage) then
				self.curPage = self.curPage + 1
				self:createBag(type)
			end
		end
	})
	local prev = KNBtn:new(COMMONPATH,{"next_big.png"} , 150 , 107 , {
		flipX = true,
		scale = true,
		callback = function()
			if self.curPage > 1 then
				self.curPage = self.curPage - 1
				self:createBag(type)
			end
		end
	})
	
	self.itemsLayer:addChild(bg)
	self.itemsLayer:addChild(max)
	self.itemsLayer:addChild(prev:getLayer())	
	self.itemsLayer:addChild(next:getLayer())
	]]
	
	self.layer:addChild(self.itemsLayer)
end

function ShopLayer:buy( type , id , index )
	self.buyLayer = display.newLayer()
	local baseX = display.cx
	local baseY = display.cy - 28
	
	local bg = display.newSprite(COMMONPATH.."tip_bg.png")
	setAnchPos( bg , baseX - 193 , baseY , 0 , 0 )
	self.buyLayer:addChild(bg)
	
	--物品Icon
	local icon = KNBtn:new( SCENECOMMON , { "skill_frame1.png" } , baseX - 148 , baseY + 135 , {  front = getImageByType(DATA_Shop:get(index , "cid") , "s") } )
	self.buyLayer:addChild( icon:getLayer() )	
	
	-- 名字
	self.name = display.strokeLabel( DATA_Shop:get(index,"name") , baseX - 75 , baseY + 170 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , 2 , ccc3(0x40 , 0x1d , 0x0c ) , { dimensions_width = 130 , dimensions_height = 30 ,align = 0 } )
	self.buyLayer:addChild( self.name )
	
	--花费总数
	local valueBg = display.newSprite(PATH.."value_bg.png")
	valueBg:setScaleY(0.89)
	setAnchPos(valueBg , baseX - 17 , baseY + 130 , 0.5)
	self.buyLayer:addChild(valueBg)
	
	local gold = display.newSprite(COMMONPATH .. "gold.png")
	setAnchPos(gold , baseX - 75  , baseY + 140 )
	self.buyLayer:addChild(gold)
	
	local priceText = display.strokeLabel( DATA_Shop:get(index,"real_price") , baseX - 40 , baseY + 135 , 20 , ccc3(0x2c , 0x00 , 0x00 ) , nil , nil ,{ dimensions_width = 80 , dimensions_height = 30 ,align = 0} )
	self.buyLayer:addChild(priceText)
	

	
	
	--购买数量
	local numText = display.newSprite(PATH.."num_text.png")
	setAnchPos(numText,baseX + 55  , baseY + 140 , 0 )
	self.buyLayer:addChild(numText)
	
	--购买数量
	local numBg = display.newSprite(PATH.."num_bg.png")
	local num = 1 
	setAnchPos(numBg,baseX + 116 , baseY + 136 , 0 )
	self.buyLayer:addChild(numBg)
	
	--数量文本
	local numText = display.strokeLabel( 1 .. "" , baseX + 116 , baseY + 136 , 20 , ccc3(0xff , 0xfb , 0xd5 ) , nil , nil , { dimensions_width = 36 , dimensions_height = 30 ,align = 1 } )
	self.buyLayer:addChild(numText)
	

	--修改数值
	local function changeValue()
		numText:setString(num)
		priceText:setString(num * DATA_Shop:get(index,"real_price"))
	end
	
	
	
	
		--划动条
	local slider = KNSlider:new( "buy" ,  {
		x = baseX - 106 , 
		y = baseY -53 , 
		minimum = 1 , 
		maximum = 20, 
		value = 1 , 
		callback  = function( _curIndex )
			num = _curIndex
			changeValue()
		end,
		priority = -140
	})
	self.buyLayer:addChild( slider )
	
	--增减按钮
	local addBtn = KNBtn:new(COMMONPATH,{"next_big.png"} , baseX + 128 , baseY + 77 , {
		scale = true,
		priority = -130,
		callback = function()
			if num < 99 then
				num = num + 1
				slider:setValue( num )
				changeValue()
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
				changeValue()
			end
		end
	})
	minusBtn:setFlip(true)
	
	addBtn:getLayer():setScale( 0.9 )
	minusBtn:getLayer():setScale( 0.9 )
	self.buyLayer:addChild(addBtn:getLayer())
	self.buyLayer:addChild(minusBtn:getLayer())
	

	

	
	local mask = KNMask:new( {item = self.buyLayer } ):getLayer()
	--确定，取消按钮
	local ok = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"}, baseX - 134 , baseY + 28 ,{
		front = COMMONPATH.."ok.png" ,
		scale = true,
		priority = -130,
		callback = function()
			if not countGold(priceText:getLabel():getString()) then
				return
			else
				HTTP:call("shop" , "buy" , {
					id = id,
					num = num
				} , {
					success_callback = function()
						KNMsg.getInstance():flashShow("购买成功")
						
						self.baseLayer:removeChild(mask,true)
						
						self:refreshMoney()
					end
				})
			end

		end
	})
	local cancel = KNBtn:new(COMMONPATH,{"btn_bg.png","btn_bg_pre.png"} , baseX + 54 , baseY + 28 ,{front = COMMONPATH.."cancel.png",scale = true,priority = -130,callback=
		function()
			self.baseLayer:removeChild(mask,true)
		end})
	self.buyLayer:addChild(ok:getLayer())
	self.buyLayer:addChild(cancel:getLayer())
	

	self.baseLayer:addChild(mask)
end


return ShopLayer
