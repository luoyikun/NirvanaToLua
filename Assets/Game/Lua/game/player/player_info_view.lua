PlayerInfoView = PlayerInfoView or BaseClass(BaseRender)

local JIEZHI_INDEX_1 = 8
local JIEZHI_INDEX_2 = 10

local MOJIE_OPEN_LEVEL = 130

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

function PlayerInfoView:__init(instance, parent_view)

	self.parent_view = parent_view
	self.from_view = TipsFormDef.FROM_PLAYER_INFO
	self.can_click = true
	self.baizhan_can_click = true
	if nil == self.baizhan_equip_change_callback then 
		self.baizhan_equip_change_callback = BindTool.Bind1(self.OnEquipBaiZhanChange, self)
		ForgeData.Instance:NotifyBaiZhanDataChangeCallBack(self.baizhan_equip_change_callback)
	end		
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)			
	self.node_list["BtnChangeName"].button:AddClickListener(BindTool.Bind(self.HandleChangeName, self))
	self.node_list["BtnHead"].button:AddClickListener(BindTool.Bind(self.HandleChangePortrait, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HandleAttributeTip, self))
	self.node_list["BtnWorld"].button:AddClickListener(BindTool.Bind(self.HandleWorld, self))
	self.node_list["BtnPkTip"].button:AddClickListener(BindTool.Bind(self.PkTip, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OpenDetailTip, self))
	self.node_list["BtnOpenTianShiEquip"].button:AddClickListener(BindTool.Bind(self.SwitchToShenEquip, self))
	self.node_list["BtnOpenFeiXianEquip"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenFeiXianEquip, self))
	self.node_list["BtnOpenBaiZhanEquip"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenBaiZhanEquip, self, 1))
	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenFeiXianEquip, self))
	self.node_list["BaiZhanBtnReturn"].button:AddClickListener(BindTool.Bind(self.OnBtnOpenBaiZhanEquip, self, 2))
	self.node_list["EquipAttrBtn1"].button:AddClickListener(BindTool.Bind(self.OnEquipAttrBtn, self, 1))
	self.node_list["EquipAttrBtn2"].button:AddClickListener(BindTool.Bind(self.OnEquipAttrBtn, self, 2))
	self.node_list["EquipAttrBtn3"].button:AddClickListener(BindTool.Bind(self.OnEquipAttrBtn, self, 3))
	self.node_list["BtnBaiZhanSuit"].button:AddClickListener(BindTool.Bind(self.OnBtnBaiZhanSuit, self))
	self.node_list["BtnBaiZhanSuitShow"].button:AddClickListener(BindTool.Bind(self.OnBtnBaiZhanSuitShow, self))
	self.node_list["BtnBaiZhanQianWangHuoQu"].button:AddClickListener(BindTool.Bind(self.OnBtnBaiZhanQianWangHuoQu, self))
	self.node_list["ZhuanZhiActBtn"].button:AddClickListener(BindTool.Bind(self.OnZhuanZhiActBtn, self))
	self.node_list["XunBaoActBtn"].button:AddClickListener(BindTool.Bind(self.OnXunBaoActBtn, self))
	self.node_list["BtnEquitSuit"].button:AddClickListener(BindTool.Bind(self.OnOpenEquimentSuit, self))
	self.node_list["DescBtnPK"].button:AddClickListener(BindTool.Bind(self.OnDescBtnPK, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])
	self.node_list["Info"]:SetActive(true)
	self.node_list["RoleShenEquipView"]:SetActive(false)

	self.head_change = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE,
						BindTool.Bind(self.OnHeadChange, self))
	self.temp_head_change = GlobalEventSystem:Bind(ObjectEventType.TEMP_HEAD_CHANGE,
						BindTool.Bind(self.ChangeTempHead, self))

	-- 属性事件处理
	self.attr_handlers = {
		capability = BindTool.Bind(self.OnFightPowerChanged, self),
		avatar_key_big = BindTool.Bind(self.OnPortraitChanged, self),
		name = BindTool.Bind(self.OnNameChanged, self),
		prof = BindTool.Bind(self.OnProfChanged, self),
		all_charm = BindTool.Bind(self.OnCharmChanged, self),
		evil = BindTool.Bind(self.OnEvilChanged, self),
		guild_name = BindTool.Bind(self.OnGuildChanged, self),
		level = BindTool.Bind(self.OnLevelChanged, self),
		exp = BindTool.Bind(self.OnExpChanged, self),
		max_exp = BindTool.Bind(self.OnExpChanged, self),
		base_max_hp = BindTool.Bind(self.OnHPChanged, self),
		base_gongji = BindTool.Bind(self.OnGongJiChanged, self),
		base_fangyu = BindTool.Bind(self.OnFangYuChanged, self),
		base_mingzhong = BindTool.Bind(self.OnMingZhongChanged, self),
		base_shanbi = BindTool.Bind(self.OnShanBiChanged, self),
		base_baoji = BindTool.Bind(self.OnBaoJiChanged, self),
		base_jianren = BindTool.Bind(self.OnKaoBaoChanged, self),
		base_move_speed = BindTool.Bind(self.OnMoveSpeedChanged, self),
	}

	-- 监听系统事件
	self.data_change_callback = BindTool.Bind1(
		self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_change_callback)
	self.feixian_cells = {}
	self.baizhan_cells = {}
	self.cells = {}
	self.do_tween = {}
	self.baizhan_do_tween = {}
	self.mojie_item_list = {}
	self.mojie_improve_list = {}
	self:Init()

	self.mojie_info_event = BindTool.Bind(self.UpdateMojieData, self)
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	-- 首次刷新数据
	for k, v in pairs(self.attr_handlers) do
		if k ~= "exp" and k ~= "max_exp" then
			v()
		end
	end
	self:OnExpInitialized()
	self:OnHeadChange()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.AvatarChange)

	self.baizhan_remind_change = BindTool.Bind(self.BaiZhanRemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.baizhan_remind_change, RemindName.BaiZhanEquipUpLevel)

	self.equimentsuit_remind_change = BindTool.Bind(self.EquimentSuitRemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.equimentsuit_remind_change, RemindName.EquimentSuit)


		--大天使
	local name_table = self.node_list["RoleShenEquipView"].gameObject:GetComponent(typeof(UINameTable))
	self.node_list2 = U3DNodeList(name_table, self)
	self.fight_text_2 = CommonDataManager.FightPower(self, self.node_list2["TxtFightPowerNum"])
	self.cur_select_index = 0
	
	self.equip_item_list = {}
	self.is_show_up_arrow = {}
	for i = 1, EquipmentShenData.SHEN_EQUIP_NUM do
		self.equip_item_list[i] = ItemCell.New()
		self.equip_item_list[i]:SetInstanceParent(self.node_list2["Item" .. i])
		--self.cells[i] = item
		--self.equip_item_list[i]:SetInstanceParent(self.node_list2["Item" .. i])
		self.equip_item_list[i]:SetToggleGroup(self.node_list["RoleShenEquipView"].toggle_group)
		self.equip_item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem11, self, i - 1))
		self.equip_item_list[i]:ShowHighLight(true)
		-- self.equip_item_list[i]:ShowHighLight(false)
		self.equip_item_list[i].root_node.toggle.isOn = (self.cur_select_index == i - 1)
		self.equip_item_list[i]:SetInteractable(true)
		self.is_show_up_arrow[i] = self.node_list2["BtnImprove" .. i]
	end
	-- self.cur_equip_item = ItemCell.New()
	-- self.cur_equip_item:SetInstanceParent(self.node_list2["EquipItem"])

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self.node_list2["ConsumeItem"])

	self.node_list2["BtnBackInfoEquip"].button:AddClickListener(BindTool.Bind(self.OnSwitchToEquip, self))
	self.node_list2["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list2["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelpBtn, self))
	self.node_list["JingJieBg"].button:AddClickListener(BindTool.Bind(self.OnBtnHunYu, self))
	self.node_list["BtnOpenFeiXianEquip"]:SetActive(true)
	local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
	self.node_list["BtnOpenBaiZhanEquip"]:SetActive(is_open)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(true)
	self.node_list["BtnReturn"]:SetActive(false)
	self.node_list["BaiZhanBtnReturn"]:SetActive(false)
	self.node_list2["BtnBackInfoEquip"]:SetActive(false)

	self.equip_index = 0
	self.item_id = 0
end

