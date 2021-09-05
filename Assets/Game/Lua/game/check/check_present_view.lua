CheckPresentView = CheckPresentView or BaseClass(BaseRender)

local EFFECT = {
	-- [4] = "uieffect_sjcz_dc",
	[5] = "zhuangbei_redbiaomian",
	[6] = "zhuangbei_fenbiaomian",
}

local EFFECT2 = {
	[5] = "zhuangbei_red",
	[6] = "zhuangbei_fen",
}

local RED_EFFECT_COLOR = 5
local FEN_EFFECT_COLOR = 6

function CheckPresentView:__init(instance)
	self.is_switch_to_shen = false
	self.item_effect = {}
	self.item_effect2 = {}

	self.node_list["BtnCheckPortrait"].button:AddClickListener(BindTool.Bind(self.OpenPortraitBg, self))
	self.node_list["BtnSwitchEquip1"].button:AddClickListener(BindTool.Bind(self.OnSwitchEquipView, self))
	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.OnSwitchEquipView, self))
	self.node_list["BtnCheck"].button:AddClickListener(BindTool.Bind(self.ShowTips, self))
	self.node_list["JingJieBg"].button:AddClickListener(BindTool.Bind(self.OpenHunyuTips, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanliNum"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["ShenzhuanPower"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["BaiZhanPower"])
	self.item_list = {}
	for i = 1, 11 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_"..i])
		self.item_list[i]:SetIsCheckItem(true)
	end

	self.shen_equip_item_list = {}
	for i = 0, 9 do
		self.shen_equip_item_list[i] = ItemCell.New()
		self.shen_equip_item_list[i]:SetInstanceParent(self.node_list["shen_equip_item_".. (i + 1)])
	end

	self.mojie_item_list = {}
	for i = 1, 4 do
		self.mojie_item_list[i] = ItemCell.New()
		self.mojie_item_list[i]:SetInstanceParent(self.node_list["MojieItem"..i])
		self.mojie_item_list[i]:SetIsCheckItem(true)
	end

	-- 小鬼
	self.xiaogui_list = {}
	for i=1, ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
		self.xiaogui_list[i] = ItemCell.New()
		self.xiaogui_list[i]:SetInstanceParent(self.node_list["ImpGuard_" .. i])
	end

	self.baizhan_flag = nil
	self.baizhan_can_click = true
	self.node_list["BtnOpenBaiZhanEquip"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenBaiZhanEquip, self, 1))
	self.node_list["BaiZhanBtnReturn"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenBaiZhanEquip, self, 2))
	self.baizhan_cells = {}
	self.baizhan_do_tween = {}
	local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
	self.node_list["BtnOpenBaiZhanEquip"]:SetActive(is_open)
	self.node_list["BaiZhanBtnReturn"]:SetActive(false)

	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if i ~= 0 and i ~= 1 and i ~= 3 then
			local item_baizhan = ItemCell.New()
			item_baizhan:SetInstanceParent(self.node_list["BaiZhanItem" .. i]) 
			item_baizhan:SetFromView(TipsFormDef.FROM_CHECK_MEG)
			self.baizhan_cells[i] = item_baizhan
		else
			self.node_list["BaiZhanItem" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBigCell, self, i))
		end
	end		
end

function CheckPresentView:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.shen_equip_item_list) do
		v:DeleteMe()
	end
	self.shen_equip_item_list = nil
	
	for k, v in pairs(self.mojie_item_list) do
		v:DeleteMe()
	end
	self.mojie_item_list = nil

	for k,v in pairs(self.xiaogui_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.item_effect) do
		ResPoolMgr:Release(v)
	end
	self.item_effect = {}

	for k,v in pairs(self.item_effect2) do
		ResPoolMgr:Release(v)
	end
	self.item_effect2 = {}

	self.xiaogui_list = nil
	self.attr = nil
	self.fight_text = nil
	self.fight_text2 = nil
	self.fight_text3 = nil

	for k,v in pairs(self.baizhan_cells) do
		v:DeleteMe()
	end
	self.baizhan_cells = {}

	for k,v in pairs(self.baizhan_do_tween) do
		if nil ~= v then 
			v:Kill()
		end
	end
	self.baizhan_do_tween = {}
	self.baizhan_flag = nil	
end

