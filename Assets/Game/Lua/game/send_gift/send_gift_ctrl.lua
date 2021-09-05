require("game/send_gift/send_gift_data")
require("game/send_gift/send_gift_view")
require("game/send_gift/send_gift_select_view")

-- 社交
-- 我曾经悄悄来过，努力过，也迟到过，被赞过，也被骂过，现在悄悄走了。
SendGiftCtrl = SendGiftCtrl or BaseClass(BaseController)
function SendGiftCtrl:__init()
	if SendGiftCtrl.Instance then
		print_error("[SendGiftCtrl] Attemp to create a singleton twice !")
	end
	SendGiftCtrl.Instance = self

	self.send_gift_data = SendGiftData.New()
	self.send_gift_view = SendGiftView.New(ViewName.SendGiftView)
	self.send_gift_select_view = SendGiftSelectView.New(ViewName.SendGiftSelectView)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function SendGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSGiveItemReq)
	self:RegisterProtocol(CSGiveItemOpera)
	self:RegisterProtocol(SCGiveItemRecord, "OnSCGiveItemRecord")		-- 记录
end

function SendGiftCtrl:MainuiOpen()
	SendGiftCtrl.Instance:SendGiveItemOpera(GIVE_ITEM_OPERA_TYPE.GIVE_ITEM_OPERA_TYPE_INFO, 0)
	SendGiftCtrl.Instance:SendGiveItemOpera(GIVE_ITEM_OPERA_TYPE.GIVE_ITEM_OPERA_TYPE_INFO, 1)
end

function SendGiftCtrl:SendGiveItemOpera(opera_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGiveItemOpera)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param1 or 0
	protocol:EncodeAndSend()
end

function SendGiftCtrl:OnSCGiveItemRecord(protocol)
	self.send_gift_data:SetGiveItemRecord(protocol)
	if self.send_gift_view then
		self.send_gift_view:Flush("record")
	end
end

function SendGiftCtrl:SendCSGiveItemReq(target_uid, item_count, send_cell_list_data)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGiveItemReq)
	send_protocol.target_uid = target_uid or 0
	send_protocol.item_count = item_count or 0
	send_protocol.send_cell_list_data = send_cell_list_data or {}
	send_protocol:EncodeAndSend()
end

function SendGiftCtrl:__delete()
	SendGiftCtrl.Instance = nil

	if self.send_gift_view then
		self.send_gift_view:DeleteMe()
		self.send_gift_view = nil
	end

	if self.send_gift_data then
		self.send_gift_data:DeleteMe()
		self.send_gift_data = nil
	end

	if self.send_gift_select_view then
		self.send_gift_select_view:DeleteMe()
		self.send_gift_select_view = nil
	end	
end

function SendGiftCtrl:SetSelectViewData(data)
	if self.send_gift_select_view then
		self.send_gift_select_view:SetSelectViewData(data)
	end
end

function SendGiftCtrl:InsertSendCellData(data)
	if self.send_gift_view and self.send_gift_view:GetSendGiftZengSongView() then
		self.send_gift_view:GetSendGiftZengSongView():InsertSendCellData(data)
	end
end

function SendGiftCtrl:CheckIsGray(in_bag_index, item_id)
	if self.send_gift_view and self.send_gift_view:GetSendGiftZengSongView() then
		return self.send_gift_view:GetSendGiftZengSongView():CheckIsGray(in_bag_index, item_id)
	end
end

function SendGiftCtrl:GetSendCellListDataLength()
	if self.send_gift_view and self.send_gift_view:GetSendGiftZengSongView() then
		return self.send_gift_view:GetSendGiftZengSongView():GetSendCellListDataLength()
	end
end

function SendGiftCtrl:SetIsFromRecordView(flag)
	if self.send_gift_view and self.send_gift_view:GetSendGiftZengSongView() then
		self.send_gift_view:GetSendGiftZengSongView():SetIsFromRecordView(flag)
	end
end