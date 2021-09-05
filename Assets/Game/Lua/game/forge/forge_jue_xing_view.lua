-- 锻造 觉醒
ForgeJueXingView = ForgeJueXingView or BaseClass(BaseRender)
local EFFECT_CD = 0.5

function ForgeJueXingView:__init(instance, parent_view)
	self.node_list["BtnJueXing"].button:AddClickListener(BindTool.Bind(self.OnBtnJueXing, self))

	self.node_list["BtnTiHuan"].button:AddClickListener(BindTool.Bind(self.OnBtnTiHuan, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		self.node_list["LockSkill" .. i].button:AddClickListener(BindTool.Bind(self.OnLockAttr, self, i))
	end
	self.node_list["BtnYuLan"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenYuLan, self))
	self.node_list["ToggleAutoBuy"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self))

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.max_cell = ItemCell.New()
	self.max_cell:SetInstanceParent(self.node_list["MaxRewardItem"])
	self.max_cell:SetFromView(TipsFormDef.JUEXINGFAKESHOW)
	
	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["MaterialCell"])

	self.material_cell2 = ItemCell.New()
	self.material_cell2:SetInstanceParent(self.node_list["MaterialCell2"])

	self.high_material = nil

	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		self.node_list["LeftText" .. i]:SetActive(true)
		self.node_list["RightText" .. i]:SetActive(true)
		self.node_list["LeftAttr" .. i]:SetActive(false)
		self.node_list["RightAttr" .. i]:SetActive(false)
		self.node_list["Lock1" .. i]:SetActive(false)
		self.node_list["Lock2" .. i]:SetActive(false)
		self.node_list["LeftLockTxt" .. i]:SetActive(false)
	end
	self.lock_index_flag = {}
	self.effect_cd = 0
end

function ForgeJueXingView:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
	if self.max_cell then
		self.max_cell:DeleteMe()
		self.max_cell = nil
	end

	if self.material_cell then
		self.material_cell:DeleteMe()
		self.material_cell = nil
	end

	if self.material_cell2 then
		self.material_cell2:DeleteMe()
		self.material_cell2 = nil
	end

	self.lock_index_flag = {}
	self.effect_cd = nil
end


function ForgeJueXingView:ClickEquipListCallBack(index)
	self.lock_index_flag = {}
	self.select_index = index
	self:Flush()
end

function ForgeJueXingView:CloseCallBack()
	
end

function ForgeJueXingView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_deity_intersify)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end


	if self.select_index == nil then 
		self.node_list["DownPanel"]:SetActive(false)
		self.node_list["TipsTxt"]:SetActive(false)
		self.node_list["BtnYuLan"]:SetActive(false)
		return 
	else
		self.node_list["BtnYuLan"]:SetActive(true)
	end

	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	local curr_equip_order = ForgeData.Instance:GetZhuanzhiEquipJieShu(self.select_index)
	local max_equip_order, color = ForgeData.Instance:GetMaxJueXingJieShu()
	local equip_color = ForgeData.Instance:GetZhuanzhiEquipColor(self.select_index)

	if curr_equip_order >= max_equip_order and equip_color >= color then
		self.node_list["DownPanel"]:SetActive(true)
		self.node_list["TipsTxt"]:SetActive(false)
		self.node_list["MaxRewardItem"]:SetActive(true)
		self.node_list["BtnYuLan"]:SetActive(true)
	else
		self.node_list["DownPanel"]:SetActive(false)
		self.node_list["TipsTxt"]:SetActive(true)
		self.node_list["MaxRewardItem"]:SetActive(false)
		self.node_list["BtnYuLan"]:SetActive(false)
	end
	self.equip_cell:SetData(self.cell_data)
	self.max_cell:SetData({item_id = self.cell_data.item_id,num = 1 ,is_bind = 0 })
	self.max_cell:SetZhuanzhiEquipJueXingEffect(true,GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT)
	self.equip_cell:ShowStrengthLable(false)

	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		local is_show_left = ForgeData.Instance:IsHasEquipAllShuXingInfo(self.select_index, i)
		local is_show_right = ForgeData.Instance:IsHasDisplacementAllShuXingInfo(self.select_index, i)
		local is_has_lock = ForgeData.Instance:IsLockJueXingShuXing(self.select_index, i)
		self.node_list["LeftText" .. i]:SetActive(is_show_left)
		self.node_list["RightText" .. i]:SetActive(is_show_right)
		self.node_list["LeftAttr" .. i]:SetActive(not is_show_left)
		self.node_list["RightAttr" .. i]:SetActive(not is_show_right)

		if nil == self.lock_index_flag[i] then
			self.lock_index_flag[i] = is_has_lock
		else
			if not self.lock_index_flag[i] and is_has_lock then
				self.node_list["LeftAttr" .. i].animator:SetTrigger("IsPlayLock")
			end
			self.lock_index_flag[i] = is_has_lock
		end

		self.node_list["LeftAttr" .. i].animator:SetBool("IsHaveLock", is_has_lock)
		self.node_list["LeftLockTxt" .. i]:SetActive(is_has_lock)

	end

	local lock_num = ForgeData.Instance:JueXingShuXingLockNum(self.select_index)
	local max_num = ForgeData.Instance:JueXingShuXingMaxNum(self.select_index)
	
	UI:SetButtonEnabled(self.node_list["BtnJueXing"], not (lock_num >= 3 and max_num >= 3))

	self.lock_cfg = ForgeData.Instance:GetJueXingShuXingLockCfg(lock_num)
	
	self:FlushhMaterialCell()
	self:FlushEquipAttr()
