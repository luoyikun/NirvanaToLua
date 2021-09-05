require("game/suit_collection/suit_collection_data")
require("game/suit_collection/suit_collection_view")
require("game/suit_collection/suit_collect_bag_view")

SuitCollectionCtrl = SuitCollectionCtrl or BaseClass(BaseController)

function SuitCollectionCtrl:__init()
	if nil ~= SuitCollectionCtrl.Instance then
		print_error("[SuitCollectionCtrl] attempt to create singleton twice!")
		return
	end
	SuitCollectionCtrl.Instance = self


	self.data = SuitCollectionData.New()
	self.view = SuitCollectionView.New(ViewName.SuitCollection)
	self.suit_bag_view = SuitCollectBagView.New(ViewName.SuitCollecBag)

	self:RegisterAllProtocols()
end

function SuitCollectionCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	SuitCollectionCtrl.Instance = nil
end

function SuitCollectionCtrl:RegisterAllProtocols()
	-- 橙装
	self:RegisterProtocol(SCOrangeEquipCollect,"OnSCOrangeEquipCollect")
	self:RegisterProtocol(SCOrangeEquipCollectOther,"OnSCOrangeEquipCollectOther")
	-- 红装
	self:RegisterProtocol(SCRedEquipCollect,"OnSCRedEquipCollect")
	self:RegisterProtocol(SCRedEquipCollectOther,"OnSCRedEquipCollectOther")
end


function SuitCollectionCtrl:SendReqCommonOpreate(operate_type, param1, param2, param3, param4)
	-- print_error(operate_type, param1, param2, param3, param4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	protocol.operate_type = operate_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol.param4 = param4 or 0
	protocol:EncodeAndSend()
end

-------------------------
-- 橙装
function SuitCollectionCtrl:OnSCOrangeEquipCollect(protocol)
	-- print_error(protocol)
	self.data:SetOrangeEquipCollect(protocol)
	self.view:Flush("orange_equip")

end

function SuitCollectionCtrl:OnSCOrangeEquipCollectOther(protocol)
	-- print_error("====protocol",protocol)
	self.data:SetOrangeEquipCollectOther(protocol)

	RemindManager.Instance:Fire(RemindName.OrangeSuitCollection)
end

-------------------------
--红装
function SuitCollectionCtrl:OnSCRedEquipCollect(protocol)
	-- print_error(protocol)
	self.data:SetRedEquipCollect(protocol)
	self.view:Flush("red_equip")

end

function SuitCollectionCtrl:OnSCRedEquipCollectOther(protocol)
	-- print_error("====protocol",protocol)
	self.data:SetRedEquipCollectOther(protocol)
	if ViewManager.Instance:IsOpen(ViewName.SuitCollecBag) then
		self.suit_bag_view:Flush()
	end
	
	RemindManager.Instance:Fire(RemindName.RedSuitCollection)
end

function SuitCollectionCtrl:OpenSuitEquipView(data)
	if self.suit_bag_view then
		self.suit_bag_view:SetEquipData(data)
	end
end