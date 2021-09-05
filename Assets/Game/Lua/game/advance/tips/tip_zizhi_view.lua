TipZiZhiView = TipZiZhiView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开
local FROM_FIGHT_MOUNT = 6  -- 从战骑界面打开
local FROM_LING_REN = 7    -- 从灵刃界面打开
local FROM_FOOT = 8    		-- 从足迹界面打开
local FROM_CLOAK = 9    	-- 从披风界面打开
local FROM_FABAO = 10 		-- 从法宝界面打开
local FROM_FASHION = 11		-- 从时装界面打开
local FROM_WUQI = 12		-- 从时装武器界面打开 神兵
local FROM_WAIST = 13		-- 从腰饰界面打开
local FROM_TOUSHI = 14		-- 从头饰界面打开
local FROM_QILINBI = 15		-- 从麒麟臂界面打开
local FROM_MASK = 16		-- 从面饰界面打开
local FROM_LING_ZHU	= 17	-- 从灵珠界面打开
local FROM_XIAN_BAO = 18	-- 从仙宝界面打开
local FROM_LING_TONG = 19	-- 从灵童界面打开
local FROM_LING_GONG = 20	-- 从灵弓界面打开
local FROM_LING_QI = 21		-- 从灵骑界面打开
local FROM_WEI_YAN = 22		-- 从尾焰界面打开
local FROM_SHOU_HUAN = 23	-- 从手环界面打开
local FROM_TAIL = 24		-- 从尾巴界面打开
local FROM_FLY_PET = 25		-- 从飞宠界面打开


-- local NameList = {"坐骑", "羽翼", "光环", "神弓", "神翼", "战骑", "灵刃", "足迹", "披风", "法宝", "时装", "神兵", "腰饰", "头饰", "麒麟臂", "面饰"}

local FLUSH_PARAM = {[FROM_MOUNT] = "mount", [FROM_WING] = "wing", [FROM_HALO] = "halo", [FROM_SHENGONG] = "shengong",
		[FROM_SHENYI] = "shenyi", [FROM_FIGHT_MOUNT] = "fightmount", [FROM_LING_REN] = "shen_bing", [FROM_FOOT] = "foot", [FROM_CLOAK] = "cloak",
		[FROM_FABAO] = "fabao", [FROM_FASHION] = "fashion", [FROM_WUQI] = "wuqi", [FROM_WAIST] = "waist", [FROM_TOUSHI] = "toushi", [FROM_QILINBI] = "qilinbi",
		[FROM_MASK] = "mask", [FROM_LING_ZHU] = "lingzhu", [FROM_XIAN_BAO] = "xianbao", [FROM_LING_TONG] = "lingtong", [FROM_LING_GONG] = "linggong", 
		[FROM_LING_QI] = "lingqi", [FROM_WEI_YAN] = "weiyan", [FROM_SHOU_HUAN] = "shouhuan", [FROM_TAIL] = "tail", [FROM_FLY_PET] = "flypet",
}

