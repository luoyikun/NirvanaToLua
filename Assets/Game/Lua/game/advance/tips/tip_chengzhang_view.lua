-- 成长丹提示框-ChengZhangTip
TipChengZhangView = TipChengZhangView or BaseClass(BaseView)

local FROM_TOUSHI = 1		-- 从头饰界面打开
local FROM_MASK = 2			-- 从面饰界面打开
local FROM_WAIST = 3		-- 从腰饰界面打开
local FROM_QILINBI = 4		-- 从麒麟臂界面打开
local FROM_CLOAK = 5 		-- 从披风界面打开
local FROM_LING_REN = 6 	-- 从灵刃界面打开
local FROM_LING_ZHU	= 7		-- 从灵珠界面打开
local FROM_XIAN_BAO = 8		-- 从仙宝界面打开
local FROM_LING_TONG = 9	-- 从灵童界面打开
local FROM_LING_GONG = 10	-- 从灵弓界面打开
local FROM_LING_QI = 11		-- 从灵骑界面打开
local FROM_WEI_YAN = 12		-- 从尾焰界面打开
local FROM_SHOU_HUAN = 13	-- 从手环界面打开
local FROM_TAIL = 14		-- 从尾巴界面打开
local FROM_FLY_PET = 15		-- 从飞宠界面打开

