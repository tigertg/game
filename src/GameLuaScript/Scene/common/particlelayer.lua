local ParticleLayer = {
	layer,
	rate = 500, --发射频率
	list = {}
}

function ParticleLayer:new()
	local this = {}
	setmetatable(this,self)
	self.__index = self

	this.layer = display.newLayer()
	local path = IMG_PATH.."image/common/particle.plist";
	if  io.exists(path) then
    else
        local array = string.split(path, "/")
        local str = ""
        for i = 5 ,table.getn(array) do
            if i == table.getn(array) then
               str = str ..array[i]
            else
       	       str = str ..array[i].."/"
             end
        end
         path = str
    end
    echo("---------------------------------",path)
	local emmit = CCParticleSystemQuad:create(path)
	

	emmit:setEmissionRate(0)
	this.layer:addChild(emmit)


	this.layer:setTouchEnabled(true)
	this.layer:registerScriptTouchHandler(
		function(type,x,y)
			if type == CCTOUCHBEGAN then
				emmit:setPosition(ccp(x,y))
				emmit:setEmissionRate(this.rate)
			elseif type == CCTOUCHMOVED then
				emmit:setPosition(ccp(x,y))
			else
				emmit:setEmissionRate(0);
			end
			return true
		end)
	return this
end

function ParticleLayer:getLayer()
	return self.layer
end
return ParticleLayer
