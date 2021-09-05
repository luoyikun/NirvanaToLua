require("game/player/luoshu/luoshu_data")
require("game/player/luoshu/luoshu_tip")

LuoShuCtrl = LuoShuCtrl or BaseClass(BaseController)

function LuoShuCtrl:__init()
	if LuoShuCtrl.Instance then
		print_error("[LuoShuCtrl] 尝试创建第二个单例模式")
		return
	end
	LuoShuCtrl.Instance = self

	self.data = LuoShuData.New()
	self.tipluoshuview = TipLuoShu.New(ViewName.TipLuoShu)

	self.heshenluoshu_item_view = LuoShuItemView.New()

	self:RegisterAllProtocols()
end

function LuoShuCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	LuoShuCtrl.Instance = nil
	if self.heshenluoshu_item_view then
		self.heshenluoshu_item_view:DeleteMe()
		self.heshenluoshu_item_view = nil
	end
	
	if self.tipluoshuview then
		self.tipluoshuview:DeleteMe()
		self.tipluoshuview = nil
	end
end

function LuoShuCtrl:RegisterAllProtocols()
	--河神洛书
	self:RegisterProtocol(SCHeShenLuoShuAllInfo, "OnSCHeShenLuoShuAllInfo")
	self:RegisterProtocol(SCHeShenLuoShuChangeInfo, "OnSCHeShenLuoShuChangeInfo")

	self:RegisterProtocol(CSHeShenLuoShuReq)
end

-----------河神洛书--------------
function LuoShuCtrl:OnSCHeShenLuoShuAllInfo(protocol)
	self.data:SetHeShenLuoShuAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.HeSheLuoShu)
	RemindManager.Instance:Fire(RemindName.LuoShu)
	RemindManager.Instance:Fire(RemindName.ShenHua)
	PlayerCtrl.Instance:FlushPlayerView("luoshu")
end

function LuoShuCtrl:OnSCHeShenLuoShuChangeInfo(protocol)
	self.data:SetHeShenLuoShuChangeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.HeSheLuoShu)
	RemindManager.Instance:Fire(RemindName.LuoShu)
	RemindManager.Instance:Fire(RemindName.ShenHua)
	PlayerCtrl.Instance:FlushPlayerView("luoshu")
	PlayerCtrl.Instance:FlushPlayerView("luoshu_view")
	self:FlushHeShenLuoShuItemView()
end

function LuoShuCtrl:FlushHeShenLuoShuItemView()
	self.tipluoshuview:Flush()
	self.heshenluoshu_item_view:Flush()
end

function LuoShuCtrl:SendHeShenLuoShuReq(opera_type, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeShenLuoShuReq)
	protocol.opera_type = opera_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

function LuoShuCtrl:OpenUpgradeView(select_info)
	self.tipluoshuview:SetSelectInfo(select_info)
	self.tipluoshuview:Open()
end




