BossTujianView = BossTujianView or BaseClass(BaseRender)

local TOGGLE_MAX = 6
local BOSS_MAX_NUM = 8
local TWEEN_TIME = 0.5
local Is_Not_ShenWei_Boss = 0
local open_list = {
	[1] = "active_boss",
	[2] = "miku_boss",
	[3] = "vip_boss",
	[4] = "world_boss",
	[5] = "dabao_boss",
	[6] = "baby_boss",
}
function BossTujianView:__init()
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

	self.choose_type_sort = 1
	self.choose_client_sort = 1

	self.cell_list = {}
	self.select_card_index = nil

	self.first_open = true

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
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Txt_zhanli_value"])
end

function BossTujianView:__delete()
	self.fight_text = nil
	if nil ~= self.bosstujian_list then
		self.bosstujian_list = nil
	end

	if self.accordion_list then
		self.accordion_list = nil
	end

	if self.accordion_cell_list then
		self.accordion_cell_list = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.first_open = false
end

function BossTujianView:LoadBossListCell(index)
	local res_async_loader = AllocResAsyncLoader(self, "ListLoader" .. index)
	res_async_loader:Load("uis/views/bossview_prefab", "TuJian_Item", nil,
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
				local item_render = BossTuJianListItemRender.New(obj)
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

function BossTujianView:GetNumberOfCells()
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_Not_ShenWei_Boss)
	return boss_data and #boss_data or 0
end

function BossTujianView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	if self.cell_list and self.cell_list[cell] == nil then
		boss_cell = BossTuJianItemRender.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.bosstujian_list.toggle_group
		boss_cell.parent_view = self
		self.cell_list[cell] = boss_cell
	end
	self.cell_list[cell]:SetIndex(data_index)
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_Not_ShenWei_Boss)
	self.cell_list[cell]:SetData(boss_data[data_index])
end

function BossTujianView:OnClickOpenBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	if self.item_data.scene_type == 1 then				-- 活跃BOSS
		self:OnEnterActiveBoss()
	elseif self.item_data.scene_type == 2 then			-- 精英BOSS
		self:OnEnterMikuBoss()
	elseif self.item_data.scene_type == 3 then			-- VIP BOSS
		self:OnEnterVipBoss()
	elseif self.item_data.scene_type == 4 then			-- 世界BOSS
		self:OnEnterWorldBoss()
	elseif self.item_data.scene_type == 6 then			-- 宝宝BOSS
		self:OnEnterBabyBoss()
	elseif self.item_data.scene_type == 5 then			-- 打宝BOSS
		self:OnEnterDaBaoBoss()
	end
end

function BossTujianView:OnEnterWorldBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_boss = BossData.Instance:GetBossCfgById(self.select_boss_id)
	if world_boss then
		local min_level = world_boss.min_lv or 0
		if my_level >= min_level then
			ViewManager.Instance:CloseAll()
			local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
			GuajiCtrl.Instance:FlyToScene(boss_data.scene_id)
		else
			local limit_text = PlayerData.GetLevelString(min_level)
			limit_text = string.format(Language.Common.CanNotEnter, limit_text)
			TipsCtrl.Instance:ShowSystemMsg(limit_text)
		end
	end
end

function BossTujianView:OnEnterVipBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local _, cost_gold = BossData.Instance:GetBossVipLismit(self.select_scene_id)
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold >= cost_gold then
			BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
			ViewManager.Instance:CloseAll()
			self:SendToActtack()
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end

	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	if BossData.Instance:GetFamilyBossCanGoByVip(self.select_scene_id) then
		self:SendToActtack()
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Boss.BossFamilyLimit, cost_gold))
	end
end

function BossTujianView:SendToActtack()
	local level = BossData.Instance:GetBossFamilyKfSceneLevel(self.select_scene_id) or 1
	if level > 1 then
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id, self.select_boss_id)
	else
		BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id)
	end
end

function BossTujianView:OnEnterDaBaoBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	if not BossData.Instance:GetCanToSceneLevel(self.select_scene_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.NotEnoughLevel)
		return
	end

	-- local _, _, need_item_id, need_item_num = BossData.Instance:GetBossVipLismit(self.select_scene_id)

	local enter_count = BossData.Instance:GetDabaoBossCount()
	local max_count = BossData.Instance:GetDabaoFreeTimes()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	local free_enter_times = BossData.Instance:GetDabaoFreeEnterTimes()
	local need_item_id, need_item_num = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)
	if free_enter_times > 0 then
		BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		return
	end
	if enter_count < max_count then
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		if self.is_quick and num > 0 and num < need_item_num then
			local rest_num = need_item_num - num
			MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, 0, 0)
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif self.is_quick and num <= 0 then
			MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, 0, 0)
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif self.is_quick and num >= need_item_num then
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif num >= need_item_num then
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif num > 0 and num < need_item_num then
			local rest_num = need_item_num - num
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
				 MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
				 if is_buy_quick then
					self.is_quick = true
				end
			end)
		elseif num <= 0 then
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
				 MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
				if is_buy_quick then
					self.is_quick = true
				end
			end)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.BabyBossEnterTimesLimit)
	end