function TipChengZhangView:__init()
	self.ui_config = {{"uis/views/tips/advancetips_prefab", "ChengZhangTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.get_way_list = {}
	self.from_view = nil
	self.info = nil
	self.max_chengzhangdan_count = nil
	self.next_grade_max_chengzhangdan_count = nil
	self.item_id = nil
	self.can_use = true
end

function TipChengZhangView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["UseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUseButton, self))
	self.node_list["TxtWay1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["BtnWay1"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 1))
	self.node_list["TxtWay2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["BtnWay2"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 2))
	self.node_list["TxtWay3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))
	self.node_list["BtnWay3"].button:AddClickListener(BindTool.Bind(self.OnClickWay, self, 3))

	self.text_way_list = {
		{is_show = self.node_list["TxtWay1"], name = self.node_list["TxtWay1"]},
		{is_show = self.node_list["TxtWay2"], name = self.node_list["TxtWay2"]},
		{is_show = self.node_list["TxtWay3"], name = self.node_list["TxtWay3"]}
	}
	self.icon_list = {
		{is_show = self.node_list["BtnWay1"], icon = self.node_list["TxtIcon1"]},
		{is_show = self.node_list["BtnWay2"], icon = self.node_list["TxtIcon2"]},
		{is_show = self.node_list["BtnWay3"], icon = self.node_list["TxtIcon3"]},
	}
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemParent"])
end

function TipChengZhangView:ReleaseCallBack()
	self.get_way_list = {}
	self.from_view = nil
	self.info = nil
	self.max_chengzhangdan_count = nil
	self.next_grade_max_chengzhangdan_count = nil
	self.item_id = nil
	self.can_use = nil

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function TipChengZhangView:OpenCallBack()
	self.can_use = true

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function TipChengZhangView:CloseCallBack()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.can_use = nil
	self.info = nil
	self.next_grade_max_chengzhangdan_count = nil
	self.max_chengzhangdan_count = nil
	self.level = nil
end

function TipChengZhangView:OnClickWay(index)
	if nil == index or nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	ViewManager.Instance:OpenByCfg(self.get_way_list[index], data)
	self:Close()
end

-- 使用成长丹
function TipChengZhangView:OnClickUseButton()
	if nil == self.info or nil == self.max_chengzhangdan_count then
		return
	end

	if self.info.chengzhangdan_count >= self.max_chengzhangdan_count then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mount.GradeNoEnough)
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
			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
			return
		end
	end
	if not self.can_use then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local neednum = self.max_chengzhangdan_count > self.info.chengzhangdan_count and (self.max_chengzhangdan_count - self.info.chengzhangdan_count) or 0
	local use_num = self.have_pro_num < neednum and self.have_pro_num or neednum
	PackageCtrl.Instance:SendUseItemMaxNum(self.item_id, use_num)
	self.can_use = false
end

function TipChengZhangView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == TouShiShuXingDanId.ChengZhangDanId then
		self.have_pro_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
		self.node_list["TxtProName"].text.text = string.format(Language.Advance.TipChengZhangViewTextProName, self.prop_name, self.have_pro_num)
		self.can_use = true
	end
end

function TipChengZhangView:SetData()
	-- 头饰
	if self.from_view == FROM_TOUSHI then
		self.info = TouShiData.Instance:GetTouShiInfo()
		self.max_chengzhangdan_count = TouShiData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = TouShiData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 面饰
	elseif self.from_view == FROM_MASK then
		self.info = MaskData.Instance:GetMaskInfo()
		self.max_chengzhangdan_count = MaskData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = MaskData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 腰饰
	elseif self.from_view == FROM_WAIST then
		self.info = WaistData.Instance:GetYaoShiInfo()
		self.max_chengzhangdan_count = WaistData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = WaistData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 麒麟臂
	elseif self.from_view == FROM_QILINBI then
		self.info = QilinBiData.Instance:GetQilinBiInfo()
		self.max_chengzhangdan_count = QilinBiData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = QilinBiData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 披风
	elseif self.from_view == FROM_CLOAK then
		self.info = CloakData.Instance:GetCloakInfo()
		self.max_chengzhangdan_count = CloakData.Instance:GetMaxChengZhangDanCount()
		local level, next_count = CloakData.Instance:GetChengZhangDanNextLevel(self.info.cloak_level)
		self.max_grade = CloakData.Instance:GetMaxCloakLevel()
		self.level = level
		self.next_grade_max_chengzhangdan_count = next_count

	-- 灵刃
	elseif self.from_view == FROM_LING_REN then
		self.info = LingRenData.Instance:GetShenBingInfo()
		self.max_chengzhangdan_count = LingRenData.Instance:GetMaxChengZhangDanCount()
		local level, next_count = LingRenData.Instance:GetChengZhangDanNextLevel(self.info.level)
		self.max_grade = LingRenData.Instance:GetMaxLevel()
		self.level = level
		self.next_grade_max_chengzhangdan_count = next_count

	-- 灵珠
	elseif self.from_view == FROM_LING_ZHU then
		self.info = LingZhuData.Instance:GetLingZhuInfo()
		self.max_chengzhangdan_count = LingZhuData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = LingZhuData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 仙宝
	elseif self.from_view == FROM_XIAN_BAO then
		self.info = XianBaoData.Instance:GetXianBaoInfo()
		self.max_chengzhangdan_count = XianBaoData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = XianBaoData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)
	
	-- 灵童
	elseif self.from_view == FROM_LING_TONG then
		self.info = LingChongData.Instance:GetLingChongInfo()
		self.max_chengzhangdan_count = LingChongData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = LingChongData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 灵弓
	elseif self.from_view == FROM_LING_GONG then
		self.info = LingGongData.Instance:GetLingGongInfo()
		self.max_chengzhangdan_count = LingGongData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = LingGongData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)
		
	-- 灵骑
	elseif self.from_view == FROM_LING_QI then
		self.info = LingQiData.Instance:GetLingQiInfo()
		self.max_chengzhangdan_count = LingQiData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = LingQiData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 尾焰
	elseif self.from_view == FROM_WEI_YAN then
		self.info = WeiYanData.Instance:GetWeiYanInfo()
		self.max_chengzhangdan_count = WeiYanData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = WeiYanData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)
		
	-- 手环
	elseif self.from_view == FROM_SHOU_HUAN then
		self.info = ShouHuanData.Instance:GetShouHuanInfo()
		self.max_chengzhangdan_count = ShouHuanData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = ShouHuanData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)
		
	-- 尾巴
	elseif self.from_view == FROM_TAIL then
		self.info = TailData.Instance:GetTailInfo()
		self.max_chengzhangdan_count = TailData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = TailData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)

	-- 飞宠
	elseif self.from_view == FROM_FLY_PET then
		self.info = FlyPetData.Instance:GetFlyPetInfo()
		self.max_chengzhangdan_count = FlyPetData.Instance:GetMaxChengZhangDanCount()
		self.next_grade_max_chengzhangdan_count = FlyPetData.Instance:GetMaxChengZhangDanCount(self.info.grade + 1)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	self.cell:SetData({item_id = self.item_id})
	self.prop_name = item_cfg.name
	self.have_pro_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	self.node_list["TxtProName"].text.text = string.format(Language.Advance.TipChengZhangViewTextProName, self.prop_name, self.have_pro_num)

	local str = string.format(Language.Advance.GreenStr, self.info.chengzhangdan_count, self.max_chengzhangdan_count)
	if self.info.chengzhangdan_count >= self.max_chengzhangdan_count then
		str = string.format(Language.Advance.RedStr, self.info.chengzhangdan_count, self.max_chengzhangdan_count)
	end
	self.node_list["TxtCurUse"].text.text = string.format(Language.Advance.TipChengZhangViewUseNum, str)
	if self.from_view == FROM_CLOAK or self.from_view == FROM_LING_REN then
		self.node_list["TxtNextCanUse"].text.text = string.format(Language.Advance.TipZiZhiLevelUseNum, self.level, self.next_grade_max_chengzhangdan_count)
	else
		self.node_list["TxtNextCanUse"].text.text = string.format(Language.Advance.TipChengZhangViewNextUseNum, self.next_grade_max_chengzhangdan_count)
	end
	self.node_list["TxtNextCanUse"]:SetActive(self.next_grade_max_chengzhangdan_count > 0)

	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	local shuxingdan = nil
	for k, v in pairs(shuxingdan_cfg) do
		if v.slot_idx == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG then
			if v.type == TouShiShuXingDanCfgType.Type and self.from_view == FROM_TOUSHI then
				shuxingdan = v
				break
			elseif v.type == MaskShuXingDanCfgType.Type and self.from_view == FROM_MASK then
				shuxingdan = v
				break
			elseif v.type == YaoShiShuXingDanCfgType.Type and self.from_view == FROM_WAIST then
				shuxingdan = v
				break
			elseif v.type == QilinBiShuXingDanCfgType.Type and self.from_view == FROM_QILINBI then
				shuxingdan = v
				break
			elseif v.type == CloakShuXingDanCfgType.Type and self.from_view == FROM_CLOAK then
				shuxingdan = v
				break
			elseif v.type == ShenBingShuXingDanCfgType.Type and self.from_view == FROM_LING_REN then
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
	-- 设置使用按钮状态
	if self.info.chengzhangdan_count < self.max_chengzhangdan_count then
		self.node_list["TxtBtnUse"].text.text = Language.Advance.OneUse
	else 
		self.node_list["TxtBtnUse"].text.text = Language.Advance.YiDaShangXian
	end
	if self.from_view then
		self.node_list["TxtallName"].text.text = Language.Advance.AdvanceAtt[self.from_view]
	end

	self.node_list["TxtCurrent"].text.text = (self.info.chengzhangdan_count * shuxingdan.attr_per / 100) .. "%"
	self.node_list["TxtNext"].text.text = (shuxingdan.attr_per / 100) .. "%"
	self.node_list["TxthpCurrent"].text.text = self.info.chengzhangdan_count * shuxingdan.maxhp or 0
	self.node_list["TxtgongjiCurrent"].text.text = self.info.chengzhangdan_count * shuxingdan.gongji or 0
	self.node_list["TxtfangyuCurrent"].text.text = self.info.chengzhangdan_count * shuxingdan.fangyu or 0
	self.node_list["TxthpNext"].text.text = shuxingdan.maxhp or 0
	self.node_list["TxtgongjiNext"].text.text = shuxingdan.gongji or 0
	self.node_list["TxtfangyuNext"].text.text = shuxingdan.fangyu or 0
	self.node_list["TxthpCurrent_full"].text.text = self.info.chengzhangdan_count * shuxingdan.maxhp or 0
	self.node_list["TxtgongjiCurrent_full"].text.text = self.info.chengzhangdan_count * shuxingdan.gongji or 0
	self.node_list["TxtfangyuCurrent_full"].text.text = self.info.chengzhangdan_count * shuxingdan.fangyu or 0
	self.node_list["TxtCurrent_full"].text.text = (self.info.chengzhangdan_count * shuxingdan.attr_per / 100) .. "%"


	local is_not_can_use = self.next_grade_max_chengzhangdan_count <= 0 and self.info.chengzhangdan_count >= self.max_chengzhangdan_count
	-- self.node_list["TxtNext"]:SetActive(not is_not_can_use)
	-- self.node_list["ImgArrow"]:SetActive(not is_not_can_use)
	self.node_list["Attribute_Full"]:SetActive(is_not_can_use)
	self.node_list["Attribute"]:SetActive(not is_not_can_use)
	UI:SetButtonEnabled(self.node_list["UseButton"], not is_not_can_use)
