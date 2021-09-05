ReviveView = ReviveView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.SpiritView, ViewName.Goddess, ViewName.BaoJu
}

function ReviveView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab","BaseThreePanel"},
		{"uis/views/reviveview_prefab", "ReviveView"}
	}
	self.is_modal = true
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function ReviveView:__delete()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	self.show_free = nil
	PlayerPrefsUtil.DeleteKey("fuhuo")

	self:StopCountDown()
end

function ReviveView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down_two ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end
	ReviveData.Instance:SetKillerName("")

	self:StopCountDown()
end

function ReviveView:OpenCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down_two ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end

	self:StopCountDown()

	self:Flush()
	ReviveData.Instance:SetLastReviveType(-1)
end

function ReviveView:LoadCallBack()
	-- self.node_list["Bg"].rect.sizeDelta = Vector2(803, 490)

	-- self.node_list["BtnClose"]:SetActive(false)
	-- self.node_list["Txt"].text.text = Language.Fuhuo.ReviveName
	self.node_list["ImgLocalRevive"].button:AddClickListener(BindTool.Bind(self.OnClickLocal, self))
	self.node_list["ButResurgence"].button:AddClickListener(BindTool.Bind(self.OnClickLocal, self))
	self.node_list["ButGratis"].button:AddClickListener(BindTool.Bind(self.OnClickFree, self))
	self.node_list["ImgFreeRevive"].button:AddClickListener(BindTool.Bind(self.OnClickFree, self))
	self.node_list["ButLocalRevive"].button:AddClickListener(BindTool.Bind(self.OnClickBtn3, self))
	self.node_list["ImgLeftArrows"].button:AddClickListener(BindTool.Bind(self.ClickPre, self))
	self.node_list["ImgRightArrows"].button:AddClickListener(BindTool.Bind(self.ClickNext, self))
	self.node_list["ImgGuildReviveIcon"].button:AddClickListener(BindTool.Bind(self.OnClickGuildRevive, self))
	self.node_list["Btn_tianshen_active"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	
	self.node_list["ImgLocalRevive"]:SetActive(false)
	self.node_list["ImgGuildReviveIcon"]:SetActive(true)
	--self.node_list["TxtRevive"]:SetActive(false)
	self.node_list["Txt_buff_tip"].text.text = Language.Revive.BuffTip

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.cell_list = {}
	self.show_free = nil
end

function ReviveView:ReleaseCallBack()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.count_down_two ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_two)
		self.count_down_two = nil
	end

	if self.free_count_down then
		CountDown.Instance:RemoveCountDown(self.free_count_down)
		self.free_count_down = nil
	end

	if self.gold_count_down then
		CountDown.Instance:RemoveCountDown(self.gold_count_down)
		self.gold_count_down = nil
	end
	PlayerPrefsUtil.DeleteKey("fuhuo")
end

function ReviveView:GetMountNumberOfCells()
	local gongneng_sort = ReviveData.Instance:GetGongNeng()
	return #gongneng_sort
end

function ReviveView:RefreshMountCell(cell, cell_index)
	local gongneng_image = ReviveData.Instance:GetGongNeng()
	local gongneng_cell = self.cell_list[cell]
	if gongneng_cell == nil then
		gongneng_cell = GongNengCell.New(cell.gameObject)
		self.cell_list[cell] = gongneng_cell
	end
	local data = {}
	data.image_name = gongneng_image[cell_index+1].img_name
	data.view_name = gongneng_image[cell_index+1].view_name
	data.index = cell_index
	gongneng_cell:SetData(data)
end

function ReviveView:ClickPre()
	local position = self.node_list["ListView"].scroller.ScrollPosition
	local index = self.node_list["ListView"].scroller:GetCellViewIndexAtPosition(position)
	index = index - 1
	self:JumpToIndex(index)
end

function ReviveView:ClickNext()
	local position = self.node_list["ListView"].scroller.ScrollPosition
	local index = self.node_list["ListView"].scroller:GetCellViewIndexAtPosition(position)
	index = index + 1
	self:JumpToIndex(index)
end

-- 点击公会复活
function ReviveView:OnClickGuildRevive()
	FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
	ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
