--[[

文件初始化

]]

require("GameLuaScript/Config/channel")

local initCopyLayer = {
	layer,
	viewLayer,
	tipsLayer
}

-- 接口
local interface_java = UpdataRes:getInstance()		-- android
local platform_type = interface_java:get_type()
local interface_oc
if platform_type == 2 then 				-- ios
	interface_oc = UpdateDataOC:getInstance()
end


local uniq_files_name = "GameLuaScript/uniq"
local update_url = ""

function initCopyLayer:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	params = params or {}

	this.layer = CCLayer:create()

	local bg = CCSprite:create("image/scene/login/bg.jpg")
	INIT_FUNCTION.setAnchPos( bg , 0 , 0 )
	this.layer:addChild( bg )

	self:init()

	if IMG_PATH == "" then
		-- 直接进入游戏
		self:go()
	else
		-- 验证安装包是否一致
		this:checkUniq()
		-- this:checkUpdate()
	end


	return this
end


function initCopyLayer:getLayer()
	return self.layer
end


-- 验证安装包是否一致，不一致则删除文件
function initCopyLayer:checkUniq(params)
	if self.viewLayer then
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
	end

	-- App 本地文件
	local app_uniq = require(uniq_files_name)
	CCLuaLog("# App Uniq File: " .. (app_uniq or "nil") )

	-- SD 卡文件
	local cache_uniq = nil
	xpcall(function()
		local cache_uniq_content = INIT_FUNCTION.readfile(IMG_PATH .. uniq_files_name .. ".lua")
		if cache_uniq_content ~= nil then
			local _ , _ , temp = string.find(cache_uniq_content , "local uniq = \"([a-zA-Z0-9]+)\"")
			cache_uniq = temp
		end
	end , function() end)
	CCLuaLog("# Cache Uniq File: " .. (cache_uniq or "nil") )

	if app_uniq == nil then
		CCLuaLog("# APK is broken...")
	end

	local version_content = INIT_FUNCTION.readfile(IMG_PATH .. "GameLuaScript/Config/version.lua")

	-- 判断是否需要删缓存的文件(version文件不为空，并且uniq一致)
	if version_content ~= nil and app_uniq == cache_uniq then
		self:checkUpdate()
		return
	end

	if platform_type == 2 then
		-- IOS 不用删文件
		self:copyfiles()
		return
	end


	-- 需要删文件
	self.viewLayer = CCLayer:create()

	local loading_box = CCSprite:create("image/box.png")
	INIT_FUNCTION.setAnchPos( loading_box , INIT_FUNCTION.cx , 50 , 0.5 , 0 )
	self.viewLayer:addChild( loading_box )
	
	local loading = CCSprite:create("image/loading.png")
	INIT_FUNCTION.setAnchPos( loading , INIT_FUNCTION.cx - 120 , 102 , 0.5 , 0.5 )
	self.viewLayer:addChild( loading )

	local action = CCRepeatForever:create( CCRotateBy:create(0.5 , 180) )
	loading:runAction(action)

	local label = CCLabelTTF:create("正在删除老版本...\n可能需要30秒~1分钟" , "Thonburi" , 20)
	INIT_FUNCTION.setAnchPos( label , INIT_FUNCTION.cx - 65 , 75 )
	label:setHorizontalAlignment(0)
	label:setColor( ccc3( 0xff , 0xff , 0xff ) )
	self.viewLayer:addChild(label )

	-- 开始删除文件(需要过一定时间，让主进程可以渲染页面)
	local handle
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil

		-- 调用本地接口
		CCLuaLog("# Begin Delete Files...")
		interface_java:deleData(IMG_PATH , "true")
		CCLuaLog("# Finish Delete Files...")

		-- 删完以后，开始拷贝文件
		self:copyfiles()
	end , 0.01 , false)

	self.layer:addChild(self.viewLayer)
end