end

-- 设置获取途径
function TipChengZhangView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.icon_list) do
		v.is_show:SetActive(false)
		self.text_way_list[k].is_show:SetActive(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.node_list["PanelWayBtn"]:SetActive(true)
				self.node_list["PanelWayText"]:SetActive(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetActive(true)
					self.icon_list[k].icon.text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetActive(true)
					self.icon_list[k].icon.text.text = getway_cfg_k.discription
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.node_list["PanelWayBtn"]:SetActive(false)
				self.node_list["PanelWayText"]:SetActive(true)
				if tonumber(v) == 0 then
					self.text_way_list[k].is_show:SetActive(true)
					self.text_way_list[k].name.text.text = Language.Common.Shop
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k].is_show:SetActive(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].name.text.text = getway_cfg_k.button_name
					else
						self.text_way_list[k].name.text.text = getway_cfg_k.discription
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.node_list["PanelWayText"]:SetActive(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetActive(true)
			self.text_way_list[k].name.text.text = v
		end
	end
end

function TipChengZhangView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "toushichengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_TOUSHI
		elseif k == "maskchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_MASK
		elseif k == "waistchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_WAIST
		elseif k == "qilinbichengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_QILINBI
		elseif k == "cloakchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_CLOAK
		elseif k == "shenbingchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_REN
		elseif k == "lingzhuchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_ZHU
		elseif k == "xianbaochengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_XIAN_BAO
		elseif k == "lingchongchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_TONG
		elseif k == "linggongchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_GONG
		elseif k == "lingqichengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_LING_QI
		elseif k == "weiyanchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_WEI_YAN
		elseif k == "shouhuanchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_SHOU_HUAN
		elseif k == "tailchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_TAIL
		elseif k == "flypetchengzhang" then
			self.item_id = v.item_id
			self.from_view = FROM_FLY_PET
		end
	end

	if nil ~= self.item_id then
		self:SetData()
		self:ShowWay()
	end
end
