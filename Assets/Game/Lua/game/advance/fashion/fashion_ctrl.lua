require("game/advance/fashion/fashion_data")
--------------------------------------------------------------
--角色服装
--------------------------------------------------------------
FashionCtrl = FashionCtrl or BaseClass(BaseController)
function FashionCtrl:__init()
	if FashionCtrl.Instance then
		print_error("[FashionCtrl] 尝试生成第二个单例模式")
	end
	FashionCtrl.Instance = self
	self.fashion_data = FashionData.New()
	self:RegisterAllProtocols()
	self.fashion_change_callback = nil
	self.fashion_view = nil
end

function FashionCtrl:__delete()
	self.fashion_data:DeleteMe()
	self.fashion_data = nil
	FashionCtrl.Instance = nil
	self.fashion_view = nil

end

function FashionCtrl:RegisterView(fashion_view)
	self.fashion_view = fashion_view
end

function FashionCtrl:UnRegisterView()
	self.fashion_view = nil
end

function FashionCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShizhuangInfo, "OnShizhuangInfo")
	self:RegisterProtocol(SCOtherCapabilityInfo, "OnOtherCapabilityInfo")
	self:RegisterProtocol(CSShizhuangUseReq)
	self:RegisterProtocol(CSShizhuangUpgradeReq)
	self:RegisterProtocol(CSShizhuangSpecialImgUpgradeReq)
	self:RegisterProtocol(CSShizhuangSkillUplevelReq)
	self:RegisterProtocol(CSShizhuangUplevelEquip)
end

function FashionCtrl:NotifyWhenFashionChange(callback)
	self.fashion_change_callback = callback
end

function FashionCtrl:UnNotifyWhenFashionChange()
	self.fashion_change_callback = nil
end

--三件套信息
function FashionCtrl:OnOtherCapabilityInfo(protocol)
	print_error("协议：三件套信息")
end

--时装信息
function FashionCtrl:OnShizhuangInfo(protocol)
	local role_vo = PlayerData.Instance:GetRoleVo()
	self.fashion_data:SetWuQiData(protocol.item_list[SHIZHUANG_TYPE.WUQI])

	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	for k,v in pairs(protocol.item_list) do
		if k == SHIZHUANG_TYPE.WUQI then
			AdvanceCtrl.Instance:FlushView("wuqihuanhuaview")
			AdvanceCtrl.Instance:FlushView("shenbing")
		elseif k == SHIZHUANG_TYPE.BODY then
			self.fashion_data:SetFashionData(v)
			AdvanceCtrl.Instance:FlushView("fashionhuanhua")
			AdvanceCtrl.Instance:FlushView("fashion")
		end
	end

	if self.fashion_change_callback ~= nil then
		self.fashion_change_callback()
	end
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	RemindManager.Instance:Fire(RemindName.AdvanceEquip)
	RemindManager.Instance:Fire(RemindName.PlayerFashion)
	RemindManager.Instance:Fire(RemindName.HuanHua)
	RemindManager.Instance:Fire(RemindName.AdvanceFashion)
	RemindManager.Instance:Fire(RemindName.AdvanceShenbing)
	ViewManager.Instance:FlushView(ViewName.AdvanceEquipView)
end

--发送使用时装协议					0-武器，1-时装		0-普通形象，1-特殊形象		形象ID
function FashionCtrl:SendShizhuangUseReq(shizhuang_type, img_type, img_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUseReq)
	protocol.shizhuang_type = shizhuang_type
	protocol.img_type = img_type
	protocol.img_id = img_id
	protocol:EncodeAndSend()
end

--发送升级时装协议
function FashionCtrl:SendFashionUpgradeReq(is_auto_buy, is_one_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUpgradeReq)
	protocol.is_auto_buy = is_auto_buy
	protocol.shizhuang_type = SHIZHUANG_TYPE.BODY
	if is_one_key then
		local cfg = FashionData.Instance:GetShizhuangUpgrade()
		if cfg then
			
			protocol.repeat_times = cfg.pack_num
		else
			protocol.repeat_times = 1
		end
	else
		protocol.repeat_times = 1
	end
	protocol:EncodeAndSend()
end

--发送升级特殊时装协议（幻化）						0-武器 1-时装	   特殊形象ID
function FashionCtrl:SendFashionSpecialImgUpgradeReq(shizhuang_type, use_special_img)
	local  protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangSpecialImgUpgradeReq)
	protocol.shizhuang_type = shizhuang_type
	protocol.use_special_img = use_special_img
	protocol:EncodeAndSend()
end

--发送升级武器协议
function FashionCtrl:SendShenBingUpgradeReq(is_auto_buy, is_one_key, pack_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUpgradeReq)
	protocol.is_auto_buy = is_auto_buy
	protocol.shizhuang_type = SHIZHUANG_TYPE.WUQI
	if is_auto_buy then
		if is_one_key then
			protocol.repeat_times = pack_num
		else
			protocol.repeat_times = 1
		end
	else
		protocol.repeat_times = 1
	end
	protocol:EncodeAndSend()
end

--时装技能升级协议
function FashionCtrl:SendWuQiUpLevelReq(skill_idx, auto_buy, shizhuang_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangSkillUplevelReq)
	protocol.skill_idx		= skill_idx	-- 请求序号
	protocol.auto_buy 		= auto_buy
	protocol.shizhuang_type = shizhuang_type
	protocol:EncodeAndSend()
end

--时装装备升级协议
function FashionCtrl:SendWuQiEquipUpLevelReq(equip_idx, shizhuang_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUplevelEquip)
	protocol.equip_idx      = equip_idx	-- 请求序号
	protocol.shizhuang_type = shizhuang_type
	protocol:EncodeAndSend()
end