end

function ForgeJueXingView:FlushhMaterialCell()
	if self.lock_cfg then
		local had_material = ItemData.Instance:GetItemNumInBagById(self.lock_cfg.consume_stuff_id)
		local need_material = 0
		if self.node_list["ToggleAutoBuy"].toggle.isOn then
			need_material = self.lock_cfg.consume_stuff_num
		else
			need_material = self.lock_cfg.consume_stuff_num_1
		end
		-- local had_material2 = ItemData.Instance:GetItemNumInBagById(self.lock_cfg.lock_stuff_id)
		-- local need_material2 = self.lock_cfg.lock_stuff_num
		self.material_cell:SetData({item_id = self.lock_cfg.consume_stuff_id})
		-- self.material_cell2:SetData({item_id = self.lock_cfg.lock_stuff_id})

		local need_mat_text = ToColorStr(need_material, TEXT_COLOR.GREEN_4)
		local had_mat_text = ToColorStr(had_material, (had_material < need_material and COLOR.RED or TEXT_COLOR.GREEN_4))

		-- local need_mat_text2 = ToColorStr(need_material2, TEXT_COLOR.GREEN_4)
		-- local had_mat_text2 = ToColorStr(had_material2, (had_material2 < need_material2 and COLOR.RED or TEXT_COLOR.GREEN_4))
		self.node_list["MaterialName1"].text.text = had_mat_text .. " / " .. need_mat_text
		-- self.node_list["MaterialName2"].text.text = had_mat_text2 .. " / " .. need_mat_text2
		self.node_list["AutoBuy"]:SetActive(self.lock_cfg.gold_num > 0)
		self.node_list["GoldTxt"].text.text = string.format(Language.Forge.JueXingGoldDec , self.lock_cfg.gold_num)
	else
		self.node_list["MaterialName1"].text.text = ""
		-- self.node_list["MaterialName2"].text.text = ""
	end
end

function ForgeJueXingView:FlushEquipAttr()
	for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		local left_attr_cfg = ForgeData.Instance:GetLeftJueXingAttrCfg(self.select_index, i)
		-- local right_attr_cfg = ForgeData.Instance:GetRightJueXingAttrCfg(self.select_index, i)

		local is_left_max = ForgeData.Instance:LeftJueXingLevelIsMax(self.select_index, i)
		-- local is_right_max = ForgeData.Instance:RightJueXingLevelIsMax(self.select_index, i)

		local _, left_level = ForgeData.Instance:LeftJueXingTypeAndLevelByIndex(self.select_index, i)
		local max_level = ForgeData.Instance:GetJueXingMaxLevelByIndex(self.select_index)

		-- local _, right_level = ForgeData.Instance:RightJueXingTypeAndLevelByIndex(self.select_index, i)

		self.node_list["LeftSkillName" .. i].text.text = left_attr_cfg.skill_name
		self.node_list["LeftSkillDec" .. i].text.text = left_attr_cfg.skill_dec

		if is_left_max then
			-- self.node_list["LeftSkillLevel" .. i].text.text = Language.Forge.JueXingDec3
			self.node_list["MaxTxt" .. i]:SetActive(true)
		else
			self.node_list["MaxTxt" .. i]:SetActive(false)
		end
		self.node_list["LeftSkillLevel" .. i].text.text = string.format(Language.Forge.JueXingDec4, left_level, max_level)

		local bundle, asset = ResPath.GetForgeJueXingIcon(left_attr_cfg.icon_id)
		self.node_list["LeftSkillImg" .. i].image:LoadSprite(bundle, asset)

		-- self.node_list["RightSkillName" .. i].text.text = right_attr_cfg.skill_name
		-- self.node_list["RightSkillDec" .. i].text.text = right_attr_cfg.skill_dec

		-- if is_right_max then
		-- 	self.node_list["RightSkillLevel" .. i].text.text = Language.Forge.JueXingDec3
		-- else
		-- 	self.node_list["RightSkillLevel" .. i].text.text = string.format(Language.Forge.JueXingDec4, right_level)
		-- end
		-- local bundle2, asset2 = ResPath.GetForgeJueXingIcon(right_attr_cfg.icon_id)
		-- self.node_list["RightSkillImg" .. i].image:LoadSprite(bundle2, asset2)
	end
