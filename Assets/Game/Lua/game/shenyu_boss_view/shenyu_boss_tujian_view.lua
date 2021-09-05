ShenYuBossTujianView = ShenYuBossTujianView or BaseClass(BaseRender)

local TOGGLE_MAX = 3 										-- 神域Boss图鉴左边toggle数目
local BOSS_MAX_NUM = 8
local TWEEN_TIME = 0.5
local Is_ShenWei_Boss = 1
local open_list = {
	[1] = "shenyu_godmagic",
	[2] = "kf_boss",
	[3] = "shenyu_secret",
}
function ShenYuBossTujianView:__init()
	if nil == self.accordion_list then
		self.accordion_list = {}
		self.accordion_cell_list = {}
		for i = 1, TOGGLE_MAX do
			self.accordion_list[i] = {}
			self.accordion_list[i].list = self.node_list["List_"..i ]
			self:LoadBossListCell(i)
			self.node_list["List_"..i ]:SetActive(true)
			self.node_list["SelectBtn_" .. i]:SetActive(true)
		end
		for i = TOGGLE_MAX + 1, 8 do
			self.node_list["List_"..i ]:SetActive(false)
			self.node_list["SelectBtn_" .. i]:SetActive(false)
		end
	end

	self.cell_list = {}
	self.select_card_index = nil

	self.first_open = true

	-- self.model_view = RoleModel.New()
	-- self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Txt_zhanli_value"], "FightPower3")
	self.bosstujian_list = self.node_list["List_Card"]
	local list_delegate = self.bosstujian_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["Img_remind"]:SetActive(false)
	self.node_list["Btn_jihuo"].button:AddClickListener(BindTool.Bind1(self.OnClickBossJiHuo, self))
	self.node_list["Btn_jisha"].button:AddClickListener(BindTool.Bind1(self.OnClickOpenBoss, self))
	for i = 1, TOGGLE_MAX do
		self.node_list["SelectBtn_" .. i].accordion_element:AddValueChangedListener(BindTool.Bind(self.OnClickExpandHandler, self, i))
	end
end

function ShenYuBossTujianView:__delete()

	if nil ~= self.bosstujian_list then
		self.bosstujian_list = nil
	end

	if self.accordion_list then
		self.accordion_list = nil
	end

	if self.accordion_cell_list then
		self.accordion_cell_list = nil
	end
	if self.cell_list then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	self.cell_list = {}
	self.fight_text = nil
	self.first_open = false
	-- if nil ~= self.model_view then
	-- 	self.model_view:DeleteMe()
	-- 	self.model_view = nil
	-- end
end

function ShenYuBossTujianView:LoadBossListCell(index)
	local res_async_loader = AllocResAsyncLoader(self, "ListLoader" .. index)
	res_async_loader:Load("uis/views/shenyubossview_prefab", "TuJian_Item", nil,
		function(new_obj)
			if nil == new_obj then
				return
			end
			local item_vo = {}
			local num = self:GetNumInList(index)
			for i = 1, num do
				local obj = ResMgr:Instantiate(new_obj)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.accordion_list[index].list.transform, false)
				obj:GetComponent("Toggle").group = self.accordion_list[index].list.toggle_group
				local item_render = ShenYuBossTuJianListItemRender.New(obj)
				item_render.parent_view = self
				item_vo[i] = item_render
			end
			self.accordion_cell_list[index] = item_vo
			if index == TOGGLE_MAX then
				self:SetAccordionData()
				self:JumpToFirst()
			end
		end)
end

function ShenYuBossTujianView:GetNumberOfCells()
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_ShenWei_Boss)
	return boss_data and #boss_data or 0
end

function ShenYuBossTujianView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	if self.cell_list[cell] == nil then
		boss_cell = ShenYuBossTuJianItemRender.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.bosstujian_list.toggle_group
		boss_cell.parent_view = self
		self.cell_list[cell] = boss_cell
	end
	self.cell_list[cell]:SetIndex(data_index)
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_ShenWei_Boss)
	self.cell_list[cell]:SetData(boss_data[data_index])
end

function ShenYuBossTujianView:OnClickOpenBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	if self.item_data.scene_type == 7 then 					-- 神魔Boss
		self:OnEnterGodMagicBoss()
	elseif self.item_data.scene_type == 8 then 					-- 神域Boss
		self:OnEnterCrossBoss()
	elseif self.item_data.scene_type == 9 then				-- 跨服BOSS
		self:OnEnterShenYuMiZangCrossBoss()
	end
