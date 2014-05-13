local Culturelayer = {layer}
function Culturelayer:new(x,y,gids)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	
	local handle = CCDirector:sharedDirector():getScheduler()
	
	local index = 1
	local hero_data = gids--DATA_Formation:get_index(gids)["gid"]
	dump(hero_data)
	this.layer:addChild( display.strokeLabel( DATA_General:get(hero_data,"name") , 60 , 590 , 24 , ccc3( 0xac , 0x25 , 0x12 )  ) )
	this.layer:addChild( display.strokeLabel( "LV"..DATA_General:get(hero_data,"lv") , 160 , 590 , 20 , ccc3( 0xac , 0x25 , 0x12 )  ) )

	for i = 1,DATA_General:get(hero_data,"star") do
				local srat = display.newSprite(IMG_PATH.."image/common/star.png")
				setAnchPos(srat ,60+(i-1)*30,552)
				this.layer:addChild(srat )
	end

	local get_fame = display.newSprite(IMG_PATH.."image/scene/Culture/9.png")
	setAnchPos(get_fame ,267,555)
	this.layer:addChild(get_fame )
	
	-----获得名气,label
	local mingqi = display.strokeLabel(DATA_Account:get("gold") , 360 , 579 , 20 , ccc3(255 , 251 , 212) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild( mingqi )
	--print("~~~~~~~~~~~~~~~~~~~~")
	------剩余名气,labelS
	--dump(DATA_General:get(DATA_Account:get("gold")))
	local shengyu = display.strokeLabel(DATA_User:get_fame() , 360 , 553 , 20 , ccc3(255 , 251 , 212) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild( shengyu )
	
	-----------------属性----------------------------
	--[[
	---原属性
	]]
	local Property_old_bg = display.newSprite(IMG_PATH.."image/scene/Culture/8.png")
	setAnchPos(Property_old_bg ,57,340)
	this.layer:addChild(Property_old_bg )
	
	local Property_old_font = display.newSprite(IMG_PATH.."image/scene/Culture/old_Property.png")
	setAnchPos(Property_old_font ,53,490)
	this.layer:addChild(Property_old_font )
	
	local font_point_old = {{110,450},{110,415},{110,380},{110,340}}
	local init_pro = {"hp_i","atk_i","def_i","agi_i"}

	local init_pro_a = {"hp_w","atk_w","def_w","agi_w"}

	local label_old_font = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[1]) , font_point_old[1][1],font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild(  label_old_font)
	local label_old_font_add = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[1]),DATA_User:get_percent()) , (label_old_font:getLabel():getContentSize().width+font_point_old[1][1]),font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild( label_old_font_add )
	
	local label_old_font1 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[2]) , font_point_old[2][1],font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild(  label_old_font1)
	local label_old_font_add1  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[2]),DATA_User:get_percent()) , (label_old_font1:getLabel():getContentSize().width+font_point_old[2][1]),font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild( label_old_font_add1 )
	
	local label_old_font2 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[3]) , font_point_old[3][1],font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild(  label_old_font2)
	local label_old_font_add2  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[3]),DATA_User:get_percent()) , (label_old_font2:getLabel():getContentSize().width+font_point_old[3][1]),font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) 
	this.layer:addChild( label_old_font_add2 )
	
	local label_old_font3 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[4]) , font_point_old[4][1],font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild(  label_old_font3 )
	local label_old_font_add3  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[4]),DATA_User:get_percent()) , (label_old_font3:getLabel():getContentSize().width+font_point_old[4][1]),font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	this.layer:addChild( label_old_font_add3 )
	
	--[[
	---新 属性
	]]
	local Property_new_bg = display.newSprite(IMG_PATH.."image/scene/Culture/8.png")
	setAnchPos(Property_new_bg ,283,340)
	this.layer:addChild(Property_new_bg )

	local Property_new_font = display.newSprite(IMG_PATH.."image/scene/Culture/new_Property.png")
	setAnchPos(Property_new_font ,278,490)
	this.layer:addChild(Property_new_font )

	local font_point = {{335,450},{335,415},{335,380},{335,340}}
	
	--[[这里还需要添加改属性的数据]]
	-----------------------------------------------
	------培养选项
	local select_culture = display.newSprite(IMG_PATH.."image/scene/Culture/13.png")
	setAnchPos(select_culture ,120,240)
	this.layer:addChild(select_culture )
	
	local select_culture = display.newSprite(IMG_PATH.."image/scene/Culture/21.png")
	setAnchPos(select_culture ,120,185)
	this.layer:addChild(select_culture )
	
	local point = {{85,240},{85,185}}
	for i,v in pairs(point) do
		--培养选项按钮
		local select_t = display.newSprite(IMG_PATH.."image/scene/Culture/17.png")
		setAnchPos(select_t ,v[1],v[2])
		this.layer:addChild(select_t )
	end
	--培养选项按钮
	local select_bt = display.newSprite(IMG_PATH.."image/scene/Culture/14.png")
	setAnchPos(select_bt ,85,240)
	this.layer:addChild(select_bt )

	local is_click = false
	local is_cultu = false
	local index_1 = 0
	local index_2 = 0
	local btn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require"GameLuaScript/Common/KNBtn"
	--[[点击培养前的按钮]]
	
	local cultu = nil
	local back = nil
	local save = nil
	local giveup
	local is_back = false
	--返回
	back = btn:new(IMG_PATH.."image/scene/Culture",{"4.png"},50,105,
	  		{

	  			front = IMG_PATH.."image/scene/Culture/25.png",
	  			--highLight = true,
	  			scale = true,
				callback=
	   			function()
					is_back = true
					cultu:showBtn(false)
					cultu:setEnable(false)
					back:showBtn(false)
					back:setEnable(false)
					save:showBtn(true)
					save:setEnable(true)
					giveup:showBtn(true)
					giveup:setEnable(true)
								
					--handle:unscheduleScriptEntry(entry)
					--if index_1 == 0 and is_click == false then
						switchScene("hero",{gid = hero_data})
					--end
	   			 end
	   	 })
	this.layer:addChild(back:getLayer(),1)
	--local label_new_font0 = nil
	local label_new_font_add0 = nil
	--local label_new_font1 = nil
	local label_new_font_add1 = nil
	--local label_new_font2 = nil
	local label_new_font_add2 = nil
	--local label_new_font3 = nil
	local label_new_font_add3 = nil
	local img_1 = nil
	local img_2 = nil
	local img_3 = nil
	local img_4 = nil
	-- 培养
	cultu = btn:new(IMG_PATH.."image/scene/Culture",{"4.png"},280,105,
	  		{

	  			front = IMG_PATH.."image/scene/Culture/28.png",
	  			--highLight = true,
	  			scale = true,
				callback=
	   			function()
					--if index_2 == 0 and is_click == false then
						local send_data = {
									type = index,
									id = hero_data
						}
						if is_back == false then
							HTTP:call("wash" , "wash",send_data,{success_callback = function()
									
									if index == 1 then  --消耗银两
										if shengyu ~= nil then
											this.layer:removeChild(shengyu,true)
											shengyu = display.strokeLabel(DATA_User:get_fame() , 360 , 553 , 20 , ccc3(255 , 251 , 212) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( shengyu )
										end
									elseif index == 2 then --消耗金币
										if mingqi ~= nil then
											this.layer:removeChild(mingqi,true)
											mingqi = display.strokeLabel(DATA_Account:get("gold") , 360 , 579 , 20 , ccc3(255 , 251 , 212) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( mingqi )
										end
									end
									
									is_click = true
									cultu:showBtn(false)
									cultu:setEnable(false)
									back:showBtn(false)
									back:setEnable(false)
									save:showBtn(true)
									save:setEnable(true)
									giveup:showBtn(true)
									giveup:setEnable(true)

									-- 新手引导
									if KNGuide:getStep() == 1103 then KNGuide:show( save:getLayer() , {remove = true} ) end

									--[[if label_new_font0 ~= nil then
										this.layer:removeChild(label_new_font0,true)
										label_new_font0 = display.strokeLabel(DATA_General:get(hero_data,init_pro[1]) , font_point[1][1],font_point[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
										this.layer:addChild(  label_new_font0 )
										
									else
										label_new_font0 = display.strokeLabel(DATA_General:get(hero_data,init_pro[1]) , font_point[1][1],font_point[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
										this.layer:addChild(  label_new_font0 )
									end
									]]
									
									local the_num = DATA_Wash:get_index(init_pro_a[1]) - DATA_General:get(hero_data,init_pro_a[1])
									
									if the_num > 0 then
										local the_data = the_num
										if the_data ~= 0 then the_data = "+"..the_data end
										if label_new_font_add0~= nil then
											this.layer:removeChild(label_new_font_add0,true)
											label_new_font_add0 = display.strokeLabel(the_data.." " , (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										else
											label_new_font_add0 = display.strokeLabel(the_data .." ", (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										end
										if the_num ~= 0 then
											if img_1 ~= nil then
												this.layer:removeChild(img_1,true)
												img_1 = draw_arrow(the_num ,(font_point[1][1]) + label_new_font_add0:getContentSize().width,font_point[1][2])
												this.layer:addChild(img_1)
											else
												img_1 = draw_arrow(the_num ,(font_point[1][1]) + label_new_font_add0:getContentSize().width,font_point[1][2])
												this.layer:addChild( img_1 )
											end
										end
									elseif the_num == 0 then
										if label_new_font_add0~= nil then
											this.layer:removeChild(label_new_font_add0,true)
											label_new_font_add0 = display.strokeLabel(the_num.." " , (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										else
											label_new_font_add0 = display.strokeLabel(the_num .." ", (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										end
									else
										if the_num > 0 then the_num = "+"..the_num end
										if label_new_font_add0~= nil then
											this.layer:removeChild(label_new_font_add0,true)
											
											label_new_font_add0 = display.strokeLabel(the_num .." " , (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										else
											label_new_font_add0 = display.strokeLabel(the_num .." ", (font_point[1][1]),font_point[1][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add0 )
										end
										if the_num  ~= 0 then
											if img_1 ~= nil then
												this.layer:removeChild(img_1,true)
												img_1 = draw_arrow(the_num ,(font_point[1][1]) + label_new_font_add0:getContentSize().width,font_point[1][2])
												this.layer:addChild( img_1 )
											else
												img_1 = draw_arrow(the_num,(font_point[1][1]) + label_new_font_add0:getContentSize().width,font_point[1][2])
												this.layer:addChild( img_1 )
											end
										end
									end
									
									local the_num = DATA_Wash:get_index(init_pro_a[2]) - DATA_General:get(hero_data,init_pro_a[2])
									if the_num > 0 then
										local the_data = the_num
										if the_data ~= 0 then the_data = "+"..the_data end
										if label_new_font_add1~= nil then
											this.layer:removeChild(label_new_font_add1,true)
											label_new_font_add1 = display.strokeLabel(the_data.." " , (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										else
											label_new_font_add1 = display.strokeLabel(the_data .." ", (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										end
										if the_num ~= 0 then
											if img_2 ~= nil then
												this.layer:removeChild(img_2,true)
												img_2 = draw_arrow(the_num ,(font_point[2][1]) + label_new_font_add1:getContentSize().width,font_point[2][2])
												this.layer:addChild(img_2)
											else
												img_2 = draw_arrow(the_num ,(font_point[2][1]) + label_new_font_add1:getContentSize().width,font_point[2][2])
												this.layer:addChild( img_2 )
											end
										end
									elseif the_num == 0 then
										if label_new_font_add1~= nil then
											this.layer:removeChild(label_new_font_add1,true)
											label_new_font_add1 = display.strokeLabel(the_num.." " , (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										else
											label_new_font_add1 = display.strokeLabel(the_num .." ", (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										end
									else
										if the_num > 0 then the_num = "+"..the_num end
										if label_new_font_add1~= nil then
											this.layer:removeChild(label_new_font_add1,true)
											
											label_new_font_add1 = display.strokeLabel(the_num .." " , (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										else
											label_new_font_add1 = display.strokeLabel(the_num .." ", (font_point[2][1]),font_point[2][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add1 )
										end
										if the_num  ~= 0 then
											if img_2 ~= nil then
												this.layer:removeChild(img_2,true)
												img_2 = draw_arrow(the_num ,(font_point[2][1]) + label_new_font_add1:getContentSize().width,font_point[2][2])
												this.layer:addChild( img_2 )
											else
												img_2 = draw_arrow(the_num,(font_point[2][1]) + label_new_font_add1:getContentSize().width,font_point[2][2])
												this.layer:addChild( img_2 )
											end
										end
									end
									
									local the_num = DATA_Wash:get_index(init_pro_a[3]) - DATA_General:get(hero_data,init_pro_a[3])
									
									if the_num > 0 then
										local the_data = the_num
										if the_data ~= 0 then the_data = "+"..the_data end
										if label_new_font_add2~= nil then
											this.layer:removeChild(label_new_font_add2,true)
											label_new_font_add2 = display.strokeLabel(the_data.." " , (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										else
											label_new_font_add2 = display.strokeLabel(the_data .." ", (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										end
										if the_num ~= 0 then
											if img_3 ~= nil then
												this.layer:removeChild(img_3,true)
												img_3 = draw_arrow(the_num ,(font_point[3][1]) + label_new_font_add2:getContentSize().width,font_point[3][2])
												this.layer:addChild(img_3)
											else
												img_3 = draw_arrow(the_num ,(font_point[3][1]) + label_new_font_add2:getContentSize().width,font_point[3][2])
												this.layer:addChild( img_3 )
											end
										end
									elseif the_num == 0 then
										if label_new_font_add2~= nil then
											this.layer:removeChild(label_new_font_add2,true)
											label_new_font_add2 = display.strokeLabel(the_num.." " , (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										else
											label_new_font_add2 = display.strokeLabel(the_num .." ", (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										end
									else
										if the_num > 0 then the_num = "+"..the_num end
										if label_new_font_add2~= nil then
											this.layer:removeChild(label_new_font_add2,true)
											
											label_new_font_add2 = display.strokeLabel(the_num .." " , (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										else
											label_new_font_add2 = display.strokeLabel(the_num .." ", (font_point[3][1]),font_point[3][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add2 )
										end
										if the_num  ~= 0 then
											if img_3 ~= nil then
												this.layer:removeChild(img_3,true)
												img_3 = draw_arrow(the_num ,(font_point[3][1]) + label_new_font_add2:getContentSize().width,font_point[3][2])
												this.layer:addChild( img_3 )
											else
												img_3 = draw_arrow(the_num,(font_point[3][1]) + label_new_font_add2:getContentSize().width,font_point[3][2])
												this.layer:addChild( img_3 )
											end
										end
									end
									
									
									local the_num = DATA_Wash:get_index(init_pro_a[4]) - DATA_General:get(hero_data,init_pro_a[4])
									
									if the_num > 0 then
										local the_data = the_num
										if the_data ~= 0 then the_data = "+"..the_data end
										if label_new_font_add3~= nil then
											this.layer:removeChild(label_new_font_add3,true)
											label_new_font_add3 = display.strokeLabel(the_data.." " , (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										else
											label_new_font_add3 = display.strokeLabel(the_data .." ", (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										end
										if the_num ~= 0 then
											if img_4 ~= nil then
												this.layer:removeChild(img_4,true)
												img_4 = draw_arrow(the_num ,(font_point[4][1]) + label_new_font_add3:getContentSize().width,font_point[4][2])
												this.layer:addChild(img_4)
											else
												img_4 = draw_arrow(the_num ,(font_point[4][1]) + label_new_font_add3:getContentSize().width,font_point[4][2])
												this.layer:addChild( img_4 )
											end
										end
									elseif the_num == 0 then
										if label_new_font_add3~= nil then
											this.layer:removeChild(label_new_font_add3,true)
											label_new_font_add3 = display.strokeLabel(the_num.." " , (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										else
											label_new_font_add3 = display.strokeLabel(the_num .." ", (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0xff , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										end
									else
										if the_num > 0 then the_num = "+"..the_num end
										if label_new_font_add3~= nil then
											this.layer:removeChild(label_new_font_add3,true)
											
											label_new_font_add3 = display.strokeLabel(the_num .." " , (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										else
											label_new_font_add3 = display.strokeLabel(the_num .." ", (font_point[4][1]),font_point[4][2] , 18 , ccc3( 0x6B , 0x8e , 0x23 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
											this.layer:addChild( label_new_font_add3 )
										end
										if the_num  ~= 0 then
											if img_4 ~= nil then
												this.layer:removeChild(img_4,true)
												img_4 = draw_arrow(the_num ,(font_point[4][1]) + label_new_font_add3:getContentSize().width,font_point[4][2])
												this.layer:addChild( img_4 )
											else
												img_4 = draw_arrow(the_num,(font_point[4][1]) + label_new_font_add3:getContentSize().width,font_point[4][2])
												this.layer:addChild( img_4 )
											end
										end
									end
									
							end })
						end
						
	   			end
	   	 })
	this.layer:addChild(cultu:getLayer(),1)
	
	
	--[[点击培养后切换为点击保存的按钮]]
	 save = btn:new(IMG_PATH.."image/scene/Culture",{"4.png"},50,105,
	  		{

	  			front = IMG_PATH.."image/scene/Culture/27.png",
	  			--highLight = true,
	  			scale = true,
				callback=
	   			function()
					local send_data = {
							type = index,
							id = hero_data
					}
					if is_back == false then
						HTTP:call("wash" , "save",send_data,{success_callback = function()
							--is_giveup = true
							cultu:showBtn(true)
							cultu:setEnable(true)
							back:showBtn(true)
							back:setEnable(true)
							save:showBtn(false)
							save:setEnable(false)
							giveup:showBtn(false)
							giveup:setEnable(false)
							if label_old_font ~= nil then
								this.layer:removeChild(label_old_font,true)
								label_old_font = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[1]) , font_point_old[1][1],font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font)
							else 
								label_old_font = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[1]) , font_point_old[1][1],font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font)
							end
							if label_old_font_add ~= nil then
								this.layer:removeChild(label_old_font_add,true)
								label_old_font_add = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[1]),DATA_User:get_percent()) , (label_old_font:getLabel():getContentSize().width+font_point_old[1][1]),font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add )
							else
								label_old_font_add = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[1]),DATA_User:get_percent()) , (label_old_font:getLabel():getContentSize().width+font_point_old[1][1]),font_point_old[1][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add )
							end
							
							if label_old_font1 ~= nil then
								this.layer:removeChild(label_old_font1,true)
								label_old_font1 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[2]) , font_point_old[2][1],font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font1)
							else 
								label_old_font1 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[2]) , font_point_old[2][1],font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font1)
							end
							if label_old_font_add1 ~= nil then
								this.layer:removeChild(label_old_font_add1,true)
								label_old_font_add1  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[2]),DATA_User:get_percent()) , (label_old_font1:getLabel():getContentSize().width+font_point_old[2][1]),font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add1 )
							else 
								label_old_font_add1  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[2]),DATA_User:get_percent()) , (label_old_font1:getLabel():getContentSize().width+font_point_old[2][1]),font_point_old[2][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add1 )
							end
							
							if label_old_font2 ~= nil then
								this.layer:removeChild(label_old_font2,true)
								label_old_font2 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[3]) , font_point_old[3][1],font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font2)
							else 
								label_old_font2 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[3]) , font_point_old[3][1],font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font2)
							end
							if label_old_font_add2 ~= nil then
								this.layer:removeChild(label_old_font_add2,true)
								label_old_font_add2  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[3]),DATA_User:get_percent()) , (label_old_font2:getLabel():getContentSize().width+font_point_old[3][1]),font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) 
								this.layer:addChild( label_old_font_add2 )
							else 	
								label_old_font_add2  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[3]),DATA_User:get_percent()) , (label_old_font2:getLabel():getContentSize().width+font_point_old[3][1]),font_point_old[3][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) ) 
								this.layer:addChild( label_old_font_add2 )
							end
							if label_old_font3 ~= nil then
								this.layer:removeChild(label_old_font3,true)
								label_old_font3 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[4]) , font_point_old[4][1],font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font3 )
							else 
								label_old_font3 = display.strokeLabel(DATA_General:get(hero_data,init_pro_a[4]) , font_point_old[4][1],font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild(  label_old_font3 )
							end
							if label_old_font_add3 ~= nil then
								this.layer:removeChild(label_old_font_add3,true)
								label_old_font_add3  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[4]),DATA_User:get_percent()) , (label_old_font3:getLabel():getContentSize().width+font_point_old[4][1]),font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add3 )
							else 
								label_old_font_add3  = display.strokeLabel("/"..get_data(DATA_General:get(hero_data,init_pro[4]),DATA_User:get_percent()) , (label_old_font3:getLabel():getContentSize().width+font_point_old[4][1]),font_point_old[4][2] , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
								this.layer:addChild( label_old_font_add3 )
							end
							
							--[[if label_new_font0 ~= nil then
								this.layer:removeChild(label_new_font0,true)
							end
							]]
							if label_new_font_add0~= nil then
								this.layer:removeChild(label_new_font_add0,true)
							end
							
							--[[if label_new_font1 ~= nil then
								this.layer:removeChild(label_new_font1,true)
							end]]
							if label_new_font_add1~= nil then
								this.layer:removeChild(label_new_font_add1,true)
							end
							
							--[[if label_new_font2 ~= nil then
								this.layer:removeChild(label_new_font2,true)
							end]]
							if label_new_font_add2 ~= nil then
								this.layer:removeChild(label_new_font_add2,true)
							end
							
							--[[if label_new_font3 ~= nil then
								this.layer:removeChild(label_new_font3,true)
							end]]
							if label_new_font_add3 ~= nil then
								this.layer:removeChild(label_new_font_add3,true)
							end
							
							if img_1 ~= nil then
								this.layer:removeChild(img_1,true)
							end
							
							if img_2 ~= nil then
								this.layer:removeChild(img_2,true)
							end
							
							if img_3 ~= nil then
								this.layer:removeChild(img_3,true)
							end
							
							if img_4 ~= nil then
								this.layer:removeChild(img_4,true)
							end
						end })
					end
					
	   				
	   			 end
	   	 })
	this.layer:addChild(save:getLayer(),1)
	save:showBtn(false)
	
	--放弃
	giveup = btn:new(IMG_PATH.."image/scene/Culture",{"4.png"},280,105,
	  		{

	  			front = IMG_PATH.."image/scene/Culture/26.png",
	  			--highLight = true,
	  			scale = true,
				callback=
	   			function()
					--is_giveup = true
					cultu:showBtn(true)
					cultu:setEnable(true)
					back:showBtn(true)
					back:setEnable(true)
					save:showBtn(false)
					save:setEnable(false)
					giveup:showBtn(false)
					giveup:setEnable(false)
					--[[if label_new_font0 ~= nil then
						this.layer:removeChild(label_new_font0,true)
					end]]
					if label_new_font_add0~= nil then
						this.layer:removeChild(label_new_font_add0,true)
					end
					
					--[[if label_new_font1 ~= nil then
						this.layer:removeChild(label_new_font1,true)
					end]]
					if label_new_font_add1~= nil then
						this.layer:removeChild(label_new_font_add1,true)
					end
					
					--[[if label_new_font2 ~= nil then
						this.layer:removeChild(label_new_font2,true)
					end]]
					if label_new_font_add2 ~= nil then
						this.layer:removeChild(label_new_font_add2,true)
					end
					
					--[[if label_new_font3 ~= nil then
						this.layer:removeChild(label_new_font3,true)
					end]]
					if label_new_font_add3 ~= nil then
						this.layer:removeChild(label_new_font_add3,true)
					end
					
					if img_1 ~= nil then
						this.layer:removeChild(img_1,true)
					end
							
					if img_2 ~= nil then
						this.layer:removeChild(img_2,true)
					end
							
					if img_3 ~= nil then
						this.layer:removeChild(img_3,true)
					end
							
					if img_4 ~= nil then
						this.layer:removeChild(img_4,true)
					end
					
	   			 end
	   	 })
	this.layer:addChild(giveup:getLayer(),1)
	giveup:showBtn(false)
	
	cultu:showBtn(true)
	cultu:setEnable(true)
	back:showBtn(true)
	back:setEnable(true)
	save:showBtn(false)
	save:setEnable(false)
	giveup:showBtn(false)
	giveup:setEnable(false)


	-- 新手引导
	if KNGuide:getStep() == 1102 then KNGuide:show( cultu:getLayer() ) end
					
	  local function onTouchBegan(x, y)
				for i , v in pairs(point) do
					if x>v[1] +(- 70) and x<v[1]+50 + (320) and y>v[2] + (-20) and y<v[2]+50 then
						setAnchPos(select_bt ,85,v[2])
						index = i
						break
					end
				end
            return true
        end

        local function onTouchMoved(x, y)

        end

        local function onTouchEnded(x, y)

        end

        local function onTouch(eventType, x, y)
            if eventType == CCTOUCHBEGAN then
                return onTouchBegan(x, y)
            elseif eventType == CCTOUCHMOVED then
                return onTouchMoved(x, y)
            else
                return onTouchEnded(x, y)
            end
        end

	function draw_arrow(num,img_x,img_y)
		local arrow_img = nil 
		if num < 0 then
			arrow_img = display.newSprite(IMG_PATH.."image/scene/Culture/16.png")
			setAnchPos(arrow_img ,400,img_y - 3)
			return arrow_img
			--this.layer:addChild(arrow_img)
		elseif num > 0 then
			arrow_img = display.newSprite(IMG_PATH.."image/scene/Culture/15.png")
			setAnchPos(arrow_img ,400,img_y - 3)
			return arrow_img
			--this.layer:addChild(arrow_img)
		end
	end
	
	this.layer:registerScriptTouchHandler(onTouch)
    this.layer:setTouchEnabled(true)
	
	
	local time_num = 0
	local time_num1 = 0
	function tick()
		if is_click == true and is_giveup == false then
			time_num = time_num +1
			if time_num > 3 then
				time_num = 0
				is_click = false
				
			end
		end
		if is_giveup == true and is_click == false then
			time_num1 = time_num1 +1
			if time_num1 > 3 then
				time_num1 = 0
				
			end
		end
	end
	
	entry = handle:scheduleScriptFunc(tick , 0.01 , false)
	return this
end

function get_data(temp1,temp2)
	local num,small_num = math.modf(temp1*temp2)
	if small_num >= 0.5 then
		num = num + 1
	end
	return num
end

function Culturelayer:getLayer()
	return self.layer
end

return Culturelayer
