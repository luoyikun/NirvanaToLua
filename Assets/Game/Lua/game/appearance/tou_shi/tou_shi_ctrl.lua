require("game/appearance/tou_shi/tou_shi_data")
require("game/appearance/tou_shi/tou_shi_huan_hua_view")

TouShiCtrl = TouShiCtrl or BaseClass(BaseController)

function TouShiCtrl:__init()
	if TouShiCtrl.Instance ~= nil then
		ErrorLog("[TouShiCtrl] attempt to create singleton twice!")
		return
	end

	TouShiCtrl.Instance = self
	self.data = TouShiData.New()
	self.huanhua_view = TouShiHuanHuaView.New(ViewName.TouShiHuanHua)

	self:RegisterTouShiProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TouShiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	TouShiCtrl.Instance = nil
end

-- 注册协议
function TouShiCtrl:RegisterTouShiProtocols()
	self:RegisterProtocol(SCTouShiInfo, "OnTouShiInfo")
	self:RegisterProtocol(SCTouShiAppeChange, "OnTouShiAppeChange")
	self:RegisterProtocol(CSTouShiOperaReq)
end

function TouShiCtrl:OnTouShiInfo(protocol)
	self.data:SetTouShiInfo(protocol.toushi_info)
	
	RemindManager.Instance:Fire(RemindName.TouShi)

	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "toushi")
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

function TouShiCtrl:OnTouShiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.toushi_used_imageid = protocol.toushi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

function TouShiCtrl:SendTouShiReq(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTouShiOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function TouShiCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "toushi_upgrade", {result})
	end
end

function TouShiCtrl:MainuiOpenCreate()
	self:SendTouShiReq(TOUSHI_OPERA_TYPE.TOUSHI_OPERA_TYPE_INFO)
end