end

function ReviveView:JumpToIndex(index)
	local max_count = self:GetMountNumberOfCells()
	index = index >= max_count and max_count - 1 or index
	if index < 0 then
		index = 0
	end
	local width = self.node_list["ListView"].transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.node_list["ListView"].scroller.spacing
	-- 当前页面可以显示的数量
	local count = math.floor((width + space) / (78 + space))
	if max_count <= count or index + count > max_count then
		return
	end

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["ListView"].scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.node_list["ListView"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

-- 原地满血复活
function ReviveView:OnClickLocal()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.remind_times ~= 0 then
		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
		ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
	elseif not ReviveView.CanUseItem() then
		local func = function ()
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)
		end
		local str = string.format(Language.Fuhuo.BuyFuHuo4, ReviveView.ReviveCost())
		TipsCtrl.Instance:ShowCommonAutoView("fuhuo", str, func)
	end
end

-- 免费复活
function ReviveView:OnClickFree()
	FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	self:OnClose()
end

function ReviveView:OnClickBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		if ct_info.current_credit >= revive_cost then
			ClashTerritoryCtrl.Instance:SendTerritoryWarReliveFightBuy(ClashTerritoryData.ReviveType, ClashTerritoryData.ReviveGoods)
			self:OnClose()
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotEnoughScore)
		end
	end
end

function ReviveView:OnClose()
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role.show_hp > 0 then
		self:Close()
	end
end