function PlayerInfoView:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.data_change_callback)
	if nil ~= self.head_change then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end

	if nil ~= self.temp_head_change then
		GlobalEventSystem:UnBind(self.temp_head_change)
		self.temp_head_change = nil
	end
	
	if nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.parent_view = nil
	end

	if nil ~= self.baizhan_remind_change then
		RemindManager.Instance:UnBind(self.baizhan_remind_change)
	end
	if nil ~= self.equimentsuit_remind_change then
		RemindManager.Instance:UnBind(self.equimentsuit_remind_change)
	end

	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end

	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end

	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end

	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}

	for k,v in pairs(self.feixian_cells) do
		v:DeleteMe()
	end
	self.feixian_cells = {}

	for k,v in pairs(self.baizhan_cells) do
		v:DeleteMe()
	end
	self.baizhan_cells = {}

	for k,v in pairs(self.do_tween) do
		if nil ~= v then 
			v:Kill()
		end
	end
	self.do_tween = {}

	for k,v in pairs(self.baizhan_do_tween) do
		if nil ~= v then 
			v:Kill()
		end
	end
	self.baizhan_do_tween = {}

	if self.baizhan_equip_change_callback and ForgeData and ForgeData.Instance then
		ForgeData.Instance:UnNotifyBaiZhanDataChangeCallBack(self.baizhan_equip_change_callback)
		self.baizhan_equip_change_callback = nil
	end	
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end			
	
	for k,v in pairs(self.mojie_item_list) do
		v:DeleteMe()
	end
	self.mojie_item_list = {}

	--大天使
	-- for k, v in pairs(self.equip_item_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.equip_item_list = {}
	self.is_show_up_arrow = {}
	self.parent_view = nil

	self.capability_text = nil
	self.is_show_next_level = nil
	self.equip_level = nil
	self.maxhp = nil
	self.add_maxhp = nil
	self.gongji = nil
	self.add_gongji = nil
	self.fangyu = nil
	self.add_fangyu = nil
	self.item_num = nil
	if self.consume_item then
		self.consume_item:DeleteMe()
		self.consume_item = nil
	end

	-- if self.cur_equip_item then
	-- 	self.cur_equip_item:DeleteMe()
	-- 	self.cur_equip_item = nil
	-- end
	for k,v in pairs(self.xiaogui_list) do
		v:DeleteMe()
	end

	self.xiaogui_list = {}
	self.fight_text = nil
	self.fight_text_2 = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.xunbao_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.xunbao_count_down)
		self.xunbao_count_down = nil
	end	

	self.equip_index = 0
	self.item_id = 0		
end

function PlayerInfoView:OpenCallBack(show_index)
	if self.equip_data_change_fun == nil then
		self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	if self.equip_datalist_change_fun == nil then
		self.equip_datalist_change_fun = BindTool.Bind1(self.OnEquipDataListChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_datalist_change_fun, true)
	end
	if nil == self.feixian_equip_change_callback then 
		self.feixian_equip_change_callback = BindTool.Bind1(self.OnEquipFeiXianChange, self)
		ForgeData.Instance:NotifyZhuanzhiDataChangeCallBack(self.feixian_equip_change_callback)
	end

	if nil == self.xiaogui_list_change then
		self.xiaogui_list_change = GlobalEventSystem:Bind(OtherEventType.IMP_GUARD, BindTool.Bind(self.SetXiaoguiListData, self))
	end

	self:OnEquipFeiXianChange()
	self:OnEquipBaiZhanChange()
	self:OnEquipDataChange()
	self:FlushXunBaoActBtn()
	self:Flush()

	if self.is_opening then
		return
	end
	self.is_opening = true
	self.is_zhuanzhi = false
end

function PlayerInfoView:CloseCallBack()
	if self.equip_data_change_fun then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
	end
	if self.equip_datalist_change_fun then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
	if self.feixian_equip_change_callback then
		ForgeData.Instance:UnNotifyZhuanzhiDataChangeCallBack(self.feixian_equip_change_callback)
		self.feixian_equip_change_callback = nil
	end

	if nil ~= self.xiaogui_list_change then
		GlobalEventSystem:UnBind(self.xiaogui_list_change)
		self.xiaogui_list_change = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.xunbao_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.xunbao_count_down)
		self.xunbao_count_down = nil
	end		
end

function PlayerInfoView:Init()
	for i = 1, 11  do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		self.cells[i] = item
	end
	for i = 0, 9 do
		local item_feixian = ItemCell.New()
		item_feixian:SetInstanceParent(self.node_list["FeiXianItem" .. i]) 
		item_feixian:SetFromView(TipsFormDef.FROM_PLAYER_INFO)
		self.feixian_cells[i] = item_feixian
	end

	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if i ~= 0 and i ~= 1 and i ~= 3 then
			local item_baizhan = ItemCell.New()
			item_baizhan:SetInstanceParent(self.node_list["BaiZhanItem" .. i]) 
			item_baizhan:SetFromView(TipsFormDef.FROM_PLAYER_INFO)
			self.baizhan_cells[i] = item_baizhan
		else
			self.node_list["BaiZhanItem" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBigCell, self, i))
		end
		self.node_list["ImproveButton" .. i].button:AddClickListener(BindTool.Bind(self.OnImproveButton, self, i))
		self.node_list["ImproveButton" .. i]:SetActive(false)
	end	

	-- 魔戒
	for i = 1, 4 do
		local mojie_list = ItemCell.New()
		mojie_list:SetInstanceParent(self.node_list["MojieItem" .. i])
		self.mojie_item_list[i] = mojie_list
		-- self.mojie_improve_list[i] = self.node_list["MojieImprove" .. i]
		self.mojie_item_list[i]:SetItemActive(GameVoManager.Instance:GetMainRoleVo().level >= MOJIE_OPEN_LEVEL)
	end
	-- 小鬼
	self.xiaogui_list = {}
	for i=1, ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
		self.xiaogui_list[i] = ItemCell.New()
		self.xiaogui_list[i]:SetInstanceParent(self.node_list["ImpGuard_" .. i])
	end

	self:UpdateMojieData()

	self:SetXiaoguiListData()
end

function PlayerInfoView:FlushPanel()
	self:UpdateMojieData()
end

function PlayerInfoView:SetFeiXianData(equiplist)
	for k, v in pairs(self.feixian_cells) do
		if equiplist[k] and equiplist[k].item_id > 0 then 
			v:SetData(equiplist[k])
			v:ShowHighLight(false)
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
			v:ListenClick()
		else
			local item_local = {}
			item_local.item_id = EquipData.Instance:GetZhuanzhiDefaultIcon(k)
			v:SetData(item_local)
			v:ShowQuality(false)
			v:ShowHighLight(false)
			v:SetIconGrayScale(true)
			v:ShowEquipGrade(false)
			v:ListenClick(BindTool.Bind(function ()
				TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetFeiXianWayTip)
			end))
		end
	end
end


function PlayerInfoView:OnClickBigCell(equip_index)
	local baizhan_equiplist = ForgeData.Instance:GetBaiZhanEquipAll()
	local data = baizhan_equiplist[equip_index]
	if data and data.item_id > 0 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_PLAYER_INFO, nil, nil, nil, nil, nil, nil)
	end
end

