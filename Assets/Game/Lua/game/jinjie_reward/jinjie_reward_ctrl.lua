require("game/jinjie_reward/jinjie_reward_data")
require("game/jinjie_reward/jinjie_reward_view")

JinJieRewardCtrl = JinJieRewardCtrl or BaseClass(BaseController)

function JinJieRewardCtrl:__init()
	if JinJieRewardCtrl.Instance ~= nil then
		ErrorLog("[JinJieRewardCtrl] attempt to create singleton twice!")
		return
	end
	JinJieRewardCtrl.Instance = self

	self.data = JinJieRewardData.New()
	self.view = JinJieRewardView.New(ViewName.JinJieRewardView)

	self:RegisterAllProtocols()
end

function JinJieRewardCtrl:__delete()
	JinJieRewardCtrl.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
end

-- 协议注册
function JinJieRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSJinjiesysRewardOpera)
	self:RegisterProtocol(SCJinjiesysRewardTimestamp, "OnSCJinjiesysRewardTimestamp")
	self:RegisterProtocol(SCJinjiesysRewardInfo, "OnSCJinjiesysRewardInfo")
end

--各系统进阶奖励相关信息
function JinJieRewardCtrl:OnSCJinjiesysRewardInfo(protocol)
	self.data:SetRewardInfo(protocol)
	self:FlushSystemView()
	self:FlushJinJieAwardView()
end

--各系统免费激活形象结束时间戳
function JinJieRewardCtrl:OnSCJinjiesysRewardTimestamp(protocol)
	self.data:SetEndTimeInfo(protocol)
end

--发送购买激活超级幻化形象所需道具请求
function JinJieRewardCtrl:SendJinJieRewardOpera(operate, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinjiesysRewardOpera)
	send_protocol.operate = operate				-- 操作类型
	send_protocol.param1 = param1 or 0			--进阶系统类型
	send_protocol.param2 = param2 or 0			--大目标/小目标   0/1
	send_protocol.param3 = param3 or 0			--暂时无用
	send_protocol:EncodeAndSend()
end

--发送幻化或者取消幻化请求
function JinJieRewardCtrl:SendHuanHuaUseOrCancle(system_type, image_id, is_canel)
	if nil == system_type or nil == image_id then
		return
	end

	local use_image_id = image_id

	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 	-- 坐骑
		local index = MultiMountData.Instance:GetCurUseMountId()
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		if index ~= 0 then 													-- 如果使用双骑的情况下先下双骑
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, index)
			if role_vo.multi_mount_res_id > 0 then
				MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UNRIDE)
			end
		end					

		MountCtrl.Instance:SendUseMountImage(use_image_id)
		local info = MountData.Instance:GetMountInfo()
		if info.mount_flag == 0 then
			MountCtrl.Instance:SendGoonMountReq(1) 							-- 上坐骑
		end
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 				-- 羽翼
		WingCtrl.Instance:SendUseWingImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		ShengongCtrl.Instance:SendUseShengongImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then				-- 伙伴法阵
		ShenyiCtrl.Instance:SendUseShenyiImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		HaloCtrl.Instance:SendUseHaloImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then			-- 足迹
		FootCtrl.Instance:SendUseFootImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then			-- 战骑
		FightMountCtrl.Instance:SendUseFightMountImage(use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_MASK then					-- 面饰
		MaskCtrl.Instance:SendMaskReq(MASK_OPERA_TYPE.MASK_OPERA_TYPE_USE_IMAGE, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_YAOSHI then				-- 腰饰
		WaistCtrl.Instance:SendYaoShiReq(YAOSHI_OPERA_TYPE.YAOSHI_OPERA_TYPE_USE_IMAGE, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_TOUSHI then				-- 头饰
		TouShiCtrl.Instance:SendTouShiReq(TOUSHI_OPERA_TYPE.TOUSHI_OPERA_TYPE_USE_IMAGE, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_QILINBI then				-- 麒麟臂
		QilinBiCtrl.Instance:SendQiLinBiReq(QILINBI_OPERA_TYPE.QILINBI_OPERA_TYPE_USE_IMAGE, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGZHU then				-- 灵珠
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_ZHU, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_XIANBAO then				-- 仙宝
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.XIAN_BAO, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WEIYAN then				-- 尾焰
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.WEI_YAN, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGCHONG then			-- 灵宠
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_TONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGGONG then				-- 灵弓
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGQI then				-- 灵骑
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_QI, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHOUHUAN then				-- 手环
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.SHOU_HUAN, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_TALT then					-- 尾巴
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.TAIL, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FLYPET then				-- 飞宠
		use_image_id = is_canel and use_image_id or use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.FLY_PET, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, use_image_id)
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FABAO then				-- 法宝
		if is_canel then
			FaBaoCtrl.Instance:SendUseFaBaoImage(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_USEIMA, use_image_id)
		else
			FaBaoCtrl.Instance:SendUseFaBaoImage(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_USESPECIALIMG, use_image_id)
		end
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FASHION then				-- 时装
		if is_canel then
			FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.BODY, 0, use_image_id)
		else
			use_image_id = use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
			FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.BODY, 1, use_image_id)
		end
	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENBING then				-- 神兵
		if is_canel then
			FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.WUQI, 0, use_image_id)
		else
			use_image_id = use_image_id - GameEnum.MOUNT_SPECIAL_IMA_ID
			FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.WUQI, 1, use_image_id)
		end
	end
end

-- 打开进阶奖励界面 system_type 系统类型
function JinJieRewardCtrl:OpenJinJieAwardView(system_type)
	if self.view and not self.view:IsOpen() and system_type then
		self.view:SetData(system_type)
	end
end

--刷新系统面板
function JinJieRewardCtrl:FlushSystemView()
	local system_type = JinJieRewardData.Instance:GetCurSystemType()
	if system_type == -1 then
		return
	end

	local flush_str = Language.JinJieReward.FlushSystemType[system_type]
	if nil == flush_str then
		return
	end
	
	if JinJieRewardData.Instance:IsAdvance(system_type) then
		AdvanceCtrl.Instance:FlushView(flush_str)
	elseif JinJieRewardData.Instance:IsGoddess(system_type) then
		GoddessCtrl.Instance:FlushView(flush_str)
	elseif JinJieRewardData.Instance:IsAppearance(system_type) then
		AppearanceCtrl.Instance:FlushView(flush_str)
	end
end

--刷新进阶奖励界面
function JinJieRewardCtrl:FlushJinJieAwardView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end