function ReviveView:OnFlush(param_t)
	local diff_time = ReviveView.ReviveTime()

	self.node_list["TxtKiller"].text.text = ReviveData.Instance:GetKillerName()
	self.node_list["TxtNum"].text.text = ReviveView.ReviveCost()
	self.node_list["TxtNum2"].text.text = ReviveView.ReviveCost()
	self.node_list["ImgIconGold"].image:LoadSprite(ResPath.GetGoldIcon(5))
	self.node_list["ImgIconGold2"].image:LoadSprite(ResPath.GetGoldIcon(5))

	local scene_type = Scene.Instance:GetSceneType()
	-- self.node_list["ImgFreeRevive"]:SetActive(ReviveView.CanUseFreeRevive())
	self.node_list["FreeRevive"]:SetActive(ReviveView.CanUseFreeRevive())
	self.node_list["TxtNum"]:SetActive(not ReviveView.CanUseItem())
	self.node_list["TxtNum2"]:SetActive(not ReviveView.CanUseItem())
	UI:SetButtonEnabled(self.node_list["ButGratis"], not ReviveView.FreeReviveEnble())
	self.node_list["Panel"]:SetActive(true)
	self.node_list["TxtTips"]:SetActive(true)

	self.node_list["PanelWorldBoss"]:SetActive(false)
	self.node_list["XiuLuoTowerNode"]:SetActive(false)
	self:UpdateShowBtn3()

	self:FlushBuff()

	local scene_id = Scene.Instance:GetSceneId()
	local free_txt = Language.Fuhuo.FreeReviveTxt[1]
	if BossData.IsBossScene(scene_id) then
		if BossData.Instance:IsFamilyBossScene(scene_id) then
			-- free_txt = Language.Fuhuo.FreeReviveTxt[2]
			free_txt = ""
		else
			local main_role = Scene.Instance:GetMainRole()
			if main_role and main_role.vo.top_dps_flag and main_role.vo.top_dps_flag > 0 then
				free_txt = Language.Fuhuo.FreeReviveTxt[3]
			end
		end
	end
	self.node_list["TxtText3"].text.text = free_txt
	self.node_list["Text4"]:SetActive(false)
	if Scene.Instance:GetSceneType() == SceneType.ChaosWar and YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo() then
			self.node_list["TxtText3"]:SetActive(false)
			local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}
			local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
			if (other_cfg.dead_max_count or 0) - user_info.dead_count > 1 then
				self.node_list["Text4"].text.text = string.format(Language.YiZhanDaoDi.RealiveTimes, (other_cfg.dead_max_count or 0) - user_info.dead_count)
			else
				self.node_list["Text4"].text.text = Language.YiZhanDaoDi.DieTip
			end
			self.node_list["Text4"]:SetActive(true)
	end
	if ReviveView.CanUseItem() then
		if Scene.Instance:GetSceneType() == SceneType.Kf_XiuLuoTower and KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
			local xlt_fh = KuaFuXiuLuoTowerData.Instance:GetReviveTxt()
			self.node_list["XiuLuoTowerNode"]:SetActive(true)
			self.node_list["TxtText3"]:SetActive(false)
			local is_show_drop_des = KuaFuXiuLuoTowerData.Instance:GetCurLayerDes()
			if nil ~= is_show_drop_des then
				self.node_list["XiuLuoTxt2"]:SetActive(is_show_drop_des)
				self.node_list["XiuLuoTxt1"]:SetActive(not is_show_drop_des)
			end
			-- self.node_list["TxtText"]:SetActive(false)
			-- self.node_list["TxtText"].text.text = xlt_fh
		-- else
		end
		local item_count = ItemData.Instance:GetItemNumInBagById(ReviveDataItemId.ItemId)
		local name = ItemData.Instance:GetItemName(ReviveDataItemId.ItemId)
		self.node_list["TxtText"].text.text = name .. ":" .. item_count .. "/1"
	else
		self.node_list["TxtText"].text.text = ""
	end
	-- if BossData.Instance:IsMikuBossScene(Scene.Instance:GetSceneId()) and BossData.Instance:GetWroldBossWeary() >= 5 then
	-- 	self.node_list["Panel"]:SetActive(false)
	-- 	self.node_list["TxtTips"]:SetActive(false)
	-- 	self.node_list["PanelWorldBoss"]:SetActive(true)

	-- 	if (TimeCtrl.Instance:GetServerTime() - BossData.Instance:GetWroldBossWearyLastDie()) >= 62 then
	-- 		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME, 1) -- 第二个参数代表超时自动复活
	-- 		ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	-- 		self:OnClose()
	-- 		return
	-- 	else
	-- 		diff_time = BossData.Instance:GetWroldBossWearyLastDie() + 61 - TimeCtrl.Instance:GetServerTime()
	-- 	end
	-- 	if self.count_down_two == nil and diff_time and self:IsOpen() then
	-- 		function diff_time_func(elapse_time, total_time)
	-- 			local left_time = math.floor(diff_time - elapse_time)
	-- 			if left_time <= 0 then
	-- 				if self.count_down_two ~= nil then
	-- 					CountDown.Instance:RemoveCountDown(self.count_down_two)
	-- 					self.count_down_two = nil
	-- 					FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME, 1) -- 第二个参数代表超时自动复活
	-- 					ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	-- 					return
	-- 				end
	-- 				return
	-- 			end
	-- 			self.node_list["TxtTime"].text.text = left_time
	-- 		end

	-- 		diff_time_func(0, diff_time)
	-- 		if self.count_down ~= nil then
	-- 			CountDown.Instance:RemoveCountDown(self.count_down)
	-- 			self.count_down = nil
	-- 		end
	-- 		self.count_down_two = CountDown.Instance:AddCountDown(
	-- 			diff_time, 0.5, diff_time_func)
	-- 	end
	-- 	return
	-- end

	if BossData.Instance:IsCrossBossScene(Scene.Instance:GetSceneId()) and BossData.Instance:GetCrossBossWeary() >= 5 then
		self.node_list["Panel"]:SetActive(false)
		self.node_list["TxtTips"]:SetActive(false)
		self.node_list["PanelWorldBoss"]:SetActive(true)
		if (BossData.Instance:GetCrossBossCanReliveTime() - TimeCtrl.Instance:GetServerTime()) >= 62 then
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME, 1) -- 第二个参数代表超时自动复活
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			self:OnClose()
			return
		end
		if self.count_down_two == nil then
			self.node_list["TxtTime"].text.text = 60
			self.count_down_two = CountDown.Instance:AddCountDown(
				62, 1, function(elapse_time, total_time)
					if elapse_time >= total_time then
						return
					end
					local left_time = math.ceil(60 - elapse_time)
					if left_time <= 0 then
						FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME, 1) -- 第二个参数代表超时自动复活
						ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
						return
					end
					self.node_list["TxtTime"].text.text = left_time
				end)
		end
		return
	end
	
	-- 夜战王城特殊复活时间
	local scene_type = Scene.Instance:GetSceneType()
	if KuaFuTuanZhanData.IsNightFightScene(scene_type) then
		diff_time = KuaFuTuanZhanData.Instance:GetReviveTime()
	end

	--跨服修罗塔复活时间
	if SceneType.Kf_XiuLuoTower == scene_type then
		diff_time = 15
	end

	if self.count_down == nil then
		local complete_func = function ()
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME, 1) -- 第二个参数代表超时自动复活
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
			self:OnClose()
		end

		local update_func = function(elapse_time, total_time)
			local left_time = math.ceil(diff_time - elapse_time)
			if left_time <= 0 then
				complete_func()
				return
			end
			local left_sec = math.floor(left_time)
			self.node_list["TxtTips"].text.text =  string.format(Language.Fuhuo.Time, left_sec)
		end

		self.count_down = CountDown.Instance:AddCountDown(diff_time, 1, update_func, complete_func)
	end
	self.node_list["TxtTips"].text.text = string.format(Language.Fuhuo.Time, diff_time )--diff_time
	local used_times = ReviveData.Instance:GetReviveFreeTime()
	local today_free_revive_num = ReviveData.Instance:GetTodayFreeReviveNum()
	if today_free_revive_num - used_times <= 0 then
		self.show_free = false
		--self.node_list["TxtNum"]:SetActive(true)
		self.node_list["TxtReviveTime"]:SetActive(false)
		self.remind_times = 0
	else
		self.show_free = true
		self.node_list["TxtNum"]:SetActive(false)
		self.node_list["TxtReviveTime"]:SetActive(true)
		self.remind_times = today_free_revive_num - used_times
		self.node_list["TxtReviveTime"].text.text = string.format(Language.Fuhuo.FreeTime, self.remind_times)
	end
	if scene_type == SceneType.CrossShuijing or scene_type == SceneType.ShuiJing or scene_type == SceneType.TowerDefend or scene_type == SceneType.TeamTowerFB then
		-- local shuijing_free_revive_num = CrossCrystalData.Instance:GetActivityShuiJingFree()
		-- local flag = shuijing_free_revive_num >= today_free_revive_num
		-- local time = flag and today_free_revive_num or shuijing_free_revive_num
		local time = today_free_revive_num
		if used_times == time then
			self.show_free = false
			self.node_list["TxtReviveTime"]:SetActive(false)
			self.remind_times = 0
		else
			self.show_free = true
			self.node_list["TxtNum"]:SetActive(false)
			self.node_list["TxtReviveTime"]:SetActive(true)
			self.remind_times = time - used_times
			self.node_list["TxtText"]:SetActive(false)
			self.node_list["TxtReviveTime"].text.text = string.format(Language.Fuhuo.FreeTime, self.remind_times)
		end
	end

	self:IsShowGoldRevive()
	if scene_type == SceneType.Kf_XiuLuoTower then
		-- if not KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
		self.node_list["TxtNum"]:SetActive(not ReviveView.CanUseItem() and not self.show_free)
		-- self.node_list["TxtText"]:SetActive(false)
		self.node_list["TxtText"]:SetActive(not self.show_free and ReviveView.CanUseItem())
		-- 	self.show_free = false
			--self.ndoe_list["TxtReviveTime"]:SetActive(false)
		-- end
		-- self.node_list["TxtReviveTime"]:SetActive(false)
		-- self.node_list["TxtReviveTime"]:SetActive(false and self.show_free)
	else
		self.node_list["TxtText"]:SetActive(not self.show_free)
		self.node_list["TxtReviveTime"]:SetActive(true and self.show_free)
	end
	if scene_type == SceneType.CrossLieKun_FB then
		local used_times = ReviveData.Instance:GetReviveFreeTime()
		local today_free_revive_num = ReviveData.Instance:GetTodayFreeReviveNum()
		if today_free_revive_num - used_times <= 0 then
			self.show_free = false
			self.node_list["TxtReviveTime"]:SetActive(false)
			self.remind_times = 0
		else
			self.show_free = true
			self.node_list["TxtNum"]:SetActive(false)
			self.node_list["TxtReviveTime"]:SetActive(true)
			self.remind_times = today_free_revive_num - used_times
			self.node_list["TxtReviveTime"].text.text = string.format(Language.Fuhuo.FreeTime, self.remind_times)
		end
	end

	if scene_type == SceneType.Kf_PVP or scene_type == SceneType.QunXianLuanDou then
		local used_times = ReviveData.Instance:GetReviveFreeTime()
		local today_free_revive_num = ReviveData.Instance:GetTodayFreeReviveNum()
		if today_free_revive_num - used_times <= 0 then
			self.show_free = false
			self.node_list["TxtReviveTime"]:SetActive(false)
			self.remind_times = 0
		else
			self.show_free = true
			self.node_list["TxtNum"]:SetActive(false)
			self.node_list["TxtReviveTime"]:SetActive(true)
			self.remind_times = today_free_revive_num - used_times
			self.node_list["TxtReviveTime"].text.text = string.format(Language.Fuhuo.FreeTime, self.remind_times)
		end
	end

	-- if scene_type == SceneType.TowerDefend then
	-- 	local other_cfg = FuBenData.Instance:GetTowerDefendOtherCfg()
	-- 	if other_cfg then
	-- 		local gold_time = other_cfg.relive_gold_interval / 1000 or 0
	-- 		local free_time = other_cfg.relive_back_home_interval / 1000 or 0
	-- 		UI:SetButtonEnabled(self.node_list["ImgFreeRevive"], false)
	-- 		UI:SetButtonEnabled(self.node_list["ImgGuildReviveIcon"], false)
	-- 		if self.free_count_down then
	-- 			CountDown.Instance:RemoveCountDown(self.free_count_down)
	-- 			self.free_count_down = nil
	-- 		end
	-- 		if nil == self.free_count_down then
	-- 			self.node_list["TxtText3"]:SetActive(true)
	-- 			self.node_list["TxtText3"].text.text = Language.Fuhuo.LengQue .. math.floor(free_time + 0.5) .. "s"
	-- 			self.free_count_down = CountDown.Instance:AddCountDown(free_time, 1, function()
	-- 				free_time = free_time - 1
	-- 				if free_time <= 0 then
	-- 					self.node_list["TxtText3"].text.text = Language.Fuhuo.FreeReviveTxt[1]
	-- 					UI:SetButtonEnabled(self.node_list["ImgFreeRevive"], true)
	-- 					return
	-- 				end
	-- 				self.node_list["TxtText3"].text.text = Language.Fuhuo.LengQue .. math.floor(free_time + 0.5) .. "s"
	-- 			end)
	-- 		end

	-- 		if self.gold_count_down then
	-- 			CountDown.Instance:RemoveCountDown(self.gold_count_down)
	-- 			self.gold_count_down = nil
	-- 		end
	-- 		if nil == self.gold_count_down then
	-- 			self.node_list["TxtNum"]:SetActive(false)
	-- 			self.node_list["TxtReviveTime"]:SetActive(false)
	-- 			self.node_list["TxtText"]:SetActive(true)
	-- 			self.node_list["TxtText"].text.text = Language.Fuhuo.LengQue .. math.floor(gold_time + 0.5) .. "s"
	-- 			self.gold_count_down = CountDown.Instance:AddCountDown(gold_time, 1, function()
	-- 				gold_time = gold_time - 1
	-- 				if gold_time <= 0 then
	-- 					self.node_list["TxtText"]:SetActive(false)
	-- 					local used_times = ReviveData.Instance:GetReviveFreeTime()
	-- 					local today_free_revive_num = ReviveData.Instance:GetTodayFreeReviveNum()
	-- 					if today_free_revive_num - used_times <= 0 then
	-- 						self.node_list["TxtReviveTime"]:SetActive(false)
	-- 						self.node_list["TxtNum"]:SetActive(true)
	-- 					else
	-- 						self.node_list["TxtNum"]:SetActive(false)
	-- 						self.node_list["TxtReviveTime"]:SetActive(true)
	-- 					end
	-- 					UI:SetButtonEnabled(self.node_list["ImgGuildReviveIcon"], true)
	-- 					return
	-- 				end
	-- 				self.node_list["TxtText"].text.text = Language.Fuhuo.LengQue .. math.floor(gold_time + 0.5) .. "s"
	-- 			end)
	-- 		end
		-- end
	-- end