function PlayerInfoView:OnImproveButton(equip_index)
	self.equip_index = equip_index
	local str1 = ""
	local str2 = ""
	local baizhan_equiplist = ForgeData.Instance:GetBaiZhanEquipAll()
	local baizhan_order_equiplist = ForgeData.Instance:GetBaiZhanEquipOrderAll()

	local can_equip = {
		[self.equip_index] = false,
	}
	if baizhan_equiplist[self.equip_index] then 
		local star_id = 0
		local for_star_id = 0
		if baizhan_equiplist[self.equip_index].item_id > 0 then
			star_id = baizhan_equiplist[self.equip_index].item_id
			for_star_id = star_id + 1
		else
			star_id = 17000 + self.equip_index * 100
			for_star_id = star_id
		end		
		local end_id = star_id + (COMMON_CONSTS.BAIZHAN_E_INDEX_MAX - star_id % 10)
		if end_id >= for_star_id then
			for k = end_id, for_star_id, -1 do
				if ItemData.Instance:GetItemNumInBagById(k) > 0 then
					local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
					if is_open then
						can_equip[self.equip_index] = true
						local item_cfg = ItemData.Instance:GetItemConfig(k)
						local data_index = ItemData.Instance:GetItemIndex(k)
						PackageCtrl.Instance:SendUseItem(data_index, 1, item_cfg.sub_type, item_cfg.need_gold)
						break
					end
				else
					can_equip[self.equip_index] = false
				end					
			end
		else
			can_equip[self.equip_index] = false
		end
	end

	if can_equip[self.equip_index] == false then
		if baizhan_equiplist[self.equip_index] and baizhan_equiplist[self.equip_index].item_id > 0 then
			local is_jump = false 
			if baizhan_order_equiplist[self.equip_index] >= 1 and baizhan_order_equiplist[self.equip_index] <= 5 then
				local up_level_cfg = {}
				if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(self.equip_index, 27275)
				end
				if up_level_cfg and up_level_cfg.need_num then
					local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
					if is_open then
						is_jump = true
						local old_item_cfg = ItemData.Instance:GetItemConfig(27275)
						local new_item_cfg = ItemData.Instance:GetItemConfig(up_level_cfg.new_equip_item_id)
						local str1 = ToColorStr(up_level_cfg.need_num, CHAT_COLOR.GREEN) .. Language.Player.BaiZhanGe .. ToColorStr(old_item_cfg.name, ITEM_COLOR[old_item_cfg.color])
						local str2 = ToColorStr(new_item_cfg.name, ITEM_COLOR[new_item_cfg.color])	
						local tips = string.format(Language.Player.BaiZhanTips, str1, str2)
						local function yes_func()
							if equip_index and self.equip_index == equip_index then			
								ForgeCtrl.Instance:SendBaiZhanOpera(BAIZHAN_EQUIP_OPERATE_TYPE.BAIZHAN_EQUIP_OPERATE_TYPE_TAKE_OFF, self.equip_index)
								ForgeCtrl.Instance:SendBaiZhanOpera(BAIZHAN_EQUIP_OPERATE_TYPE.BAIZHAN_EQUIP_OPERATE_TYPE_UP_LEVEL, self.equip_index, 27275)
							end
						end
						local function no_func()
						end	
						TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, nil, nil, no_func)											
					end		
				else
					is_jump = false 
				end						
			end						
			if is_jump == false then
				local up_level_cfg = {}
				local all_up_level_cfg = {}
				up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(self.equip_index, baizhan_equiplist[self.equip_index].item_id)
				all_up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOrder(self.equip_index, baizhan_order_equiplist[self.equip_index])
				if up_level_cfg and up_level_cfg.need_num and all_up_level_cfg and #all_up_level_cfg > 0 then
					local need_stuff_num = up_level_cfg.need_stuff_num
					for k, v in ipairs(all_up_level_cfg) do
						-- 只能拿同阶或者以下的去合成（升级）
						if v.stuff_num <= up_level_cfg.stuff_num and need_stuff_num > 0 then
							local need_num = 999999999
							-- 防止策划把除数v.stuff_num配成0
							if v.stuff_num > 0 then
								need_num = math.ceil(need_stuff_num / v.stuff_num)
							end
							local old_item_cfg = ItemData.Instance:GetItemConfig(v.old_equip_item_id)
							local new_item_cfg = ItemData.Instance:GetItemConfig(up_level_cfg.new_equip_item_id)
							if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) >= need_num then
								str1 = str1 .. ToColorStr(need_num, CHAT_COLOR.GREEN) .. Language.Player.BaiZhanGe .. ToColorStr(old_item_cfg.name, ITEM_COLOR[old_item_cfg.color])
								str2 = ToColorStr(new_item_cfg.name, ITEM_COLOR[new_item_cfg.color])
								need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
								if need_stuff_num <= 0 then
									break
								end
							elseif ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) < need_num then
								if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) > 0 then
									str1 = str1 .. ToColorStr(ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id), CHAT_COLOR.GREEN) .. Language.Player.BaiZhanGe .. ToColorStr(old_item_cfg.name, ITEM_COLOR[old_item_cfg.color]) .. "，"
									need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
								end
							end
						end
					end
				end
			end
		else
			local up_level_cfg = {}
			if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
				up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(self.equip_index, 27275)
				self.item_id = 27275
			elseif ItemData.Instance:GetItemNumInBagById(27274) >= 10 then
				up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(self.equip_index, 27274)
				self.item_id = 27274
			end
			if up_level_cfg and up_level_cfg.need_num then
				local old_item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
				local new_item_cfg = ItemData.Instance:GetItemConfig(up_level_cfg.new_equip_item_id)
				str1 = ToColorStr(up_level_cfg.need_num, CHAT_COLOR.GREEN) .. Language.Player.BaiZhanGe .. ToColorStr(old_item_cfg.name, ITEM_COLOR[old_item_cfg.color])
				str2 = ToColorStr(new_item_cfg.name, ITEM_COLOR[new_item_cfg.color])
			end		
		end
		if str2 ~= "" then
			local tips = string.format(Language.Player.BaiZhanTips, str1, str2)
			local function yes_func()
				if equip_index and self.equip_index == equip_index and self.item_id then			
					ForgeCtrl.Instance:SendBaiZhanOpera(BAIZHAN_EQUIP_OPERATE_TYPE.BAIZHAN_EQUIP_OPERATE_TYPE_UP_LEVEL, self.equip_index, self.item_id)
				end
			end
			local function no_func()
			end	
			TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, nil, nil, nil, nil, nil, no_func)
		end		
	end
end

function PlayerInfoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if ForgeData and ForgeData.Instance then
		local level_up_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByOldId(item_id)
		if level_up_cfg then
			self:OnEquipBaiZhanChange()
		end
	end
	if item_id == 27274 or item_id == 27275 then
		self:OnEquipBaiZhanChange()
	end
end

function PlayerInfoView:SetBaiZhanData(baizhan_equiplist, baizhan_order_equiplist)
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
				local bundle1, asset1 = ResPath.GetPlayerImage("color" .. item_cfg.color)
				self.node_list["Quality" .. i].image:LoadSprite(bundle1, asset1)
				self.node_list["DownExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["UpExtremeEffectRed" .. i]:SetActive(item_cfg.color == RED_EFFECT_COLOR)
				self.node_list["DownExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)
				self.node_list["UpExtremeEffectFen" .. i]:SetActive(item_cfg.color == FEN_EFFECT_COLOR)		
				local bundle, asset = ResPath.GetPlayerImage("icon" .. i .. baizhan_order_equiplist[i])
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
	
	local can_equip = {
		[0] = false,
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
	}
	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if baizhan_equiplist[i] then
			local star_id = 0
			local for_star_id = 0
			if baizhan_equiplist[i].item_id > 0 then
				star_id = baizhan_equiplist[i].item_id
				for_star_id = star_id + 1
			else
				star_id = 17000 + i * 100
				for_star_id = star_id
			end
			local end_id = star_id + (COMMON_CONSTS.BAIZHAN_E_INDEX_MAX - star_id % 10)
			if end_id >= for_star_id then
				for k = end_id, for_star_id, -1 do				
					if ItemData.Instance:GetItemNumInBagById(k) > 0 then
						local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
						if is_open then
							self.node_list["ImproveButton" .. i]:SetActive(true)
							can_equip[i] = true
							break
						end
					else
						self.node_list["ImproveButton" .. i]:SetActive(false)
						can_equip[i] = false
					end					
				end
			else
				self.node_list["ImproveButton" .. i]:SetActive(false)
				can_equip[i] = false
			end
		end
	end

	for i = 0, COMMON_CONSTS.BAIZHAN_E_INDEX_MAX do
		if can_equip[i] == false then
			if baizhan_equiplist[i] and baizhan_equiplist[i].item_id > 0 then
				local is_jump = false 
				if baizhan_order_equiplist[i] >= 1 and baizhan_order_equiplist[i] <= 5 then
					local up_level_cfg = {}
					if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
						up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27275)
					end
					if up_level_cfg and up_level_cfg.need_num then
						local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
						if is_open then
							self.node_list["ImproveButton" .. i]:SetActive(true)
							is_jump = true
						end		
					else
						self.node_list["ImproveButton" .. i]:SetActive(false)
						is_jump = false
					end
				end						
				if is_jump == false then
					local up_level_cfg = {}
					local all_up_level_cfg = {}
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, baizhan_equiplist[i].item_id)
					all_up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOrder(i, baizhan_order_equiplist[i])
					if up_level_cfg and up_level_cfg.need_num and all_up_level_cfg and #all_up_level_cfg > 0 then
						local need_stuff_num = up_level_cfg.need_stuff_num
						for k, v in ipairs(all_up_level_cfg) do
							-- 只能拿同阶或者以下的去合成（升级）
							if v.stuff_num <= up_level_cfg.stuff_num and need_stuff_num > 0 then
								local need_num = 999999999
								-- 防止策划把除数v.stuff_num配成0
								if v.stuff_num > 0 then
									need_num = math.ceil(need_stuff_num / v.stuff_num)
								end
								local old_item_cfg = ItemData.Instance:GetItemConfig(v.old_equip_item_id)
								local new_item_cfg = ItemData.Instance:GetItemConfig(up_level_cfg.new_equip_item_id)
								if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) >= need_num then
									need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
									if need_stuff_num <= 0 then
										break
									end
								elseif ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) < need_num then
									if ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) > 0 then
										need_stuff_num = need_stuff_num - (ItemData.Instance:GetItemNumInBagById(v.old_equip_item_id) * v.stuff_num)
									end
								end
							end
						end
						if need_stuff_num <= 0 then
							local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
							if is_open then
								self.node_list["ImproveButton" .. i]:SetActive(true)
							end
						else
							self.node_list["ImproveButton" .. i]:SetActive(false)
						end	
					else
						self.node_list["ImproveButton" .. i]:SetActive(false)
					end
				end
			else
				local up_level_cfg = {}
				if ItemData.Instance:GetItemNumInBagById(27275) >= 5 then
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27275)
				elseif ItemData.Instance:GetItemNumInBagById(27274) >= 10 then
					up_level_cfg = ForgeData.Instance:GetBaiZhanLevelUpCfgByPartAndOldId(i, 27274)
				end
				if up_level_cfg and up_level_cfg.need_num then
					local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
					if is_open then
						self.node_list["ImproveButton" .. i]:SetActive(true)
					end		
				else
					self.node_list["ImproveButton" .. i]:SetActive(false)
				end	
			end
		end
	end		
