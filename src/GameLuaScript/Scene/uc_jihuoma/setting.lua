--[[

uc 激活码

]]

local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNInputText = requires(IMG_PATH , "GameLuaScript/Common/KNInputText")


local M = {}


function M:create(  )
	local layer = display.newLayer()
	
	local init_y = 800
	local offset_y = 36
	
	if CHANNEL_GROUP == "dhsh" then
		if CHANNEL_ID == "game1" then
       		-- 我们自己的（wap的）
	    else
	           -- 联运的
	    end
		layer:addChild( display.strokeLabel("请输入你的激活码" , 30 , init_y - offset_y * 4 - 15 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
		layer:addChild( display.strokeLabel("每个用户限领取1次激活奖励" , 30 , init_y - offset_y * 5 - 15 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	elseif CHANNEL_GROUP == "tmsj" then
		layer:addChild( display.strokeLabel("请输入你的激活码" , 30 , init_y - offset_y * 4 - 15 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
		layer:addChild( display.strokeLabel("每个用户限领取1次激活奖励" , 30 , init_y - offset_y * 5 - 15 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	end

	


	local username_input_bg , username_textfield , send_btn , cancel_btn

	-- 切换真假输入框的状态
	local function changeStauts(status)
		if status == true then
			username_textfield:startInput()
		else
			username_textfield:stopInput()
		end
	end

	-- 用户名输入框
	username_textfield = KNInputText:new( { width = 212 , 
										height = 28 , 
										size = 20 , 
										defStr = "请输入激活码" , 
										existStr = nil,
										defColor = ccc3( 0xff , 0xfb , 0xd4 ) , 
										inputColor = ccc3( 0x4d , 0x15 , 0x15 )
										} )
	setAnchPos( username_textfield:getLayer() , 135 , 566 )
	layer:addChild( username_textfield:getLayer() , 10 )

	-- 假用户名输入框背景
	username_input_bg = KNBtn:new(IMG_PATH .. "image/scene/login", {"input_bg.png"} , 125 , 550 , {
		callback = function()
			changeStauts(true)
		end
	}):getLayer()
	layer:addChild(username_input_bg)

	
	-- 确定按钮
	send_btn = KNBtn:new(COMMONPATH , {"btn_bg_red.png" , "btn_bg_red_pre.png"} , 90 , 470 , {
		front = COMMONPATH .. "ok.png",
		callback = function()
			local jihuoma = username_textfield:getString()
			jihuoma = string.trim( jihuoma )
			
			if jihuoma == "" then
				-- 错误提示
				KNMsg:getInstance():flashShow("请输入激活码")
				return
			end

			-- 发请求
			if CHANNEL_GROUP == "dhsh" then
				if CHANNEL_ID == "game1" then
		       		HTTP:call("dhshjhm" , "receive" , {code = jihuoma,}) 		 -- 我们自己的（wap的）官服
			    else
			        HTTP:call("dhshjhm" , "receive_union" , {code = jihuoma,})   -- 联运的
			    end
			elseif CHANNEL_GROUP == "tmsj" then
				HTTP:call("tmsjactivation" , "receive" , {code = jihuoma,})
			end
			changeStauts(false)
		end
	}):getLayer()
	layer:addChild( send_btn )

	-- 取消按钮
	cancel_btn = KNBtn:new(COMMONPATH , {"btn_bg_red.png" , "btn_bg_red_pre.png"} , 270 , 470 , {
		front = COMMONPATH .. "cancel.png",
		callback = function()
			changeStauts(false)
			switchScene("home")
		end
	}):getLayer()
	layer:addChild( cancel_btn )



	changeStauts(true)

	return layer
end


return M