end

function ReviveView:StopCountDown()
	if self.buff_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.buff_count_down)
		self.buff_count_down = nil
	end

	if self.cooling_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.cooling_count_down)
		self.cooling_count_down = nil
	end
end

function ReviveView:FlushBuff()
	self:StopCountDown()
	self.buff_info = ReviveData.Instance:GetDieBuffInfo()
	self.other_buff_cfg = ReviveData.Instance:GetOtherDieBuffCfg()

	if next(self.buff_info) == nil then
		return
	end

	local buff_maxhp_per = self.other_buff_cfg.injure_maxhp_per    -- 效果百分比
	local buff_interval_s = self.other_buff_cfg.buff_interval_s    -- 持续cd
	local buff_cd_s = self.other_buff_cfg.buff_cd_s                -- 冷却cd
	local max_can_active_times = ReviveData.Instance:GetMaxCanActiveBuffTimes()

	-- buff可激活次数
	local can_active_times = ReviveData.Instance:GetCanActiveTimesByDieTimes(self.buff_info.today_die_times) - self.buff_info.today_active_times
	if can_active_times > 0 and can_active_times <= max_can_active_times then
		self.node_list["Txt_buff_remind"].text.text = string.format(Language.Revive.BuffRemind1, can_active_times)
		UI:SetButtonEnabled(self.node_list["Btn_tianshen_active"], true)
	elseif self.buff_info.today_active_times >= max_can_active_times then
		self.node_list["Txt_buff_remind"].text.text = Language.Revive.BuffRemind3
		UI:SetButtonEnabled(self.node_list["Btn_tianshen_active"], false)
	else
		UI:SetButtonEnabled(self.node_list["Btn_tianshen_active"], false)
		local need_die_time = ReviveData.Instance:GetNeedDieTimesByActivedTimes(self.buff_info.today_active_times + 1) - self.buff_info.today_die_times
		self.node_list["Txt_buff_remind"].text.text = string.format(Language.Revive.BuffRemind2, need_die_time)
	end

	-- buff描述
	self.node_list["Slide_buff"].slider.value = buff_maxhp_per

	-- buff进度条
	local now_time = TimeCtrl.Instance:GetServerTime()
	local now_buff_time = math.max(0, (now_time - self.buff_info.active_buiff_timestamp + 1))
	self.node_list["Slide_buff"]:SetActive(false)
	if now_buff_time <= buff_interval_s then
		self.node_list["Slide_buff"]:SetActive(true)
		self.node_list["Slide_buff"].slider.value = (buff_interval_s - now_buff_time) / buff_interval_s
		self.buff_count_down = CountDown.Instance:AddCountDown(
			buff_interval_s - now_buff_time, 1, function(elapse_time, total_time)
				local left_time = total_time - elapse_time
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.buff_count_down)
					self.buff_count_down = nil
					return
				end
				local left_sec = left_time / buff_interval_s
				if self.node_list and self.node_list["Slide_buff"] then
					self.node_list["Slide_buff"].slider.value = left_sec
				end
			end)
	end
	-- 冷却时间
	if now_buff_time < buff_cd_s then
		UI:SetButtonEnabled(self.node_list["Btn_tianshen_active"], false)
		self.node_list["Btn_TianShen_Txt"].text.text = TimeUtil.FormatSecond(buff_cd_s - now_buff_time, 2)
		self.cooling_count_down = CountDown.Instance:AddCountDown(
			buff_cd_s - now_buff_time, 1, function(elapse_time, total_time)
				local left_time = total_time - elapse_time
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.cooling_count_down)
					self.cooling_count_down = nil
					self:Flush()
					return
				end
				local left_sec = TimeUtil.FormatSecond(left_time, 2)
				if self.node_list and self.node_list["Btn_TianShen_Txt"] then
					self.node_list["Btn_TianShen_Txt"].text.text = left_sec
				end
			end)
	else
		self.node_list["Btn_TianShen_Txt"].text.text = Language.Revive.ButtonText
	end