end

function PlayerInfoView:OnEquipFeiXianChange()
	local equiplist = ForgeData.Instance:GetZhuanzhiEquipAll()
	self:SetFeiXianData(equiplist)
end

function PlayerInfoView:OnEquipBaiZhanChange()
	local baizhan_equiplist = ForgeData.Instance:GetBaiZhanEquipAll()
	local baizhan_order_equiplist = ForgeData.Instance:GetBaiZhanEquipOrderAll()
	self:SetBaiZhanData(baizhan_equiplist, baizhan_order_equiplist)
end

function PlayerInfoView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		v:ShowGetEffect(false)
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(equiplist[k - 1])
			v:SetIconGrayScale(false)
			v:ShowHighLight(true)
			v:ShowQuality(true)
			v:SetHighLight(self.cur_index == k)
			v:ShowEquipGrade(true)
			local cfg = ItemData.Instance:GetItemConfig(equiplist[k - 1].item_id)
			if cfg and cfg.color == GameEnum.ITEM_COLOR_PINK then
				v:ShowGetEffect(true)
			end
			v:ListenClick(BindTool.Bind(self.OnClickItem1, self, k, equiplist[k - 1], v))
		else
			local data = {}
			v:ShowQuality(false)
			data.is_bind = 0
			data.item_id = EquipData.Instance:GetDefaultIcon(k - 1)
			v:SetData(data)
			v:SetIconGrayScale(true)
			v:SetHighLight(false)
			v:ShowHighLight(false)
			v:ShowEquipGrade(false)
			v:ListenClick(BindTool.Bind(function ()
			end))
		end
	end
end

function PlayerInfoView:OnClickItem1(index, data, cell)
	if data == nil or not next(data) then
		cell:SetHighLight(false)
		if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
			ViewManager.Instance:Close(ViewName.Player)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		cell:SetHighLight(false)
		if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
			ViewManager.Instance:Close(ViewName.Player)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	self.cur_index = index
	cell:SetHighLight(self.cur_index == index)
	local close_callback = function ()
		cell:SetHighLight(false)
		self.cur_index = nil
	end

	if data.param then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local shen_info = EquipmentShenData.Instance:GetEquipData(equip_index)
		data.param.angel_level = shen_info and shen_info.level or 0
	end
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_PLAYER_INFO, nil, close_callback)
end

--主角身上的装备发生变化
function PlayerInfoView:OnEquipDataChange(item_id, index, reason)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

--主角身上的列表装备变化
function PlayerInfoView:OnEquipDataListChange()
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function PlayerInfoView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function PlayerInfoView:HandleChangeName()
	local callback = function (new_name)
		PlayerCtrl.Instance:SendRoleResetName(1, new_name)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(PlayerDataReNameItemId.ItemId)
	local bag_num = ItemData.Instance:GetItemNumInBagById(PlayerDataReNameItemId.ItemId)
	local card_color = bag_num > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local des = item_cfg.name
	local des2 = ToColorStr(bag_num, card_color) .. " / 1"
	TipsCtrl.Instance:ShowRename(callback, true, PlayerDataReNameItemId.ItemId, des, des2)
end

function PlayerInfoView:HandleChangePortrait()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	if not OtherData.Instance:CanChangePortrait() then
		return
	end
	TipsCtrl.Instance:ShowPortraitView()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:isDefaultImg(vo.role_id)
	-- print_log("HandleChangePortrait", vo.role_id, AvatarManager.GetFileUrl(vo.role_id, true))
end

function PlayerInfoView:HandleAttributeTip()
	TipsCtrl.Instance:ShowOtherHelpTipView(1)
end

function PlayerInfoView:PkTip()
	TipsCtrl.Instance:ShowHelpTipView(155)
end

function PlayerInfoView:HandleWorld()
	local open_level_str = PlayerData.GetLevelString(COMMON_CONSTS.WORLD_LEVEL_OPEN)
	open_level_str = string.format(Language.Player.WorldOpenLevel, "<color=#00ff00>"..open_level_str.."</color>")

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = RankData.Instance:GetWordLevel() or 0
	local exp_add = PlayerData.Instance:GetWorldLevelExpAdd(role_level, world_level) .. "%"
	TipsCtrl.Instance:ShowWorldLevelView(PlayerData.GetLevelString(world_level), exp_add, open_level_str)
end

function PlayerInfoView:OpenDetailTip()
	TipsCtrl.Instance:ShowPlayerAttrView()
end

function PlayerInfoView:SwitchToShenEquip()
	self.node_list["Info"]:SetActive(false)
	self.node_list["RoleShenEquipView"]:SetActive(true)
	self.node_list["BtnOpenFeiXianEquip"]:SetActive(true)
	self.node_list["BtnReturn"]:SetActive(false)
	self.node_list2["BtnBackInfoEquip"]:SetActive(true)
	self.node_list["BtnOpenTianShiEquip"]:SetActive(false)
end


function PlayerInfoView:OnBtnOpenBaiZhanEquip(index)
	if index == 2 then
		UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], false)
	end
	if self.baizhan_can_click == true then 
		self.baizhan_can_click = false
		local move_one = self.node_list["EquipAnim"].transform:DOLocalMoveX(-190,0.5)
		local move_two = self.node_list["EquipAnim"].transform:DOLocalMoveX(70,0.5)
		local icon_move_one = self.node_list["RightIcon"].transform:DOLocalMoveY(620,0.5)
		local icon_move_two = self.node_list["RightIcon"].transform:DOLocalMoveY(172,0.5)
		local mojie_move_one = self.node_list["MojieAnim"].transform:DOLocalMoveY(-290, 0.5)
		local mojie_move_two = self.node_list["MojieAnim"].transform:DOLocalMoveY(10, 0.5)
		local mojie_move2_one = self.node_list["MojieAnim2"].transform:DOLocalMoveY(-290, 0.5)
		local mojie_move2_two = self.node_list["MojieAnim2"].transform:DOLocalMoveY(10, 0.5)
		local suit_icon_move_one = self.node_list["BtnBaiZhanSuit"].transform:DOLocalMoveY(620,0.5)
		local suit_icon_move_two = self.node_list["BtnBaiZhanSuit"].transform:DOLocalMoveY(272,0.5)
		local show_icon_move_one = self.node_list["BtnBaiZhanSuitShow"].transform:DOLocalMoveY(508,0.5)
		local show_icon_move_two = self.node_list["BtnBaiZhanSuitShow"].transform:DOLocalMoveY(160,0.5)
		local qianwang_move_one = self.node_list["BtnBaiZhanQianWangHuoQu"].transform:DOLocalMoveY(-658,0.5)
		local qianwang_move_two = self.node_list["BtnBaiZhanQianWangHuoQu"].transform:DOLocalMoveY(-310,0.5)
		local sequence_1 = DG.Tweening.DOTween.Sequence()
		local sequence_2 = DG.Tweening.DOTween.Sequence()
		local sequence_3 = DG.Tweening.DOTween.Sequence()
		local sequence_4 = DG.Tweening.DOTween.Sequence()
		local sequence_5 = DG.Tweening.DOTween.Sequence()
		local sequence_6 = DG.Tweening.DOTween.Sequence()
		local sequence_7 = DG.Tweening.DOTween.Sequence()
		sequence_1:Append(move_one)
		sequence_2:Append(icon_move_one)
		sequence_3:Append(mojie_move_one)
		sequence_4:Append(mojie_move2_one)
		sequence_5:Append(suit_icon_move_one)
		sequence_6:Append(show_icon_move_one)
		sequence_7:Append(qianwang_move_one)
		sequence_1:AppendCallback(BindTool.Bind(self.BaiZhanCheckState, self))
		sequence_1:Append(move_two)
		sequence_2:Append(icon_move_two)
		sequence_3:Append(mojie_move_two)
		sequence_4:Append(mojie_move2_two)
		sequence_5:Append(suit_icon_move_two)
		sequence_6:Append(show_icon_move_two)
		sequence_7:Append(qianwang_move_two)
		sequence_1:AppendCallback(BindTool.Bind(self.BaiZhanCanClick, self))
		sequence_1:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_2:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_3:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_4:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_5:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_6:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_7:SetEase(DG.Tweening.Ease.InOutQuad)
		table.insert(self.baizhan_do_tween ,sequence_1)
		table.insert(self.baizhan_do_tween ,sequence_2)
		table.insert(self.baizhan_do_tween ,sequence_3)
		table.insert(self.baizhan_do_tween ,sequence_4)
		table.insert(self.baizhan_do_tween ,sequence_5)
		table.insert(self.baizhan_do_tween ,sequence_6)
		table.insert(self.baizhan_do_tween ,sequence_7)
	end
