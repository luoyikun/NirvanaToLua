-- 副本爬塔信息
FuBenInfoTowerView = FuBenInfoTowerView or BaseClass(BaseView)

function FuBenInfoTowerView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "TowerFBInFoView"}}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.title_obj = nil
	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.pata_camera_move_quest = nil
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
end


function FuBenInfoTowerView:OnClickSkillTips()
	local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
	local tmp_id = next_reward_mojie_cfg.skill_id % 10 + 1
	local name = next_reward_mojie_cfg.name
	TipsCtrl.Instance:PataSkillTips(tmp_id,name)
end

function FuBenInfoTowerView:LoadCallBack()
	self.is_pass_level = -1
	self.today_pass_level = -1
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.node_list["LeftSkill"].button:AddClickListener(BindTool.Bind(self.OnClickSkillTips, self))
end

function FuBenInfoTowerView:ReleaseCallBack()

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenInfoTowerView:__delete()
	self.item_data = nil
	self.fail_data = nil

	self.is_load_tittle = nil
	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = nil
	self.is_open_finish = nil
end

function FuBenInfoTowerView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
	self.is_load_tittle = false
end

function FuBenInfoTowerView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if nil ~= self.pata_camera_move_quest then
		GlobalTimerQuest:CancelQuest(self.pata_camera_move_quest)
		self.pata_camera_move_quest = nil
	end

	self.temp_level = nil
	self.bg_animator = nil
end

function FuBenInfoTowerView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.PataFB then
		FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		self.is_first_open = true
	end
end


function FuBenInfoTowerView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info then return end
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	local diff_time = 0
	if fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 0 then -- role_hp <= 0 and
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
		end
		self.is_open_finish = true
		return
	end

	if fb_scene_info.time_out_stamp ~= nil then
		diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	end

	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	if fb_info and fb_info.today_level and fb_scene_info.is_finish == 1 and ((fb_info.today_level + 1) <= FuBenData.Instance:MaxTowerFB()) and fb_scene_info.is_pass == 1 then
		if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
			diff_time = 30
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			local func = function()
				local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName("Xzptfb01_Main")
				if scene:IsValid() then
					local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
					local animator = nil
					if self.bg_animator == nil then
						for k,v in pairs(objects:ToTable()) do
							if v.name == "Main" then
								local bg = v.transform:FindHard("Background")
								self.bg_animator = bg:GetComponent(typeof(UnityEngine.Animator))
								self.bg_animator:ListenEvent("AniFinish", function ()
									if self.bg_animator then
										self.bg_animator:SetBool("down", false)
										FuBenCtrl.Instance:SendEnterNextFBReq()
										Scene.SendGetAllObjMoveInfoReq()
									 end
								end)
							end
						end
					end
				-- 场景异常，直接跳到下一关
				else
					FuBenCtrl.Instance:SendEnterNextFBReq()
				end
				if self.bg_animator then
					self.bg_animator:SetBool("down", true)
				end

				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end

			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end

			if not self.is_first_open then
				if fb_info.today_level ~= self.today_pass_level then
					if FuBenData.Instance:GetIsMojieLayer() then
						TipsCtrl.Instance:TipsTowerRewardInfoShow(no_func, func)
					else
						local fb_info = FuBenData.Instance:GetTowerFBInfo()
						local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()

						local reward_cfg = {}
						local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
						if tower_fb_info and fuben_cfg then
							reward_cfg = tower_fb_info.pass_level - 1 < tower_fb_info.today_level and fuben_cfg[tower_fb_info.today_level].first_reward
								or fuben_cfg[tower_fb_info.today_level].normal_reward
						end
						TipsCtrl.Instance:TipsPaTaView(no_func, func, reward_cfg)
					end
				end
			else
				diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end

			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
		else
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
		end
	elseif fb_info.today_level and (fb_info.today_level + 1) > FuBenData.Instance:MaxTowerFB() then
		diff_time = 30
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
		end
		self.is_open_finish = true
	end

	if self.count_down == nil then
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 then
					if not self.is_open_finish then
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
					self.is_open_finish = true
				else
					FuBenCtrl.Instance:SendEnterNextFBReq()
					-- FuBenCtrl.Instance:SendExitFBReq()
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
		end

		diff_time_fun(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_fun)
	end

	if next(fb_info) and fb_scene_info.is_finish then
		self.is_first_open = false
		self.today_pass_level = fb_info.today_level
	end
