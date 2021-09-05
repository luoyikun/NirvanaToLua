
require("game/tianshu/tianshu_data")
require("game/tianshu/tianshu_view")
require("game/tianshu/tianshuskill_finish_view")

TianShuCtrl = TianShuCtrl or BaseClass(BaseController)

function TianShuCtrl:__init()
	if nil ~= TianShuCtrl.Instance then
		print("[TianShuCtrl] attempt to create singleton twice!")
		return
	end
	TianShuCtrl.Instance = self
	self.data = TianShuData.New()
	self.view = TianShuView.New(ViewName.TianShuView)
	self.tip_finish_view = TianShuSkillFinishView.New()
	self:RegisterAllProtocols()
	self.open_day_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.FlushTianShuView, self))
end

function TianShuCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.tip_finish_view then
		self.tip_finish_view :DeleteMe()
		self.tip_finish_view  = nil
	end
	
	if self.open_day_event then
		GlobalEventSystem:UnBind(self.open_day_event)
		self.open_day_event = nil
	end
	TianShuCtrl.Instance = nil
end

function TianShuCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTianShuXZInfo,"OnTianShuXZInfo")
end

-- 打开主窗口
function TianShuCtrl:Open()
	self.view:Open()
end

function TianShuCtrl:OnTianShuXZInfo(protocol)
	self.data:SetTianshuXunzhuInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.TianShu)
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "tianshuview")
end

function TianShuCtrl:CloseView()
	self.view:Close()
end

function TianShuCtrl:SendTianShuFetchReward(type, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTianShuXZFetchReward)
	protocol.type = CS_TIANSHUXZ_SEQ_TYPE.CS_TIANSHUXZ_SEQ_TYPE_FETCH
	protocol.tianshu_type = type
	protocol.seq = seq
	protocol:EncodeAndSend()
end

function TianShuCtrl:SendTianShuInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTianShuXZFetchReward)
	protocol.type = CS_TIANSHUXZ_SEQ_TYPE.CS_TIANSHUXZ_SEQ_TYPE_INFO
	protocol:EncodeAndSend()
end

function TianShuCtrl:FlushTianShuView()
	if self.view and self.view:IsOpen() then
		self.view:FlushTianshuView()
	end
end

function TianShuCtrl:OpenTianShuSkillFinishView(index)
	if self.tip_finish_view and index then
		self.tip_finish_view:SetIndex(index)
	end
end