end

function PlayerInfoView:OnBtnOpenFeiXianEquip()
	local function callback()

	end

	if self.can_click == true then 
		self.can_click = false
		local move_one = self.node_list["EquipAnim"].transform:DOLocalMoveX(-190,0.5)
		local move_two = self.node_list["EquipAnim"].transform:DOLocalMoveX(70,0.5)
		local icon_move_one = self.node_list["RightIcon"].transform:DOLocalMoveY(620,0.5)
		local icon_move_two = self.node_list["RightIcon"].transform:DOLocalMoveY(172,0.5)
		local mojie_move_one = self.node_list["MojieAnim"].transform:DOLocalMoveY(-190, 0.5)
		local mojie_move_two = self.node_list["MojieAnim"].transform:DOLocalMoveY(10, 0.5)
		-- local mojie_move2_one = self.node_list["MojieAnim2"].transform:DOLocalMoveY(-190, 0.5)
		-- local mojie_move2_two = self.node_list["MojieAnim2"].transform:DOLocalMoveY(10, 0.5)
		local sequence_1 = DG.Tweening.DOTween.Sequence()
		local sequence_2 = DG.Tweening.DOTween.Sequence()
		local sequence_3 = DG.Tweening.DOTween.Sequence()
		-- local sequence_4 = DG.Tweening.DOTween.Sequence()
		sequence_1:Append(move_one)
		sequence_2:Append(icon_move_one)
		sequence_3:Append(mojie_move_one)
		-- sequence_4:Append(mojie_move2_one)
		sequence_1:AppendCallback(BindTool.Bind(self.CheckState, self))
		sequence_1:Append(move_two)
		sequence_2:Append(icon_move_two)
		sequence_3:Append(mojie_move_two)
		-- sequence_4:Append(mojie_move2_two)
		sequence_1:AppendCallback(BindTool.Bind(self.CanClick, self))
		sequence_1:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_2:SetEase(DG.Tweening.Ease.InOutQuad)
		sequence_3:SetEase(DG.Tweening.Ease.InOutQuad)
		-- sequence_4:SetEase(DG.Tweening.Ease.InOutQuad)
		-- sequence_1:OnComplete(function ()
			-- if self.is_up_zhuanzhi then
			-- 	self.node_list["BtnOpenFeiXianEquip"].animator:SetBool("IsShake" , true)
			-- end
		-- end)
		table.insert(self.do_tween ,sequence_1)
		table.insert(self.do_tween ,sequence_2)
		table.insert(self.do_tween ,sequence_3)
		-- table.insert(self.do_tween ,sequence_4)
	end
	-- self.node_list["BtnOpenFeiXianEquip"]:SetActive(false)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(true)
	-- self.node_list["BtnReturn"]:SetActive(true)
	-- self.node_list2["BtnBackInfoEquip"]:SetActive(false)

end
function PlayerInfoView:CheckState()
	if self.node_list["BtnOpenFeiXianEquip"].gameObject.activeInHierarchy == false then 
		self:ChangeState(true)
	else
		self:ChangeState(false)
	end
end

function PlayerInfoView:BaiZhanCheckState()
	if self.node_list["BtnOpenBaiZhanEquip"].gameObject.activeInHierarchy == false then 
		self:BaiZhanChangeState(true)
	else
		self:BaiZhanChangeState(false)
	end
end

function PlayerInfoView:CanClick()
	self.can_click = true
end

function PlayerInfoView:BaiZhanCanClick()
	self.baizhan_can_click = true
end

function PlayerInfoView:ChangeState(bool)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(bool)
	self.node_list["BtnReturn"]:SetActive(not bool)
	self.node_list["BtnOpenFeiXianEquip"]:SetActive(bool)
	local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
	self.node_list["BtnOpenBaiZhanEquip"]:SetActive(bool and is_open)
	self.node_list["EquipList"]:SetActive(bool)
	self.node_list["EquipListFeiXian"]:SetActive(not bool)
	self.node_list["MoJieIcon"]:SetActive(bool)
	-- self.node_list["JingJieIcon"]:SetActive(not bool)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(true)
	self.node_list["Info"]:SetActive(true)
	self.node_list["RoleShenEquipView"]:SetActive(false)
	self.node_list2["BtnBackInfoEquip"]:SetActive(false)
	
	self.is_zhuanzhi = not bool
	if bool then
		self.node_list["AttrBtnText1"].text.text = Language.Player.AttrBtnText[1]
		self.node_list["AttrBtnText2"].text.text = Language.Player.AttrBtnText[2]
		self.node_list["AttrBtnText3"].text.text = Language.Player.AttrBtnText[3]
		for i = 1, 3 do
			-- self.node_list["EquipAttrIcon" .. i] :SetActive(true)
			-- self.node_list["EquipAttrIcon" .. (i + 3)] :SetActive(false)
			if i ~= 1 then
				self.node_list["EquipAttrBtn" .. i]:SetActive(false)
			end
		end
	else
		self.node_list["AttrBtnText1"].text.text = Language.Player.AttrBtnText[4]
		self.node_list["AttrBtnText2"].text.text = Language.Player.AttrBtnText[5]
		self.node_list["AttrBtnText3"].text.text = Language.Player.AttrBtnText[6]
		for i = 1, 3 do
			-- self.node_list["EquipAttrIcon" .. i] :SetActive(false)
			-- self.node_list["EquipAttrIcon" .. (i + 3)] :SetActive(true)
			if i ~= 1 then
				self.node_list["EquipAttrBtn" .. i]:SetActive(false)
			end
		end
	end
end

function PlayerInfoView:BaiZhanChangeState(bool)
	PlayerCtrl.Instance:BanZhanChange(bool)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.sex == 1 then
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

	self.node_list["BaiZhanBtnReturn"]:SetActive(not bool)
	self.node_list["EquipListBaiZhan"]:SetActive(not bool)
	self.node_list["BtnBaiZhanSuit"]:SetActive(not bool)
	self.node_list["BtnBaiZhanSuitShow"]:SetActive(not bool)
	self.node_list["BtnBaiZhanQianWangHuoQu"]:SetActive(not bool)
	self.node_list["BaiZhanEquipCell"]:SetActive(not bool)
	UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], true)
	UITween.ScaleShowPanel(self.node_list["BaiZhanEquipCell"], Vector3(0.7, 0.7, 0.7))

	self.node_list["BtnOpenFeiXianEquip"]:SetActive(bool)
	local is_open = OpenFunData.Instance:CheckIsHide("baizhanequip")
	self.node_list["BtnOpenBaiZhanEquip"]:SetActive(bool and is_open)
	self.node_list["EquipList"]:SetActive(bool)
	self.node_list["MoJieIcon"]:SetActive(bool)
	self.node_list["RightIcon"]:SetActive(bool)
	self.node_list["JingJieIcon"]:SetActive(bool)
	self.node_list["ImpGuard_1"]:SetActive(bool)
	self.node_list["ImpGuard_2"]:SetActive(bool)	
end


