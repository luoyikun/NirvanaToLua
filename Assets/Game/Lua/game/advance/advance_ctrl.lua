require("game/advance/advance_view")
require("game/advance/advance_data")
require("game/advance/mount/advance_mount_view")
require("game/advance/tips/tip_zizhi_view")
require("game/advance/tips/tip_skill_upgrade_view")
require("game/advance/tips/tip_xunzhang_view")
require("game/advance/tips/tip_chengzhang_view")
require("game/advance/wing/advance_wing_view")
require("game/advance/foot/advance_foot_view")
require("game/advance/halo/advance_halo_view")
require("game/advance/fightmount/advance_fight_mount_view")
require("game/advance/advance_equip_view")
require("game/advance/advance_equip_skill_view")
require("game/advance/cloak/advance_cloak_view")
require("game/advance/fashion/advance_fashion_view")
require("game/advance/fabao/advance_fabao_view")
require("game/advance/shengbing/advance_shenbing_view")
require("game/advance/tips/clear_bless_tip_view")
require("game/advance/ling_ren/advance_lingren_view")
require("game/advance/advance_huanhua_view")
require("game/advance/advance_huanhua_content")
require("game/advance/jinjie_show_goal_view")
require("game/advance/shenci_mount_huanhua_view")
require("game/advance/shenci_wing_huanhua_view")
require("game/advance/shenci_fightmount_huanhua_view")

AdvanceCtrl = AdvanceCtrl or BaseClass(BaseController)

AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
function AdvanceCtrl:__init()
	if AdvanceCtrl.Instance then
		return
	end
	AdvanceCtrl.Instance = self
	self.advance_view = AdvanceView.New(ViewName.Advance)
	self.huan_hua_view = AdvanceHuanHuaView.New(ViewName.AdvanceHuanhua)
	self.shenci_mount_huan_hua_view = ShenCiMountHuanHuaView.New(ViewName.ShenCiMountHuanHua)
	self.shenci_wing_huan_hua_view = ShenCiWingHuanHuaView.New(ViewName.ShenCiWingHuanHua)
	self.shenci_fightmount_huan_hua_view = ShenCiFightMountHuanHuaView.New(ViewName.ShenCiFightMountHuanHua)
	self.advance_data = AdvanceData.New()
	self.tip_zizhi_view = TipZiZhiView.New(ViewName.TipZiZhi)						-- 资质丹提示框
	self.tip_skill_upgrade_view = TipSkillUpgradeView.New(ViewName.TipSkillUpgrade)	-- 进阶技能提示框
	self.tip_xunzhang_view = TipXunZhangView.New(ViewName.TipXunZhangView)			-- 进阶勋章提示框
	self.tip_chengzhang_view = TipChengZhangView.New(ViewName.TipChengZhang)		-- 成长丹提示框
	self.equip_view = AdvanceEquipView.New(ViewName.AdvanceEquipView)
	self.equip_skill_view = AdvanceEquipSkillView.New(ViewName.AdvanceEquipSkillView)
	self.clear_bless_tip_view = ClearBlessTipView.New(ViewName.ClearBlessTipView)
	self.jinjie_show_goal_view = JinJieShowGoalView.New(ViewName.JinJieShowGoalView)
	self.set_mount_attr = GlobalEventSystem:Bind(OtherEventType.MOUNT_INFO_CHANGE, BindTool.Bind1(self.FlushView, self, "mount"))
	self:RegisterAllProtocols()
end

function AdvanceCtrl:__delete()
	if nil ~= self.set_mount_attr then
		GlobalEventSystem:UnBind(self.set_mount_attr)
		self.set_mount_attr = nil
	end

	if self.tip_skill_upgrade_view ~= nil then
		self.tip_skill_upgrade_view:DeleteMe()
		self.tip_skill_upgrade_view = nil
	end

	if self.tip_xunzhang_view ~= nil then
		self.tip_xunzhang_view:DeleteMe()
		self.tip_xunzhang_view = nil
	end

	if self.tip_zizhi_view ~= nil then
		self.tip_zizhi_view:DeleteMe()
		self.tip_zizhi_view = nil
	end

	if nil ~= self.tip_chengzhang_view then
		self.tip_chengzhang_view:DeleteMe()
		self.tip_chengzhang_view = nil
	end

	if self.advance_data ~= nil then
		self.advance_data:DeleteMe()
		self.advance_data = nil
	end

	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if self.shenci_wing_huan_hua_view then
		self.shenci_wing_huan_hua_view:DeleteMe()
		self.shenci_wing_huan_hua_view = nil
	end

	if self.shenci_fightmount_huan_hua_view then
		self.shenci_fightmount_huan_hua_view:DeleteMe()
		self.shenci_fightmount_huan_hua_view = nil
	end

	if self.shenci_mount_huan_hua_view then
		self.shenci_mount_huan_hua_view:DeleteMe()
		self.shenci_mount_huan_hua_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.equip_skill_view then
		self.equip_skill_view:DeleteMe()
		self.equip_skill_view = nil
	end

	if self.clear_bless_tip_view then
		self.clear_bless_tip_view:DeleteMe()
		self.clear_bless_tip_view = nil
	end

	if self.jinjie_show_goal_view then
		self.jinjie_show_goal_view:DeleteMe()
		self.jinjie_show_goal_view = nil
	end
	AdvanceCtrl.Instance = nil