end

function ShenYuBossTujianView:OnEnterGodMagicBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_ENTER, self.select_scene_id)
end

function ShenYuBossTujianView:OnEnterShenYuMiZangCrossBoss()
	local scene_id = Scene.Instance:GetSceneId()
	ShenYuBossData.Instance:SetSelectBoss(self.select_scene_id, self.select_boss_id)
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		local boss_list = ShenYuBossData.Instance:GetCrossLayerBossBylayer(self.layer)
		for k,v in pairs(boss_list) do
			if v.boss_id == self.select_boss_id then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				local callback = function()
					GuajiCtrl.Instance:MoveToPos(self.select_scene_id, v.data.x_pos, v.data.y_pos, 10, 10)
				end
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
				ViewManager.Instance:Close(ViewName.ShenYuBossView)
				return
			end
		end
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	ShenYuBossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_MIZANG_BOSS, self.layer)
end

function ShenYuBossTujianView:OnEnterCrossBoss()
	local scene_id = Scene.Instance:GetSceneId()
	ShenYuBossData.Instance:SetSelectBoss(self.select_scene_id, self.select_boss_id)
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		local boss_list = BossData.Instance:GetCrossLayerBossBylayer(self.layer)
		for k,v in pairs(boss_list) do
			if v.boss_id == self.select_boss_id then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				local callback = function()
					GuajiCtrl.Instance:MoveToPos(self.select_scene_id, v.data.x_pos, v.data.y_pos, 10, 10)
				end
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
				ViewManager.Instance:Close(ViewName.ShenYuBossView)
				return
			end
		end
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_BOSS, self.layer)
end

function ShenYuBossTujianView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Top_Content"], BossData.TweenPosition.TujianDown , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftBar"], BossData.TweenPosition.TujianLeft , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom_Content"], BossData.TweenPosition.TujianUp , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ShenYuBossTujianView:OnFlush()
	self:SetAccordionData()
	if self.bosstujian_list ~= nil and self.bosstujian_list.gameObject.activeInHierarchy then
		if self:IsActiveHave(self.choose_type_sort, self.choose_client_sort) then
			self:SelectTheActiveTujian(self.choose_type_sort, self.choose_client_sort)
		else
			local choose_type_sort, choose_client_sort = self:GetSelectTheActiveClient()
			if choose_type_sort ~= nil and choose_client_sort ~= nil then
				self.node_list["SelectBtn_" .. choose_type_sort].accordion_element.isOn = true
				GlobalTimerQuest:AddDelayTimer(function()
					self:OnClickExpandHandler(choose_type_sort, choose_client_sort)
				end, 0.1)
			end
		end
	end
	if nil ~= self.item_data and nil ~= self.select_card_index then
		self:BossInfoShow(self.item_data, self.select_card_index)
	end
end


function ShenYuBossTujianView:CloseBossView()
	-- body
end

function ShenYuBossTujianView:BossInfoShow(data, index)
	if not data then return end
	self.item_data = data
	self.select_card_index = index
	local data_list  = data.list
	self.boss_seq = data_list.monster_seq
	-- local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[data_list.monster_id]
	-- if nil == cfg then
	-- 	return
	-- end

	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if data.open_level > my_level then
		self.node_list["Img_remind"]:SetActive(false)
		self.node_list["Btn_jihuo"].button.interactable = false
		UI:SetGraphicGrey(self.node_list["Btn_jihuo"], true)
	else
		self.node_list["Img_remind"]:SetActive(true)
		self.node_list["Btn_jihuo"].button.interactable = true
		UI:SetGraphicGrey(self.node_list["Btn_jihuo"], false)
	end

	self.node_list["Txt_hp"].text.text = data_list.maxhp
	self.node_list["Txt_fangyu"].text.text = data_list.fangyu
	self.node_list["Txt_gongji"].text.text = data_list.gongji

	local jihuo_cfg  =  BossData.Instance:SetAllBossActiveFlagInfo(data_list.monster_seq)
	if jihuo_cfg.can_active == 1 and jihuo_cfg.has_active == 0 then
		self.node_list["Btn_jihuo"]:SetActive(true)
		self.node_list["Txt_jihuo"].text.text = Language.Common.Activate
		self.node_list["Img_remind"]:SetActive(true)
		self.node_list["Btn_jihuo"].button.interactable = true
		self.node_list["Btn_jisha"]:SetActive(false)
		UI:SetGraphicGrey(self.node_list["Btn_jihuo"], false)
	elseif jihuo_cfg.can_active ==  0 and jihuo_cfg.has_active == 0 then
		-- self.node_list["Txt_jihuo"].text.text = Language.Common.NoActivate
		self.node_list["Img_remind"]:SetActive(false)
		self.node_list["Btn_jihuo"]:SetActive(false)
		self.node_list["Btn_jisha"]:SetActive(true)
		-- UI:SetGraphicGrey(self.node_list["Btn_jihuo"], true)
	elseif jihuo_cfg.has_active == 1 then
		self.node_list["Btn_jihuo"]:SetActive(true)
		self.node_list["Txt_jihuo"].text.text = Language.Role.HadActive
		self.node_list["Img_remind"]:SetActive(false)
		self.node_list["Btn_jihuo"].button.interactable = false
		self.node_list["Btn_jisha"]:SetActive(false)
		UI:SetGraphicGrey(self.node_list["Btn_jihuo"], true)
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = data_list.zhanli
	end

	self:SetSelectBoss(data.scene_id, data.list.monster_id, data.map_type)
	self:FlushBOSSModel(data)
	self:FlushCellHL()
