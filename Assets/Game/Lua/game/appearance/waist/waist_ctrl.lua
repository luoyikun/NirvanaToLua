require("game/appearance/waist/waist_data")
require("game/appearance/waist/waist_huan_hua_view")

WaistCtrl = WaistCtrl or BaseClass(BaseController)

function WaistCtrl:__init()
	if WaistCtrl.Instance ~= nil then
		ErrorLog("[WaistCtrl] attempt to create singleton twice!")
		return
	end

	WaistCtrl.Instance = self
	self.data = WaistData.New()
	self.huanhua_view = WaistHuanHuaView.New(ViewName.WaistHuanHua)

	self:RegisterWaistProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function WaistCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	WaistCtrl.Instance = nil
end

-- 注册协议
function WaistCtrl:RegisterWaistProtocols()
	self:RegisterProtocol(SCYaoShiInfo, "OnYaoShiInfo")
	self:RegisterProtocol(SCYaoShiAppeChange, "OnYaoShiAppeChange")
	self:RegisterProtocol(CSYaoShiOperaReq)
end

function WaistCtrl:OnYaoShiInfo(protocol)
	self.data:SetYaoShiInfo(protocol.yaoshi_info)
	
	RemindManager.Instance:Fire(RemindName.Waist)
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "waist")
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
end

function WaistCtrl:OnYaoShiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.yaoshi_used_imageid = protocol.yaoshi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

function WaistCtrl:SendYaoShiReq(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSYaoShiOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function WaistCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "waist_upgrade", {result})
	end
end

function WaistCtrl:MainuiOpenCreate()
	self:SendYaoShiReq(YAOSHI_OPERA_TYPE.YAOSHI_OPERA_TYPE_INFO)
end