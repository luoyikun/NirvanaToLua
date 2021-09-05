require("game/image_fuling/image_fuling_data")
require("game/image_fuling/image_fuling_view")
require("game/image_fuling/image_fuling_content_view")
require("game/image_fuling/image_fuling_talent_view")
require("game/image_fuling/image_fuling_talent_bag_view")
require("game/image_fuling/image_fuling_talent_upgrade_view")
require("game/image_fuling/talent_skill_upgrade_view")
require("game/image_fuling/wakeup_focus_view")
require("game/image_fuling/wakeup_focus_data")

ImageFuLingCtrl = ImageFuLingCtrl or BaseClass(BaseController)

function ImageFuLingCtrl:__init()
	if ImageFuLingCtrl.Instance then
		return
	end
	ImageFuLingCtrl.Instance = self

	self.view = ImageFuLingView.New(ViewName.ImageFuLing)
	self.data = ImageFuLingData.New()
	self.talent_bag_view = ImageFulingTalentBagView.New(ViewName.TalentBagView)
	self.focus_view = WakeUpFocusView.New(ViewName.WakeUpFocusView)
	self.focus_data = WakeUpFocusData.New()
	self.talent_upgrade_view = ImageFuLingTalentUpgradeView.New(ViewName.TalentUpgradeView)
	self.talent_skill_upgrade_view = TalentSkillUpgradeView.New(ViewName.TalentSkillUpgradeView)
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainUIOpenComlete, self))
	self:RegisterAllProtocols()
end

function ImageFuLingCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	
	if self.talent_bag_view ~= nil then
		self.talent_bag_view:DeleteMe()
		self.talent_bag_view = nil
	end

	if self.focus_view ~= nil then
		self.focus_view:DeleteMe()
		self.focus_view = nil
	end

	if self.focus_data ~= nil then
		self.focus_data:DeleteMe()
		self.focus_data = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.talent_skill_upgrade_view then
		self.talent_skill_upgrade_view:DeleteMe()
		self.talent_skill_upgrade_view = nil
	end

	if self.talent_upgrade_view ~= nil then
		self.talent_upgrade_view:DeleteMe()
		self.talent_upgrade_view = nil
	end
	ImageFuLingCtrl.Instance = nil
end

function ImageFuLingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCImgFulingInfo, "OnImgFulingInfo")
	self:RegisterProtocol(CSImgFulingOperate)

	--天赋
	self:RegisterProtocol(CSTalentOperaReqAll)
	self:RegisterProtocol(SCTalentAllInfo, "OnTalentAllInfo")
	self:RegisterProtocol(SCTalentUpdateSingleGrid, "OnTalentUpdateSingleGrid")
	self:RegisterProtocol(SCTalentChoujiangPage, "OnTalentChoujiangPage")
	self:RegisterProtocol(SCTalentAttentionSkillID, "TalentAttentionSkillID")
end

function ImageFuLingCtrl:MainUIOpenComlete()
	self:SendImgFuLingOperate(IMG_FULING_OPERATE_TYPE.IMG_FULING_OPERATE_TYPE_INFO_REQ)
	self:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_INFO)
	self:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_INFO)
end

function ImageFuLingCtrl:OnImgFulingInfo(protocol)
	self.data:SetImgFuLingData(protocol)
	RemindManager.Instance:Fire(RemindName.ImgFuLing)
	self.view:Flush()
end

function ImageFuLingCtrl:SendImgFuLingUpLevelReq(fuling_type, item_index)
	self:SendImgFuLingOperate(IMG_FULING_OPERATE_TYPE.IMG_FULING_OPERATE_TYPE_LEVEL_UP, fuling_type, item_index)
end

function ImageFuLingCtrl:SendImgFuLingOperate(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSImgFulingOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function ImageFuLingCtrl:OnTalentAllInfo(protocol)
	self.data:SetTalentAllInfo(protocol.talent_info_list)
	RemindManager.Instance:Fire(RemindName.ImgTalent)
	self.view:Flush()
	self.talent_upgrade_view:Flush()
	self.talent_skill_upgrade_view:Flush()
end

function ImageFuLingCtrl:OnTalentUpdateSingleGrid(protocol)
	self.data:SetTalentOneGridInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ImgTalent)
	self.view:Flush()
	self.talent_upgrade_view:Flush()
	self.talent_skill_upgrade_view:Flush()
end

function ImageFuLingCtrl:OnTalentChoujiangPage(protocol)
	self.data:SetTalentChoujiangPageInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ImgTalent)
	self.view:Flush()
	self.view:GetChouJiangData()
	RemindManager.Instance:Fire(RemindName.ImgTianFu)
	RemindManager.Instance:Fire(RemindName.ImgSuXing)
	-- self.view:FlushTalent()
end

function ImageFuLingCtrl:SendTalentOperaReq(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTalentOperaReqAll)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function ImageFuLingCtrl:TalentAttentionSkillID(protocol)
	self.focus_data:SetData(protocol)
	self.view:Flush()
end

function ImageFuLingCtrl:OpenTalentUpgradeView(select_info)
	self.talent_upgrade_view:SetSelectInfo(select_info)
	self.talent_upgrade_view:Open()
end

function ImageFuLingCtrl:OpenTalentSkillUpgradeView(select_info)
	self.talent_skill_upgrade_view:SetSelectInfo(select_info)
	self.talent_skill_upgrade_view:Open()
end