end

function ShenYuBossTujianView:FlushBOSSModel(data)
	local data_list = data.list
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[data_list.monster_id]
	if cfg == nil then
		return
	end
	ShenYuBossCtrl.Instance:SetBossTujianDisPlay(cfg)
end

function ShenYuBossTujianView:FlushCellHL()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:Flush()
		end
	end
end

function ShenYuBossTujianView:OnClickBossJiHuo()
	if not self.boss_seq then return end
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_ACTIVE,self.boss_seq)
end

function ShenYuBossTujianView:SetAccordionData()
	local accordion_tab = BossData.Instance:FormatMenu(Is_ShenWei_Boss)
	self.accordion_tab_data = accordion_tab
	for i = 1, TOGGLE_MAX do
		if accordion_tab[i] and accordion_tab[i].scene_type then
			self.node_list["BtnText_" .. i].text.text = Language.Boss.BossMap[accordion_tab[i].scene_type]
			self.node_list["TextBtn_" .. i].text.text = Language.Boss.BossMap[accordion_tab[i].scene_type]
			if accordion_tab[i].can_activef then
				self.node_list["RedPoint_" .. i]:SetActive(accordion_tab[i].can_activef >= 1)
			end
			self:FlushToggleListRedPoint(i, accordion_tab[i]["child"])
			self:ClickFlushAccordionData(i)
			local is_open = OpenFunData.Instance:CheckIsHide(open_list[i])
			self.node_list["SelectBtn_" .. i]:SetActive(is_open)
			if self.node_list["List_"..i ]:GetActive() and not is_open then
				self.node_list["List_"..i ]:SetActive(false)
			end
		else
			self.node_list["SelectBtn_" .. i]:SetActive(false)
		end
	end
end

function ShenYuBossTujianView:ClickFlushAccordionData(index)
	local accordion_tab = BossData.Instance:FormatMenu(Is_ShenWei_Boss)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if index and self.accordion_cell_list[index] ~= nil then
		for k,v in pairs(self.accordion_cell_list[index]) do
			if nil == accordion_tab[index] then
				break
			end
			-- if k <= #accordion_tab[index]["child"] and role_level >= accordion_tab[index]["child"][k].layer_level then
			-- 	v:SetActive(true)
			-- else
			-- 	v:SetActive(false)
			-- end
			if k <= #accordion_tab[index]["child"] then
				v:SetData(accordion_tab[index]["child"][k])
			end
		end
	end
	-- local rect = self.node_list["List_" .. index]:GetComponent(typeof(UnityEngine.RectTransform))
	-- --强制刷新
	-- UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
end

function ShenYuBossTujianView:GetNumInList(index)
	local accordion_tab = BossData.Instance:FormatMenu(Is_ShenWei_Boss)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local num = 0
	if index and accordion_tab[index] and accordion_tab[index]["child"] then
		for i,v in ipairs(accordion_tab[index]["child"]) do
			if role_level >= v.layer_level then
				num = num + 1
			end
		end
	end
	return num
end

