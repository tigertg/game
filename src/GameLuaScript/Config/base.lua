local config_type = ""

if UpdataRes:getInstance():get_type() == 0 and config_type ~= "" then
	requires(IMG_PATH , "GameLuaScript/Config/test_configs/" .. config_type)
else


-- 固定不变的host
CONFIG_LOGIN_HOST = "http://gamelogin.szkuniu.com"
CONFIG_UPDATA_URL = "http://gameupdate.szkuniu.com"
CONFIG_SERVICE_URL = "http://gameservice.szkuniu.com/service.php"
CONFIG_STAT_URL = "http://gamestat.szkuniu.com/stat.php"

-- 可能会被覆盖的
CONFIG_PAY_URL = "http://gamepay.szkuniu.com/pay.php"

end