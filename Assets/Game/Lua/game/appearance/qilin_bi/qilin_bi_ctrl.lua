require("game/appearance/qilin_bi/qilin_bi_data")
require("game/appearance/qilin_bi/qilin_bi_huan_hua_view")

QilinBiCtrl = QilinBiCtrl or BaseClass(BaseController)

function QilinBiCtrl:__init()
	if QilinBiCtrl.Instance ~= nil then
		ErrorLog("[QilinBiCtrl] attempt to create singleton twice!")
		return
	end
	
	QilinBiCtrl.Instance = self
	self.data = QilinBiData.New()
	self.huanhua_view = QilinBiHuanHuaView.New(ViewName.QilinBiHuanHua)

	self:RegisterQilinBiProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function QilinBiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	QilinBiCtrl.Instance = nil
end

-- 注册协议
function QilinBiCtrl:RegisterQilinBiProtocols()
	self:RegisterProtocol(SCQilinBiInfo, "OnQilinBiInfo")
	self:RegisterProtocol(SCQilinBiAppeChange, "OnQilinBiAppeChange")
	self:RegisterProtocol(CSQiLinBiOperaReq)
end

function QilinBiCtrl:OnQilinBiInfo(protocol)
	self.data:SetQilinBiInfo(protocol.qilinbi_info)
	
	RemindManager.Instance:Fire(RemindName.QilinBi)
	RemindManager.Instance:Fire(RemindName.AppearanceEquip)
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "qilinbi")
	end

	if ViewManager.Instance:IsOpen(ViewName.TipZiZhi) then
		AdvanceCtrl.Instance:FlushZiZhiTips()
	end

	if ViewManager.Instance:IsOpen(ViewName.TipSkillUpgrade) then
		AdvanceCtrl.Instance.tip_skill_upgrade_view:Flush()
	end

	if ViewManager.Instance:IsOpen(ViewName.TipChengZhang) then
		AdvanceCtrl.Instance:FlushChengZhangTips()
	end

	if self.huanhua_view and self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush()
	end
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	AppearanceCtrl.Instance:FlushEquipView()
end

function QilinBiCtrl:OnQilinBiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.qilinbi_used_imageid = protocol.qilinbi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 麒麟臂请求
function QilinBiCtrl:SendQiLinBiReq(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQiLinBiOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function QilinBiCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "qilinbi_upgrade", {result})
	end
end

function QilinBiCtrl:MainuiOpenCreate()
	self:SendQiLinBiReq(QILINBI_OPERA_TYPE.QILINBI_OPERA_TYPE_INFO)
end