end

function BossTujianView:OnEnterMikuBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if not BossData.Instance:IsMikuBossScene(scene_id) and not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_scene_id)
end

function BossTujianView:OnEnterActiveBoss()
	local scene_id = Scene.Instance:GetSceneId()
	if not BossData.Instance:IsActiveBossScene(scene_id) and not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_scene_id, 1)
end

function BossTujianView:OnEnterBabyBoss()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local gold_cost, is_bind = BossData.Instance:GetBabyBossEnterCost()
	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
	-- 进入次数已达上限
	if enter_times >= enter_limit then
		if enter_limit < enter_times_max_vip then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BABYBOSS_ENTER_TIMES)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BabyBossEnterTimesLimit)
		end
		return
	end

	local need_item_id, need_item_num = BossData.Instance:GetBabyEnterCondition()

	local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
	if self.is_quick and num > 0 and num < need_item_num then
		local rest_num = need_item_num - num
		MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, 0, 0)
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif self.is_quick and num <= 0 then
		MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, 0, 0)
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif self.is_quick and num >= need_item_num then
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif num >= need_item_num then
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif num > 0 and num < need_item_num then
		local rest_num = need_item_num - num
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
			 if is_buy_quick then
				self.is_quick = true
			end
		end)
	elseif num <= 0 then
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_quick = true
			end
		end)
	end
end

function BossTujianView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Top_Content"], BossData.TweenPosition.TujianDown , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftBar"], BossData.TweenPosition.TujianLeft , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom_Content"], BossData.TweenPosition.TujianUp , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function BossTujianView:OnFlush()
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


function BossTujianView:CloseBossView()
	-- body
end

function BossTujianView:BossInfoShow(data, index)
	if not data then return end
	self.item_data = data
	self.select_card_index = index
	local data_list  = data.list
	self.boss_seq = data_list.monster_seq
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[data_list.monster_id]
	if nil == cfg then
		return
	end
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

function BossTujianView:FlushBOSSModel(data)
	local data_list = data.list
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[data_list.monster_id]
	if cfg == nil then
		return
	end
	BossCtrl.Instance:SetBossTujianDisPlay(cfg)
end

function BossTujianView:FlushCellHL()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:Flush()
		end
	end
end

function BossTujianView:OnClickBossJiHuo()
	if not self.boss_seq then return end
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_ACTIVE,self.boss_seq)
end

function BossTujianView:SetAccordionData()
	local accordion_tab = BossData.Instance:FormatMenu(Is_Not_ShenWei_Boss)
	-- local role_level = GameVoManager.Instance:GetMainRoleVo().level
	self.accordion_tab_data = accordion_tab
	for i = 1, TOGGLE_MAX do
		if accordion_tab[i] and accordion_tab[i].scene_type then
			self.node_list["BtnText_" .. i].text.text = Language.Boss.BossMap[accordion_tab[i].scene_type]
			self.node_list["TextBtn_" .. i].text.text = Language.Boss.BossMap[accordion_tab[i].scene_type]
			self.node_list["RedPoint_" .. i]:SetActive(accordion_tab[i].can_activef >= 1)
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

function BossTujianView:ClickFlushAccordionData(index)
	local accordion_tab = BossData.Instance:FormatMenu(Is_Not_ShenWei_Boss)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if index and self.accordion_cell_list[index] ~= nil then
		for k,v in pairs(self.accordion_cell_list[index]) do
			if nil == accordion_tab[index] then
				break
			end
			-- if k <= #accordion_tab[index]["child"] and role_level >= accordion_tab[index]["child"][k].layer_level then
			-- 	if index == 3 then
			-- 		local num = BossData.Instance:GetIsEnoughVipLevelInVipBossNum()
			-- 		v:SetActive(k <= num)
			-- 	else
			-- 		v:SetActive(true)
			-- 	end
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

function BossTujianView:GetNumInList(index)
	local accordion_tab = BossData.Instance:FormatMenu(Is_Not_ShenWei_Boss)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local num = 0
	if index and accordion_tab[index] and accordion_tab[index]["child"] then
		for i,v in ipairs(accordion_tab[index]["child"]) do
			if index == 3 then
				num = BossData.Instance:GetIsEnoughVipLevelInVipBossNum()
				return num
			else
				if role_level >= v.layer_level then
					num = num + 1
				end
			end
		end
	end
	return num