end

function AdvanceCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSMountSpecialImgUpgrade)
	self:RegisterProtocol(CSWingSpecialImgUpgrade)
	self:RegisterProtocol(CSHaloSpecialImgUpgrade)
	self:RegisterProtocol(CSFightMountSpecialImgUpgrade)
end

function AdvanceCtrl:MountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function AdvanceCtrl:WingSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function AdvanceCtrl:HaloSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function AdvanceCtrl:FaBaoSpecialImaUpgrade(req_type,special_image_id)
	local send_protocol 	 = FaBaoCtrl.Instance:GetTheFaBaoProtocol()
	send_protocol.req_type   = req_type or 0
	send_protocol.param1 	 = special_image_id
	send_protocol:EncodeAndSend()
end

function AdvanceCtrl:FightMountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function AdvanceCtrl:FootSpecialImaUpgrade(special_image_id)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_SPECIAL_IMAGE, special_image_id)
end

function AdvanceCtrl:GetAdvanceView()
	return self.advance_view
end

function AdvanceCtrl:FlushXunZhangView()
	if self.tip_xunzhang_view then
		self.tip_xunzhang_view:Flush()
	end
end

function AdvanceCtrl:FlushView(...)
	if self.advance_view:IsOpen() then
		self.advance_view:Flush(...)
	end
	if self.huan_hua_view then
		self.huan_hua_view:Flush(...)
	end
	if self.shenci_wing_huan_hua_view then
		self.shenci_wing_huan_hua_view:Flush(...)
	end
	if self.shenci_fightmount_huan_hua_view then
		self.shenci_fightmount_huan_hua_view:Flush(...)
	end

	if self.shenci_mount_huan_hua_view then
		self.shenci_mount_huan_hua_view:Flush(...)
	end

	self.tip_skill_upgrade_view:Flush()
	self.tip_xunzhang_view:Flush()

	self.tip_zizhi_view:Flush()
	KaifuActivityCtrl.Instance:FlushView()
end

function AdvanceCtrl:FlushHuashen(...)
	-- self.advance_view:Flush(...)
end

-- 刷新资质丹提示框
function AdvanceCtrl:FlushZiZhiTips()
	if self.tip_zizhi_view:IsOpen() then
		self.tip_zizhi_view:Flush()
	end
end

-- 刷新成长丹提示框
function AdvanceCtrl:FlushChengZhangTips()
	if nil ~= self.tip_chengzhang_view then
		self.tip_chengzhang_view:Flush()
	end
end

function AdvanceCtrl:FlushViewFromZiZhi(...)
	self.advance_view:Flush(...)
end

function AdvanceCtrl:FlushHuashenProtect(...)
	-- self.advance_view:Flush(...)
end

function AdvanceCtrl:OnHuashenUpgradeResult(result)
	self.advance_view:OnHuashenUpgradeResult(result)
end

function AdvanceCtrl:OnSpiritUpgradeResult(result)
	self.advance_view:OnSpiritUpgradeResult(result)
end

function AdvanceCtrl:OnFightMountUpgradeResult(result)
	self.advance_view:OnFightMountUpgradeResult(result)
end

-- 坐骑进阶结果返回
function AdvanceCtrl:MountUpgradeResult(result)
	self.advance_view:MountUpgradeResult(result)
end

-- 羽翼进阶结果返回
function AdvanceCtrl:WingUpgradeResult(result)
	self.advance_view:WingUpgradeResult(result)
end

-- 足迹进阶结果返回
function AdvanceCtrl:FootUpgradeResult(result)
	self.advance_view:FootUpgradeResult(result)
end

-- 披风进阶结果返回
function AdvanceCtrl:CloakUpgradeResult(result)
	self.advance_view:CloakUpgradeResult(result)
end

-- 时装进阶结果返回
function AdvanceCtrl:ShizhuangUpgradeResult(result)
	self.advance_view:FashionUpgradeResult(result)