function TipZiZhiView:__init()
	self.ui_config = {{"uis/views/tips/advancetips_prefab", "ZiZhiTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_first_open = false
	self.get_way_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

-- 创建完调用
function TipZiZhiView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["UseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUseButton, self))

	self.icon_list = {}
	self.icon_name_list = {}
	self.bg_node_list = {}
	for i = 1,3 do
		self.icon_list[i] = self.node_list["IconWay" .. i]
		self.node_list["IconWay" .. i].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, i))
		self.icon_name_list[i] = self.node_list["TxtIcon" .. i]
		self.bg_node_list[i] = self.node_list["BtnWay" .. i]
	end

	self.have_pro_num = ""
	self.pro_name = ""
	self.next_use_num = ""
	self.jie_text = ""

	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemCell"])

	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = 0
	self.grade_cfg = nil
	self.item_id = nil
	self.max_grade = 0
	self.grade = -1
	self.next_max_shuxingdan_count = nil
	self:Flush()
end

function TipZiZhiView:ReleaseCallBack()
	self.exp_cur_value = nil
	self.exp_max_value = nil
	self.from_view = nil
	self.info = nil
	self.max_shuxingdan_count = nil
	self.grade_cfg = nil
	self.item_id = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	self.get_way_list = {}

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	-- 清理变量和对象
	self.gongji = nil
	self.gongji_add = nil
	self.fangyu = nil
	self.fangyu_add = nil
	self.shengming = nil
	self.shengming_add = nil
	self.have_pro_num = nil
	self.explain = nil
	self.exp_cur_value = nil
	self.exp_max_value = nil
	self.pro_name = nil
	self.cur_uese_text = nil
	self.next_use_num = nil
	self.show_ways = nil
	self.show_icons = nil
	self.show_next_effect = nil
	self.show_tip = nil
	self.show_next_use_text = nil
	self.tip_name = nil
	self.icon_list = nil
	self.icon_name_list = nil
	self.use_button = nil
	self.scroller = nil
	self.jie_text = nil
	self.is_text_gray = nil
end

function TipZiZhiView:OnClickWay(index)
	if nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	ViewManager.Instance:Close(ViewName.Advance)
	local list = Split(self.get_way_list[index], "#")
	if list then
		local tab_index = list[2] and TabIndex[list[2]] or 2701
		ViewManager.Instance:Open(list[1], tab_index)
	end

	self:Close()
end

function TipZiZhiView:OpenCallBack()
	self.is_first_open = true
	self.can_use = true

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)

	self.node_list["Scroller"].scroll_rect.normalizedPosition = Vector2(0, 1)

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function TipZiZhiView:CloseCallBack()
	self.is_first_open = false
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.info = nil
	self.max_shuxingdan_count = nil
	self.grade_cfg = nil
	self.can_use = nil
	self.is_first_open = nil
	self.max_grade = nil
	self.next_max_shuxingdan_count = nil
	self.get_way_list = {}
end

function TipZiZhiView:OnClickCloseButton()
	self:Close()
end

function TipZiZhiView:OnClickUseButton()
	if self.info == nil or self.grade_cfg == nil or self.max_shuxingdan_count == nil then
		return
	end
	if (self.grade_cfg.shuxingdan_limit + self.max_shuxingdan_count) == 0 and self.from_view ~= FROM_LING_REN then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
		return
	end

	if self.info.shuxingdan_count >= self.max_shuxingdan_count and self.from_view ~= FROM_LING_REN then
		TipsCtrl.Instance:ShowSystemMsg(self.from_view ~= FROM_LING_REN and Language.Mount.GradeNoEnough or Language.Common.ShenBingZiZhiLimit)
		return
	end

	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)

	if self.bag_prop_data == nil then
		local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_shop_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			return
		else
			if item_shop_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(self.item_id, 2)
				return
			end

			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
			return
		end
	end
	
	if not self.can_use then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local neednum = self.max_shuxingdan_count > self.info.shuxingdan_count and (self.max_shuxingdan_count - self.info.shuxingdan_count) or 0
	local use_num = self.have_pro_num < neednum and self.have_pro_num or neednum
	PackageCtrl.Instance:SendUseItemMaxNum(self.item_id, use_num)

	self.can_use = false
end

function TipZiZhiView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == MountDanId.ZiZhiDanId or item_id == WingDanId.ZiZhiDanId or item_id == FootDanId.ZiZhiDanId or
		item_id == HaloDanId.ZiZhiDanId or item_id == ShengongDanId.ZiZhiDanId or item_id == ShenyiDanId.ZiZhiDanId
		or item_id == FightMountDanId.ZiZhiDanId or item_id == ShenBingDanId.ZiZhiDanId or item_id == CloakDanId.ZiZhiDanId
		or item_id == FaBaoDanId.ZiZhiDanId or item_id == FashionDanId.ZiZhiDanId or item_id == FashionDanId.ShenBingZiZhiDanID
		or item_id == TouShiShuXingDanId.ZiZhiDanId then

		if self.from_view == FROM_SHENGONG or self.from_view == FROM_SHENYI then
			GoddessCtrl.Instance:FlushView(FLUSH_PARAM[self.from_view])
		else
			AdvanceCtrl.Instance:FlushViewFromZiZhi(FLUSH_PARAM[self.from_view])
		end

		self.have_pro_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
		self.node_list["TxtProName"].text.text = string.format(Language.Advance.TipZiZhiHave, self.pro_name, self.have_pro_num)
		self.can_use = true
	end