-- 拷贝文件到SD卡
function initCopyLayer:copyfiles(params)
	CCLuaLog("# Check Copy Files...")
	if self.viewLayer then
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
	end


	-- 需要拷贝文件
	self.viewLayer = CCLayer:create()

	local loading_box = CCSprite:create("image/box.png")
	INIT_FUNCTION.setAnchPos( loading_box , INIT_FUNCTION.cx , 50 , 0.5 , 0 )
	self.viewLayer:addChild( loading_box )
--	
--	local loading = CCSprite:create("image/loading.png")
--	INIT_FUNCTION.setAnchPos( loading , INIT_FUNCTION.cx - 120 , 102 , 0.5 , 0.5 )
--	self.viewLayer:addChild( loading )
--
--	local action = CCRepeatForever:create( CCRotateBy:create(0.5 , 180) )
--	loading:runAction(action)

	local label = CCLabelTTF:create("正在初始化资源,请稍候...可能需要1-2分钟" , "Thonburi" , 16)
	INIT_FUNCTION.setAnchPos( label , INIT_FUNCTION.cx , 75, 0.5 )
	label:setHorizontalAlignment(0)
	label:setColor( ccc3( 0xff , 0xff , 0xff ) )
	self.viewLayer:addChild(label )
	
	refreshCopy(0)
--
--	-- 开始部署文件(需要过一定时间，让主进程可以渲染页面)
	CCLuaLog("# Start Copy Files...")
	if platform_type == 1 then
		interface_java:copydata("" , IMG_PATH , function(_ , _)end)  
	elseif platform_type == 2 then
		interface_oc:copyAssets()
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			
			if interface_oc:get_copy() ~= 1 then
				return
			end
	
			CCLuaLog("# Finish Copy Files...")
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
	
			self:checkUpdate()
		end , 0.05 , false)
	end

	self.layer:addChild(self.viewLayer)



	--[[上报统计]]
	xpcall(function()
		local deviceinfo = nil
		if platform_type == 1 then 			-- android
			deviceinfo = interface_java:DeviceId() or "unknown"
		elseif platform_type == 2 then    -- ios
			deviceinfo = interface_oc:deviceId() or "unknown"
		end

		if deviceinfo ~= nil and type(deviceinfo) == "string" then
			require("GameLuaScript/Config/base")
			INIT_FUNCTION:httpPost(CONFIG_STAT_URL , {
				action = "active",
				info = deviceinfo,
				channel = CHANNEL_ID
			} , function(_ , _)end)
		end
	end , function() end)
end