end
--神兵进阶结果返回
function AdvanceCtrl:ShenBingUpgradeResult(result)
	self.advance_view:ShenBingUpgradeResult(result)
end
--武器进阶结果返回
function AdvanceCtrl:WuQiUpgradeResult(result)
	self.advance_view:WuQiUpgradeResult(result)
end

function AdvanceCtrl:HaloUpgradeResult(result)
	self.advance_view:HaloUpgradeResult(result)
end

-- 法宝进阶结果返回
function AdvanceCtrl:FaBaoUpgradeResult(result)
	self.advance_view:FaBaoUpgradeResult(result)
end

function AdvanceCtrl:FlushEquipView(...)
	self.equip_view:Flush(...)
end

--根据不同界面判断是否打开清除祝福值提示
function AdvanceCtrl:OpenClearBlessView(view_name, view_index, call_back, to_index)
	local info = nil
	local grade, grade_name = nil, nil
	local grade_cfg = nil
	if view_name == ViewName.Advance then
		if view_index == TabIndex.mount_jinjie then
			info = MountData.Instance:GetMountInfo()
			grade, grade_name = MountData.Instance:GetClearBlessGrade()
			grade_cfg = MountData.Instance:GetMountGradeCfg()
		elseif view_index == TabIndex.wing_jinjie then
			info = WingData.Instance:GetWingInfo()
			grade, grade_name = WingData.Instance:GetClearBlessGrade()
			grade_cfg = WingData.Instance:GetWingGradeCfg()
		elseif view_index == TabIndex.halo_jinjie then
			info = HaloData.Instance:GetHaloInfo()
			grade, grade_name = HaloData.Instance:GetClearBlessGrade()
			grade_cfg = HaloData.Instance:GetHaloGradeCfg()
		elseif view_index == TabIndex.fight_mount then
			info = FightMountData.Instance:GetFightMountInfo()
			grade, grade_name = FightMountData.Instance:GetClearBlessGrade()
			grade_cfg = FightMountData.Instance:GetMountGradeCfg()
		elseif view_index == TabIndex.foot_jinjie then
			info = FootData.Instance:GetFootInfo()
			grade, grade_name = FootData.Instance:GetClearBlessGrade()
			grade_cfg = FootData.Instance:GetFootGradeCfg()
		elseif view_index == TabIndex.fabao_jinjie then
			info = FaBaoData.Instance:GetFaBaoInfo()
			grade, grade_name = FaBaoData.Instance:GetClearBlessGrade()
			grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg()
		elseif view_index == TabIndex.fashion_jinjie then
			info = FashionData.Instance:GetFashionInfo()
			grade, grade_name = FashionData.Instance:GetClearBlessGrade2()
			grade_cfg = FashionData.Instance:GetShizhuangUpgrade()
		elseif view_index == TabIndex.role_shenbing then
			info = FashionData.Instance:GetWuQiInfo()
			grade, grade_name = FashionData.Instance:GetClearBlessGrade()
			grade_cfg = FashionData.Instance:GetWuQiGradeCfg()
		end
	elseif view_name == ViewName.Goddess then
		if view_index == TabIndex.goddess_shengong then
			info = ShengongData.Instance:GetShengongInfo()
			grade, grade_name = ShengongData.Instance:GetClearBlessGrade()
			grade_cfg = ShengongData.Instance:GetShengongGradeCfg()
		elseif view_index == TabIndex.goddess_shenyi then
			info = ShenyiData.Instance:GetShenyiInfo()
			grade, grade_name = ShenyiData.Instance:GetClearBlessGrade()
			grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg()
		end
	end
	local data = {}
	if grade_cfg then
		data.is_clear_bless = grade_cfg.is_clear_bless
		data.cur_val = info.grade_bless_val
		self.advance_view:SetClearData(data)
	end

	if not AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T[view_index] and
		grade_cfg and grade_cfg.is_clear_bless == 1 and info.grade_bless_val and info.grade_bless_val > 0 then
		data.view_name = view_name
		data.view_index = view_index
		data.call_back = call_back
		data.max_val = grade_cfg.bless_val_limit
		data.cur_val = info.grade_bless_val
		data.grade = grade
		data.grade_name = grade_name
		data.to_index = to_index
		self.clear_bless_tip_view:SetData(data)
		AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T[view_index] = true
	else
		if call_back then
			call_back(to_index)
		else
			ViewManager.Instance:Close(view_name)
		end
	end
end

function AdvanceCtrl:ClearBlessTipView()
	AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
end


function AdvanceCtrl:OpenJinJieShowGoalView(system_type, show_type)
	self.jinjie_show_goal_view:SetData(system_type, show_type)
end