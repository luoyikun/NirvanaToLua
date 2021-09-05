TipSkillUpgradeView = TipSkillUpgradeView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开
local FROM_FOOT = 6			-- 从足迹界面打开
local FROM_FABAO = 7 		-- 从法宝界面打开
local FROM_WUQI = 8			-- 从神兵界面打开
local FROM_SHIZHUANG = 9	-- 从时装界面打开
local FROM_TOUSHI = 10		-- 从头饰界面打开
local FROM_MASK = 11		-- 从面饰界面打开
local FROM_WAIST = 12		-- 从腰饰界面打开
local FROM_QILINBI = 13		-- 从麒麟臂界面打开
local FROM_FIGHTMOUNT = 14	-- 从战骑界面打开
local FROM_LINGZHU = 15		-- 从灵珠界面打开
local FROM_XIANBAO = 16		-- 从仙宝界面打开
local FROM_LINGTONG = 17	-- 从灵童界面打开
local FROM_LINGGONG = 18	-- 从灵弓界面打开
local FROM_LINGQI = 19		-- 从灵骑界面打开
local FROM_WEIYAN = 20		-- 从尾焰界面打开
local FROM_SHOUHUAN = 21	-- 从手环界面打开
local FROM_TAIL = 22		-- 从尾巴界面打开
local FROM_FLYPET = 23		-- 从飞宠界面打开

-- local NAME_LIST = {"坐骑", "羽翼", "光环", "神弓", "神翼", "足迹", "法宝","神兵", "时装", "头饰", "面饰", "腰饰", "麒麟臂", "战骑", "灵珠", "仙宝", "灵童", "灵弓", "灵骑", "尾焰", "手环", "尾巴", "飞宠", }
local EFFECT_CD = 0.8

function TipSkillUpgradeView:__init()
	self.ui_config = {{"uis/views/tips/advancetips_prefab", "SkillUpgradeTip"}}
	self.play_audio = true
	self.info = nil
	self.cur_index = nil
	self.cur_data = {}
	self.next_data_cfg = {}
	self.client_grade_cfg = nil
	self.temp_level = nil
	self.next_level = nil
	self.item_id = 0
	self.effect_cd = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