function PlayerInfoView:OnUpClick()
	ViewManager.Instance:Open(ViewName.HelperView)
end

function PlayerInfoView:PlayerDataChangeCallback(attr_name, value, old_value)
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end

function PlayerInfoView:OnFightPowerChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = vo.capability
	end
end

function PlayerInfoView:OnPortraitChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = AvatarManager.Instance.GetDefAvatar(vo.prof, true, vo.sex)
	self.node_list["PortraitImage"].image:LoadSprite(bundle, asset .. ".png")
end

function PlayerInfoView:OnNameChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtNameName"].text.text = vo.name
end

function PlayerInfoView:OnProfChanged()
	local prof, grade = PlayerData.Instance:GetRoleBaseProf()
	self.node_list["TxtProfName"].text.text = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
end

function PlayerInfoView:OnCharmChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtCharmName"].text.text = vo.all_charm
end

function PlayerInfoView:OnEvilChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtPKName"].text.text = vo.evil
end

function PlayerInfoView:OnGuildChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_name == ""	then
		self.node_list["TxtGuildName"].text.text = Language.Role.NoGuild
	else
		self.node_list["TxtGuildName"].text.text = vo.guild_name
	end
end

function PlayerInfoView:OnLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(vo.level)
	-- self.node_list["TxtLevelName"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	self.node_list["TxtLevelName"].text.text = PlayerData.GetLevelString(vo.level)
end

function PlayerInfoView:OnExpInitialized()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_exp = vo.exp
	if vo.exp >= vo.max_exp then
		cur_exp = vo.exp - vo.max_exp
	else
		cur_exp = vo.exp
	end

	local percentage_exp = math.floor(cur_exp / vo.max_exp * 100)
	if string.find(cur_exp, "e") then
		local temp_exp = CommonDataManager.ConverNum(cur_exp)
		self.node_list["SliderSkillInfoExpNum"].text.text = string.format("%s（<color=#f5c779>%s%%</color>）", tostring(temp_exp), tostring(percentage_exp))
	else
		self.node_list["SliderSkillInfoExpNum"].text.text = string.format("%s（<color=#f5c779>%s%%</color>）", tostring(cur_exp), tostring(percentage_exp))
	end
	self.node_list["SliderTxtEx"].slider.value = cur_exp / vo.max_exp
	self.node_list["SliderBg"].slider.value = cur_exp / vo.max_exp
end

function PlayerInfoView:OnExpChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local percentage_exp = math.floor(vo.exp / vo.max_exp * 100)

	if string.find(vo.exp, "e") then
		local temp_exp = CommonDataManager.ConverNum(vo.exp)
		self.node_list["SliderSkillInfoExpNum"].text.text = string.format("%s（<color=#f5c779>%s%%</color>）", temp_exp, tostring(percentage_exp))
	else
		self.node_list["SliderSkillInfoExpNum"].text.text = string.format("%s（<color=#f5c779>%s%%</color>）", vo.exp, tostring(percentage_exp))
	end

	self.node_list["SliderTxtEx"].slider.value = vo.exp / vo.max_exp
	self.node_list["SliderBg"].slider.value = vo.exp / vo.max_exp
end

function PlayerInfoView:OnHPChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtHPValue"].text.text = vo.base_max_hp
end

function PlayerInfoView:OnGongJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoGongJi"].text.text = vo.base_gongji
end

function PlayerInfoView:OnFangYuChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoFangYu"].text.text = vo.base_fangyu
end

function PlayerInfoView:OnMingZhongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoMingZhong"].text.text = vo.base_mingzhong
end

function PlayerInfoView:OnShanBiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoShanBi"].text.text = vo.base_shanbi
end

function PlayerInfoView:OnBaoJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoBaoJi"].text.text = vo.base_baoji
end

function PlayerInfoView:OnKaoBaoChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoKangBao"].text.text = vo.base_jianren
end

function PlayerInfoView:OnMoveSpeedChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtSkillInfoSpeed"].text.text = (vo.base_move_speed / 2000) .. "%"
end

function PlayerInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Player) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = vo.role_id
	if IS_ON_CROSSSERVER then
		role_id = CrossServerData.Instance:GetRoleId()
	end
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["PortraitRaw"], self.node_list["PortraitImage"], vo.sex, vo.prof, false)
end

function PlayerInfoView:OnOpenEquimentSuit()
	ViewManager.Instance:Open(ViewName.EquimentSuitView)
end

function PlayerInfoView:OnDescBtnPK()
	TipsCtrl.Instance:ShowOtherHelpTipView(332)
end

function PlayerInfoView:ChangeTempHead(path)
	if nil == path then
		return
	end
	self.node_list["PortraitImage"]:SetActive(false)
	self.node_list["PortraitRaw"]:SetActive(true)
	self.node_list["PortraitRaw"].raw_image:LoadSprite(path, function()
	end)
end

function PlayerInfoView:RemindChangeCallBack(remind_name, num)
	if self.node_list and self.node_list["RedPoint"] then
		self.node_list["RedPoint"]:SetActive(num > 0)
	end
end

function PlayerInfoView:BaiZhanRemindChangeCallBack(remind_name, num)
	if self.node_list and self.node_list["BaiZhanRedPoint"] then
		self.node_list["BaiZhanRedPoint"]:SetActive(num > 0)
	end
end
function PlayerInfoView:EquimentSuitRemindChangeCallBack(remind_name, num)
	if self.node_list and self.node_list["EquimentRemind"] then
		self.node_list["EquimentRemind"]:SetActive(num > 0)
	end
end

--大天使
function PlayerInfoView:OnSwitchToEquip( )
	self.node_list["Info"]:SetActive(true)
	self.node_list["RoleShenEquipView"]:SetActive(false)
	self.node_list["BtnReturn"]:SetActive(false)
	self.node_list["BtnOpenFeiXianEquip"]:SetActive(true)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(true)
	self.node_list2["BtnBackInfoEquip"]:SetActive(false)
end

function PlayerInfoView:OnClickUpLevel()
	EquipmentShenCtrl.Instance:SendShenzhuangUpLevel(self.cur_select_index)
end

function PlayerInfoView:OnClickHelpBtn()
	local tips_id = 220
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerInfoView:OnClickItem11(index)
	self.cur_select_index = index
	-- for k,v in pairs(self.equip_item_list) do
	-- 	v:ShowHighLight(index == self.cur_select_index)
	-- 	v:ShowHighLight(true)
	-- end
	self:FlushRightPanel()
end

function PlayerInfoView:UpdateMojieData()
	for k, v in pairs(self.mojie_item_list) do
		local data = MojieData.Instance:GetOneMojieInfo(k - 1)
		v:SetData(data)
		v:ListenClick(BindTool.Bind(self.OnClickMojieItem, self, k, data, v))
		v:SetIconGrayScale(data.mojie_level <= 0)
		v:ShowQuality(data.mojie_level > 0)
		if MojieData.Instance:IsShowMojieRedPoint(k - 1) then
			v:SetRedPoint(true)
		else
			v:SetRedPoint(false)
		end
	end
end

function PlayerInfoView:OnClickMojieItem(index, data, cell)
	-- local close_callback = function ()
	cell:SetHighLight(false)
	-- end
	MojieCtrl.Instance:OpenMoJieView(index)
	-- TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerInfoView:OnFlush(param_t)
	self:ChangeView()
	-- self:FlushLeftEquipList()
	self:FlushRightPanel()
	self:SetXiaoguiListData()
	self:SetHunYuImage()
	self:FlushPanel()

	for k,v in pairs(param_t) do
		if k == "select_equip" then
			self:OnBtnOpenFeiXianEquip()
		elseif k == "xun_bao_act_btn" then
			self:FlushXunBaoActBtn()
		end
	end

	self:FlushZhuanZhiActBtn()
end

function PlayerInfoView:ChangeView()
	local tianshi_flag = PlayerData.Instance:GetTianShiFlag()
	if tianshi_flag then
		self:SwitchToShenEquip()
		PlayerData.Instance:SetTianShiFlag(false)
	end
end