end

function FuBenInfoTowerView:SetTowerFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if nil == fb_scene_info or nil == tower_fb_info or nil == fuben_cfg or nil == monster_cfg then
		return
	end

	if fb_scene_info.is_finish == 1 then
		if self.is_first_open then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		if self.is_pass_level ~= tower_fb_info.today_level then
			if tower_fb_info.today_level ~= nil and fuben_cfg[tower_fb_info.today_level] ~= nil then
				local boss_id = fuben_cfg[tower_fb_info.today_level].boss_id
				if monster_cfg[boss_id] ~= nil then
					local monster_name = monster_cfg[boss_id].name
					local kill_boss_num = fb_scene_info.kill_boss_num >= fb_scene_info.total_boss_num and ToColorStr(fb_scene_info.kill_boss_num, TEXT_COLOR.GREEN) or ToColorStr(fb_scene_info.kill_boss_num, TEXT_COLOR.RED)
					self.node_list["TextKill"].text.text = string.format(Language.FuBen.KillNumber1, monster_name, kill_boss_num, fb_scene_info.total_boss_num)
					self.is_pass_level = tower_fb_info.today_level
				end
			end
		end
		return
	end

	local monster_name = ""
	if tower_fb_info and next(tower_fb_info) then
		local temp_td_level = tower_fb_info.today_level + 1
		local temp_level_str = ""
		for s in string.gmatch(temp_td_level, "%d") do
			temp_level_str = temp_level_str .. s .. "\n"
		end
		
		self.node_list["TextFbName"].text.text = string.format(Language.FB.CurLevel, temp_level_str)
		if fuben_cfg[tower_fb_info.today_level + 1] then
			local capability = GameVoManager.Instance:GetMainRoleVo().capability
			local str_fight_power = string.format(Language.Mount.ShowGreenStr, fuben_cfg[tower_fb_info.today_level + 1].capability)

			if capability < fuben_cfg[tower_fb_info.today_level + 1].capability then
				str_fight_power = string.format(Language.Mount.ShowRedStr, fuben_cfg[tower_fb_info.today_level + 1].capability)
			end

			self.node_list["Capability"].text.text = string.format(Language.FuBen.RecommendCap, str_fight_power)
			local boss_id = fuben_cfg[tower_fb_info.today_level + 1].boss_id
			monster_name = monster_cfg[boss_id].name

			if self.temp_change_level and self.temp_change_level ~= tower_fb_info.today_level then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			end

			local reward_cfg = tower_fb_info.pass_level < tower_fb_info.today_level + 1 and fuben_cfg[tower_fb_info.today_level + 1].first_reward
								or fuben_cfg[tower_fb_info.today_level + 1].normal_reward

			local tongguandes = tower_fb_info.pass_level < tower_fb_info.today_level + 1 and Language.FB.NormalReward or Language.FB.NormalReward
			self.node_list["TongGuanDes"].text.text = string.format(Language.FuBen.TongGuanDes, tongguandes)

			local reward_count = 0
			for k, v in pairs(self.item_cells) do
				v:SetActive(false)
				if reward_cfg[k - 1] then
					reward_count = reward_count + 1
					v:SetData(reward_cfg[k - 1])
					v:SetActive(true)
					self.item_data[k] = reward_cfg[k - 1]
				end
			end
		end

		-- if self.item_cells[reward_count + 1] then
		-- 	local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg[tower_fb_info.today_level + 1].reward_exp}
		-- 	self.item_cells[reward_count + 1]:SetData(data)
		-- 	self.item_cells[reward_count + 1]:SetActive(true)
		-- 	self.item_data[reward_count + 1] = data
		-- end
		self.temp_change_level = tower_fb_info.today_level

		-- 设置爬塔魔戒/传世佩剑奖励信息
		local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
		if next_reward_mojie_cfg then					
			self.node_list["TextReward"].text.text = string.format(Language.FuBen.SpecailReward, next_reward_mojie_cfg.pata_layer) 
			local tmp_id = next_reward_mojie_cfg.skill_id % 10 + 1
			-- local bundle, asset = ResPath.GetTowerPeiJianIcon(tmp_id)
			-- self.node_list["AwardIcon"].raw_image:LoadSprite(bundle, asset,function()
			-- 	self.node_list["AwardIcon"].raw_image:SetNativeSize()
			-- end)


			local tmp_id2 = math.modf(next_reward_mojie_cfg.skill_id / 10)
			tmp_id2 = tmp_id2 > 1 and 3 or 2 										--策划要求显示中级跟高级特效
			local roadA = "KGH_mingjian_" .. 0 .. tmp_id .. "_0" .. tmp_id2
			local roadB = "KGH_mingjian_" .. tmp_id .. "_0" .. tmp_id2
			local asset1 = tmp_id < 10 and roadA or roadB
			local bundle_name, asset_name = ResPath.GetUiMingJianEffect(asset1)
			self.node_list["Node_effect"]:ChangeAsset(bundle_name, asset_name)
			self:SetName(next_reward_mojie_cfg.skill_id)																	
		end
	end
	local chuanshi_list = FuBenData.Instance:GetTowerMojieCfg().active_cfg
	local is_show = false
	if tower_fb_info.today_level then
		for k,v in pairs(chuanshi_list) do 
			if tower_fb_info.today_level + 1 == v.pata_layer then
				is_show = true
			end
		end
		self.is_pass_level = tower_fb_info.today_level
	end
	if is_show then
		self.node_list["Skill"]:SetActive(false)
		if FuBenData.Instance:GetIsCanOpenJieSuo() then
			TipsCtrl.Instance:TipsTowerJieSuoShow()
			self.node_list["Skill"]:SetActive(self.is_show)
		end
		FuBenCtrl.Instance:SetCanMove(false)
		self.node_list["TongGuanDes"].text.text = Language.FuBen.MingJianDes
		local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
		local tmp_id = next_reward_mojie_cfg.skill_id % 10 + 1
		local skill_bundle, skill_asset = ResPath.GetFuBenViewImage("peijian_skill_" .. tmp_id)
		self.node_list["Skill"].image:LoadSprite(skill_bundle, skill_asset)
	end
	self.node_list["LeftSkill"]:SetActive(is_show)
	self.node_list["Items"]:SetActive(not is_show)
	if fb_scene_info and next(fb_scene_info) then
		local kill_boss_num = fb_scene_info.kill_boss_num >= fb_scene_info.total_boss_num and ToColorStr(fb_scene_info.kill_boss_num, TEXT_COLOR.GREEN) or ToColorStr(fb_scene_info.kill_boss_num, TEXT_COLOR.RED)
		self.node_list["TextKill"].text.text = string.format(Language.FuBen.KillNumber1, monster_name, kill_boss_num, fb_scene_info.total_boss_num)
	end
end

function FuBenInfoTowerView:FuwenImgState(is_show)
	self.is_show = is_show
	self:SetTowerFBSceneData()
end

-- 设置魔戒/佩剑名称
function FuBenInfoTowerView:SetName(skill_id)
	local tmp_id = skill_id % 10 + 1
	local tmp_id2 = math.modf(skill_id / 10)
	self.node_list["NameIcon"]:SetActive(tmp_id2 > 0)
	if tmp_id2 > 0 then
		local bundle, asset = ResPath.GetTowerMojieLittleNameIconVertical(tmp_id2)
		self.node_list["NameIcon"].image:LoadSprite(bundle, asset)
	end

	local bundle, asset = ResPath.GetTowerMojieLittleNameVertical(tmp_id)
	self.node_list["NameImg"].image:LoadSprite(bundle, asset)
end

function FuBenInfoTowerView:SwitchButtonState(enable)
	self.node_list["PanelInfo"]:SetActive(enable)
end

function FuBenInfoTowerView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.PataFB then
		MainUICtrl.Instance:SetViewState(false)
		self:SetCountDown()
		self:SetTowerFBSceneData()
	end
end