-- 检查在线版本更新
function initCopyLayer:checkUpdate()
	CCLuaLog("# Check Update...")
	if self.viewLayer then
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
	end


	self.viewLayer = CCLayer:create()

	local loading_box = CCSprite:create("image/box.png")
	INIT_FUNCTION.setAnchPos( loading_box , INIT_FUNCTION.cx , 50 , 0.5 , 0 )
	self.viewLayer:addChild( loading_box )
	
	local loading = CCSprite:create("image/loading.png")
	INIT_FUNCTION.setAnchPos( loading , INIT_FUNCTION.cx - 120 , 102 , 0.5 , 0.5 )
	self.viewLayer:addChild( loading )

	local action = CCRepeatForever:create( CCRotateBy:create(0.5 , 180) )
	loading:runAction(action)

	local label = CCLabelTTF:create("正在检查新版本,请稍候..." , "Thonburi" , 20)
	INIT_FUNCTION.setAnchPos( label , INIT_FUNCTION.cx - 65 , 85 )
	label:setHorizontalAlignment(0)
	label:setColor( ccc3( 0xff , 0xff , 0xff ) )
	self.viewLayer:addChild(label )

	self.layer:addChild(self.viewLayer)


	-- 开始发包检查新版本
	local config_content = INIT_FUNCTION.readfile(IMG_PATH .. "GameLuaScript/Config/base.lua")
	if config_content ~= nil then
		local _ , _ , temp = string.find(config_content , "CONFIG_UPDATA_URL = \"([^\"]+)\"")
		update_url = temp
	end
	-- 如果没找到 SD 卡中的文件，则使用APP里原始的
	if not update_url or update_url == "" then
		CCLuaLog("# Cache Config is broken")
		require "GameLuaScript/Config/base"
		update_url = CONFIG_UPDATA_URL
	end
	
	local url = update_url .. "/versionup.php"
	CCLuaLog("# Update URL: " .. url)

	-- 获取当前版本号
	local version = ""
	local version_content = INIT_FUNCTION.readfile(IMG_PATH .. "GameLuaScript/Config/version.lua")
	if version_content ~= nil then
		local _ , _ , temp = string.find(version_content , 'VERSION = "(%d%d%.%d%d%.%d%d%.%d)"')
		version = temp
	end

	CCLuaLog("# Current Version: " .. (version or "nil"))

	if version == nil then
		CCLuaLog("# No Version Update")
		self:go()
		return
	end

	version = string.gsub(version , "%." , "")
	INIT_FUNCTION:httpPost(url , {channel = CHANNEL_ID , channel_group = CHANNEL_GROUP , version = version} , function(http_code , response)
		CCLuaLog("# Response back")

		if type(response) ~= "string" or response == "" then
			CCLuaLog("# Get Version Error.")
			response = "version=0"

			ERROR_CODE = -1
			ERROR_MSG = "网络异常，检查新版本失败"
		end

		local rows = INIT_FUNCTION.split(response , "\n")
		local version_data = INIT_FUNCTION.split(rows[1] , "=")
		if #version_data ~= 2 then
			CCLuaLog("# Get Version Error..")

			ERROR_CODE = http_code
			ERROR_MSG = "网络异常，检查新版本失败\n" .. response

			self:go()
			return
		end
		
		CCLuaLog("# New Version: " .. version_data[2])

		if version_data[2] == "0" then
			self:go()
			return
		end

		-- 显示升级界面
		self:newVersion(version_data[2] , rows)
	end)
end