function PlayerInfoView:FlushRightPanel()
	local equip_info = EquipmentShenData.Instance:GetEquipData(self.cur_select_index)

	if nil == equip_info then
		return
	end

	-- self.cur_equip_item:SetAsset(ResPath.GetPlayerImage("equipshen_" .. self.cur_select_index))
	-- self.cur_equip_item:ShowStrengthLable(equip_info.level > 0)
	-- self.cur_equip_item:SetStrength(equip_info.level)

	local color = math.ceil(equip_info.level / 5)
	color = color <= 6 and color or 6
	color = color > 0 and color or 1
	-- self.cur_equip_item:SetQualityByColor(color > 0 and color or 1)
	-- self.cur_equip_item:ShowQuality(color > 0)

	local cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level)
	local attr = CommonDataManager.GetAttributteByClass(cfg)
	self.node_list2["TxtHPContenValue"].text.text = attr.max_hp
	self.node_list2["TxtAtkContentValue"].text.text = attr.gong_ji
	self.node_list2["TxtDefContentValue"].text.text = attr.fang_yu
	self.node_list2["TxtMZContentValue"].text.text = attr.ming_zhong
	self.node_list2["TxtSBContentValue"].text.text = attr.shan_bi
	self.node_list2["TxtBJContentValue"].text.text = attr.bao_ji
	self.node_list2["TxtJRContentValue"].text.text = attr.jian_ren

	for i = 1, 4 do
		local cur_value
		if i < 4 then
			cur_value = (cfg and cfg["red_ratio_" .. i] or 0) / 100
		else
			cur_value = (cfg and cfg["pink_ratio"] or 0) / 100
		end
	self.node_list2["TxtSpcAttrContent1"].text.text = string.format(Language.Player.Equip1, cur_value)
	self.node_list2["TxtSpcAttrContent2"].text.text = string.format(Language.Player.Equip2, cur_value)
	self.node_list2["TxtSpcAttrContent3"].text.text = string.format(Language.Player.Equip3, cur_value)
	self.node_list2["TxtSpcAttrContentText"].text.text = string.format(Language.Player.Equip4, equip_index_name, cur_value)
	end
	
	local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(self.cur_select_index, equip_info.level + 1)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)

	local name = nil ~= cfg and cfg.name or next_cfg.name
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. name .. "</color>"
	self.node_list2["TxtName"].text.text = name_str
	self.node_list2["TxtLevel"].text.text = equip_info.level > 0 and  "+" .. equip_info.level or ""
	self.node_list2["TxtSpcAttrContentText"].text.text = string.format(Language.Player.Equip4, equip_index_name, Language.Forge.EquipName[self.cur_select_index])

	self.node_list2["NoteHPAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteAtkAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteDefAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteMZAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteSBAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteBJAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteJRAddContent"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteSPecAddContent1"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteSPecAddContent2"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteSPecAddContent3"]:SetActive(nil ~= next_cfg)
	self.node_list2["NoteSPecAddContent4"]:SetActive(nil ~= next_cfg)
	self.node_list2["PanelLower"]:SetActive(nil ~= next_cfg)

	self.node_list2["NoteHPContent"]:SetActive(attr.max_hp > 0 or next_attr.max_hp > 0)
	--self.node_list2["is_show_gongji"]:SetActive(attr.gong_ji > 0 or next_attr.gong_ji > 0)
	self.node_list2["NoteDefContent"]:SetActive(attr.fang_yu > 0 or next_attr.fang_yu > 0)
	self.node_list2["NoteMZContent"]:SetActive(attr.ming_zhong > 0 or next_attr.ming_zhong > 0)
	self.node_list2["NoteSBContent"]:SetActive(attr.shan_bi > 0 or next_attr.shan_bi > 0)
	self.node_list2["NoteBJContent"]:SetActive(attr.bao_ji > 0 or next_attr.bao_ji > 0)
	self.node_list2["NoteJRContent"]:SetActive(attr.jian_ren > 0 or next_attr.jian_ren > 0)
	if nil == next_cfg then
		return
	end

	local dif_attr = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	self.node_list2["TxtHPContentUpvalue"].text.text = dif_attr.max_hp
	self.node_list2["TxtAtkContentUpvalue"].text.text = dif_attr.gong_ji
	self.node_list2["TxtDefContentUpvalue"].text.text = dif_attr.fang_yu
	self.node_list2["TxtMZContentUpvalue"].text.text = dif_attr.ming_zhong
	self.node_list2["TxtSBContentUpvalue"].text.text = dif_attr.shan_bi
	self.node_list2["TxtBJContentUpvalue"].text.text = dif_attr.bao_ji
	self.node_list2["TxtJRContentUpvalue"].text.text = dif_attr.jian_ren

	for i = 1, 4 do
		local dif, to_level = EquipmentShenData.Instance:GetNextUpSpecialAttr(self.cur_select_index, equip_info.level, i)
		self.node_list2["NoteSPecAddContent1"]:SetActive(dif > 0)
		self.node_list2["NoteSPecAddContent2"]:SetActive(dif > 0)
		self.node_list2["NoteSPecAddContent3"]:SetActive(dif > 0)
		self.node_list2["NoteSPecAddContent4"]:SetActive(dif > 0)

		local str = "<color=#33E45DFF>".. dif / 100 .. "%</color>" .. "（" .. "<color=" .. TEXT_COLOR.RED .. ">" .. equip_info.level .. "</color>" ..  "/" .. to_level .. Language.Common.Ji .."）"
		self.node_list2["TxtSpcAttrContent1Value"].text.text = str
		self.node_list2["TxtSpcAttrContent2Value"].text.text = str
		self.node_list2["TxtSpcAttrContent3Value"].text.text = str
		self.node_list2["TxtSpcAttrContentValue"].text.text = str
	end

	local data = {}
	data.item_id = cfg and cfg.stuff_id or next_cfg.stuff_id
	data.num = 0
	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.consume_item:SetShowNumTxtLessNum(0)
	self.consume_item:SetData(data)

	local txt_color = num >= next_cfg.stuff_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list2["TxtUpButton"].text.text = equip_info.level > 0 and Language.Common.Up or Language.Common.Activate
	self.node_list2["TxtNum"].text.text = "<color=" .. txt_color .. ">" .. num .. "</color>" .. ToColorStr(" / " .. next_cfg.stuff_num, TEXT_COLOR.GREEN_4)
	self.node_list["RedPoint2"]:SetActive(num > next_cfg.stuff_num)

end

function PlayerInfoView:FlushLeftEquipList()
	for i = 1, EquipmentShenData.SHEN_EQUIP_NUM do
		local index = i - 1
		if self.equip_item_list[i] then
			self.equip_item_list[i]:SetAsset(ResPath.GetPlayerImage("equipshen_" .. i - 1))
			.image:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(ResPath.GetPlayerImage("equipshen_" .. i - 1))

			local equip_info = EquipmentShenData.Instance:GetEquipData(index)
			self.equip_item_list[i]:ShowStrengthLable(equip_info.level > 0)
			self.equip_item_list[i]:SetStrength(equip_info.level)

			local color = math.ceil(equip_info.level / 5)
			color = color <= 6 and color or 6
			self.equip_item_list[i]:SetQualityByColor(color > 0 and color or 1)
			self.equip_item_list[i]:ShowQuality(color > 0)
			self.equip_item_list[i]:SetIconGrayScale(equip_info.level <= 0)

			local next_cfg = EquipmentShenData.Instance:GetShenzhuangCfg(index, equip_info.level + 1)
			if nil ~= next_cfg then
				local num = ItemData.Instance:GetItemNumInBagById(next_cfg.stuff_id)
				self.is_show_up_arrow[i]:SetActive(num >= next_cfg.stuff_num)
			else
				self.is_show_up_arrow[i]:SetActive(false)
			end
		end
	end

	local capability = EquipmentShenData.Instance:GetShenEquipTotalCapability()
	self.node_list2["TxtCount"].text.text = capability
	if self.fight_text_2 and self.fight_text_2.text then
		self.fight_text_2.text.text = capability
	end
end

function PlayerInfoView:SetXiaoguiListData()
	local xiaogui_cfg_list = EquipData.Instance:GetImpGuardInfo()
	local is_overdue = false
	if xiaogui_cfg_list then
		for i = 1, ImpGuardData.IMP_GUARD_GRID_INDEX_MAX do
			if nil == xiaogui_cfg_list[i] then
				return
			end

			xiaogui_id = xiaogui_cfg_list[i].item_wrapper.item_id
			local data = {item_id = xiaogui_id, index = i}
			self.xiaogui_list[i]:SetData(data)
			if xiaogui_id == 0 then
				if i == 1 then
					self.xiaogui_list[i]:SetAsset(ResPath.GetItemIcon(64100))
				elseif i == 2 then
					self.xiaogui_list[i]:SetAsset(ResPath.GetItemIcon(64200))
				end
				self.xiaogui_list[i]:SetIconGrayScale(true)
			else
				if i == 1 then
					is_overdue = EquipData.Instance:GetGuoQiExpXiaoGui()
				else
					is_overdue = EquipData.Instance:GetGuoQiGuardXiaoGui()
				end
				if is_overdue then
					self.xiaogui_list[i]:SetShowLimitUse(true)
					self.xiaogui_list[i]:SetTimeLimitText(Language.Player.OverdueTimeLimit)
				else
					self.xiaogui_list[i]:SetShowLimitUse(false)
					self.xiaogui_list[i]:SetTimeLimitText(Language.Player.TimeLimit)
				end
				self.xiaogui_list[i]:SetIconGrayScale(false)
			end

			self.xiaogui_list[i]:ListenClick(BindTool.Bind(self.OnClickXiaogui, self, data, self.xiaogui_list[i]))
		end
	end
end

function PlayerInfoView:SetHunYuImage()
	local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	local cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level)
	if not cfg then return end

	self.node_list["JingJieItem"].image:LoadSprite(ResPath.GetHunyuIcon(cfg.pic_hunyu))
	self.node_list["JingJieBg"].image:LoadSprite(ResPath.GetQualityIcon(cfg.color))
	UI:SetGraphicGrey(self.node_list["JingJieItem"], cur_jingjie_level <= 0)
	UI:SetGraphicGrey(self.node_list["JingJieBg"], cur_jingjie_level <= 0)

	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end
	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end
	if EFFECT[cfg.color] then
		local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT[cfg.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
			if nil == obj then
				return
			end
			self.item_effect = obj
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
			self.item_effect2 = obj
			obj.transform:SetParent(self.node_list["HunyinEffecct1"].transform)
			obj.transform.localScale = Vector3(1, 1, 1)
			obj.transform.localPosition = Vector3(0, 0, 0)
		end)
	end
