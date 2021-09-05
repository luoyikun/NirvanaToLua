require("game/couple_home/couple_home_shop/couple_home_shop_data")

CoupleHomeShopCtrl = CoupleHomeShopCtrl or BaseClass(BaseController)

function CoupleHomeShopCtrl:__init()
	if CoupleHomeShopCtrl.Instance ~= nil then
		print_error("[CoupleHomeShopCtrl] attempt to create singleton twice!")
		return
	end

	CoupleHomeShopCtrl.Instance = self

	-- self:RegisterAllProtocols()

	self.data = CoupleHomeShopData.New()
end

function CoupleHomeShopCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	CoupleHomeShopCtrl.Instance = nil
end

-- 协议注册
function CoupleHomeShopCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(CSHiddenCoupleHome)
end

-- function CoupleHomeShopCtrl:SendHiddenCoupleHome(app_type, is_hidden)
-- 	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHiddenCoupleHome)
-- 	send_protocol:EncodeAndSend()
-- end