function CheckPresentView:OpenPortraitBg()
	local data = {}
	local info = CheckData.Instance:GetRoleInfo()
	data.role_id = info.role_id
	data.avatar_key_big = info.avatar_key_big
	data.avatar_key_small = info.avatar_key_small
	data.prof = info.prof
	data.sex = info.sex
	TipsCtrl.Instance:ShowOtherPortraitView(data)
end

function CheckPresentView:OnSwitchEquipView()
	self.is_switch_to_shen = not self.is_switch_to_shen

	local left_move_one = self.node_list["LeftFrame"].transform:DOAnchorPosX(180,0.5)
	local left_move_two = self.node_list["LeftFrame"].transform:DOAnchorPosX(417,0.5)
	local sequence_l = DG.Tweening.DOTween.Sequence()
	sequence_l:Append(left_move_one)
	sequence_l:AppendCallback(BindTool.Bind(self.JudgeState, self))
	sequence_l:Append(left_move_two)
	sequence_l:SetEase(DG.Tweening.Ease.InOutQuad)

	local right_move_one = self.node_list["RightView"].transform:DOAnchorPosX(200,0.5)
	local right_move_two = self.node_list["RightView"].transform:DOAnchorPosX(-310,0.5)
	local sequence_r = DG.Tweening.DOTween.Sequence()
	sequence_r:Append(right_move_one)
	sequence_r:Append(right_move_two)
	sequence_r:SetEase(DG.Tweening.Ease.InOutQuad)

	local bottom_move_one = self.node_list["MoJieIcon"].transform:DOAnchorPosY(-200, 0.5)
	local bottom_move_two = self.node_list["MoJieIcon"].transform:DOAnchorPosY(50, 0.5)
	local sequence_b = DG.Tweening.DOTween.Sequence()
	sequence_b:Append(bottom_move_one)
	sequence_b:Append(bottom_move_two)
	sequence_b:SetEase(DG.Tweening.Ease.InOutQuad)	

	-- self:Flush()
end

function CheckPresentView:OnBtnOpenBaiZhanEquip(index)
	if index == 2 then
		UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], false)
	end
	if self.baizhan_can_click == true then 
		self.baizhan_can_click = false
		local move_one = self.node_list["LeftFrame"].transform:DOAnchorPosX(180,0.5)
		local move_two = self.node_list["LeftFrame"].transform:DOAnchorPosX(417,0.5)
		local right_move_one = self.node_list["RightView"].transform:DOAnchorPosX(200,0.5)
		local right_move_two = self.node_list["RightView"].transform:DOAnchorPosX(-310,0.5)		
		local mojie_move_one = self.node_list["MoJieIcon"].transform:DOAnchorPosY(-200, 0.5)
		local mojie_move_two = self.node_list["MoJieIcon"].transform:DOAnchorPosY(50, 0.5)
		local mojie_move2_one = self.node_list["MoJieAnim2"].transform:DOAnchorPosY(-250, 0.5)
		local mojie_move2_two = self.node_list["MoJieAnim2"].transform:DOAnchorPosY(50, 0.5)
		local sequence_1 = DG.Tweening.DOTween.Sequence()
		local sequence_2 = DG.Tweening.DOTween.Sequence()
		local sequence_3 = DG.Tweening.DOTween.Sequence()
		local sequence_4 = DG.Tweening.DOTween.Sequence()
		sequence_1:Append(move_one)
		sequence_2:Append(right_move_one)
		sequence_3:Append(mojie_move_one)
		sequence_4:Append(mojie_move2_one)
		sequence_1:AppendCallback(BindTool.Bind(self.BaiZhanCheckState, self))
		sequence_1:Append(move_two)
		sequence_2:Append(right_move_two)
		sequence_3:Append(mojie_move_two)
		sequence_4:Append(mojie_move2_two)	
		sequence_1:AppendCallback(BindTool.Bind(self.BaiZhanCanClick, self))
		sequence_1:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_2:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_3:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_4:SetEase(DG.Tweening.Ease.InOutQuad)
		table.insert(self.baizhan_do_tween ,sequence_1)
		table.insert(self.baizhan_do_tween ,sequence_2)
		table.insert(self.baizhan_do_tween ,sequence_3)
		table.insert(self.baizhan_do_tween ,sequence_4)
	end
end