function ShenYuBossTujianView:FlushToggleListRedPoint(index, list)
	if list == nil then
		return
	end

	-- for k,v in pairs(list) do
	-- 	if v.reward_flag == 0 and v.progress == 100 then
	-- 		self.node_list["RedPoint_" .. index]:SetActive(true)
	-- 		return
	-- 	end
	-- end
end

function ShenYuBossTujianView:JumpToFirst()
	self:ReSetToggles()
		self.node_list["SelectBtn_" .. 1].accordion_element.isOn = true
		self:OnClickExpandHandler(1)
end

function ShenYuBossTujianView:ShowIndex()
	self.choose_type_sort = 1
	self.choose_client_sort = 1
	self:SetAccordionData()
	if self.first_open then
		self.first_open = false
	else
		self:BossInfoShow(self.item_data, self.select_card_index)
	end
end

--外层
function ShenYuBossTujianView:OnClickExpandHandler(index, index2)
	index2 = tonumber(index2) or 1
	if self.node_list["SelectBtn_" .. index].accordion_element.isOn and nil ~= self.accordion_cell_list[index] and self.accordion_cell_list[index][index2] then
		self:ClickFlushAccordionData(index)
		if nil ~= self.accordion_cell_list[index][index2] then
			self.accordion_cell_list[index][index2].node_toggle.isOn = false
			self.accordion_cell_list[index][index2].node_toggle.isOn = true
		end
	end
end
--内层
function ShenYuBossTujianView:OnClickProductHandler(cell)
	for i = 1, TOGGLE_MAX do
		if self.node_list["SelectBtn_" .. i].accordion_element.isOn == true then
			if self.accordion_tab_data[i] then
				local num = BossData.Instance:GetNotShenYuBossNum()
				self.choose_type_sort = self.accordion_tab_data[i].scene_type - num
			end
		end
	end
	if cell.data then
		self.choose_client_sort = cell.data.map_id
	end
	self:SelectTheActiveTujian()
end

function ShenYuBossTujianView:SelectTheActiveTujian()
	if self.bosstujian_list and self.bosstujian_list.gameObject.activeInHierarchy then
		self.bosstujian_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
	local active_index = nil
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_ShenWei_Boss)
	if boss_data then
		for i,v in ipairs(boss_data) do
			if v.can_active == 1 and v.has_active ==0 then
				active_index = i
				break
			end
		end
	end
	active_index = active_index or 1
	local list_num = self:GetNumberOfCells()
	if self.bosstujian_list and self.bosstujian_list.gameObject.activeInHierarchy and list_num > 0 then
		-- self.bosstujian_list.scroller:JumpToDataIndex(active_index - 1)
		if active_index == 1 then
			self.bosstujian_list.scroll_rect.horizontalNormalizedPosition = 0
		elseif active_index == list_num then
			self.bosstujian_list.scroll_rect.horizontalNormalizedPosition = 1
		else
			self.bosstujian_list.scroll_rect.horizontalNormalizedPosition = active_index / list_num
		end
	end

	if nil ~= boss_data then
		for k,v in pairs(boss_data) do
			if k == active_index then
				self:BossInfoShow(v, k)
				break
			end
		end
	end
end

function ShenYuBossTujianView:GetSelectTheActiveClient()
	local accordion_tab = BossData.Instance:FormatMenu(Is_ShenWei_Boss)
	for i = 1, TOGGLE_MAX do
		if nil == accordion_tab[i] then
			break
		end
		if accordion_tab[i]["child"] ~= nil then
			for i1 = 1, #accordion_tab[i]["child"] do
				local boss_data = BossData.Instance:SetBossAllInfo(i, i1, Is_ShenWei_Boss)
				if boss_data == nil then
					break
				end
				for k,v in pairs(boss_data) do
					if v.can_active == 1 and v.has_active ==0 then
						return i, i1
					end
				end
			end
		end
	end
end

function ShenYuBossTujianView:IsActiveHave(choose_type_sort, choose_client_sort)
	local boss_data = BossData.Instance:SetBossAllInfo(choose_type_sort, choose_client_sort, Is_ShenWei_Boss)
	if boss_data == nil then
		return false
	end
	for k,v in pairs(boss_data) do
		if v.can_active == 1 and v.has_active ==0 then
			return true
		end
	end
	return false
end

function ShenYuBossTujianView:ReSetToggles()
	for i = 1, TOGGLE_MAX do
		for k = 1, BOSS_MAX_NUM do
			if nil ~= self.accordion_cell_list[i] and nil ~= self.accordion_cell_list[i][k] then
				self.accordion_cell_list[i][k].node_toggle.isOn = false
			end
		end
	end
	self:ReSetListToggles()
