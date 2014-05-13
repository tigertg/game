CHANNEL_ID = "windows"
CHANNEL_GROUP = "windows"
if UpdataRes:getInstance():get_type() ~= 0 then
	CHANNEL_ID = "tmsj"
	CHANNEL_GROUP = "tmsj"
end

print("# CHANNEL_ID                   = " .. CHANNEL_ID)
print("# CHANNEL_GROUP                = " .. CHANNEL_GROUP)
