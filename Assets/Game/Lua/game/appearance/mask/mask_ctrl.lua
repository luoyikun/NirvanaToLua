require("game/appearance/mask/mask_data")
require("game/appearance/mask/mask_huan_hua_view")

MaskCtrl = MaskCtrl or BaseClass(BaseController)

function MaskCtrl:__init()
	if MaskCtrl.Instance ~= nil then
		ErrorLog("[MaskCtrl] attempt to create singleton twice!")
		return
	end
	MaskCtrl.Instance = self
	self.data = MaskData.New()
	self.huanhua_view = MaskHuanHuaView.New(ViewName.MaskHuanHua)

	self:RegisterMaskProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function MaskCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	MaskCtrl.Instance = nil
end

-- 注册协议
function MaskCtrl:RegisterMaskProtocols()
	self:RegisterProtocol(SCMaskInfo, "OnMaskInfo")
	self:RegisterProtocol(SCMaskAppeChange, "OnMaskAppeChange")
	self:RegisterProtocol(CSMaskOperaReq)
end

function MaskCtrl:OnMaskInfo(protocol)
	self.data:SetMaskInfo(protocol.mask_info)

	RemindManager.Instance:Fire(RemindName.Mask)

	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "mask")
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

function MaskCtrl:OnMaskAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.mask_used_imageid = protocol.mask_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 面饰请求
function MaskCtrl:SendMaskReq(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMaskOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function MaskCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "mask_upgrade", {result})
	end
end

function MaskCtrl:MainuiOpenCreate()
	self:SendMaskReq(MASK_OPERA_TYPE.MASK_OPERA_TYPE_INFO)
end