-- 创建完调用
function TipSkillUpgradeView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["UpLevelButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpgradeButton, self))
	self.need_item_cell = ItemCell.New()
	self.need_item_cell:SetInstanceParent(self.node_list["NeedItemCell"])	


	self.is_Active_text = ""
	self.skill_name = ""
	self.need_pro_name = ""
	self.need_pro_id = {}
	self.need_pro_num = ""
	self.have_pro_num = ""
	self.grade = ""
	self.advance_type = ""
	self.can_up_level_grade = ""

end

function TipSkillUpgradeView:ReleaseCallBack()
	-- 清理变量和对象
	self.grade = nil
	self.advance_type = nil
	self.level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.grade = nil
	self.is_Active_text = nil
	self.skill_icon = nil
	self.skill_name = nil
	self.need_pro_name = nil
	self.need_pro_num = nil
	self.have_pro_num = nil
	self.show_cur_effect = nil
	self.show_max_level_tip = nil
	self.show_normal_text = nil
	self.advance_type = nil
	self.show_up_level_tip = nil
	self.can_up_level_grade = nil
	self.show_effect = nil
	self.special_skill_up_view = nil
	self.normal_skill_up_view = nil
	self.gray_up_level_btn = nil
	self.is_text_gray = nil
	self.need_pro_id = {}
	if nil ~= self.need_item_cell then 
		self.need_item_cell:DeleteMe()
	end
	self.need_item_cell = nil
end

function TipSkillUpgradeView:__delete()
	self.info = nil
	self.cur_index = nil
	self.cur_data = nil
	self.next_data_cfg = nil
	self.next_level = nil
	self.item_id = nil
	if nil ~= self.need_item_cell then 
		self.need_item_cell:DeleteMe()
	end
	self.need_item_cell = nil 
	self.need_pro_id = {}
end

function TipSkillUpgradeView:OpenCallBack()
	self.temp_level = nil
	self.info = nil
	self.cur_index = nil
	self.cur_data = nil
	self.next_data_cfg = nil
	self.next_level = nil
	self.item_id = nil
end

function TipSkillUpgradeView:OnClickCloseButton()
	self:Close()
end

function TipSkillUpgradeView:CloseCallBack()
	self.temp_level = nil
end

function TipSkillUpgradeView:OnClickUpgradeButton()
	if not self.info or self.info.grade == 0 then
		return
	end
	if nil == next(self.next_data_cfg) then
		return
	end

	if self.info.grade < self.next_data_cfg.grade then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.NotEnoughGrade, Language.Advance.NAME_LIST[self.from_view]))
		return
	end
	if ItemData.Instance:GetItemNumInBagById(self.item_id) <= 0 or
		ItemData.Instance:GetItemNumInBagById(self.item_id) < self.next_data_cfg.uplevel_stuff_num then

		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			return
		end
		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(self.item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
		return
	end
	if self.from_view == FROM_MOUNT then
		MountCtrl.Instance:MountSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_WING then
		WingCtrl.Instance:WingSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_HALO then
		HaloCtrl.Instance:HaloSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_SHENGONG then
		ShengongCtrl.Instance:ShengongSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_FOOT then 
		FootCtrl.Instance:FootSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_FABAO then
		FaBaoCtrl.Instance:FaBaoSkillUplevelReq(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_UPLEVELSKILL,self.cur_index)
	elseif self.from_view == FROM_WUQI then
		FashionCtrl.Instance:SendWuQiUpLevelReq(self.cur_index, 0, SHIZHUANG_TYPE.WUQI)
	elseif self.from_view == FROM_SHIZHUANG then
		FashionCtrl.Instance:SendWuQiUpLevelReq(self.cur_index, 0, SHIZHUANG_TYPE.BODY)
	elseif self.from_view == FROM_SHENYI then
		ShenyiCtrl.Instance:ShenyiSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_TOUSHI then
		TouShiCtrl.Instance:SendTouShiReq(TOUSHI_OPERA_TYPE.TOUSHI_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_MASK then
		MaskCtrl.Instance:SendMaskReq(MASK_OPERA_TYPE.MASK_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_WAIST then
		WaistCtrl.Instance:SendYaoShiReq(YAOSHI_OPERA_TYPE.YAOSHI_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_QILINBI then
		QilinBiCtrl.Instance:SendQiLinBiReq(QILINBI_OPERA_TYPE.QILINBI_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_FIGHTMOUNT then
		FightMountCtrl.Instance:FightMountSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_LINGZHU then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_ZHU, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_XIANBAO then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.XIAN_BAO, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_LINGTONG then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_TONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_LINGGONG then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_LINGQI then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_QI, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_WEIYAN then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.WEI_YAN, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_SHOUHUAN then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.SHOU_HUAN, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_TAIL then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.TAIL, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_FLYPET then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.FLY_PET, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	end
end

function TipSkillUpgradeView:SetData()
	local bundle, asset = nil, nil
	local cur_level = 0
	local next_level = 1
	local cur_desc = nil
	local next_desc = nil
	local is_active = false

	-- 坐骑技能
	if self.from_view == FROM_MOUNT then							
		self.cur_data = MountData.Instance:GetMountSkillCfgById(self.cur_index) or {}
		self.info = MountData.Instance:GetMountInfo()
		bundle, asset = ResPath.GetMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = MountData.Instance:GetMountSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = MountData.Instance:GetMountGradeCfg(self.next_data_cfg.grade)
		end

	-- 羽翼技能
	elseif self.from_view == FROM_WING then							
		self.cur_data = WingData.Instance:GetWingSkillCfgById(self.cur_index) or {}
		self.info = WingData.Instance:GetWingInfo()
		bundle, asset = ResPath.GetWingSkillIcon(self.cur_index + 1)
		self.skill_cfg = WingData.Instance:GetWingSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WingData.Instance:GetWingSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WingData.Instance:GetWingGradeCfg(self.next_data_cfg.grade)
		end

	-- 光环技能
	elseif self.from_view == FROM_HALO then							
		self.cur_data = HaloData.Instance:GetHaloSkillCfgById(self.cur_index) or {}
		self.info = HaloData.Instance:GetHaloInfo()
		bundle, asset = ResPath.GetAdvanceHaloSkillIcon(self.cur_index + 1)
		self.skill_cfg = HaloData.Instance:GetHaloSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HaloData.Instance:GetHaloSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.next_data_cfg.grade)
		end

	-- 神弓技能
	elseif self.from_view == FROM_SHENGONG then						
		self.cur_data = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index) or {}
		self.info = ShengongData.Instance:GetShengongInfo()
		bundle, asset = ResPath.GetHaloSkillIcon(self.cur_index + 1)
		self.skill_cfg = ShengongData.Instance:GetShengongSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.next_data_cfg.grade)
		end

	-- 神翼技能
	elseif self.from_view == FROM_SHENYI then						
		self.cur_data = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index) or {}
		self.info = ShenyiData.Instance:GetShenyiInfo()
		bundle, asset = ResPath.GetFaZhenSkillIcon(self.cur_index + 1)
		self.skill_cfg = ShenyiData.Instance:GetShenyiSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.next_data_cfg.grade)
		end

	-- 足迹技能
	elseif self.from_view == FROM_FOOT then						
		self.cur_data = FootData.Instance:GetFootSkillCfgById(self.cur_index) or {}
		self.info = FootData.Instance:GetFootInfo()
		bundle, asset = ResPath.GetFootSkillIcon(self.cur_index + 1)
		self.skill_cfg = FootData.Instance:GetFootSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FootData.Instance:GetFootSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FootData.Instance:GetFootGradeCfg(self.next_data_cfg.grade)
		end

	-- 法宝技能
	elseif self.from_view == FROM_FABAO then						
		self.cur_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index) or {}
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		bundle, asset = ResPath.GetFaBaoSkillIcon(self.cur_index + 1)
		self.skill_cfg = FaBaoData.Instance:GetFaBaoSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.next_data_cfg.grade)
		end

	--时装技能
	elseif self.from_view == FROM_SHIZHUANG then				
		self.cur_data = FashionData.Instance:GetShizhuangSkillCfgById(self.cur_index) or {}
		self.info = FashionData.Instance:GetShizhuangSkillInfo()
		bundle, asset = ResPath.GetFashionSkillIcon(self.cur_index + 1)
		self.skill_cfg = FashionData.Instance:GetShizhuangSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FashionData.Instance:GetShizhuangSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FashionData.Instance:GetShizhuangUpgrade(self.next_data_cfg.grade)
		end

	-- 神兵技能
	elseif self.from_view == FROM_WUQI then						
		self.cur_data = FashionData.Instance:GetWuQiSkillCfgById(self.cur_index) or {}
		self.info = FashionData.Instance:GetWuQiInfo()
		bundle, asset = ResPath.GetShenBingSkillIcon(self.cur_index + 1)
		self.skill_cfg = FashionData.Instance:GetWuQiSkillCfg()

		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end

		self.next_data_cfg = FashionData.Instance:GetWuQiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(self.next_data_cfg.grade)
		end

	-- 头饰技能
	elseif self.from_view == FROM_TOUSHI then
		self.cur_data = TouShiData.Instance:GetTouShiSkillCfgById(self.cur_index) or {}
		self.info = TouShiData.Instance:GetTouShiInfo()
		bundle, asset = ResPath.GetTouShiSkillIcon(self.cur_index + 1)
		self.skill_cfg = TouShiData.Instance:GetTouShiSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = TouShiData.Instance:GetTouShiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 面饰技能
	elseif self.from_view == FROM_MASK then
		self.cur_data = MaskData.Instance:GetMaskSkillCfgById(self.cur_index) or {}
		self.info = MaskData.Instance:GetMaskInfo()
		bundle, asset = ResPath.GetMaskSkillIcon(self.cur_index + 1)
		self.skill_cfg = MaskData.Instance:GetMaskSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MaskData.Instance:GetMaskSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = MaskData.Instance:GetMaskGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 腰饰技能
	elseif self.from_view == FROM_WAIST then
		self.cur_data = WaistData.Instance:GetYaoShiSkillCfgById(self.cur_index) or {}
		self.info = WaistData.Instance:GetYaoShiInfo()
		bundle, asset = ResPath.GetYaoShiSkillIcon(self.cur_index + 1)
		self.skill_cfg = WaistData.Instance:GetYaoShiSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WaistData.Instance:GetYaoShiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 麒麟臂技能
	elseif self.from_view == FROM_QILINBI then
		self.cur_data = QilinBiData.Instance:GetQiLinBiSkillCfgById(self.cur_index) or {}
		self.info = QilinBiData.Instance:GetQilinBiInfo()
		bundle, asset = ResPath.GetQiLinBiSkillIcon(self.cur_index + 1)
		self.skill_cfg = QilinBiData.Instance:GetQiLinBiSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = QilinBiData.Instance:GetQiLinBiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end
	-- 战骑技能
	elseif self.from_view == FROM_FIGHTMOUNT then
		self.cur_data = FightMountData.Instance:GetMountSkillCfgById(self.cur_index) or {}
		self.info = FightMountData.Instance:GetFightMountInfo()
		bundle, asset = ResPath.GetFightMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = FightMountData.Instance:GetMountSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FightMountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.next_data_cfg.grade)
		end

	-- 灵珠
	elseif self.from_view == FROM_LINGZHU then
		self.cur_data = LingZhuData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = LingZhuData.Instance:GetLingZhuInfo()
		bundle, asset = ResPath.GetLingZhuSkillIcon(self.cur_index + 1)
		self.skill_cfg = LingZhuData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingZhuData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 仙宝
	elseif self.from_view == FROM_XIANBAO then
		self.cur_data = XianBaoData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = XianBaoData.Instance:GetXianBaoInfo()
		bundle, asset = ResPath.GetXianBaoSkillIcon(self.cur_index + 1)
		self.skill_cfg = XianBaoData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = XianBaoData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 灵童
	elseif self.from_view == FROM_LINGTONG then
		self.cur_data = LingChongData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = LingChongData.Instance:GetLingChongInfo()
		bundle, asset = ResPath.GetLingTongSkillIcon(self.cur_index + 1)
		self.skill_cfg = LingChongData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingChongData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end
		
	-- 灵弓
	elseif self.from_view == FROM_LINGGONG then
		self.cur_data = LingGongData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = LingGongData.Instance:GetLingGongInfo()
		bundle, asset = ResPath.GetLingGongSkillIcon(self.cur_index + 1)
		self.skill_cfg = LingGongData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingGongData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 灵骑
	elseif self.from_view == FROM_LINGQI then
		self.cur_data = LingQiData.Instance:GetSkillCfgById(self.cur_index) or {}
		-- self.info = LingQiData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		self.info = LingQiData.Instance:GetLingQiInfo()
		bundle, asset = ResPath.GetLingQiSkillIcon(self.cur_index + 1)
		self.skill_cfg = LingQiData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingQiData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 尾焰
	elseif self.from_view == FROM_WEIYAN then
		self.cur_data = WeiYanData.Instance:GetSkillCfgById(self.cur_index) or {}
		-- self.info = WeiYanData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		self.info = WeiYanData.Instance:GetWeiYanInfo()
		bundle, asset = ResPath.GetSkillIcon("WeiYanSkill_" .. (self.cur_index + 1))
		self.skill_cfg = WeiYanData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WeiYanData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(self.next_data_cfg.grade)		
		end

	-- 手环
	elseif self.from_view == FROM_SHOUHUAN then
		self.cur_data = ShouHuanData.Instance:GetSkillCfgById(self.cur_index) or {}
		-- self.info = ShouHuanData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		self.info = ShouHuanData.Instance:GetShouHuanInfo()
		bundle, asset = ResPath.GetSkillIcon("ShouHuanSkill_" .. (self.cur_index + 1))
		self.skill_cfg = ShouHuanData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShouHuanData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade(self.next_data_cfg.grade)		
		end

	-- 尾巴
	elseif self.from_view == FROM_TAIL then
		self.cur_data = TailData.Instance:GetSkillCfgById(self.cur_index) or {}
		-- self.info = TailData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		self.info = TailData.Instance:GetTailInfo()
		bundle, asset = ResPath.GetSkillIcon("TailSkill_" .. (self.cur_index + 1))
		self.skill_cfg = TailData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = TailData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = TailData.Instance:GetTailGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end

	-- 飞宠
	elseif self.from_view == FROM_FLYPET then
		self.cur_data = FlyPetData.Instance:GetSkillCfgById(self.cur_index) or {}
		-- self.info = FlyPetData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		self.info = FlyPetData.Instance:GetFlyPetInfo()
		bundle, asset = ResPath.GetSkillIcon("FlyPetSkill_" .. (self.cur_index + 1))
		self.skill_cfg = FlyPetData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FlyPetData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(self.next_data_cfg.grade)		
		end
	end

	if nil == self.info then
		return
	end

	is_active = nil ~= next(self.cur_data)
	self.item_id = self.cur_data.uplevel_stuff_id or self.next_data_cfg.uplevel_stuff_id
	local count = ItemData.Instance:GetItemNumInBagById(self.item_id)
	UI:SetButtonEnabled(self.node_list["UpLevelButton"], self.info.grade ~= 0 and nil ~= next(self.next_data_cfg))
	self.node_list["NormalSkillUpInfo"]:SetActive(self.cur_index ~= 0)
	self.node_list["SpecialSkillUpInfo"]:SetActive(self.cur_index == 0)
	self.node_list["ImgSIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgNIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.skill_name = self.cur_data.skill_name or self.next_data_cfg.skill_name or ""
	self.node_list["EffectSperialSkill"]:SetActive(is_active)
	self.node_list["EffectNomeralSkill"]:SetActive(is_active)
	if next(self.next_data_cfg) then
		self.node_list["TxtNomalUpLevelTip"]:SetActive(not is_active)
		self.node_list["TxtNomalUpLevelTipParent"]:SetActive(not is_active)
	else
		self.node_list["TxtNomalUpLevelTip"]:SetActive(true)
		self.node_list["TxtNomalUpLevelTipParent"]:SetActive(true)
	end
	self.is_Active_text = not is_active and Language.Mount.NotActive or ""
	self.node_list["TxtSProName"].text.text = string.format("%s   %s", self.skill_name, self.is_Active_text)
	self.node_list["TxtNProName"].text.text = string.format("%s   %s", self.skill_name, self.is_Active_text)
	self.node_list["TxtSSkillLevel"].text.text = string.format(Language.Advance.TipSkillUpgradeViewLevel, cur_level)
	self.node_list["TxtNSkillLevel"].text.text = string.format(Language.Advance.TipSkillUpgradeViewLevel, cur_level)

	if self.next_data_cfg and next(self.next_data_cfg) and self.info.grade >= self.next_data_cfg.grade then
		self.node_list["PanelShowMaxLevel"]:SetActive(false)
	else
		self.node_list["PanelShowMaxLevel"]:SetActive(true)
	end

	if self.temp_level == cur_level then
		return
	end

	if self.temp_level and self.temp_level < cur_level then
		if Status.NowTime - self.effect_cd > EFFECT_CD then
			self.node_list["EffectUI"]:SetActive(false)
			self.node_list["EffectUI"]:SetActive(true)
			self.effect_cd = Status.NowTime
		end
	else
		self.node_list["EffectUI"]:SetActive(false)
	end
	self.temp_level = cur_level

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg ~= nil then
		self.need_pro_name = item_cfg.name
		self.need_pro_id.item_id = item_cfg.id
		self.node_list["TxtNeed"].text.text = string.format("%s / %s", self.have_pro_num, self.need_pro_num)
		self.need_item_cell:SetData(self.need_pro_id)
	end

	if is_active then
		cur_desc = string.gsub(self.cur_data.desc, "%b()%%", function (str)
			return (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 1000)
		end)
		cur_desc = string.gsub(cur_desc, "%b[]%%", function (str)
			return (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		cur_desc = string.gsub(cur_desc, "%[.-%]", function (str)
			return self.cur_data[string.sub(str, 2, -2)]
		end)
		self.node_list["TxtCurSEft"].text.text = cur_desc
		self.node_list["TxtCurNEft"].text.text = cur_desc
	end

	if next(self.next_data_cfg) then
		self.grade = Language.Common.NumToChs[self.next_data_cfg.grade - 1]
		if self.info.grade >= self.next_data_cfg.grade then
			self.grade = ToColorStr(self.grade, TEXT_COLOR.GREEN)
		else
			self.grade = ToColorStr(self.grade, TEXT_COLOR.RED)
		end
		self.node_list["TxtNormal"].text.text = string.format(Language.Advance.TipSkillUpgradeViewTxt, self.advance_type, self.grade)
		if count < self.next_data_cfg.uplevel_stuff_num then
			self.have_pro_num = string.format(Language.Mount.ShowRedNum, count)	
			self.node_list["TxtNeed"].text.text = string.format("%s / %s", self.have_pro_num, self.need_pro_num)
			self.need_item_cell:SetData(self.need_pro_id)
		else
			self.have_pro_num = string.format(Language.Mount.ShowGreenStr, count)
			self.node_list["TxtNeed"].text.text = string.format("%s / %s", self.have_pro_num, self.need_pro_num)
			self.need_item_cell:SetData(self.need_pro_id)
		end
		self.need_pro_num = self.next_data_cfg.uplevel_stuff_num
		self.node_list["TxtNeed"].text.text = string.format("%s / %s", self.have_pro_num, self.need_pro_num)
		self.need_item_cell:SetData(self.need_pro_id)
		next_desc = string.gsub(self.next_data_cfg.desc, "%b()%%", function (str)
			return  (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 1000)..""
		end)
		next_desc = string.gsub(next_desc, "%b[]%%", function (str)
			return (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		next_desc = string.gsub(next_desc, "%[.-%]", function (str)
			return self.next_data_cfg[string.sub(str, 2, -2)]
		end)
		self.node_list["TxtSNextEft"].text.text = next_desc
		self.node_list["NextEffect"]:SetActive(true)
		self.node_list["TxtNNextEft"].text.text = next_desc
		self.node_list["TxtShowMax"]:SetActive(false)
		self.node_list["Item"]:SetActive(true)
		self.node_list["TxtNormal"]:SetActive(true)
		self.advance_type = Language.Advance.NAME_LIST[self.from_view]
		self.node_list["TxtNormal"].text.text = string.format(Language.Advance.TipSkillUpgradeViewTxt, self.advance_type, self.grade)
		self.node_list["TxtNomalUpLevelTip"].text.text = string.format(Language.Advance.TipSkillUpgradeViewActiveLevel, self.advance_type, self.can_up_level_grade)
		if self.client_grade_cfg then
			local str = string.format(Language.Mount.ShowRedStr, self.client_grade_cfg.gradename)
			if self.info.grade >= self.next_data_cfg.grade then
				str = string.format(Language.Mount.ShowGreenStr, self.client_grade_cfg.gradename)
			end
			self.can_up_level_grade = str
			self.node_list["TxtNomalUpLevelTip"].text.text = string.format(Language.Advance.TipSkillUpgradeViewActiveLevel, self.advance_type, self.can_up_level_grade)
		end
	else
		self.have_pro_num = string.format(Language.Mount.ShowRedNum, count)		
		self.grade = ""
		self.node_list["TxtNormal"].text.text = string.format(Language.Advance.TipSkillUpgradeViewTxt, self.advance_type,self.grade)

		self.node_list["TxtSNextEft"].text.text = Language.Common.MaxLvTips
		self.node_list["NextEffect"]:SetActive(false)

		self.node_list["TxtNNextEft"].text.text = Language.Common.MaxLvTips
		self.node_list["TxtNomalUpLevelTip"].text.text = Language.Common.MaxLvTips
		self.node_list["TxtShowMax"]:SetActive(true)
		self.node_list["Item"]:SetActive(false)
		self.node_list["TxtNormal"]:SetActive(false)
		self.need_pro_num = 0
		self.node_list["TxtNeed"].text.text = string.format("%s / %s", self.have_pro_num, self.need_pro_num)
		self.need_item_cell:SetData(self.need_pro_id)
	end
end

function TipSkillUpgradeView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountskill" then
			self.cur_index = v.index
			self.from_view = FROM_MOUNT
		elseif k == "wingskill" then
			self.cur_index = v.index
			self.from_view = FROM_WING
		elseif k == "haloskill" then
			self.cur_index = v.index
			self.from_view = FROM_HALO
		elseif k == "shengongskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENGONG
		elseif k == "shenyiskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENYI
		elseif k == "footskill" then
			self.cur_index = v.index
			self.from_view = FROM_FOOT
		elseif k == "fabaoskill" then
			self.cur_index = v.index
			self.from_view = FROM_FABAO
		elseif k == "fashionskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHIZHUANG
		elseif k == "wuqikill" then
			self.cur_index = v.index
			self.from_view = FROM_WUQI
		elseif k == "toushiskill" then
			self.cur_index = v.index
			self.from_view = FROM_TOUSHI
		elseif k == "maskskill" then
			self.cur_index = v.index
			self.from_view = FROM_MASK
		elseif k == "yaoshiskill" then
			self.cur_index = v.index
			self.from_view = FROM_WAIST
		elseif k == "qilinbiskill" then
			self.cur_index = v.index
			self.from_view = FROM_QILINBI
		elseif k == "fightmountskill" then
			self.cur_index = v.index
			self.from_view = FROM_FIGHTMOUNT
		elseif k == "lingzhuskill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGZHU
		elseif k == "xianbaoskill" then
			self.cur_index = v.index
			self.from_view = FROM_XIANBAO
		elseif k == "lingchongskill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGTONG
		elseif k == "linggongskill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGGONG
		elseif k == "lingqiskill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGQI
		elseif k == "weiyan_skill" then
			self.cur_index = v.index
			self.from_view = FROM_WEIYAN
		elseif k == "shouhuan_skill" then
			self.cur_index = v.index
			self.from_view = FROM_SHOUHUAN
		elseif k == "tail_skill" then
			self.cur_index = v.index
			self.from_view = FROM_TAIL
		elseif k == "flypet_skill" then
			self.cur_index = v.index
			self.from_view = FROM_FLYPET
		end
	end

	if self.cur_index ~= nil then
		self:SetData()
	end
end