end

function TipZiZhiView:SetData()
	if self.from_view == FROM_MOUNT then
		self.info = MountData.Instance:GetMountInfo()
		self.max_shuxingdan_count = MountData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)
		self.max_grade = MountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < MountData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and MountData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_WING then
		self.info = WingData.Instance:GetWingInfo()
		self.max_shuxingdan_count = WingData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
		self.max_grade = WingData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < WingData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and WingData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_HALO then
		self.info = HaloData.Instance:GetHaloInfo()
		self.max_shuxingdan_count = HaloData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
		self.max_grade = HaloData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < HaloData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and HaloData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_FOOT then
		self.info = FootData.Instance:GetFootInfo()
		self.max_shuxingdan_count = FootData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = FootData.Instance:GetFootGradeCfg(self.info.grade)
		self.max_grade = FootData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < FootData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and FootData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_SHENGONG then
		self.info = ShengongData.Instance:GetShengongInfo()
		self.max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.info.grade)
		self.max_grade = ShengongData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShengongData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count
	elseif self.from_view == FROM_SHENYI then
		self.info = ShenyiData.Instance:GetShenyiInfo()
		self.max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.info.grade)
		self.max_grade = ShenyiData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		self.next_max_shuxingdan_count = ShenyiData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count
	elseif self.from_view == FROM_FIGHT_MOUNT then
		self.info = FightMountData.Instance:GetFightMountInfo()
		self.max_shuxingdan_count = FightMountData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.info.grade)
		self.max_grade = FightMountData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < FightMountData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and FightMountData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_LING_REN then
		-- 以前叫神兵系统，但其实是灵刃系统，现在名字改回来
		local ling_ren_data = LingRenData.Instance
		self.info = ling_ren_data:GetShenBingInfo()
		self.max_shuxingdan_count = ling_ren_data:GetLimitXingDanCount()
		self.grade_cfg = ling_ren_data:GetLevelAttrCfg(self.info.level)
		self.max_grade = #ling_ren_data:GetShenBingCfg().level_attr
		local level, next_count = ling_ren_data:GetLimitXingDanNextLevelCount(self.info.level)
		self.grade = level
		local no_max_level = self.grade < self.max_grade
		self.next_max_shuxingdan_count = no_max_level and next_count or 0
	elseif self.from_view == FROM_CLOAK then
		self.info = CloakData.Instance:GetCloakInfo()
		self.info.level = self.info.cloak_level
		local level_cfg = CloakData.Instance:GetCloakLevelCfg(self.info.level)
		self.max_shuxingdan_count = level_cfg and level_cfg.shuxingdan_limit or 0
		self.grade_cfg = CloakData.Instance:GetCloakLevelCfg(self.info.level)
		self.max_grade = CloakData.Instance:GetMaxCloakLevel()
		local level, next_count = CloakData.Instance:GetCloakNextLevelCfg(self.info.level)
		self.grade = level
		local no_max_level = self.grade < self.max_grade
		self.next_max_shuxingdan_count = no_max_level and next_count or 0
		-- local next_level_cfg = CloakData.Instance:GetCloakLevelCfg(self.info.level + 1)
		-- self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or level_cfg.shuxingdan_limit
	elseif self.from_view == FROM_FABAO then
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		self.max_shuxingdan_count = FaBaoData.Instance:GetSpecialImageAttrSum().shuxingdan_count
		self.grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.info.grade)
		self.max_grade = FaBaoData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, active_special_image_flag = self.info.active_special_image_flag}
		local no_max_level = self.info.grade < FaBaoData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and FaBaoData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_FASHION then
		self.info = FashionData.Instance:GetFashionZizhiInfo()
		self.grade_cfg = FashionData.Instance:GetShizhuangUpgrade(self.info.grade)
		self.max_shuxingdan_count = self.grade_cfg.shuxingdan_limit
		self.max_grade = FashionData.Instance:GetShizhuangImgMaxGrade()
		local next_level_cfg = FashionData.Instance:GetShizhuangUpgrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0
	elseif self.from_view == FROM_WUQI then
		self.info = FashionData.Instance:GetWuQiInfo()
		self.grade_cfg = FashionData.Instance:GetWuQiGradeCfg(self.info.grade)
		self.max_shuxingdan_count = self.grade_cfg.shuxingdan_limit
		self.max_grade = FashionData.Instance:GetMaxGrade()
		local info = {grade = self.info.grade + 1, special_active_flag = self.info.special_active_flag}
		local no_max_level = self.info.grade < FashionData.Instance:GetMaxGrade()
		self.next_max_shuxingdan_count = no_max_level and FashionData.Instance:GetSpecialImageAttrSum(info).shuxingdan_count or 0
	elseif self.from_view == FROM_WAIST then
		self.info = WaistData.Instance:GetYaoShiInfo()
		self.grade_cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = WaistData.Instance:GetMaxShuXingDanCount()
		self.max_grade = WaistData.Instance:GetYaoShiMaxGrade()
		local next_level_cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0
	elseif self.from_view == FROM_TOUSHI then
		self.info = TouShiData.Instance:GetTouShiInfo()
		self.grade_cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = TouShiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = TouShiData.Instance:GetTouShiMaxGrade()
		local next_level_cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0
	elseif self.from_view == FROM_QILINBI then
		self.info = QilinBiData.Instance:GetQilinBiInfo()
		self.grade_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = QilinBiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = QilinBiData.Instance:GetQiLinBiMaxGrade()
		local next_level_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0
	elseif self.from_view == FROM_MASK then
		self.info = MaskData.Instance:GetMaskInfo()
		self.grade_cfg = MaskData.Instance:GetMaskGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = MaskData.Instance:GetMaxShuXingDanCount()
		self.max_grade = MaskData.Instance:GetMaskMaxGrade()
		local next_level_cfg =  MaskData.Instance:GetMaskGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_LING_ZHU then
		self.info = LingZhuData.Instance:GetLingZhuInfo()
		self.grade_cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = LingZhuData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingZhuData.Instance:GetLingZhuMaxGrade()
		local next_level_cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_XIAN_BAO then
		self.info = XianBaoData.Instance:GetXianBaoInfo()
		self.grade_cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = XianBaoData.Instance:GetMaxShuXingDanCount()
		self.max_grade = XianBaoData.Instance:GetXianBaoMaxGrade()
		local next_level_cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_LING_TONG then
		self.info = LingChongData.Instance:GetLingChongInfo()
		self.grade_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = LingChongData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingChongData.Instance:GetLingChongMaxGrade()
		local next_level_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_LING_GONG then
		self.info = LingGongData.Instance:GetLingGongInfo()
		self.grade_cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = LingGongData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingGongData.Instance:GetLingGongMaxGrade()
		local next_level_cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_LING_QI then
		self.info = LingQiData.Instance:GetLingQiInfo()
		self.grade_cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = LingQiData.Instance:GetMaxShuXingDanCount()
		self.max_grade = LingQiData.Instance:GetLingQiMaxGrade()
		local next_level_cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_WEI_YAN then
		self.info = WeiYanData.Instance:GetWeiYanInfo()
		self.grade_cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = WeiYanData.Instance:GetMaxShuXingDanCount()
		self.max_grade = WeiYanData.Instance:GetWeiYanMaxGrade()
		local next_level_cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_SHOU_HUAN then
		self.info = ShouHuanData.Instance:GetShouHuanInfo()
		self.grade_cfg = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = ShouHuanData.Instance:GetMaxShuXingDanCount()
		self.max_grade = ShouHuanData.Instance:GetShouHuanMaxGrade()
		local next_level_cfg = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_TAIL then
		self.info = TailData.Instance:GetTailInfo()
		self.grade_cfg = TailData.Instance:GetTailGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = TailData.Instance:GetMaxShuXingDanCount()
		self.max_grade = TailData.Instance:GetTailMaxGrade()
		local next_level_cfg = TailData.Instance:GetTailGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0

	elseif self.from_view == FROM_FLY_PET then
		self.info = FlyPetData.Instance:GetFlyPetInfo()
		self.grade_cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(self.info.grade)
		self.max_shuxingdan_count = FlyPetData.Instance:GetMaxShuXingDanCount()
		self.max_grade = FlyPetData.Instance:GetFlyPetMaxGrade()
		local next_level_cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(self.info.grade + 1)
		self.next_max_shuxingdan_count = next_level_cfg and next_level_cfg.shuxingdan_limit or 0
	end

	if self.info == nil or self.max_shuxingdan_count == nil or self.grade_cfg == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local shuxingdan = nil
	for k, v in pairs(shuxingdan_cfg) do
		if v.slot_idx == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI then
			if v.type == MountShuXingDanCfgType.Type and self.from_view == FROM_MOUNT then
				shuxingdan = v
				break
			elseif v.type == WingShuXingDanCfgType.Type and self.from_view == FROM_WING then
				shuxingdan = v
				break
			elseif v.type == HaloShuXingDanCfgType.Type and self.from_view == FROM_HALO then
				shuxingdan = v
				break
			elseif v.type == FootShuXingDanCfgType.Type and self.from_view == FROM_FOOT then
				shuxingdan = v
				break
			elseif v.type == ShengongShuXingDanCfgType.Type and self.from_view == FROM_SHENGONG then
				shuxingdan = v
				break
			elseif v.type == ShenyiShuXingDanCfgType.Type and self.from_view == FROM_SHENYI then
				shuxingdan = v
				break
			elseif v.type == FightMountShuXingDanCfgType.Type and self.from_view == FROM_FIGHT_MOUNT then
				shuxingdan = v
				break
			elseif v.type == ShenBingShuXingDanCfgType.Type and self.from_view == FROM_LING_REN then
				shuxingdan = v
				break
			elseif v.type == CloakShuXingDanCfgType.Type and self.from_view == FROM_CLOAK then
				shuxingdan = v
				break
			elseif v.type == FaBaoShuXingDanCfgType.Type and self.from_view == FROM_FABAO then
				shuxingdan = v
				break
			elseif v.type == ShizhuangShuXingDanCfgType.Type and self.from_view == FROM_FASHION then
				shuxingdan = v
				break
			elseif v.type == WuQiShuXingDanCfgType.Type and self.from_view == FROM_WUQI then
				shuxingdan = v
				break
			elseif v.type == YaoShiShuXingDanCfgType.Type and self.from_view == FROM_WAIST then
				shuxingdan = v
				break
			elseif v.type == TouShiShuXingDanCfgType.Type and self.from_view == FROM_TOUSHI then
				shuxingdan = v
				break
			elseif v.type == QilinBiShuXingDanCfgType.Type and self.from_view == FROM_QILINBI then
				shuxingdan = v
				break
			elseif v.type == MaskShuXingDanCfgType.Type and self.from_view == FROM_MASK then
				shuxingdan = v
				break
			elseif v.type == LingZhuShuXingDanCfgType.Type and self.from_view == FROM_LING_ZHU then
				shuxingdan = v
				break
			elseif v.type == XianBaoShuXingDanCfgType.Type and self.from_view == FROM_XIAN_BAO then
				shuxingdan = v
				break
			elseif v.type == LingChongShuXingDanCfgType.Type and self.from_view == FROM_LING_TONG then
				shuxingdan = v
				break
			elseif v.type == LingGongShuXingDanCfgType.Type and self.from_view == FROM_LING_GONG then
				shuxingdan = v
				break
			elseif v.type == LingQiShuXingDanCfgType.Type and self.from_view == FROM_LING_QI then
				shuxingdan = v
				break
			elseif v.type == WeiYanShuXingDanCfgType.Type and self.from_view == FROM_WEI_YAN then
				shuxingdan = v
				break
			elseif v.type == ShouHuanShuXingDanCfgType.Type and self.from_view == FROM_SHOU_HUAN then
				shuxingdan = v
				break
			elseif v.type == TailShuXingDanCfgType.Type and self.from_view == FROM_TAIL then
				shuxingdan = v
				break
			elseif v.type == FlyPetShuXingDanCfgType.Type and self.from_view == FROM_FLY_PET then
				shuxingdan = v
				break
			end
		end
	end

	if not shuxingdan then return end

	self.node_list["TxtHp"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["hp"], shuxingdan.maxhp * self.info.shuxingdan_count)
	self.node_list["TxtHpAdd"].text.text = shuxingdan.maxhp
	self.node_list["TxtGongji"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["gongji"], shuxingdan.gongji * self.info.shuxingdan_count)
	self.node_list["TxtGongjiAdd"].text.text = shuxingdan.gongji
	self.node_list["TxtFangyu"].text.text = string.format(Language.Advance.TipZiZhiViewAttr["fangyu"], shuxingdan.fangyu * self.info.shuxingdan_count)
	self.node_list["TxtFangyuAdd"].text.text = shuxingdan.fangyu
	local data = {}
	data.item_id = self.item_id
	data.prop_name = item_cfg.pro_name
	self.cell:SetData(data)
	self.bag_prop_data = ItemData.Instance:GetItem(self.item_id)
	self.have_pro_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	self.exp_cur_value = self.info.shuxingdan_count
	self.exp_max_value = self.max_shuxingdan_count
	self.node_list["TxtExpVal"].text.text = string.format("%s/%s", self.info.shuxingdan_count, self.max_shuxingdan_count)
	self.pro_name = item_cfg.name
	self.node_list["TxtProName"].text.text = string.format(Language.Advance.TipZiZhiHave, self.pro_name, self.have_pro_num)
	self.jie_text = self.from_view == FROM_LING_REN and Language.Common.Ji or Language.Common.Jie
	self.node_list["TxtCurUse"]:SetActive(true)
	self.node_list["TxTips"]:SetActive(false)
	if self.is_first_open then
		self.node_list["SliderProgressBG"].slider.value = self.info.shuxingdan_count / self.max_shuxingdan_count
	else
		self.node_list["SliderProgressBG"].slider.value = self.info.shuxingdan_count / self.max_shuxingdan_count
	end

	local str = ""
	str = string.format(Language.Advance.GreenStr, self.info.shuxingdan_count, self.max_shuxingdan_count)
	if self.info.shuxingdan_count >= self.max_shuxingdan_count then
		str = string.format(Language.Advance.RedStr, self.info.shuxingdan_count, self.max_shuxingdan_count)
	end
	self.node_list["TxtCurUse"].text.text = string.format(Language.Advance.TipZiZhiUseNum, str)
	self.next_use_num = self.next_max_shuxingdan_count or 0
	
	if self.from_view ~= FROM_LING_REN and self.from_view ~= FROM_CLOAK then
		self.node_list["TxtNextUse"].text.text = string.format(Language.Advance.TipZiZhiNextUseNum, self.jie_text, self.next_use_num)
	else
		self.node_list["TxtNextUse"]:SetActive(self.grade == -1)
		self.node_list["TxtNextUse"].text.text = string.format(Language.Advance.TipZiZhiLevelUseNum, self.grade, self.next_use_num)
	end
	self.is_first_open = false
	self.node_list["ImgShowGongjiIcon"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["TxtShowGongjiText"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["ImgShowFangyuIcon"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["ImgShowFangyuTxt"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["ImgShowHPIcon"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["ImgShowHPTxt"]:SetActive(self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count)
	self.node_list["TxtNextUse"]:SetActive(self.next_max_shuxingdan_count and self.next_max_shuxingdan_count > 0 or false)
	self.node_list["node_gongji_null"]:SetActive (not (self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count))
	self.node_list["node_fangyu_null"]:SetActive (not (self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count))
	self.node_list["node_shengming_null"]:SetActive(not (self.max_grade > (self.info.grade or self.info.level) or self.max_shuxingdan_count > self.info.shuxingdan_count))
	local is_limit = true
	if self.info.grade then
		is_limit = (self.info.grade or self.info.level) > shuxingdan.order_limit - 1
	end
	if is_limit and self.info.shuxingdan_count < self.max_shuxingdan_count then
		self.node_list["TxtGrayBtn"].text.text = Language.Advance.OneUse
	elseif self.info.shuxingdan_count >= self.max_shuxingdan_count then 
		self.node_list["TxtGrayBtn"].text.text = Language.Advance.YiDaShangXian
	else
		self.node_list["TxtGrayBtn"].text.text = Language.Advance.SanJieUse
	end
	if self.from_view == FROM_LING_REN or self.from_view == FROM_CLOAK then
		UI:SetButtonEnabled(self.node_list["UseButton"], ((self.info.level < self.max_grade) and true or (self.max_shuxingdan_count > self.info.shuxingdan_count)) and is_limit)
	else
		UI:SetButtonEnabled(self.node_list["UseButton"], ((self.info.grade < self.max_grade) and true or (self.max_shuxingdan_count > self.info.shuxingdan_count)) and is_limit)
	end
end

function TipZiZhiView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.bg_node_list) do
		v:SetActive(false)
		self.node_list["TxtWay" .. k]:SetActive(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.node_list["PanelWayBtn"]:SetActive(true)
				self.node_list["PanelWayText"]:SetActive(false)
				if tonumber(v) == 0 then
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon("Icon_System_Shop")
					self.icon_list[k].image:LoadSprite(bundle,asset, function()
						self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k]:SetActive(true)
					self.bg_node_list[k]:SetActive(true)
					local bundle, asset = ResPath.GetMainIcon(getway_cfg_k.icon)
					self.icon_list[k].image:LoadSprite(bundle,asset, function()
						self.icon_list[k].image:SetNativeSize()
					end)
					self.icon_name_list[k].image:LoadSprite(bundle, asset .. "Name", function()
						self.icon_name_list[k].image:SetNativeSize()
					end)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["PanelWayText"]:SetActive(true)
				self.node_list["PanelWayBtn"]:SetActive(false)
				if tonumber(v) == 0 then
					self.node_list["TxtWay" .. k]:SetActive(true)
					self.node_list["TxtWay" .. k].text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.node_list["TxtWay" .. k]:SetActive(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.node_list["TxtWay" .. k].text.text = getway_cfg_k.button_name
					else
						self.node_list["TxtWay" .. k].text.text = getway_cfg_k.discription
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.node_list["PanelWayText"]:SetActive(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.node_list["PanelWayBtn"]:SetActive(false)
		for k, v in pairs(msg) do
			self.node_list["TxtWay" .. k]:SetActive(true)
			self.node_list["TxtWay" .. k].text.text = v
		end
	end
end

function TipZiZhiView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountzizhi" then
			self.item_id = v.item_id or MountDanId.ZiZhiDanId
			self.from_view = FROM_MOUNT
		elseif k == "wingzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WING
		elseif k == "halozizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_HALO
		elseif k == "shengongzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_SHENGONG
		elseif k == "shenyizizhi" then 
			self.item_id = v.item_id
			self.from_view = FROM_SHENYI
		elseif k == "fightmountzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FIGHT_MOUNT
		elseif k == "shenbingzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_REN
		elseif k == "footzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FOOT
		elseif k == "cloakzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_CLOAK
		elseif k == "fabaozizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FABAO
		elseif k == "fashionzizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FASHION
		elseif k == "wuqizizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WUQI
		elseif k == "waist_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WAIST
		elseif k == "toushi_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_TOUSHI
		elseif k == "qilinbi_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_QILINBI
		elseif k == "mask_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_MASK
		elseif k == "lingzhu_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_ZHU
		elseif k == "xianbao_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_XIAN_BAO
		elseif k == "lingchong_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_TONG
		elseif k == "linggong_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_GONG
		elseif k == "lingqi_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_QI
		elseif k == "weiyan_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_WEI_YAN
		elseif k == "shouhuan_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_SHOU_HUAN
		elseif k == "tail_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_TAIL
		elseif k == "flypet_zizhi" then
			self.item_id = v.item_id
			self.from_view = FROM_FLY_PET
		end

		if self.item_id ~= nil then
			self:SetData()
			self:ShowWay()
		end
	end
end


