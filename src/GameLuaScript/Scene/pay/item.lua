local PATH = IMG_PATH .. "image/scene/pay/"
local KNLoading = requires(IMG_PATH, "GameLuaScript/Common/KNLoading")


--[[一条数据]]
local PayItem = {
	layer,
	params,
}



function PayItem:new(data , params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	this.params = params or {}

	this.layer = display.newLayer()

	
	local bg = display.newSprite( PATH .. "bar.png" )
	setAnchPos(bg , 0 , 0)
	this.layer:addChild(bg)


	local chong = display.newSprite( PATH .. "chong_" .. data.rmb .. ".png" )
	setAnchPos(chong , 30 , 20)
	this.layer:addChild(chong)

	local gold = display.newSprite( PATH .. "gold.png" )
	setAnchPos(gold , 200 , 20)
	this.layer:addChild(gold)

	local get = display.newSprite( PATH .. "get_" .. data.rmb .. ".png" )
	setAnchPos(get , 265 , 22)
	this.layer:addChild(get)

	if data.extra then
		local extra = display.newSprite( PATH .. "extra_" .. data.rmb .. ".png" )
		setAnchPos(extra , 360 , 15)
		this.layer:addChild(extra)
	end


	this.layer:setContentSize( CCSizeMake( 436 , 80 ) )


	-- 设置可点击
	local init_y = 0
	this.layer:registerScriptTouchHandler(function( type , x , y )
		if type == CCTOUCHBEGAN then
			local range = this:getRange()
			if y < this.params.parent:getY() + this.params.parent:getHeight() and y > this.params.parent:getY()  then
				if this:getRange():containsPoint( ccp(x , y) ) then
					init_y = y
					return true
				end
			end

			return false
		elseif type == CCTOUCHMOVED then
		elseif type == CCTOUCHENDED then
			if this:getRange():containsPoint( ccp(x , y) ) then
				if math.abs(y - init_y) < 30 then
				
					HTTP:call("iapppay","token",{
						num = data.num
					} , {
						success_callback = function(response)
						dump(response)
						dump(data.num)
						    if device.platform == "ios" then
						    	if CHANNEL_ID == "91" then
						    	    -- IOS 91平台
									LuaCall91PlatForm:getInstance():buy(response["exorderno"] , response["waresid"] , data.num .. "两黄金" , response["price"] , 1)
								
								elseif CHANNEL_ID == "appFame" then
									--ios 云顶sdk平台
								    LuaCallAppFrameSDK:getInstance():buy(0) --参数为0,不需要传
								
								elseif CHANNEL_ID == "appFameOfficial" then
									--ios 云顶sdk平台正版
									local load = KNLoading:new()
                                    display.getRunningScene():addChild(load:getLayer())
								    LuaCallAppFameSDKOfficial:getInstance():buy(response["price"] , response["exorderno"],
                        				function() 
                        					load:remove() 
                        				end ,
                        				function(response)
                        					load:remove()
                        					local orderNo = response["orderNo"]
                        					local receiptString = response["receiptString"]
                        				
                        					HTTP:call("pay", "callback", { orderNo = orderNo , receiptString = receiptString } , {
                        						requestUrl = CONFIG_PAY_URL .. "?from=appFameOfficial",
                        						success_callback = function()
												-- this:selectActivity( curName )
											end
											})

                        			end) 
                                

                                elseif CHANNEL_ID == "tmsjIosAppStore" then
                                     --ios 唐门世界正版
                                    local load = KNLoading:new()
                                    display.getRunningScene():addChild(load:getLayer())
                        			LuaCallAppStore:getInstance():buy( response["price"] , response["exorderno"],
                        				function() 
                        					load:remove() 
                        				end ,
                        				function(response)
                        					load:remove()
                        					local orderNo = response["orderNo"]
                        					local receiptString = response["receiptString"]
                        				
                        					HTTP:call("pay", "callback", { orderNo = orderNo , receiptString = receiptString } , {
                        						requestUrl = CONFIG_PAY_URL .. "?from=tmsjIosAppStore",
                        						success_callback = function()
												-- this:selectActivity( curName )
											end
											})

                        			end)
								elseif CHANNEL_ID == "tmsjios"  then
								    LuaCalliPaySDK:getInstance():buy(response["exorderno"] , response["waresid"],response["price"])
								elseif CHANNEL_ID == "dhshIosIpay"  then
								    LuaCalliPaySDK:getInstance():buy(response["exorderno"] , response["waresid"],response["price"])
								else
								end

						    else
						    	-- 中国手游集团
						    	if CHANNEL_ID == "cmge" then
						    		CMGEsdk:getInstance():cmgepay("1" , "dhsh_game1" , "1" , "cmge" , "orderId=" .. response["exorderno"] , (response["price"] * 100) .. "" , "1" , "3")
						    	elseif CHANNEL_ID == "longyin" or CHANNEL_ID == "mi" or CHANNEL_ID == "downjoy" or CHANNEL_ID == "DK" or CHANNEL_ID == "kugou" or CHANNEL_ID == "gfan" or CHANNEL_ID == "nearme.gamecenter" then
									FlySDK:getInstance():FlyPay(response["exorderno"] .. "" , CONFIG_PAY_URL .. "?from=longyin", response["price"] .. "", "黄金",function(response) end)
								elseif CHANNEL_ID == "ledou" then
									ledouSDK:getInstance():ledoupay("ss")
								elseif CHANNEL_ID == "pada" then
									CCLuaLog("exorderno"..response["exorderno"])
									padaSDK:getInstance():padapay("黄金",response["exorderno"] .. "", data.num .. "" )
								elseif CHANNEL_ID == "qihoo" then
									qihooSDK:getInstance():qihoopay("false","true", (response["price"] * 100) .. "", data.num .. "黄金","大话水浒",response["access_token"],response["qihoo_id"],response["exorderno"],DATA_User:get("name"),CONFIG_PAY_URL .. "?from=qihoo")
								elseif CHANNEL_ID == "uc" then
									UCGameSDK:getInstance():pay(true , response["price"] , 2126 , DATA_Session:get("uid") .. "" , DATA_User:get("name").."" , DATA_User:get("lv") .. "" , "orderId=" .. response["exorderno"])
								elseif CHANNEL_ID == "youxin" then
									youxinSDK:getInstance():youxinPay(response["price"] * 100 , "黄金" , "10" , response["exorderno"],  CONFIG_PAY_URL .. "?from=youxin", response["time"])
								elseif CHANNEL_ID == "uucun" then
									uucon:getInstance():uuconpay(response["exorderno"], "EFfizphjQohcE4FKXbKZqsETzXHYPnpF", "GZilGc", CONFIG_PAY_URL .. "?from=uucun", "", "10", "黄金", "黄金", "1", "1", response["time"])	
								else
									local pay_url = CONFIG_PAY_URL
									if CHANNEL_ID == "test" or CHANNEL_ID == "game1" then
										pay_url = CONFIG_PAY_URL .. "?from=iapppay2"
									end
									UpdataRes:getInstance():play( response["exorderno"] .. "" , (response["price"] * 100) .. "" , response["waresid"] .. "" , "1" , pay_url)   --android
								end
						    end
						end
					})
				end
			end
		end

		return true
	end)
	this.layer:setTouchEnabled(true)
	
	return this
end

function PayItem:getLayer()
	return self.layer
end

--获取所有父组件，取得按钮的绝对位置
function PayItem:getRange()
	local x = self.layer:getPositionX()
	local y = self.layer:getPositionY()

	local parent = self.layer:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end
	return CCRectMake(x,y,self.layer:getContentSize().width,self.layer:getContentSize().height)
end


return PayItem