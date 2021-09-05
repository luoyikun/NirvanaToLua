-- TaskDialogView
TaskDialogView = TaskDialogView or BaseClass(BaseView)

local NUM = 4  -- 奖励栏数量
local DELAY_TIME = 15 -- 自动做任务的时间
local LEVEL_LIMIT = 900 -- 自动做任务的等级
local MOUNT_NPC = 4079001	--特殊坐骑马要调30的角度

function TaskDialogView:__init()
	self.ui_config = {{"uis/views/taskview_prefab", "TaskDialogView"}}
	self.play_audio = true
	self.vew_cache_time = ViewCacheTime.NORMAL
	self.is_async_load = true
	self.npc_id = 0
	self.task_id = 0
	self.talk_id = 0
	self.is_auto = true

	self.talk_table = nil
	self.cur_index = 0
	self.last_npc_resid = 0
	self.auto_do_task = true
	self.auto_talk = false

	self.active_close = false
	self.story_talk_end_callback = nil
	self.talk_audio_list = {}
	self.rewards = {}
	self.is_play_audio = false
end

function TaskDialogView:__delete()
	self.npc_talk_audio = nil
end

function TaskDialogView:ReleaseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end

	self.story_talk_end_callback = nil

	for k,v in pairs(self.rewards) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.rewards = {}

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	-- 清理变量和对象
	self.show_time = nil
	self.show_npc = nil
	self.show_btn = nil
	-- self.npc_talk_audio = nil
end

function TaskDialogView:LoadCallBack()
	--监听
	self.node_list["NodeClose"].button:AddClickListener(BindTool.Bind(self.OnCloseTask, self))
	self.node_list["BtnAccept"].button:AddClickListener(BindTool.Bind(self.HandleAccept, self))
	self.node_list["NodeBlock"].button:AddClickListener(BindTool.Bind(self.ClickGoOn, self))
	self.node_list["ImgPanel"].button:AddClickListener(BindTool.Bind(self.ClickPanel, self))

	self.npc_talk_audio = nil
	self.show_time = false
	self.show_btn = false
	self:ShowBtn(false)
	self.show_npc = true
	self:ShowNPC(true)

	for i = 1, NUM do
		self.rewards[i] = {}
		self.rewards[i].obj = self.node_list["Reward" .. i]
		self.rewards[i].cell = ItemCell.New()
		self.rewards[i].cell:SetInstanceParent(self.rewards[i].obj)
	end

	self.rewards[1].cell:ShowHighLight(false)
	self.is_auto = true
end

-- 显示npc控制
function TaskDialogView:ShowNPC(show_npc)
	self.show_npc = show_npc
	if show_npc then
		self.node_list["Display3D2"]:SetActive(false) -- role
		self.node_list["Display3D"]:SetActive(true) -- npc
	else
		self.node_list["Display3D"]:SetActive(false) -- npc
		self.node_list["Display3D2"]:SetActive(true) -- role
	end

	self.node_list["ImgArrowLight"]:SetActive((not self.show_btn) and (not show_npc))
	self.node_list["NodeFinger"]:SetActive((not self.show_btn) and (not show_npc))
	self.node_list["TxtFinger"]:SetActive((not self.show_btn) and (not show_npc))
	self.node_list["NodeFinger1"]:SetActive((not self.show_btn) and show_npc)
	self.node_list["ImgArrowLight2"]:SetActive((not self.show_btn) and show_npc)
	self.node_list["ImgLabelTitle"]:SetActive(show_npc)
	self.node_list["ImgLabelTitle1"]:SetActive(not show_npc)
	self.node_list["TxtContent"]:SetActive(show_npc)
	self.node_list["TxtContent2"]:SetActive(not show_npc)
end

-- 显示按钮控制
function TaskDialogView:ShowBtn(show_btn)
	self.show_btn = show_btn
	self.node_list["ImgArrowLight"]:SetActive((not show_btn) and (not self.show_npc))
	self.node_list["NodeFinger"]:SetActive((not show_btn) and (not self.show_npc))
	self.node_list["TxtFinger"]:SetActive((not show_btn) and (not self.show_npc))
	self.node_list["NodeFinger1"]:SetActive((not show_btn) and self.show_npc)
	self.node_list["ImgArrowLight2"]:SetActive((not show_btn) and self.show_npc)
	self.node_list["NodeBlock"]:SetActive(not show_btn)
	self.node_list["BtnAccept"]:SetActive(show_btn)
	self.node_list["TxtCountDown"]:SetActive(self.show_time)