function initCopyLayer:newVersion(new_version , rows)
	if self.viewLayer then
		self.viewLayer:removeFromParentAndCleanup(true)
		self.viewLayer = nil
	end

	self.viewLayer = CCLayer:create()

	local label = CCLabelTTF:create("发现新版本 " .. "V" .. new_version , "Thonburi" , 36)
	label:setColor(ccc3( 0x2c , 0x00 , 0x00 ))
	INIT_FUNCTION.setAnchPos(label , INIT_FUNCTION.cx , 180 , 0.5)
	self.viewLayer:addChild(label)
	
    local bg = CCSprite:create("image/scene/updata/bar_1.png")
    INIT_FUNCTION.setAnchPos(bg , 67 , 136 , 0 , 0.5)
    self.viewLayer:addChild(bg)

    local bg1 = CCSprite:create("image/scene/updata/bar_0.png")
	INIT_FUNCTION.setAnchPos(bg1 , 67 , 136 , 0 , 0.5)
	self.viewLayer:addChild(bg1)
	bg1:setTextureRect(CCRectMake(0,0,1,39))
	
	local updata_font_max = CCLabelTTF:create( "" , "Thonburi" , 20 )
	INIT_FUNCTION.setAnchPos(updata_font_max , 410 , 93 , 1 , 0)
	updata_font_max:setColor(ccc3( 0x2c , 0x00 , 0x00 ))
	self.viewLayer:addChild(updata_font_max)

	local update_filename = CCLabelTTF:create( "" , "Thonburi" , 20 )
	INIT_FUNCTION.setAnchPos(update_filename , 70 , 93)
	update_filename:setColor(ccc3( 0x2c , 0x00 , 0x00 ))
	self.viewLayer:addChild(update_filename)
	
	-- 按钮
	local btn_callback = nil
	local btn_bg = CCSprite:create("image/scene/updata/button.png")
	INIT_FUNCTION.setAnchPos(btn_bg , 167 , 45)
	self.viewLayer:addChild(btn_bg)
	local btn_rect = CCRectMake(btn_bg.x , btn_bg.y , btn_bg:getContentSize().width , btn_bg:getContentSize().height)

	local btn_grey_bg = CCSprite:create("image/scene/updata/button_grey.png")
	INIT_FUNCTION.setAnchPos(btn_grey_bg , 167 , 45)
	self.viewLayer:addChild(btn_grey_bg)
	btn_grey_bg:setVisible(false)
	
	local font_img = CCSprite:create("image/scene/updata/font.png")
	INIT_FUNCTION.setAnchPos(font_img , 180 , 42)
	self.viewLayer:addChild(font_img)

	self.layer:addChild(self.viewLayer)

	-- 按钮是否正在执行
	local btn_progress = false


	-- 计算总大小
	local filesize_max = 0
	for i = 2 , #rows do
		local temp = INIT_FUNCTION.split(rows[i] , "\t")
		if #temp >= 2 then
			filesize_max = filesize_max + tonumber(temp[2]) / 1024
		end
	end
	filesize_max = string.format("%.2f" , filesize_max)
	filesize_max = tonumber(filesize_max)
	updata_font_max:setString("0/" .. filesize_max .. "K")


	-- 更新进度条
	local filesize_cur = 0
	local function updateBar(cur)
		cur = string.format("%.2f" , cur)
		cur = tonumber(cur)

		if type(cur) ~= "number" then return end

		if cur >= filesize_max then
			cur = filesize_max
		end
		
		updata_font_max:setString(cur .. "/" .. filesize_max .. "K")
		
		local width = math.floor( cur * (346 / (filesize_max)) )
		if width > 346 then width = 346 end
		if width <= 0 then width = 1 end
		bg1:setTextureRect( CCRectMake(0 , 0 , width , 39) )
	end

	--[[ 更新文件 ]]
	local function updateOneFile(url , path , name , filesize , callback)
        if IMG_PATH == "" then
            print("哥,IMG_PATH不对,是空的")
            callback(0)
            return
        end

        local show_name = string.gsub(name , "%.lua" , "")
        update_filename:setString( show_name )

		INIT_FUNCTION:httpGet(url , function(http_code , response)
			-- 网络请求超时
			if http_code == -28 or type(response) ~= "string" or string.len(response) ~= tonumber(filesize) then
				if http_code == -28 then
					self:showTips("下载文件超时\n请点击按钮重试")
				else
					self:showTips("下载文件异常\n请点击按钮重试")
				end

				btn_grey_bg:setVisible(false)
				btn_bg:setVisible(true)
				btn_progress = false

				btn_callback = function()
					self:hideTips()

					-- 重新开始下载
					updateOneFile(url , path , name , filesize , callback)
				end

				return
			end

			-- 有一些特殊文件，不更新
			if name == "uniq.lua" or name == "channel.lua" then
				callback(0)
				return
			end

            local full_path = IMG_PATH .. path .. name

            local temp = INIT_FUNCTION.split(path , "/")
            local dir = ""
            for i = 1 , #temp do
                if temp[i] ~= "" then
                    dir = dir .. temp[i] .. "/"

                    local temp_fp = io.open(IMG_PATH .. dir , "r")
                    if temp_fp then
                        io.close(temp_fp)
                    else
                        if platform_type == 2 then
                              UpdateDataOC:getInstance():createDir(IMG_PATH .. dir)
                        else
                              os.execute("mkdir \"" .. IMG_PATH .. dir .. "\"")
                        end
                    end
                end
            end
        
            local fp = io.open(full_path , "w")
            if fp then
                fp:write(response)
                fp:close()
            end

			callback(http_code)
		end , {
			timeout = math.max( math.ceil(filesize / 1024) , 15),
			progress_callback = function(total , now)
				updateBar(filesize_cur + (now / 1024) )
			end
		})
	end

	--[[ 更新文件 ]]
	local function beginUpdateFile()
		local index = 2 	-- 从第二个文件开始
		local version_path
		local version_url
		local version_file_size

		local function go()
			if type(rows[index]) == "string" and rows[index] ~= "" then
				local url_data = INIT_FUNCTION.split(rows[index] , "\t")

				if #url_data < 2 then
					return false
				end

				local full_url = url_data[1]
				local temp = INIT_FUNCTION.split(full_url , '/')
				local path = ""
				local name = temp[#temp]
				for i = 4 , #temp - 1 do
					path = path .. temp[i] .. "/"
				end


				if name == "version.lua" then
					version_path = path
					version_url = full_url
					version_file_size = url_data[2]

					-- 继续执行下一个
					index = index + 1
					go()
					return true
				end

				updateOneFile(update_url .. "/" .. full_url , path , name , url_data[2] , function(http_code)
					if http_code ~= 0 then
						return
					end

					-- 更新界面
					filesize_cur = filesize_cur + url_data[2] / 1024
					updateBar(filesize_cur)

					-- 继续执行下一个
					index = index + 1
					go()
				end)
			else
				-- 开始更新版本号
				if version_path and version_url and version_file_size then
					updateOneFile(update_url .. "/" .. version_url , version_path , "version.lua" , version_file_size , function(http_code)
						self.go()
					end)
				end
			end
		end

		-- 开始
		go()
	end
	
	


	-- 按钮点击事件
	btn_callback = function()
		beginUpdateFile()
	end
	
	local function onTouch(eventType , x , y)
		if eventType == CCTOUCHBEGAN then
			if btn_progress == false then
				if btn_rect:containsPoint( ccp(x , y) ) then
					btn_progress = true
					btn_grey_bg:setVisible(true)
					btn_bg:setVisible(false)

					btn_callback()
				end
			end
			return true
		end
		return true
	end
	self.viewLayer:registerScriptTouchHandler(onTouch)
    self.viewLayer:setTouchEnabled(true)
end


-- 进入主界面
function initCopyLayer:go()
	CCLuaLog("# All is ok")

	local handle
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil

		requires(IMG_PATH , "GameLuaScript/GameCanvasLua")
	end , 0.01 , false)
	