end

function BossTujianView:FlushToggleListRedPoint(index, list)
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

function BossTujianView:JumpToFirst()
	self:ReSetToggles()
	self.node_list["SelectBtn_" .. 1].accordion_element.isOn = true
	self:OnClickExpandHandler(1)
end

function BossTujianView:ShowIndex()
	self:SetAccordionData()
	if self.first_open then
		self.first_open = false
	else
		self:BossInfoShow(self.item_data, self.select_card_index)
	end
end

--外层
function BossTujianView:OnClickExpandHandler(index, index2)
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
function BossTujianView:OnClickProductHandler(cell)
	for i = 1, TOGGLE_MAX do
		if self.node_list["SelectBtn_" .. i].accordion_element.isOn == true then
			if self.accordion_tab_data[i] then
				self.choose_type_sort = self.accordion_tab_data[i].scene_type
			end
		end
	end
	if cell.data then
		self.choose_client_sort = cell.data.map_id
	end
	self:SelectTheActiveTujian()
end

function BossTujianView:SelectTheActiveTujian()
	if self.bosstujian_list and self.bosstujian_list.gameObject.activeInHierarchy then
		self.bosstujian_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
	local active_index = nil
	local boss_data = BossData.Instance:SetBossAllInfo(self.choose_type_sort, self.choose_client_sort, Is_Not_ShenWei_Boss)
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

function BossTujianView:GetSelectTheActiveClient()
	local accordion_tab = BossData.Instance:FormatMenu(Is_Not_ShenWei_Boss)
	for i = 1, TOGGLE_MAX do
		if nil == accordion_tab[i] then
			break
		end
		if accordion_tab[i]["child"] ~= nil then
			for i1 = 1, #accordion_tab[i]["child"] do
				local boss_data = BossData.Instance:SetBossAllInfo(i, i1, Is_Not_ShenWei_Boss)
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

function BossTujianView:IsActiveHave(choose_type_sort, choose_client_sort)
	local boss_data = BossData.Instance:SetBossAllInfo(choose_type_sort, choose_client_sort, Is_Not_ShenWei_Boss)
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

function BossTujianView:ReSetToggles()
	for i = 1, TOGGLE_MAX do
		for k = 1, BOSS_MAX_NUM do
			if nil ~= self.accordion_cell_list[i] and nil ~= self.accordion_cell_list[i][k] then
				self.accordion_cell_list[i][k].node_toggle.isOn = false
			end
		end
	end
	self:ReSetListToggles()
end

function BossTujianView:ReSetListToggles()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v.node_toggle.isOn = false
		end
	end
end

function BossTujianView:SetSelectBoss(scene_id, boss_id, map_type)
	self.select_scene_id = tonumber(scene_id)
	self.select_boss_id = tonumber(boss_id)
	-- self.layer = map_type
end

BossTuJianListItemRender = BossTuJianListItemRender or BaseClass(BaseCell)
function BossTuJianListItemRender:__init()
	-- self.node_list["Btn_Click"].button:AddClickListener(BindTool.Bind1(self.OnClickGet, self))
	self.node_toggle = self.node_list["TuJian_Item"].toggle
	self.node_toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
	-- self.node_list["Img_reward"].button:AddClickListener(BindTool.Bind1(self.ShowReward, self))
end

function BossTuJianListItemRender:__delete()

end

function BossTuJianListItemRender:OnClickItem(is_on)
	if nil == is_on then return end
	self.node_list["select_HL"]:SetActive(is_on)
	if true == is_on then
		self.parent_view:OnClickProductHandler(self)
	end
end

function BossTuJianListItemRender:ShowReward()
	if nil ~= self.data and nil ~= self.data.reward_item then
		BossCtrl.Instance:SetRewardTips(self.data.reward_item, self.data.reward_flag == 1)
	end

end

function BossTuJianListItemRender:OnFlush()
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

function BossTuJianListItemRender:OnClickGet()
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_FETCH,self.data.card_type)
end

BossTuJianItemRender = BossTuJianItemRender or BaseClass(BaseCell)
function BossTuJianItemRender:__init()
	self.node_toggle = self.node_list["Boss_Card_Item"].toggle
	self.node_toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
end

function BossTuJianItemRender:__delete()
	self.parent_view = nil
end

function BossTuJianItemRender:OnClickItem(is_click)
	if is_click then
		self.parent_view:BossInfoShow(self.data, self.index)
	end
end

function BossTuJianItemRender:OnFlush()
	if self.data == nil then
		return
	end
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

function BossTuJianItemRender:GetTujianRedPointActive()
	if self.data == nil then
		return
	end
	local active = (self.data.can_active == 1 and self.data.has_active ==0)
	return active
end