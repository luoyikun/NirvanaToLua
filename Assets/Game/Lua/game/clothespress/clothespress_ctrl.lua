require("game/clothespress/clothespress_view")
require("game/clothespress/clothespress_data")
require("game/clothespress/suit_attr_tip_view")
require("game/clothespress/clotherpress_suit_attr_view")
require("game/clothespress/clotherpress_suit_tips_view")

ClothespressCtrl = ClothespressCtrl or BaseClass(BaseController)

function ClothespressCtrl:__init()
	if ClothespressCtrl.Instance ~= nil then
		ErrorLog("[ClothespressCtrl] attempt to create singleton twice!")
		return
	end
	ClothespressCtrl.Instance = self

	self.data = ClothespressData.New()
	self.view = ClothespressView.New(ViewName.ClothespressView)
	-- self.suit_attr_tip_view = SuitAttrTipView.New(ViewName.SuitAttrTipView) -- 以前界面
	self.suit_attr_tip_view = ClothespressSuitAttrView.New(ViewName.SuitAttrTipView)
	self.suit_suit_model_tips_view = ClotherpressTipsModleView.New(ViewName.SuitModelTipView)

	self:RegisterAllProtocols()

end

function ClothespressCtrl:__delete()
	ClothespressCtrl.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.suit_attr_tip_view ~= nil then
		self.suit_attr_tip_view:DeleteMe()
		self.suit_attr_tip_view = nil
	end	

	if self.suit_suit_model_tips_view ~= nil then
		self.suit_suit_model_tips_view:DeleteMe()
		self.suit_suit_model_tips_view = nil
	end
end

-- 协议注册
function ClothespressCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSDressingRoomOpera)
	self:RegisterProtocol(CSDressingRoomExchange)
	self:RegisterProtocol(SCDressingRoomInfo, "OnSCDressingRoomInfo")
	self:RegisterProtocol(SCDressingRoomSingleInfo, "OnSCDressingRoomSingleInfo")
end

function ClothespressCtrl:SendDressingRoomOpera()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDressingRoomOpera)
	send_protocol.opera_type = opera_type
	send_protocol:EncodeAndSend()
end

function ClothespressCtrl:SendDressingRoomExchangeOpera(suit_index, sub_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDressingRoomExchange)
	send_protocol.suit_index = suit_index or -1
	send_protocol.sub_index = sub_index or -1
	send_protocol:EncodeAndSend()
end

function ClothespressCtrl:OnSCDressingRoomInfo(protocol)
	self.data:SetAllSuitInfo(protocol)
	self:FlushClothespressView()
end

function ClothespressCtrl:OnSCDressingRoomSingleInfo(protocol)
	self.data:SetSingleSuitInfo(protocol)
	self:FlushClothespressView()
end

function ClothespressCtrl:FlushClothespressView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end

function ClothespressCtrl:ShowSuitAttrTipView(data_index)
	if self.suit_attr_tip_view and not self.suit_attr_tip_view:IsOpen()then 
		self.suit_attr_tip_view:SetData(data_index)
	end
end

function ClothespressCtrl:SetCloseCallBack(data, from_view, param_t, close_call_back)
	if self.suit_suit_model_tips_view then
		self.suit_suit_model_tips_view:SetCloseCallBack(data, from_view, param_t, close_call_back)
	end
end