function CheckPresentView:BaiZhanCheckState()
	if self.node_list["BtnOpenBaiZhanEquip"].gameObject.activeInHierarchy == false then 
		self:BaiZhanChangeState(true)
	else
		self:BaiZhanChangeState(false)
	end
end

function CheckPresentView:BaiZhanCanClick()
	self.baizhan_can_click = true
end

function CheckPresentView:BaiZhanChangeState(bool)
	CheckCtrl.Instance:BanZhanChange(bool)
	self.baizhan_flag = bool

	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info and role_info.sex == 1 then
		local bundle, asset = ResPath.GetRawImage("BaiZhanMen")
		self.node_list["SexBg"].raw_image:LoadSprite(bundle, asset, function()
			self.node_list["SexBg"].raw_image:SetNativeSize()
			self.node_list["SexBg"].transform.localPosition = Vector3(130, -8, 0)
		end)	
	else
		local bundle, asset = ResPath.GetRawImage("BaiZhanWomen")
		self.node_list["SexBg"].raw_image:LoadSprite(bundle, asset, function()
			self.node_list["SexBg"].raw_image:SetNativeSize()
			self.node_list["SexBg"].transform.localPosition = Vector3(130, -20, 0)
		end)
	end	

	self.node_list["BaiZhanEquipAttr"]:SetActive(not bool)
	self.node_list["BaiZhanBtnReturn"]:SetActive(not bool)
	self.node_list["EquipListBaiZhan"]:SetActive(not bool)
	self.node_list["BaiZhanEquipCell"]:SetActive(not bool)
	UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], true)
	UITween.ScaleShowPanel(self.node_list["BaiZhanEquipCell"], Vector3(0.7, 0.7, 0.7))

	self.node_list["BtnSwitchEquip1"]:SetActive(bool)
	local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
	self.node_list["BtnOpenBaiZhanEquip"]:SetActive(bool and is_open)
	self.node_list["BaseEquipAttr"]:SetActive(bool)
	self.node_list["RoleEquipView"]:SetActive(bool)
	self.node_list["MoJieIcon"]:SetActive(bool)
	self.node_list["JingJieIcon"]:SetActive(bool)
	self.node_list["ImpGuard_1"]:SetActive(bool)
	self.node_list["ImpGuard_2"]:SetActive(bool)	
end

function CheckPresentView:ShowTips()
	local check_info = CheckData.Instance:UpdateAttrView()
	TipsCtrl.Instance:ShowPlayerAttrView(check_info.info_attr)
	self:Flush()
end

function CheckPresentView:OnFlush()
	if self.attr then
		self:EquipAttr()
		-- self:AngelEquipAttr()
		self:MojieAndImpGuardAttr()
		self:FlushGeneralEquip()
		self:FlushShenEquip()
		self:FlushMyInfo()
		self:SetModle()
		-- self:JudgeState(self.is_switch_to_shen)

		self:OnEquipBaiZhanChange()
	end
	self:JudgeState()
end

function CheckPresentView:OnEquipBaiZhanChange()
	local baizhan_equiplist = self.attr.baizhan_equiplist
	local baizhan_order_equiplist = self.attr.baizhan_order_equiplist
	self:SetBaiZhanData(baizhan_equiplist, baizhan_order_equiplist)
	self:FlushBaiZhanEquipAttr()
end

function CheckPresentView:OnClickBigCell(equip_index)
	local baizhan_equiplist = self.attr.baizhan_equiplist
	local data = baizhan_equiplist[equip_index]
	if data and data.item_id > 0 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_CHECK_MEG, nil, nil, nil, nil, nil, nil)
	end
end

