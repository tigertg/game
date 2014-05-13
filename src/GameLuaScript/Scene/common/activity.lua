-- 设置界面
local PATH = IMG_PATH .. "image/scene/activity/"
local COMMONPATH = IMG_PATH .. "image/common/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")


local M = {

}


function M:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	this.content = display.newLayer()
	this.propLayer = display.newLayer()
	this.text = {}
	this.award = {}
	this.completeFlag = {} --任务完成标记
	this.isComplete = false --是否完成当天任务
	this.curIndex = 1
	this.data = {}
	this.getGift = nil	--领取按钮
	this.tip = "" 	--提示信息
	this.isGetOver = false --是否已经领取
	
	
	-- 背景
	local bg = display.newSprite(COMMONPATH .."bg.png")
	setAnchPos(bg , 13 , 200)
	this.content:addChild(bg)
	-- 背景框
	local bg = display.newSprite(PATH .."bg_frame.png")
	setAnchPos(bg , 36 , 260)
	this.content:addChild(bg)

	local list_title_bg = display.newSprite(COMMONPATH .. "list_title.png")
	setAnchPos(list_title_bg , 25 , 633)
	this.content:addChild(list_title_bg)

	local title = display.newSprite(PATH .. "activity_title.png")
	setAnchPos(title , 170 , 633)
	this.content:addChild(title)
	
	local closeBtn = KNBtn:new(COMMONPATH, { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"} ,  display.cx + 27 , 218 , {
	scale = true,
	priority = -130,
	front = COMMONPATH .. "colse_text.png" , 
	callback = function()
		this.layer:removeFromParentAndCleanup( true )
	end
	}):getLayer()
	this.content:addChild(closeBtn)

	--完成任务标题
	local completeTitle = display.newSprite(PATH .. "complete_title.png")
	setAnchPos(completeTitle , 52 , 553 - 30 )
	this.content:addChild(completeTitle)
	
	--可领取标题
	local rewardTitle = display.newSprite(SCENECOMMON .. "prop_bg.png")
	setAnchPos(rewardTitle , display.cx , 553 - 250 - 16 , 0.5)
	this.content:addChild(rewardTitle)
	
	--可领取标题
	local rewardTitle = display.newSprite(PATH .. "reward_title.png")
	setAnchPos(rewardTitle , 52 , 553 - 190 )
	this.content:addChild(rewardTitle)
	
	
	for i = 1 , 5 do
		this.text[i] = display.strokeLabel( "" , 70, 510 - i * 25 , 18, ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 360 , dimensions_height = 30 , align = 0 } )
		this.content:addChild( this.text[i] )
		this.completeFlag[i] = display.newSprite( PATH .. "complete_flag.png")
		setAnchPos( this.completeFlag[i] , 48, 526 - i * 25 )
		this.content:addChild( this.completeFlag[i] )
	end
	
	--截止时间
	this.deadline = display.strokeLabel( "" , 227, 272 , 16, ccc3( 0x2c , 0x00 , 0x00 )  )
	this.content:addChild( this.deadline )
	
	--价值  人民币
	local cost = display.strokeLabel( "价值       人民币" , 70, 272 , 16, ccc3( 0x2c , 0x00 , 0x00 )  )
	this.content:addChild( cost )
	
	
	




	
	
	
	local temp
	this.group = KNRadioGroup:new()
	for i = 1, 3 do
		temp = KNBtn:new(COMMONPATH.."tab/",{"tab_normal.png","tab_select.png"} , 67 + 105 *( i - 1 ) , 537 + 42 ,{
			disableWhenChoose = true,
			upSelect = true,
			id = i,
			priority = -130,
			front = {PATH .. "day".. i .. ".png",PATH .. "day".. i .. "_normal.png"},
			callback=
			function()
				this.curIndex = i
				this:createPage( this.curIndex )
			end
		},this.group)
		this.content:addChild(temp:getLayer())
	end
	this:createPage( this.curIndex )

	-- 遮罩
	this.baseLayer:addChild( this.content )
	local mask = KNMask:new({item = this.baseLayer })
	this.layer:addChild( mask:getLayer() )

	
    return this
end