end

function ReviveView:OnClickActive()
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Revive.ActiveRemind, function ()
		ReviveCtrl.Instance:SendDieBuffInfo(FETCH_BUFF_OPERATE_TYPE.ACTIVE_BUFF)
	end)
end

-- 是否能够使用公会复活
function ReviveView:CheckGuildRevive()
	self.node_list["ImgLocalRevive"]:SetActive(false)
	self.node_list["TxtRevive"]:SetActive(true)
	self.node_list["ImgGuildReviveIcon"]:SetActive(true)

	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		local rest_guild_daily_relive_times = GuildData.Instance:GetRestGuildTotalReviveCount() or 0
		local rest_personal_revive_times = GuildData.Instance:GetRestPersonalGuildReviveCount() or 0
		if rest_guild_daily_relive_times > 0 and rest_personal_revive_times > 0 then
			self.node_list["TxtNum"]:SetActive(false)
			self.node_list["TxtNum2"]:SetActivce(false)
			self.node_list["TxtText2"].text.text = string.format(Language.Fuhuo.GuildRevive, rest_personal_revive_times)
				self.node_list["ImgLocalRevive"]:SetActive(false)
				--self.node_list["TxtRevive"]:SetActive(true)
				self.node_list["ImgGuildReviveIcon"]:SetActive(true)
				self.node_list["TxtNumer"].text.text = rest_guild_daily_relive_times
		end
	end