function CheckPresentView:SetBaiZhanData(baizhan_equiplist, baizhan_order_equiplist)
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if i ~= 0 and i ~= 1 and i ~= 3 then
			if baizhan_equiplist[i] and baizhan_equiplist[i].item_id > 0 then 
				self.baizhan_cells[i]:SetData(baizhan_equiplist[i])
				self.baizhan_cells[i]:ShowHighLight(false)
				self.baizhan_cells[i]:ShowQuality(true)
				self.baizhan_cells[i]:ListenClick()
				self.baizhan_cells[i]:SetActive(true)
			else
				self.baizhan_cells[i]:SetActive(false)
			end
		else
			if baizhan_equiplist[i] and baizhan_equiplist[i].item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(baizhan_equiplist[i].item_id)
				local bundle1, asset1 = ResPath.GetCheckViewImage("color" .. item_cfg.color)
				self.node_list["Quality" .. i].image:LoadSprite(bundle1, asset1)
				self.node_list["DownExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["UpExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["DownExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)
				self.node_list["UpExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)		
				local bundle, asset = ResPath.GetCheckViewImage("icon" .. i .. baizhan_order_equiplist[i])
				self.node_list["Icon" .. i].image:LoadSprite(bundle, asset)		
				self.node_list["Grade" .. i].text.text = tostring((baizhan_order_equiplist[i]) .. Language.Common.Jie) or ""
				self.node_list["BindLock" .. i]:SetActive(baizhan_equiplist[i].is_bind == 1)
				
				self.node_list["BaiZhanItemCellBG" .. i]:SetActive(false)
				self.node_list["BaiZhanItem" .. i]:SetActive(true)
			else
				self.node_list["BaiZhanItemCellBG" .. i]:SetActive(true)
				self.node_list["BaiZhanItem" .. i]:SetActive(false)
			end			
		end
	end
end

function CheckPresentView:EquipAttr()
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.attr.info_attr.capability
	end
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.attr.level)
		-- self.node_list["TxtLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(self.attr.level)
		self.node_list["TxtCharm"].text.text = self.attr.all_charm

		self.node_list["TxtGongji"].text.text = self.attr.info_attr.gongji
		self.node_list["TxtFanyu"].text.text = self.attr.info_attr.fangyu
		self.node_list["TxtHp"].text.text = self.attr.info_attr.shengming
		self.node_list["TxtMingzhong"].text.text = self.attr.info_attr.mingzhong
		self.node_list["TxtShanbi"].text.text = self.attr.info_attr.shanbi
		self.node_list["TxtBaoji"].text.text = self.attr.info_attr.baoji
		self.node_list["TxtKangbao"].text.text = self.attr.info_attr.kangbao
		self.node_list["TxtPk"].text.text = self.attr.info_attr.evil_val
end

function CheckPresentView:AngelEquipAttr()
	local equip_list = {}
		for i = 1, 10 do
			local data = {}
			data.index = i - 1
			data.item_id = self.attr.equip_attr[i].equip_id
			data.param = self.attr.equip_attr[i]
			data.num = 1
			local index = i - 1
			equip_list[index] = data
		end
		--神装属性(大天使)
		local capability, total_attribute = EquipmentShenData.Instance:GetShenEquipTotalCapability(self.attr.shen_equip_part_list, equip_list)
		if nil ==  capability then
			return
		end
		if self.is_switch_to_shen then
			self.node_list["TxtZhanliNum"].text.text = capability
		end
		self.node_list["TxtShengMing"].text.text = total_attribute.max_hp
		self.node_list["TxtGongJi"].text.text = total_attribute.gong_ji
		self.node_list["TxtFangYu"].text.text = total_attribute.fang_yu
		self.node_list["TxtMingZhong"].text.text = total_attribute.ming_zhong
		self.node_list["TxtShanBi"].text.text = total_attribute.shan_bi
		self.node_list["TxtBaoJi"].text.text = total_attribute.bao_ji
		self.node_list["TxtKangBao"].text.text = total_attribute.jian_ren
end

function CheckPresentView:MojieAndImpGuardAttr()
	for k,v in pairs(self.mojie_item_list) do
		local data = self.attr.mojie_attr[k - 1]
		if data then
			data.item_id = MojieData.ITEM_ID_T[k - 1]
			v:SetData(data)
			v:SetIconGrayScale(data.mojie_level <= 0)
			v:ShowQuality(data.mojie_level > 0)
			v:SetInteractable(false)
			if data.mojie_level > 0 then
				v:ShowStrengthLable(true)
				v:SetStrength(data.mojie_level)
			end
			v:ListenClick(BindTool.Bind(function () end))
		end
	end
	
	for k, v in pairs(self.xiaogui_list) do
		local impguard_cfg = EquipData.GetXiaoGuiCfgType(self.attr.impguard_attr[k].imp_guard_usetype)
		if impguard_cfg then
			local data = {item_id = impguard_cfg.item_id}
			v:SetData(data)
			v:SetInteractable(false)
			v:ListenClick(BindTool.Bind(function () end))
			v:SetIconGrayScale(false)
		else
			if k == 1 then
				-- if PlayerData.Instance:GetRoleLevel() > 371 then
				-- 	v:SetAsset(ResPath.GetItemIcon(64300))
				-- else
					v:SetAsset(ResPath.GetItemIcon(64100))
				-- end
			elseif k == 2 then
				-- if PlayerData.Instance:GetRoleLevel() > 371 then
				-- 	v:SetAsset(ResPath.GetItemIcon(64400))
				-- else
					v:SetAsset(ResPath.GetItemIcon(64200))
				-- end
			end
			v:SetIconGrayScale(true)
		end
	end

	local cfg = JingJieData.Instance:GetjingjieCfg(self.attr.jingjie)
	if cfg then
		UI:SetGraphicGrey(self.node_list["JingJieItem"], self.attr.jingjie <= 0)
		UI:SetGraphicGrey(self.node_list["JingJieBg"], self.attr.jingjie <= 0)

		self.node_list["JingJieItem"].image:LoadSprite(ResPath.GetHunyuIcon(cfg.pic_hunyu))
		self.node_list["JingJieBg"].image:LoadSprite(ResPath.GetQualityIcon(cfg.color))
		if self.item_effect[cfg.color] then
			ResPoolMgr:Release(self.item_effect[cfg.color])
			self.item_effect[cfg.color] = nil
		end		
		if self.item_effect2[cfg.color] then
			ResPoolMgr:Release(self.item_effect2[cfg.color])
			self.item_effect2[cfg.color] = nil
		end
		if EFFECT[cfg.color] then
			local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT[cfg.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if nil == obj then
					return
				end
				self.item_effect[cfg.color] = obj
				obj.transform:SetParent(self.node_list["JingJieBg"].transform)
				obj.transform.localScale = Vector3(1, 1, 1)
				obj.transform.localPosition = Vector3(0, 0, 0)
			end)
		end	
		if EFFECT2[cfg.color] then
			local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT2[cfg.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if nil == obj then
					return
				end
				self.item_effect2[cfg.color] = obj
				obj.transform:SetParent(self.node_list["EffectDi"].transform)
				obj.transform.localScale = Vector3(1, 1, 1)
				obj.transform.localPosition = Vector3(0, 0, 0)
			end)
		end		
	end
end

function CheckPresentView:OpenHunyuTips()
	if self.attr.jingjie <= 0 then
		return
	end
	local cfg = JingJieData.Instance:GetjingjieCfg(self.attr.jingjie)
	TipsCtrl.Instance:ShowHunyuTips(cfg, true)
end

function CheckPresentView:FlushMyInfo()
	local pro = ""
	local prof, grade = PlayerData.Instance:GetRoleBaseProf(self.attr.prof)
	if prof then
		pro = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
	end
	self.node_list["TxtProf"].text.text = pro

	if self.attr.lover_name == "" then
		self.node_list["TxtBanlv"].text.text = Language.Marriage.NoPartner
	else
		self.node_list["TxtBanlv"].text.text = self.attr.lover_name
	end
	if self.attr.guild_name == "" then
		self.node_list["TxtGuild"].text.text = Language.Guild.NoGuild
	else
		self.node_list["TxtGuild"].text.text = self.attr.guild_name
	end
	self.node_list["TxtName"].text.text = self.attr.role_name

	local info = CheckData.Instance:GetRoleInfo()
	AvatarManager.Instance:SetAvatarKey(info.plat_role_id, info.avatar_key_big, info.avatar_key_small)

	AvatarManager.Instance:SetAvatar(info.plat_role_id, self.node_list["raw_image_obj"], self.node_list["image_obj"], info.sex, info.prof, false)
end

function CheckPresentView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.present_attr and check_attr.equip_attr then
		self.attr = check_attr.present_attr
		self.attr.used_imageid = check_attr.wing_attr.used_imageid
		self.attr.info_attr = check_attr.info_attr
		self.attr.equip_attr = check_attr.equip_attr
		self.attr.halo_attr = check_attr.halo_attr
		self.attr.impguard_attr = check_attr.impguard_attr
		self.attr.mojie_attr = check_attr.mojie_attr
		self.attr.zhuanzhi_capability = check_attr.zhuanzhi_capability
		self.attr.baizhan_capability = check_attr.baizhan_capability
		self.attr.baizhan_equiplist = check_attr.baizhan_equiplist
		self.attr.baizhan_order_equiplist = check_attr.baizhan_order_equiplist
		self.attr.zhuanzhi_equip_list = check_attr.zhuanzhi_equip_list
		self.attr.zhuanzhi_suit_order_list = check_attr.zhuanzhi_suit_order_list
		self:Flush()
	end
end

function CheckPresentView:SetModle()
	if self.baizhan_flag ~= false then
		local role_info = CheckData.Instance:GetRoleInfo()
		local info = TableCopy(role_info)
		info.appearance = {}
		info.appearance.mask_used_imageid = role_info.mask_info.used_imageid
		info.appearance.toushi_used_imageid = role_info.head_info.used_imageid
		info.appearance.yaoshi_used_imageid = role_info.waist_info.used_imageid
		info.appearance.qilinbi_used_imageid = role_info.arm_info.used_imageid
		info.appearance.shouhuan_used_imageid = role_info.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN].used_imageid
		info.appearance.tail_used_imageid = role_info.upgrade_sys_info[UPGRADE_TYPE.TAIL].used_imageid

		local fashion_info = role_info.shizhuang_part_list[2]
		local wuqi_info = role_info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		info.is_normal_wuqi = wuqi_info.use_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
		info.appearance.fashion_wuqi = wuqi_id
		info.appearance.fashion_body = fashion_id
		UIScene:SetRoleModelResInfo(info, false, false, false, false, false, false, false, false)
		UIScene:ResetLocalPostion()

		local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(8, -168, 0)
		UIScene:SetCameraTransform(transform)

		UIScene:SetActionEnable(false)
		if UIScene.role_model then
			local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		end
	end
end

function CheckPresentView:JudgeState()
	if self.baizhan_flag ~= false then
		self.node_list["RoleEquipView"]:SetActive(not self.is_switch_to_shen)
		-- self.node_list["UpperFrame"]:SetActive(not self.is_switch_to_shen)
		-- self.node_list["LowerFrame"]:SetActive(not self.is_switch_to_shen)
		self.node_list["BaseEquipAttr"]:SetActive(not self.is_switch_to_shen)
		self.node_list["BtnSwitchEquip1"]:SetActive(not self.is_switch_to_shen)
		local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
		self.node_list["BtnOpenBaiZhanEquip"]:SetActive(not self.is_switch_to_shen and is_open)
		self.node_list["MoJieIcon"]:SetActive(not self.is_switch_to_shen)
		self.node_list["RoleShenEquipView"]:SetActive(self.is_switch_to_shen)
		self.node_list["ShenEquipAttr"]:SetActive(self.is_switch_to_shen)
		self.node_list["BtnReturn"]:SetActive(self.is_switch_to_shen)
		-- self.node_list["JingJieIcon"]:SetActive(self.is_switch_to_shen)
	end
end

-- 普通装备
function CheckPresentView:FlushGeneralEquip()
	for i = 1, 11 do
		self.item_list[i]:ShowGetEffect(false)
		if self.attr.equip_attr[i].equip_id ~= 0 and ItemData.Instance:GetItemConfig(self.attr.equip_attr[i].equip_id) then
			self.item_list[i]:SetIconGrayVisible(false)
			local data = {}
			data.index = i - 1
			data.item_id = self.attr.equip_attr[i].equip_id
			data.param = self.attr.equip_attr[i]
			data.num = 1
			self.item_list[i]:SetData(data)
			self.item_list[i]:SetFromView(TipsFormDef.FROM_CHECK_MEG)
			self.item_list[i]:ShowQuality(true)
			self.item_list[i]:SetIconGrayVisible(false)
			self.item_list[i]:SetInteractable(true)
			if ItemData.Instance:GetItemConfig(data.item_id).color == GameEnum.ITEM_COLOR_PINK then
				self.item_list[i]:ShowGetEffect(true)
			end
			self.item_list[i]:SetIconGrayScale(false)
			self.item_list[i]:ListenClick()
		else
			local equip_id = EquipData.Instance:GetDefaultIcon(i - 1)
			local data = {}
			data.item_id = equip_id
			self.item_list[i]:SetData(data)
			self.item_list[i]:ShowQuality(false)
			self.item_list[i]:SetInteractable(false)
			self.item_list[i]:ShowEquipGrade(false)
			self.item_list[i]:SetIconGrayScale(true)
			self.item_list[i]:ListenClick(BindTool.Bind(function ()
			end))
		end
	end
end


function CheckPresentView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftFrame"], CheckData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightView"], CheckData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["ButtomView"], CheckData.TweenPosition.SkillPanel , TWEEN_TIME, DG.Tweening.Ease.InOutSine)

	UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], true)
	UITween.ScaleShowPanel(self.node_list["BaiZhanEquipCell"], Vector3(0.7, 0.7, 0.7))		