--生成页面奖励信息
function M:createPage( dayIndex )
	self.data = DATA_Olgift:get("achievegift")
	
	--截止时间
	if self.data.deadline then
		self.deadline:setString( "截止日期:" .. self.data.deadline )
	end
	
	--文字设置
	local condition = self.data.conf[dayIndex .. ""].condition	
	self.isComplete = true --是否完成当天任务
	for i = 1 , #self.text do
		if i <= #condition then
			local completeState = "  (".. condition[i].cur .. "/" .. condition[i].max ..")"
			self.text[i]:setString( i .. ":" .. condition[i].str .. completeState)
			if condition[i].cur >= condition[i].max then
				self.text[i]:setColor( ccc3( 0xef , 0x00 , 0x00 ) )
				self.completeFlag[i]:setVisible( true )
			else
				self.text[i]:setColor( ccc3( 0x2c , 0x00 , 0x00 ) )
				self.completeFlag[i]:setVisible( false )
				self.isComplete = false 
			end
		else
			self.text[i]:setString( "" )
			self.completeFlag[i]:setVisible( false )
		end
	end
	
	
	
	
	--奖励布局
	if self.propLayer then
		self.propLayer:removeFromParentAndCleanup( true )
		self.propLayer = display.newLayer()
		self.content:addChild( self.propLayer )
	end
	
	self.award = {}
	local awardData = self.data.conf[dayIndex .. ""].award	
	--正常道具布局
	local conut = 1
	for key , v in pairs(awardData)  do
		if v.type == "prop" then
			local iconPath = getImageByType(v.cid , "s")
			local equipBtn = KNBtn:new( SCENECOMMON , 
										{ "skill_frame1.png" } ,
										 conut * 83 - 10  ,
										 297 , 
										 { 
										 	priority = -130,
										 	scale = true ,
										 	front = iconPath , 
										 	other = { COMMONPATH .. "egg_num_bg.png" , 52 , 0 } , 
										 	text = {v.num , 16 , ccc3( 0xff , 0xff , 0xff ) , { x = 30 , y = -21 } , nil , 17 } ,
										 	callback =
										 		 function()
										 		 	--当点击图标按钮后先从全局数据中查找是否存在数据，若没有则请求网络，否则隐藏用户信息栏，显示详细界面
													local detail_type = getCidType(v["cid"])
													local data = getConfig( detail_type , v["cid"] )
													data["cid"] = v["cid"]

													pushScene("detail" , {
														detail = detail_type,
														data = data,
													})
										 		 end
										 })
			self.propLayer:addChild( equipBtn:getLayer() )
			self.award[ #self.award + 1 ] = equipBtn
			conut = conut + 1 
		end
		
	end
	conut = 0
	--银两金币布局
	local propNum = #self.award
	for i = 1 , #awardData do
		if awardData[i].type == "silver" or awardData[i].type == "gold" then
			local tempSp = display.newSprite( COMMONPATH .. awardData[i].type .. ".png" )
			local numText = display.strokeLabel( awardData[i].num , 30 , 5 , 16, ccc3( 0x2c , 0x00 , 0x00 ) )
			tempSp:addChild( numText )
			setAnchPos( tempSp , propNum * 83 + 70 , 300 + conut * 30 )
			self.propLayer:addChild( tempSp  )
			self.award[#self.award + 1 ] = tempSp
			conut = conut + 1
		end
	end
	
	local costSp = display.newSprite(PATH .."day_num" .. self.curIndex .. ".png" )
	setAnchPos( costSp , 100 , 271 )
	self.propLayer:addChild( costSp )
	--生成领取按钮
	self:createGetBtn()
end

--创建领取按钮
function M:createGetBtn()
	if self.getGift then
		self.getGift:getLayer():removeFromParentAndCleanup( true )
	end
	self.tip = "" --清空提示信息
	
	if not self.isComplete then
		self.tip = "未达到领取条件，不可领取!"
	end
	
	if  self.data.reg_pass_day > self.data.available_day then	--注册天数大于 最大领取期限则不可以领取
		self.tip = "礼包已经过期!"
	end
	
	self.isGetOver = false	--是否已经领取
	for i = 1 , #self.data.received do
		if self.data.received[i] == self.curIndex then
			self.isGetOver = true
			self.tip = "奖励已经领取！"
			break
		end
	end

	
	local isEnable =  self.tip == "" and true or false	--是否灰显按钮
	
	self.getGift = KNBtn:new( COMMONPATH , 
		isEnable and { "btn_bg_red.png" ,"btn_bg_red_pre.png"} or { "btn_bg_red2.png" } , 
		63 , 
		218 ,
		{
			priority = -130,
			scale = true,
			front = COMMONPATH .. ( isEnable and "get.png" or ( self.isGetOver and "get_over.png" or "get_grey.png" ) ) ,
			callback = 
			function()
				if isEnable and not self.isGetOver then
					HTTP:call("achievegift", "receive", { index = self.curIndex },{success_callback = 
					function()
						self:createPage( self.curIndex )
					end})
				else
					KNMsg.getInstance():flashShow( self.tip )
				end
			end
		})
	
	self.content:addChild( self.getGift:getLayer() )
end

function M:getLayer()
	return self.layer
end


return M