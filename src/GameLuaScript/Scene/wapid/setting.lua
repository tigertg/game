--[[

wap输入id

]]

local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")


local M = {}


function M:create(  )
	local layer = display.newLayer()
	
	local init_y = 760
	local offset_y = 36
	layer:addChild( display.strokeLabel("温馨提示:" , 30 , init_y , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	layer:addChild( display.strokeLabel("请输入你玩大话水浒wap的游戏ID" , 30 , init_y - offset_y , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	layer:addChild( display.strokeLabel("以便后续的奖励发放!" , 30 , init_y - offset_y * 2 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	layer:addChild( display.strokeLabel("切记填写正确的ID,以免奖励不能正常发放！" , 30 , init_y - offset_y * 3 , 22, ccc3( 0xff , 0xff , 0xff ) ) )
	layer:addChild( display.strokeLabel("一旦提交，不可更改！" , 30 , init_y - offset_y * 4 , 22, ccc3( 0xff , 0xff , 0xff ) ) )


	local username_input_bg , username_textfield , username_mask , send_btn , cancel_btn

	-- 切换真假输入框的状态
	local function changeStauts(status)
		if status == true then
			username_textfield:attachWithIME()
		else
			username_textfield:detachWithIME()
		end
	end

	-- 用户名输入框
	username_textfield = CCTextFieldTTF:textFieldWithPlaceHolder("请输入wap游戏ID" , FONT , 20)
	display.align(username_textfield , display.CENTER_LEFT , 0 , 0)
	username_textfield:setColor( ccc3( 0xff , 0xfb , 0xd4 ) )
	username_textfield:setColorSpaceHolder( ccc3( 0x4d , 0x15 , 0x15 ) )

	username_mask = WindowLayer:createWindow()
	username_mask:setAnchorPoint( ccp(0 , 0.5) )
	username_mask:setContentSize( CCSizeMake(212 , 28) )
	username_mask:addChild( username_textfield )
	layer:addChild( username_mask , 10 )


	-- 假用户名输入框背景
	username_input_bg = KNBtn:new(IMG_PATH .. "image/scene/login", {"input_bg.png"} , 125 , 550 , {
		callback = function()
			changeStauts(true)
		end
	}):getLayer()
	username_mask:setPosition(135 , 566)
	layer:addChild(username_input_bg)

	
	-- 确定按钮
	send_btn = KNBtn:new(COMMONPATH , {"btn_bg_red.png" , "btn_bg_red_pre.png"} , 90 , 470 , {
		front = COMMONPATH .. "ok.png",
		callback = function()
			local wapid = username_textfield:getString()
			wapid = string.trim( wapid )

			if wapid == "" then
				-- 错误提示
				KNMsg:getInstance():flashShow("请输入wap游戏id")
				return
			end

			-- 发请求
			HTTP:call("wap" , "set" , {
				wapid = wapid,
			})

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