end

function ForgeJueXingView:OnBtnJueXing()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return 
	end
	if self.lock_cfg then
		if ItemData.Instance:GetItemNumInBagById(self.lock_cfg.consume_stuff_id) <= 0 then
			-- 物品不足，弹出TIP框
			TipsCtrl.Instance:ShowItemGetWayView(self.lock_cfg.consume_stuff_id)
			return
		end

		-- --锁道具不足
		-- local need_lock_stuff_num = self.lock_cfg.lock_stuff_num
		-- if 0 == self.lock_cfg.lock_stuff_id then
		-- 	need_lock_stuff_num = 0
		-- end
		-- local lock_id = self.lock_cfg.lock_stuff_id
		-- if ItemData.Instance:GetItemNumInBagById(lock_id) < need_lock_stuff_num and not self.node_list["ToggleAutoBuy"].toggle.isOn then
		-- 	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		-- 		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		-- 		if is_buy_quick then
		-- 			self.node_list["ToggleAutoBuy"].toggle.isOn = true
		-- 		end
		-- 	end
		-- 	TipsCtrl.Instance:ShowCommonBuyView(func, lock_id, nil, need_lock_stuff_num)
		-- 	return
		-- end

		-- 元宝不足
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if self.lock_cfg and self.node_list["ToggleAutoBuy"].toggle.isOn then
			if main_vo.gold < self.lock_cfg.gold_num then
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			end
		end


		-- local is_show_lock = false
		-- for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
		-- 	local is_show = ForgeData.Instance:IsHasDisplacementAllShuXingInfo(self.select_index, i)
		-- 	if not is_show then
		-- 		is_show_lock = true
		-- 		break
		-- 	end
		-- end

		local des = Language.Forge.JueXingTips
		local function ok_callback()
			local is_auto_buy = self.node_list["ToggleAutoBuy"].toggle.isOn and 1 or 0
			local had_material = ItemData.Instance:GetItemNumInBagById(self.lock_cfg.consume_stuff_id)
			local need_material = 0
			if self.node_list["ToggleAutoBuy"].toggle.isOn then
				need_material = self.lock_cfg.consume_stuff_num
			else
				need_material = self.lock_cfg.consume_stuff_num_1
			end

			if had_material >= need_material then
				ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_WAKE, self.select_index, is_auto_buy)
				ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_REPLACE, self.select_index)
				self:PlayEffect()
			else
				TipsCtrl.Instance:ShowItemGetWayView(self.lock_cfg.consume_stuff_id)
			end
			
		end

		-- if is_show_lock then
		-- 	ok_callback()
		-- else
			local is_show_tips = true
			for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
				is_show_tips = ForgeData.Instance:IsZhenXiAttrByIndex(self.select_index, i)
				local is_has_lock = ForgeData.Instance:IsLockJueXingShuXing(self.select_index, i)
				if is_show_tips and not is_has_lock then
					break
				end
				is_show_tips = false
			end

			if is_show_tips then
				TipsCtrl.Instance:ShowCommonTip(ok_callback, nil, des, nil, close_func)
			else
				ok_callback()
			end
		-- end
	end
	
end


function ForgeJueXingView:PlayEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_SX_02")
		EffectManager.Instance:PlayEffect(
			bundle_name,
			asset_name,
			self.node_list["Effect"].transform,
			nil,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ForgeJueXingView:OnBtnTiHuan()
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_REPLACE, self.select_index)
end

function ForgeJueXingView:OnLockAttr(jue_xing_index)
	local is_has_lock = ForgeData.Instance:IsLockJueXingShuXing(self.select_index, jue_xing_index)
	if is_has_lock then
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_UNLOCK, self.select_index, jue_xing_index -1)
	else
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_AWAKENING_LOCK, self.select_index, jue_xing_index - 1)
	end
end


function ForgeJueXingView:OnButtonHelp()
	local tips_id = 325
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function ForgeJueXingView:OnToggleClick()
	self:Flush()
end

function ForgeJueXingView:OnBtnOpenYuLan()
	TipsCtrl.Instance:ShowJueXingYuLanTips(self.select_index)
end