end

-- 转职装/神装
function CheckPresentView:FlushShenEquip()
	local zhuanzhi_equip = self.attr.zhuanzhi_equip_list
	for k, v in pairs(self.shen_equip_item_list) do
		if zhuanzhi_equip[k] and zhuanzhi_equip[k].item_id > 0 then 
			v:SetData(zhuanzhi_equip[k])
			v:ShowHighLight(false)
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
			v:SetFromView(TipsFormDef.FROM_CHECK_MEG)
			if zhuanzhi_equip[k].star_level > 0 then
				v:ShowStrengthLable(true)
				v:SetStrength("+" .. zhuanzhi_equip[k].star_level)
			else
				v:ShowStrengthLable(false)
			end
			v:ListenClick()
		else
			local item_local = {}
			item_local.item_id = EquipData.Instance:GetZhuanzhiDefaultIcon(k)
			v:SetData(item_local)
			v:ShowQuality(false)
			v:ShowHighLight(false)
			v:SetIconGrayScale(true)
			v:ShowEquipGrade(false)
			v:ShowStrengthLable(false)
			v:ListenClick(BindTool.Bind(function ()
			end))
		end
	end
	self:FlushShenEquipBaseAttr()
end

-- 转职装备属性
function CheckPresentView:FlushShenEquipBaseAttr()
	local zhuanzhi_equip = self.attr.zhuanzhi_equip_list
	local attr_tab = CommonStruct.Attribute()
	for k, v in pairs(zhuanzhi_equip) do
		if zhuanzhi_equip[k] and zhuanzhi_equip[k].item_id > 0 then 
			local item_cfg = ItemData.Instance:GetItemConfig(zhuanzhi_equip[k].item_id)
			local temp_attr_tab = CommonDataManager.GetAttributteByClass(item_cfg)
			attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, temp_attr_tab)
		end
	end

	self.node_list["TxtShengMing"].text.text = attr_tab.max_hp
	self.node_list["TxtGongJi"].text.text = attr_tab.gong_ji
	self.node_list["TxtFangYu"].text.text = attr_tab.fang_yu
	self.node_list["TxtMingZhong"].text.text = attr_tab.ming_zhong
	self.node_list["TxtShanBi"].text.text = attr_tab.shan_bi
	self.node_list["TxtBaoJi"].text.text = attr_tab.bao_ji
	self.node_list["TxtKangBao"].text.text = attr_tab.jian_ren
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = self.attr.zhuanzhi_capability
	end