end

function PlayerInfoView:OnBtnHunYu()
	local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	if cur_jingjie_level <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.BaoJu.JingJieTips)
		return
	end

	local cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level)
	TipsCtrl.Instance:ShowHunyuTips(cfg)
end

function PlayerInfoView:OnClickXiaogui(data, cell)
	local close_callback = function ()
		cell:SetHighLight(false)
		self.cur_index = nil
	end

	local item_id = 0
	if data.item_id == 0 then
		if data.index == 1 then
			-- if PlayerData.Instance:GetRoleLevel() > 371 then
			-- 	item_id = 64300
			-- else
				item_id = 64100
			-- end
		elseif data.index == 2 then
			-- if PlayerData.Instance:GetRoleLevel() > 371 then
			-- 	item_id = 64400
			-- else
				item_id = 64200
			-- end
		end
	end
	if item_id ~= 0 then
		self:BuyAndUseItem(item_id)
	end
	TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerInfoView:BuyAndUseItem(item_id)
	local func = function(item_id, item_num, is_bind, is_use)
	MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		local timer_callback = function()
			local bag_index = ItemData.Instance:GetItemIndex(item_id)
			PackageCtrl.Instance:SendUseItem(bag_index, 1)
		end
		GlobalTimerQuest:AddDelayTimer(timer_callback, 0.5)			--延迟发送协议
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1, true)
end

function PlayerInfoView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BottonView"], PlayerData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightIcon"], PlayerData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BtnBaiZhanSuit"], PlayerData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BtnBaiZhanSuitShow"], PlayerData.TweenPosition.Up2 , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BtnBaiZhanQianWangHuoQu"], PlayerData.TweenPosition.Down2 , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightView"], PlayerData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)

	UITween.AlpahShowPanel(self.node_list["BaiZhanEquipCell"], true)
	UITween.ScaleShowPanel(self.node_list["BaiZhanEquipCell"], Vector3(0.7, 0.7, 0.7))	
end

function PlayerInfoView:OnEquipAttrBtn(btn_type)
	if not self.is_zhuanzhi then
		if btn_type == 1 then
			TipsCtrl.Instance:OpenEquipAttrTipsView("yongheng_attr")
		elseif btn_type == 2 then
			local level = ForgeData.Instance:GetTotalStrengthLevel()
			local cu_cfg, ne_cfg = ForgeData.Instance:GetTotalStrengthCfgByLevel(level)
			TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeSuitAtt, level, cu_cfg, ne_cfg)
		else
			local level, current_cfg, next_cfg = ForgeData.Instance:GetTotalGemCfg()
			TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeGemSuitAtt, level, current_cfg, next_cfg)
		end
	else
		if btn_type == 1 then
			TipsCtrl.Instance:OpenEquipAttrTipsView("deity_suit_attr")
		elseif btn_type == 2 then
			local star_level, now_cfg, next_cfg = ForgeData.Instance:GetTotleStarInfo()
			TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeStarSuitAtt, star_level, now_cfg, next_cfg)
		else
			local level, current_cfg, next_cfg = ForgeData.Instance:GetTotalJadeCfg()
			TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeJadeSuitAtt, level, current_cfg, next_cfg)
		end
	end
end

function PlayerInfoView:OnBtnBaiZhanSuit(btn_type)
	TipsCtrl.Instance:OpenEquipAttrTipsView("baizhan_suit_attr")
end

function PlayerInfoView:OnBtnBaiZhanSuitShow()
	ViewManager.Instance:Open(ViewName.BaiZhanSuitView)
end

function PlayerInfoView:OnBtnBaiZhanQianWangHuoQu()
	ViewManager.Instance:Open(ViewName.Map, TabIndex.map_world)
end

function PlayerInfoView:OnZhuanZhiActBtn()
	-- KaifuActivityData.Instance:SetSelect(8)
	ViewManager.Instance:Open(ViewName.KaifuActivityView, 8)
end

function PlayerInfoView:OnXunBaoActBtn()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_exchange)
end

function PlayerInfoView:FlushZhuanZhiActBtn()
	local act_statu  = ActivityData.Instance:GetActivityStatuByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT)
	if act_statu and next(act_statu) then
		local end_act_time  = act_statu.end_time -  TimeCtrl.Instance:GetCurOpenServerDay()

		if end_act_time >  0 then
			if KaifuActivityData.Instance:GetIsBuyGiftShopEquipGift() then
				self.node_list["ZhuanZhiActBtn"]:SetActive(false)
			else
				self.node_list["ZhuanZhiActBtn"]:SetActive(true)
				local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
				local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
				local reset_time_s = 24 * 3600 - cur_time
				self:SetZhuanZHiActBtnTime(reset_time_s)
			end
		else
			self.node_list["ZhuanZhiActBtn"]:SetActive(false)
		end
	else
		self.node_list["ZhuanZhiActBtn"]:SetActive(false)
	end
end

function PlayerInfoView:FlushXunBaoActBtn()
	if ExchangeData.Instance:GetIsHasNewLimitExchange() then
		local end_act_time = ExchangeData.Instance:GetIsHasNewLimitExchange() - TimeCtrl.Instance:GetServerTime()
		if end_act_time >  0 then
			self:SetXunBaoActBtnTime(end_act_time)
			self.node_list["XunBaoActBtn"]:SetActive(true)
		else
			self.node_list["XunBaoActBtn"]:SetActive(false)
		end
	end
end

function PlayerInfoView:SetZhuanZHiActBtnTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.node_list["ZhuanZhiActBtn"]:SetActive(false)
				return
			end
			local format_time = TimeUtil.Format2TableDHMS(left_time)
			local time_str = ""

			if format_time.day >= 1 then
				time_str = ToColorStr(string.format(Language.JinYinTa.ActEndTime6, format_time.day, format_time.hour), TEXT_COLOR.GREEN) 
			else
				time_str = ToColorStr(string.format(Language.JinYinTa.ActEndTime7, format_time.hour, format_time.min, format_time.s), TEXT_COLOR.GREEN) 
			end
			self.node_list["ZhuanZhiActTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function PlayerInfoView:SetXunBaoActBtnTime(diff_time)
	if self.xunbao_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.xunbao_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.xunbao_count_down)
					self.xunbao_count_down = nil
				end	
				self.node_list["XunBaoActBtn"]:SetActive(false)
				return
			end
			local format_time = TimeUtil.Format2TableDHMS(left_time)
			local time_str = ""

			if format_time.day >= 1 then
				time_str = ToColorStr(string.format(Language.JinYinTa.ActEndTime6, format_time.day, format_time.hour), TEXT_COLOR.GREEN) 
			else
				time_str = ToColorStr(string.format(Language.JinYinTa.ActEndTime7, format_time.hour, format_time.min, format_time.s), TEXT_COLOR.GREEN) 
			end
			self.node_list["XunBaoActTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.xunbao_count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end