end



-- 初始化
function initCopyLayer:init()
	--[[	
	if CHANNEL_ID == "uc" then
		UCGameSDK:getInstance():setLogLevel(2)
		UCGameSDK:getInstance():setOrientation(0)
		UCGameSDK:getInstance():initSDK(false , 2 , 27820 , 518084 , 2126 , "安卓大话水浒" , true , true)
	end
	]]
end


-- show tips
function initCopyLayer:showTips(msg)
	if self.tipsLayer then
		self.tipsLayer:removeFromParentAndCleanup(true)
		self.tipsLayer = nil
	end

	self.tipsLayer = CCSprite:create("image/common/prompt_bg.png")
	INIT_FUNCTION.setAnchPos(self.tipsLayer , INIT_FUNCTION.cx , INIT_FUNCTION.cy , 0.5)

	local textField = CCLabelTTF:create(msg , "Thonburi" , 20)
	textField:setColor(ccc3( 0xff , 0xff , 0xff ))
	textField:setAnchorPoint( ccp( 0 , 1 ) )

	if textField:getContentSize().width > 360 then
		textField:setDimensions(CCSize:new( 360 , 70 ))
		textField:setPosition( ccp( ( self.tipsLayer:getContentSize().width - textField:getContentSize().width ) / 2 , self.tipsLayer:getContentSize().height / 1.5 + 10 ) )
	else
		textField:setPosition( ccp( ( self.tipsLayer:getContentSize().width - textField:getContentSize().width ) / 2 , self.tipsLayer:getContentSize().height / 1.5 - 8 ) )
	end

	self.tipsLayer:addChild(textField)

	self.viewLayer:addChild(self.tipsLayer)
end

function initCopyLayer:hideTips()
	if self.tipsLayer then
		self.tipsLayer:removeFromParentAndCleanup(true)
		self.tipsLayer = nil
	end
end

return initCopyLayer