end

function ReviveView.CanUseItem()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing then
		return false
	-- elseif scene_type == SceneType.Kf_XiuLuoTower and KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
	-- 	return true
	end
	local item_count = ItemData.Instance:GetItemNumInBagById(ReviveDataItemId.ItemId)
	if item_count < 1 then
		return false
	end
	return true
end

function ReviveView.ReviveTime()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.TowerDefend or scene_type == SceneType.TeamTowerFB then
		return ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1].relive_time
	elseif IsFightSceneType[scene_type] or scene_type == SceneType.Kf_XiuLuoTower then
		return 5
	end
	return ReviveDataTime.RevivieTime
end

function ReviveView.ReviveCost()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_XiuLuoTower then
		return ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].cross_relive_gold
	end
	local shop_cfg = ShopData.Instance:GetShopItemCfg(ReviveDataItemId.ItemId) or {}
	return shop_cfg.gold or 20
end

function ReviveView.FreeReviveEnble()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.TowerDefend or scene_type == SceneType.TeamTowerFB then
		return false
	end
	return true
end

function ReviveView.CanUseFreeRevive()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing or scene_type == SceneType.TowerDefend or scene_type == SceneType.TeamTowerFB then
		return false
	end
	return true
end

function ReviveView:UpdateShowBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		self.node_list["ButLocalRevive"]:SetActive(true)
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		local color = revive_cost > ct_info.current_credit and "ff0000" or "00ff00"
		self.node_list["TxtText2"].text.text = string.format(Language>ClashTerritory.ScoreCost, color, revive_cost)
	else
		self.node_list["ButLocalRevive"]:SetActive(false)
	end
end

function ReviveView:IsShowGoldRevive()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ChaosWar then
		self.node_list["PlaneLocalRevive"]:SetActive(false)
	end
	
end

GongNengCell = GongNengCell or BaseClass(BaseRender)
function GongNengCell:__init()
	self.node_list["Image"].button:AddClickListener(BindTool.Bind(self.ClickOpen, self))
end

function GongNengCell:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	local bundle, asset = ResPath.GetSystemIcon(self.data.image_name)
	self.node_list["IconImage"].image:LoadSprite(bundle, asset .. ".png")

	local word_bundle, word_asset = ResPath.GetSystemIcon(self.data.image_name .. "Name")
	self.node_list["WordImage"].image:LoadSprite(word_bundle, word_asset)
end

function GongNengCell:ClickOpen()
	if self.data then
		ViewManager.Instance:Open(self.data.view_name)
	end
end