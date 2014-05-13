local PATH = IMG_PATH .. "image/scene/pay/"

local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")

local PayItem = requires(IMG_PATH , "GameLuaScript/Scene/pay/item")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")

local PayLayer = {
	layer,
	infolayer,
}

function PayLayer:new(args)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	args = args or {}


	-- 基础层
	this.layer   = display.newLayer()
	

	-- 背景
	local bg = display.newSprite(COMMONPATH .. "mid_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.layer:addChild(bg)
	
	
	local goVip = KNBtn:new( COMMONPATH , { "big.png" ,"big_pre.png"}, 307 , 700 ,
	{
		priority = -130,
		front = PATH .. "vip_privilege.png" ,
		callback = 
		function()
			HTTP:call("vip", "get", {},{success_callback = 
			function()
				switchScene("vip")
			end})
		end
	}):getLayer()
	this.layer:addChild( goVip )


	this.layer:addChild( display.newSprite( PATH .. "vip_tip.png" , 33 , 720 , 0 , 0 ) )	--充值额度越高，越实惠
	local vipinfo = DATA_Vip:get( "vipinfo" )
	local costValue = math.ceil( ( vipinfo.lvup_exp - vipinfo.cur_exp ) / 10 )
	
	local curVipLv =  DATA_Vip:get( "viplv" )
	local nextVipLv = curVipLv + 1
	nextVipLv = nextVipLv > 6 and 6 or nextVipLv
	local str
	if DATA_Vip:get("viplv") <= 5 then
		str = "您是VIP-" .. curVipLv .. "再充" .. costValue .. "元成为VIP-" .. ( nextVipLv )
	else
		str = "您是VIP-6"
	end
	this.layer:addChild( display.strokeLabel( str , 33 , 700 , 18 , ccc3( 0x2c , 0x00 , 0x00 ) ) )

    local data

if CHANNEL_ID == "appFameOfficial" or CHANNEL_ID == "tmsjIosAppStore" then
		 data = {
				{ rmb = 518 , num = 5180 , extra = true },
				{ rmb = 308 , num = 3080 , extra = true },
				{ rmb = 208 , num = 2080 , extra = true },
				{ rmb = 108 , num = 1080 , extra = true },
				{ rmb = 60 , num = 600 , extra = true },
				{ rmb = 30 , num = 300 },
				{ rmb = 6 , num = 60 },
              }
    else
    	 data = {
    	 		{ rmb = 5000, num = 50000, extra = true },
				{ rmb = 500 , num = 5000 , extra = true },
				{ rmb = 300 , num = 3000 , extra = true },
				{ rmb = 200 , num = 2000 , extra = true },
				{ rmb = 100 , num = 1000 , extra = true },
				{ rmb = 50 , num = 500 , extra = true },
				{ rmb = 30 , num = 300 },
				{ rmb = 20 , num = 200 },
				{ rmb = 10 , num = 100 },
				-- { rmb = 1 , num = 10 },
			}
    end

	

	local scroll = KNScrollView:new(20 , 120 , 436 , 580 , 0 , false)
	for i = 1 , #data do
		local item = PayItem:new( data[i] , {
			parent = scroll
		})
		scroll:addChild(item:getLayer() , item)
	end
	

	--海外充值链接
	if CHANNEL_GROUP == "tmsj" then
    local PATH = IMG_PATH .. "image/scene/pay/"
    local otherCountryBtn = KNBtn:new( PATH , {"bar.png"}, 307 , 300 ,
	{
		priority = -130,
		front = PATH .. "otherCountry.png" ,
		callback = 
		function()
			
				local pay_url = CONFIG_LOGIN_HOST.. "/html.php?m=paypal&a=token&server_id="..DATA_Session:get("server_id").."&uid="..DATA_Session:get("uid").."&sid="..DATA_Session:get("sid").."&channel=paypal&channel_group=tmsj"
				if device.platform == "ios" then
                   UpdateDataOC:getInstance():openUrl(pay_url)

				elseif device.platform == "android" then
				  UpdataRes:getInstance():openUrl( pay_url )

				end
			
		end
	}):getLayer()

	scroll:addChild(otherCountryBtn)
	end




	this.layer:addChild( scroll:getLayer() )
	

	this.infolayer = InfoLayer:new("pay" , 0 , {tail_hide = true , title_text = PATH .. "title.png" , closeCallback = args.closeFun })
	this.layer:addChild(this.infolayer:getLayer(),1)

--	-- 弹窗
--	if CHANNEL_ID ~= "uc" then
--		local handle
--		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
--			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
--			handle = nil
--			
--			local msg = "【温馨提示】\n1，大家在本轮测试的充值，公测时将三倍返还\n2，本轮测试时间截止8月15日"
--			if CHANNEL_ID == "cmge" then
--				msg = "【温馨提示】\n大家在本轮测试的充值，公测时将三倍返还\n进入支付页面后，请重新填写充值金额"
--			end
--			KNMsg.getInstance():boxShow(msg , {
--				confirmFun = function() end,
--				align = 0
--			})
--		end , 0.02 , false)
--	end
--	

	return this.layer 
end


function PayLayer:getLayer()
	return self.layer
end

return PayLayer
