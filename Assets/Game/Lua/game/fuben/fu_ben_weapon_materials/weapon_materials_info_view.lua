FuBenInfoWeaponView = FuBenInfoWeaponView or BaseClass(BaseView)

function FuBenInfoWeaponView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "WeaponFBInFoView"}}
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.cur_star = 0
	self.cur_time = 0
	self.select_layer = 0 -- 当前选择的层
	self.item_list = {}
end

function FuBenInfoWeaponView:LoadCallBack()
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
	self.cur_select_index = FuBenData.Instance:GetMapListNum() or 0  -- 当前的章节
	for i=1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function FuBenInfoWeaponView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end

	self.node_list["TrackInfo"]:SetActive(state)
end

function FuBenInfoWeaponView:__delete()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function FuBenInfoWeaponView:ReleaseCallBack()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end
	self:RemoveCountDown()

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

end

function FuBenInfoWeaponView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenInfoWeaponView:OpenCallBack()
	for i =1, 3 do
		UI:SetGraphicGrey(self.node_list["Star" .. i], false)
	end
	self.cur_star = 0
	self.cur_time = 0
	self:SetCountDown()
	self:SetStarCountDown()
	self:Flush()
end

function FuBenInfoWeaponView:CloseCallBack()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	self.cur_star = 0
	self.cur_time = 0
	self.first_flag = nil
end

function FuBenInfoWeaponView:OnFlush()
	-- local info = ActivityData.Instance:GetActivityStatuByType(activity_type)

	self.node_list["TextBest"].text.text = "02:00" .. Language.FuBen.VictoryTime
	self.node_list["TextCommon"].text.text = "02:30" .. Language.FuBen.VictoryTime
	self:SetStarCountDown()
	self.cur_select_index = FuBenData.Instance:GetMapListNum() or 0  -- 当前的章节
	self.select_layer = FuBenData.Instance:GetSceneCurSelectLayer(Scene.Instance:GetSceneId())
	local other_cfg = FuBenData.Instance:GetWeaponCfgOther()
	if other_cfg == nil then
		return
	end
	local effect_level = other_cfg.effect_show
	if self.select_layer then
		local item_list = {}
		-- local data = FuBenData.Instance:GetData(self.cur_select_index)
		local data = FuBenData.Instance:GetMonsterSpecialCfg(Scene.Instance:GetSceneId())
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		-- if data[self.select_layer - 1] and data[self.select_layer - 1]["item_list" .. prof] ~= nil then
		-- 	local show_data = data[self.select_layer - 1]["item_list" .. prof]
		-- 	item_list = Split(show_data, "|")
		-- end
		if data["item_list"..prof] then
			local show_data = data["item_list"..prof]
			item_list = Split(show_data, "|")
		end
		for i,v in ipairs(self.item_list) do
			if data["item_list"..prof] then
				self.item_list[i]:SetData({item_id = tonumber(item_list[i])})
				self.item_list[i]:SetShowStar(data.equiment_star)
				self.item_list[i]:SetQualityByColor(data.equiment_quality)
				self.item_list[i]:ShowHighLight(false)

			if effect_level ~= nil and data.equiment_quality and data.equiment_quality >= effect_level then
				if data.equiment_quality == 4 then
					self.item_list[i]:ShowEquipOrangeEffect(true)
				elseif data.equiment_quality == 5 then
					self.item_list[i]:ShowEquipRedEffect(true)
				elseif data.equiment_quality == 6 then
					self.item_list[i]:ShowEquipFenEffect(true)
				end
			end

				local func = function()
					local item_data = {item_id = tonumber(item_list[i])}
					TipsCtrl.Instance:OpenItem(item_data)
					GlobalTimerQuest:AddDelayTimer(function()
						TipsCtrl.Instance:SetQualityAndClor(data.equiment_quality)
						TipsCtrl.Instance:SetOtherQualityAndClor(data.equiment_quality)
						end, 0.1)
				end
				self.item_list[i]:ListenClick(func)
			end
		end
	end
	local scene_id = Scene.Instance:GetSceneId()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local scene_cfg = FuBenData.Instance:GetMonsterSpecialCfg(scene_id)
	local monster_info_cfg = FuBenData.Instance:GetMonsterInfoCfg()
	if scene_cfg == nil or monster_info_cfg == nil then
		return
	end
	local fb_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_info and next(fb_info) then
		local total_monster = monster_info_cfg.monster_number
		local total_boss_num = monster_info_cfg.boss_number
		local total_kill_monster = fb_info.kill_allmonster_num - fb_info.kill_boss_num
		local total_kill = total_kill_monster >= total_monster and total_kill_monster or ToColorStr(total_kill_monster, TEXT_COLOR.RED)
		local str1 = string.format(Language.FuBen.KillNumber1, monster_cfg[scene_cfg.monster_id].name, total_kill, total_monster)
		local kill_boss_num = fb_info.kill_boss_num >= total_boss_num and fb_info.kill_boss_num or ToColorStr(fb_info.kill_boss_num, TEXT_COLOR.RED)
		local str2 = string.format(Language.FuBen.KillNumber2, monster_cfg[scene_cfg.boss_id].name, kill_boss_num, total_boss_num)
		self.node_list["JiBaiTxt1"].text.text = str1
		self.node_list["JiBaiTxt2"].text.text = str2
	end