end

function CheckPresentView:FlushBaiZhanEquipAttr()
	local baizhan_equiplist = self.attr.baizhan_equiplist
	local attr_tab = CommonStruct.Attribute()
	for k, v in pairs(baizhan_equiplist) do
		if baizhan_equiplist[k] and baizhan_equiplist[k].item_id > 0 then 
			local item_cfg = ItemData.Instance:GetItemConfig(baizhan_equiplist[k].item_id)
			local temp_attr_tab = CommonDataManager.GetAttributteByClass(item_cfg)
			attr_tab = CommonDataManager.AddAttributeAttr(attr_tab, temp_attr_tab)
		end
	end

	self.node_list["BaiZhanTxtShengMing"].text.text = attr_tab.max_hp
	self.node_list["BaiZhanTxtGongJi"].text.text = attr_tab.gong_ji
	self.node_list["BaiZhanTxtFangYu"].text.text = attr_tab.fang_yu
	self.node_list["BaiZhanTxtMingZhong"].text.text = attr_tab.ming_zhong
	self.node_list["BaiZhanTxtShanBi"].text.text = attr_tab.shan_bi
	self.node_list["BaiZhanTxtBaoJi"].text.text = attr_tab.bao_ji
	self.node_list["BaiZhanTxtKangBao"].text.text = attr_tab.jian_ren

	if self.fight_text3 and self.fight_text3.text then
		self.fight_text3.text.text = self.attr.baizhan_capability
	end
end