end

function TaskDialogView:OpenCallBack()
	self:ShowNPC(true)
	GuajiCtrl.Instance:PlayNpcVoice(self.npc_obj_id)
end

-- 设置NPC模型
function TaskDialogView:SetNpcModel(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New()
		self.npc_model:SetDisplay(self.node_list["Display3D"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetNpcModel(resid))
		if resid == MOUNT_NPC then
			self.npc_model:SetRotation(Vector3(0, -15, 0))
		end
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

-- 设置NPC特殊模型(人物)
function TaskDialogView:SetNpcModel2(role_res, weapen_res, mount_res, wing_res, halo_res)
	if not self.npc_model then
		self.npc_model = RoleModel.New()
		self.npc_model:SetWingNeedAction(false)
		self.npc_model:SetDisplay(self.node_list["Display3D"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end

	if self.last_npc_resid ~= role_res then
		self.npc_model:SetMainAsset(ResPath.GetRoleModel(role_res))
		if weapen_res > 0 then
			self.npc_model:SetWeaponResid(weapen_res)
			-- 如果是枪手模型
			if math.floor(role_res / 1000) % 1000 == 3 then
				self.npc_model:SetWeapon2Resid(weapen_res + 1)
			end
		end
		if mount_res > 0 then
			self.npc_model:SetMountResid(mount_res)
		end
		if wing_res > 0 then
			self.npc_model:SetWingResid(wing_res)
		end
		if halo_res > 0 then
			self.npc_model:SetHaloResid(halo_res)
		end
		self:SetNpcAction()
		self.last_npc_resid = role_res
	end
end

-- 设置NPC特殊模型(怪物)
function TaskDialogView:SetNpcModel3(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New()
		self.npc_model:SetDisplay(self.node_list["Display3D"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end

	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetMonsterModel(resid))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

function TaskDialogView:SetRoleModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		self.role_model:SetDisplay(self.node_list["Display3D2"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
		self.role_model:SetRoleResid(main_role:GetRoleResId())
		self.role_model:SetWeaponResid(main_role:GetWeaponResId())
		self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
		self.role_model:SetWingResid(main_role:GetWingResId())
		self.role_model:SetHaloResid(main_role:GetHaloResId())
		self.role_model:SetScale(Vector3(1.05, 1.05, 1.05))
	end
end

function TaskDialogView:SetNpcAction()
	if not self:IsOpen() then
		return
	end
	if self.delay_action then
		return
	end
	self.npc_model:SetTrigger("Action")
	self.delay_action = GlobalTimerQuest:AddDelayTimer(function()
		self:SetNpcAction()
		self.delay_action = nil
	end, 10)
end

function TaskDialogView:OnFlush(param_list)
	if self.npc_id == nil then
		return
	end

	local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.npc_id]
	if npc_cfg == nil then
		return
	end

	self.npc_name = npc_cfg.show_name
	if self.node_list["TxtName"] and self.node_list["TxtName2"] then
		self.node_list["TxtName"].text.text = self.npc_name
		self.node_list["TxtName2"].text.text = self.npc_name
	end
	self:FlushNpcTalk()

	if npc_cfg.role_res == nil or npc_cfg.role_res <= 0 then
		if npc_cfg.monster_res == "" or npc_cfg.monster_res <= 0 then
			self:SetNpcModel(npc_cfg.resid)
		else
			self:SetNpcModel3(npc_cfg.monster_res)
		end
	else
		self:SetNpcModel2(npc_cfg.role_res, npc_cfg.weapen_res, npc_cfg.mount_res, npc_cfg.wing_res, npc_cfg.halo_res)
	end

	if self.npc_model then
		local scale = npc_cfg.scale_h or 1.5
		self.npc_model:SetScale(Vector3(scale, scale, scale))
	end

	-- 公会争霸npc
	if self.npc_id == GuildFightData.Instance.npc_id then
		if Scene.Instance:GetMainRole().vo.special_param > 0 then
			if self.node_list["TxtAccept"] then
				self.node_list["TxtAccept"].text.text = Language.Task.CommitBox
			end
			self.auto_talk = true
			self:SetAutoTalkTime(5)
			return
		end
	end

		--精华护送npc
	if self.npc_id == JingHuaHuSongData.Instance:GetCommitNpc() then
		if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
			local talk_content = Language.Task.LingCommit
			self:SetTalk(talk_content)
			if self.node_list["TxtAccept"] then
				self.node_list["TxtAccept"].text.text = Language.Task.task_status_word[2]
			end
			self:SetAutoTalkTime(5)
			return
		end
	end

	


	--版本派对npc
	if FestivalSinglePartyData.Instance:IsSinglePartyNpc(self.npc_id) then
		if self.node_list["TxtAccept"] then
			self.node_list["TxtAccept"].text.text = Language.Task.task_status_word[7]
		end
		self:SetAutoTalkTime(5)
		return
	end

	self:SetAutoTalkTime()
	self.task_staus = TaskData.Instance:GetTaskStatus(self.task_id)
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if self.node_list["TxtAccept"] and self.node_list["TxtReward"] then
		if(self.task_staus == TASK_STATUS.CAN_ACCEPT) then
			self.node_list["TxtAccept"].text.text = (Language.Task.task_status_word[1])
			self.node_list["TxtReward"]:SetActive(self:GetTextRewardShow())
		elseif(self.task_staus == TASK_STATUS.COMMIT) then
			self.node_list["TxtAccept"].text.text = (Language.Task.task_status_word[2])
			self.node_list["TxtReward"]:SetActive(self:GetTextRewardShow())
			if task_cfg.task_type == TASK_TYPE.ZHUANZHI then
				local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
				local zhuanzhi_text = zhuan < 5 and Language.Task.task_status_word[5] or Language.Task.task_status_word[6]
				self.node_list["TxtAccept"].text.text = zhuanzhi_text
			end
		elseif(self.task_staus == TASK_STATUS.ACCEPT_PROCESS) then
			self.node_list["TxtAccept"].text.text = (Language.Task.task_status_word[4])
			self.node_list["TxtReward"]:SetActive(false)	
		else
			self.node_list["TxtAccept"].text.text = (Language.Task.task_status_word[3])
			self.node_list["TxtReward"]:SetActive(false)	
		end
	end
end

function TaskDialogView:SetNpcId(npc_id, npc_obj_id)
	local not_same_npc = self.npc_id ~= npc_id
	if not_same_npc then
		self:StopTaskDialogAudio()
	end
	if is_same_npc and self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end
	self.npc_id = npc_id
	self.npc_obj_id = npc_obj_id
	self:Flush()
end

function TaskDialogView:SetStoryNpcId(npc_id, story_talk_end_callback)
	if self.npc_id ~= npc_id and self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end

	self.auto_talk = true
	self.npc_id = npc_id
	self.npc_obj_id = nil
	self.story_talk_end_callback = story_talk_end_callback
	self:Flush()
end

function TaskDialogView:ClickPanel()
	self:HandleAccept()
	self:Close()
end

function TaskDialogView:GetTextRewardShow()
	for k,v in pairs(self.rewards) do
		if v.obj:GetActive() then
			return true
		end
	end
	return false
end

function TaskDialogView:OnCloseTask()
	self:HandleAccept()
end

function TaskDialogView:HandleClose(not_clear_toggle)
	GuajiCtrl.Instance:ClearTaskOperate(not_clear_toggle)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:Close()
end

function TaskDialogView:HandleAccept()
	-- 版本活动入口
	if FestivalSinglePartyData.Instance:IsSinglePartyNpc(self.npc_id) then
		FestivalSinglePartyCtrl.Instance:AskEnterSingleParty()
		self:HandleClose()
	end
	if self.npc_id == JingHuaHuSongData.Instance:GetCommitNpc() then
		if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
			JingHuaHuSongCtrl.Instance:SendCommitReq()								--提交任务
			self:HandleClose()
			JingHuaHuSongCtrl.Instance:CheckAndOpenContinueMessageBox()				--询问玩家是否回去采集
			return
		end
	end
	if self.task_id ~= 0 then
		if self:IsDailyTaskFb() and self.task_staus ~= TASK_STATUS.COMMIT then
			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DAILY_TASK_FB, task_cfg.c_param1)
			self:HandleClose()
			return
		end
		if(GuajiCache.guaji_type == GuajiType.None) then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		end
		if self.task_staus == TASK_STATUS.CAN_ACCEPT then
			if not self:IsShouldKeepWindow() then
				self:HandleClose(true)
			else
				GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id, true)
			end
			TaskCtrl.Instance.SendTaskAccept(self.task_id)

			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
			if nil ~= task_cfg then
				if TASK_ACCEPT_OP.TASK_ACCEPT_OP_CLIENT_PARAM == task_cfg.accept_op then		-- 用于飞行
					-- local main_role = Scene.Instance:GetMainRole()
					-- if main_role then
					-- 	if "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then
					-- 		main_role:SetFlyMaxHeight(task_cfg.a_param1)
					-- 		-- main_role:SetFlyUpUseTime(task_cfg.a_param2)
					-- 		-- main_role:SetFlyDownUseTime(task_cfg.a_param3)
					-- 	end
					-- 	main_role:StartFlyingUp()
					-- end
				elseif TASK_ACCEPT_OP.ENTER_FB == task_cfg.accept_op and "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then  -- 进入副本
					FuBenCtrl.Instance:SendEnterFBReq(task_cfg.a_param1, task_cfg.a_param2)
				elseif TASK_ACCEPT_OP.OPEN_GUIDE_FB_ENTRANCE == task_cfg.accept_op then -- 进入引导副本
					StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, self.task_id)
				end
			end

		elseif self.task_staus == TASK_STATUS.COMMIT then
			if self:IsShouldKeepWindow() then
				GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id, true)
			else
				self:HandleClose()
			end
			TaskCtrl.Instance.SendTaskCommit(self.task_id)
			-- TaskData.Instance:SetTaskCompleted(self.task_id)
		elseif self.task_staus == TASK_STATUS.ACCEPT_PROCESS then
			self:HandleClose()
			TaskCtrl.Instance:DoTask(self.task_id)
		end
	else
		self:HandleClose()
	end
end

function TaskDialogView:IsShouldKeepWindow()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg and self.auto_do_task then
		if task_cfg.task_type == TASK_TYPE.ZHU then
			local next_task_cfg = TaskData.Instance:GetNextZhuTaskConfigById(self.task_id)
			if next_task_cfg then
				if self.task_staus == TASK_STATUS.COMMIT then
					if next_task_cfg.accept_npc and type(next_task_cfg.accept_npc) == "table"
						and next_task_cfg.accept_npc.id == self.npc_id
						and next_task_cfg.min_level <= GameVoManager.Instance:GetMainRoleVo().level then
						return true
					end
				elseif self.task_staus == TASK_STATUS.CAN_ACCEPT then
					if task_cfg.condition == TASK_COMPLETE_CONDITION.NOTHING and task_cfg.commit_npc
						and type(task_cfg.commit_npc) == "table" and task_cfg.commit_npc.id == self.npc_id then
						return true
					end
				end
			end
		end
	end
	return false
end

function TaskDialogView:ClickGoOn()
	if self.talk_table then
		self.cur_index = self.cur_index + 1
		if self.cur_index > #self.talk_table then
			self:HandleAccept()
			return
		end
		self:SetAutoTalkTime()
		if self.cur_index == #self.talk_table then
			self:ShowBtn(true)
			self:FlushRewardList()
		else
			self:ShowBtn(false)
		end
		local content = self.talk_table[self.cur_index]
		if content then
			self:ShowNPC(true)
			self.node_list["TxtName"].text.text = self.npc_name
			self.node_list["TxtName2"].text.text = self.npc_name
			local content, prof = self:GetTaskContent(content, true)
			if self.talk_audio then
				local _, next_prof = self:GetTaskContent(self.talk_table[self.cur_index + 1], false)
				local audio_key = self.talk_audio.."_"..self.cur_index.."_"..prof
				self.talk_audio_list[audio_key] = {talk_audio = self.talk_audio, subsection = self.cur_index, prof = prof, next_prof = next_prof}
				self:PlayNpcTalkAudio(self.talk_audio, self.cur_index, prof)
			end

			self.node_list["TxtContent"].text.text = content
			self.node_list["TxtContent2"].text.text = content
		end
	end
end

function TaskDialogView:GetTaskContent(content, show_name)
	local prof = 0
	if content then
		local i, j = string.find(content, "{npc}")
		if not i or not j then
			i, j = string.find(content, "{plr}")
			if i and j then
				prof = PlayerData.Instance:GetRoleBaseProf()
				if show_name then
					self:ShowNPC(false)
					self:SetRoleModel()
					local name = GameVoManager.Instance:GetMainRoleVo().name
					self.node_list["TxtName"].text.text = name
					self.node_list["TxtName2"].text.text = name
				end
			end
		end
		if i and j then
			content = string.sub(content, j + 1, -1)
		end
	end
	return content, prof
end

-- 刷新NPC对话内容
function TaskDialogView:FlushNpcTalk()
	local task_id = TaskData.Instance:GetCurTaskId()
	local exits_task = TaskData.Instance:GetNpcOneExitsTask(self.npc_id)
	self.npc_status = TaskData.Instance:GetNpcTaskStatus(self.npc_id)
	self.talk_id = 0
	if (self.npc_status == TASK_STATUS.CAN_ACCEPT or self.npc_status == TASK_STATUS.ACCEPT_PROCESS)then			--有可接任务或者未完成的任务
		if exits_task then
			self.talk_id = exits_task.accept_dialog
		end
	elseif self.npc_status == TASK_STATUS.COMMIT then			--有可提交任务
		if exits_task then
			self.talk_id = exits_task.commit_dialog
		end
	else
		local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.npc_id]
		if npc_cfg then
			self.talk_id = npc_cfg.talkid
		end
	end

	if nil ~= exits_task then
		self.task_id = exits_task.task_id
	else
		self.task_id = 0
	end

	for i = 1, NUM do
		self.rewards[i].obj:SetActive(false)
	end

	local talk_content = Language.Task.DefaultTalk
	local npc_obj = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
	if npc_obj then
		if npc_obj:IsWalkNpc() then
			talk_content = npc_obj:GetRandomStr()
		end
	end
	local talk_cfg = ConfigManager.Instance:GetAutoConfig("npc_talk_list_auto").npc_talk_list[self.talk_id]

	self.talk_audio = nil
	if talk_cfg ~= nil then
		talk_content = talk_cfg.talk_text
		talk_content = CommonDataManager.ParseTagContent(talk_content)
		self.talk_audio = talk_cfg.talk_audio
		if self.talk_audio == "" then
			self.talk_audio = nil
		end
	end

	self:SetTalk(talk_content)
	GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 1, self.task_id)
	if self.node_list["TxtReward"] then
		self.node_list["TxtReward"]:SetActive(self:GetTextRewardShow())
	end
	
end

function TaskDialogView:SetTalk(talk_content)
	if not talk_content then return end
	self.talk_table = Split(talk_content, "|")
	if #self.talk_table > 1 then
		self:ShowBtn(false)
		self.cur_index = 0
		self:ClickGoOn()
	elseif #self.talk_table == 1 then
		self.cur_index = 1
		self:ShowBtn(true)
		self:ShowNPC(true)
		self:FlushRewardList()

		if self.talk_audio then
			local audio_key = self.talk_audio.."_"..self.cur_index.."_0"
			self.talk_audio_list[audio_key] = {talk_audio = self.talk_audio, subsection = self.cur_index, prof = 0, next_prof = 0}
			self:PlayNpcTalkAudio(self.talk_audio, self.cur_index)
		end
		self.node_list["TxtContent"].text.text = self.talk_table[1]
		self.node_list["TxtContent2"].text.text = self.talk_table[1]
	end
end

-- 播放NPC任务对话音效
function TaskDialogView:PlayNpcTalkAudio(talk_audio, subsection, prof)
	if not talk_audio then
		return
	end
	
	-- if self.npc_talk_audio then
	-- 	AudioManager.StopAudio(self.npc_talk_audio)
	-- 	self.npc_talk_audio = nil
	-- end

	local bundle, asset = ResPath.GetNpcTalkVoiceRes(talk_audio, subsection, prof)
	if not self.is_play_audio and bundle and asset then
		self.is_play_audio = true
		AudioManager.PlayAndForget(bundle, asset, nil, nil,
			function (call_back_audio, asset_name)
				self.npc_talk_audio = call_back_audio
			end,
			function (call_back_audio, asset_name)
				self.npc_talk_audio = nil
				self.is_play_audio = false
				local tab = self.talk_audio_list[asset_name]
				self.talk_audio_list[asset_name] = nil
				if tab then
					local talk_audio = tab["talk_audio"]
					local subsection = tonumber(tab["subsection"]) + 1
					-- local prof = tab["prof"]
					local next_prof = tab["next_prof"]

					local audio_key = talk_audio.."_"..subsection.."_"..next_prof
					local list = self.talk_audio_list[audio_key]
					if list then
						self:PlayNpcTalkAudio(talk_audio, subsection, next_prof)
					end
				end
			end)
	end
end

function TaskDialogView:StopTaskDialogAudio()
	if self.npc_talk_audio then
		self.talk_audio_list = {}
		AudioManager.StopAudio(self.npc_talk_audio)
		self.npc_talk_audio = nil
	end
end

-- 刷新任务奖励列表
function TaskDialogView:FlushRewardList()
	if self.task_id == 0 then return end
	local config = TaskData.Instance:GetTaskConfig(self.task_id)
	if not config then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local reward_list = config["prof_list" .. prof]
	local count = 0
	if reward_list then
		for k,v in pairs(reward_list) do
			count = count + 1
			self.rewards[count + 1].obj:SetActive(true)
			self.rewards[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
			if count >= NUM - 1 then
				break
			end
		end
	end
	for i = 2 + count, NUM do
		self.rewards[i].obj:SetActive(false)
	end
	self.rewards[1].obj:SetActive(true)
	local num = tonumber(config.exp)
	-- 如果是运镖
	if config.task_id == YunbiaoData.Instance:GetTaskIdByCamp() then
		local yunbiao_cfg = YunbiaoData.Instance:GetCurExitTaskRewardCfg() or {}
		num = yunbiao_cfg.exp or 0
	end
	if num then
		local data = {item_id = ResPath.CurrencyToIconId.exp, num = num}
		self.rewards[1].cell:SetData(data)
	else
		self.rewards[1].obj:SetActive(false)
	end
	self.node_list["TxtReward"]:SetActive(self:GetTextRewardShow())
end

-- 设置自动对话的倒计时
function TaskDialogView:SetAutoTalkTime(delay_time)
	delay_time = delay_time and delay_time or DELAY_TIME
	if self:CheckIsAutoTalk() or self.auto_talk then
		self.auto_talk = false
		self.show_time = true
		self.node_list["TxtCountDown"]:SetActive(self.show_time)

		self.node_list["TxtCountDown"].text.text = string.format(Language.Task.AutoGoOn, ToColorStr(DELAY_TIME, TEXT_COLOR.GREEN))
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		local time = self:IsDailyTaskFb() and 5 or delay_time
		self:CountDown(0, time)
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	else
		self.show_time = false
		self.node_list["TxtCountDown"]:SetActive(self.show_time)
	end
end

-- 设置自动对话的倒计时
function TaskDialogView:CountDown(elapse_time, total_time)
	if self.node_list["TxtCountDown"] then
		self.node_list["TxtCountDown"].text.text = string.format(Language.Task.AutoGoOn, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.GREEN))
		if elapse_time >= total_time then
			self:ClickGoOn()
		end
	end
end

function TaskDialogView:SetAutoTalkState(state)
	self.is_auto = state
	if self:IsOpen() then
		if state and not self.count_down then
			self:SetAutoTalkTime()
		elseif not state then
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
				self.show_time = false
				self.node_list["TxtCountDown"]:SetActive(self.show_time)
			end
		end
	end
end

function TaskDialogView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end

	self.last_npc_resid = 0
	GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id)
	if self.npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
		if npc_obj then
			if npc_obj:IsWalkNpc() then
				npc_obj:Continue()
			else
				local npc_vo = npc_obj:GetVo()
				if npc_vo then
					local obj = npc_obj:GetRoot()
					if obj then
						obj.transform:DORotate(u3d.vec3(0, npc_vo.rotation_y or 0, 0), 0.5)
					end
				end
			end
		end
	end
	self.npc_obj_id = nil

	if nil ~= self.story_talk_end_callback then
		self.story_talk_end_callback()
		self.story_talk_end_callback = nil
	end

	if self.npc_id and self.npc_id > 0 then
		TaskCtrl.SendTaskTalkToNpc(self.npc_id)
	end
end

function TaskDialogView:SetAutoDoTask(switch)
	self.auto_do_task = switch
	if not switch then
		self:Close()
	end
end


-- 是否自动对话
function TaskDialogView:CheckIsAutoTalk()
	local flag = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if TaskData.Instance:GetNpcOneExitsTask(self.npc_id) and self.is_auto then
		if main_role_vo.level <= LEVEL_LIMIT or self.npc_id == COMMON_CONSTS.NPC_HUSONG_DONE_ID then
			flag = true
		end
	end
	if self:IsDailyTaskFb() then
		flag = true
	end
	return flag
end

function TaskDialogView:IsDailyTaskFb()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg and TASK_ACCEPT_OP.ENTER_DAILY_TASKFB == task_cfg.accept_op then
		return true
	end
	return false
end