end

function FuBenInfoWeaponView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	local star_time_list = FuBenData.Instance:GetWeaponCfgStarTime()
	if not next(fb_scene_info) then return end

	local function diff_time_func (elapse_time, total_time)
		local left_time = math.floor(total_time - elapse_time + 0.5)
		left_time = 300 - left_time
		local texttime = TimeUtil.Format2TableDHMS(left_time)
		local use_time = ""
		if texttime.s > 9 then
			use_time = "0" .. texttime.min .. ":" .. texttime.s
		else
			use_time = "0" .. texttime.min .. ":" .. "0" .. texttime.s
		end
		self.node_list["TextTime"].text.text = string.format(Language.FuBen.UsedTime ,ToColorStr(use_time, TEXT_COLOR.GREEN))
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	local diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	if diff_time > 0 then
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end


-- 评星
function FuBenInfoWeaponView:SetStarCountDown()
	-- 星级
	local star_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	if star_info == nil or next(star_info) == nil then return end
	-- 相等情况下说明数据没更新，不执行刷新
	if self.cur_star == star_info.cur_star_level then
		return
	end
	local star_num = 3
	local left_time = star_info.next_change_star_time - TimeCtrl.Instance:GetServerTime()
	self.cur_star = star_info.cur_star_level
	self.cur_time = star_info.next_change_star_time

	if self.cur_star == 2 then
		left_time = star_info.next_change_star_time - TimeCtrl.Instance:GetServerTime()
		self.cur_star = 2
	end

	local function diff_time_fun(elapse_time, total_time)
		local star_time = math.floor(total_time - elapse_time + 0.5)
		local count_down_text = string.format(Language.ExpFuBen.GreenText, TimeUtil.FormatSecond(star_time, 2))
		local next_star = math.max(self.cur_star - 1, 1)
		if self.cur_star <= 1 or self.first_flag then
			self.node_list["StarTxt"].text.text = string.format(Language.FuBen.StarFail, count_down_text)
		else
			self.node_list["StarTxt"].text.text = string.format(Language.FuBen.NetStar, count_down_text, next_star)
		end
		if self.cur_star > 0 then
			for i = 1,star_num do
				local is_gray = i > self.cur_star
				UI:SetGraphicGrey(self.node_list["Star" .. i], is_gray)
			end
		end

		if star_time <= 0 and next_star <= 1 and not self.first_flag then
			if self.star_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.star_count_down)
				self.star_count_down = nil
			end
			self.first_flag = true
			left_time = FuBenData.Instance:GetFuBenSceneLeftTime() or 0
			self.star_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)
		end
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	if self.cur_star <= 1 or self.first_flag then
		left_time = FuBenData.Instance:GetFuBenSceneLeftTime() or 0
	end
	self.star_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)
end