end

function ShenYuBossTujianView:ReSetListToggles()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v.node_toggle.isOn = false
		end
	end
end

function ShenYuBossTujianView:SetSelectBoss(scene_id, boss_id, map_type)
	self.select_scene_id = scene_id
	self.select_boss_id = boss_id
	self.layer = map_type
end

ShenYuBossTuJianListItemRender = ShenYuBossTuJianListItemRender or BaseClass(BaseCell)
function ShenYuBossTuJianListItemRender:__init()
	-- self.node_list["Btn_Click"].button:AddClickListener(BindTool.Bind1(self.OnClickGet, self))
	self.node_toggle = self.node_list["TuJian_Item"].toggle
	self.node_toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
	-- self.node_list["Img_reward"].button:AddClickListener(BindTool.Bind1(self.ShowReward, self))
end

function ShenYuBossTuJianListItemRender:__delete()

end

function ShenYuBossTuJianListItemRender:OnClickItem(is_on)
	if nil == is_on then return end
	self.node_list["select_HL"]:SetActive(is_on)
	if true == is_on then
		self.parent_view:OnClickProductHandler(self)
	end
end

function ShenYuBossTuJianListItemRender:ShowReward()
	if nil ~= self.data and nil ~= self.data.reward_item then
		BossCtrl.Instance:SetRewardTips(self.data.reward_item, self.data.reward_flag == 1)
	end

end

function ShenYuBossTuJianListItemRender:OnFlush()
	if self.data == nil then
		return
	end
	if self.data.box_color then
		self.node_list["Txt_name"].text.text = ToColorStr(self.data.name, SOUL_NAME_COLOR[self.data.box_color + 1])
		local bg_bundle, bg_asset = ResPath.GetTujianBgIcon(self.data.box_color)
		self.node_list["TuJian_Item"].image:LoadSprite(bg_bundle, bg_asset)
	end
	self.node_list["Img_remind"]:SetActive(self.data.can_active >= 1)
end

function ShenYuBossTuJianListItemRender:OnClickGet()
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_FETCH,self.data.card_type)
end

ShenYuBossTuJianItemRender = ShenYuBossTuJianItemRender or BaseClass(BaseCell)
function ShenYuBossTuJianItemRender:__init()
	self.node_toggle = self.node_list["Boss_Card_Item"].toggle
	self.node_toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
end

function ShenYuBossTuJianItemRender:__delete()
	self.parent_view = nil
end

function ShenYuBossTuJianItemRender:OnClickItem(is_click)
	if is_click then
		self.parent_view:BossInfoShow(self.data, self.index)
	end
end

function ShenYuBossTuJianItemRender:OnFlush()
	local boss_list  = self.data.list
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_list.monster_id]
	if nil == cfg then
		return
	end

	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if self.data.open_level <= my_level then
		UI:SetGraphicGrey(self.node_list["Img_Boss_head"], self.data.has_active == 0)
		UI:SetGraphicGrey(self.node_list["head_frame"], self.data.has_active == 0)
		UI:SetGraphicGrey(self.node_list["Img_Card"], self.data.has_active == 0)
	else
		UI:SetGraphicGrey(self.node_list["Img_Boss_head"], self.data.open_level > my_level)
		UI:SetGraphicGrey(self.node_list["head_frame"], self.data.open_level > my_level)
		UI:SetGraphicGrey(self.node_list["Img_Card"], self.data.open_level > my_level)
	end
	self.node_list["Img_HL"]:SetActive(self.parent_view.select_card_index == self.index)
	self.node_list["Img_Boss_head"].image:LoadSprite(ResPath.GetBossIcon(cfg.headid))
	self.node_list["Img_Card"].image:LoadSprite(ResPath.GetBossNoPackImage("bosscard_bg_"..boss_list.quality_id))
	self.node_list["Txt_Level"].text.text = string.format(Language.Boss.Level, cfg.level)
	self.node_list["Txt_name"].text.text = cfg.name
	self.node_list["Img_boss_remind"]:SetActive(self.data.can_active == 1 and self.data.has_active ==0)
end

function ShenYuBossTuJianItemRender:GetTujianRedPointActive()
	if self.data == nil then
		return
	end
	local active = (self.data.can_active == 1 and self.data.has_active ==0)
	return active
end