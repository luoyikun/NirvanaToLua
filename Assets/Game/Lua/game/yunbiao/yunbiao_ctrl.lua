require("game/yunbiao/yunbiao_view")
require("game/yunbiao/yunbiao_data")
-- 运镖
YunbiaoCtrl = YunbiaoCtrl or BaseClass(BaseController)

function YunbiaoCtrl:__init()
	if YunbiaoCtrl.Instance ~= nil then
		print_error("[YunbiaoCtrl] attempt to create singleton twice!")
		return
	end
	YunbiaoCtrl.Instance = self

	self.view = YunbiaoView.New(ViewName.YunbiaoView)
	self.data = YunbiaoData.New()

	self.continue_alert = nil

	self.jiu_yuan_alert = nil

	self:RegisterAllProtocols()
end

function YunbiaoCtrl:__delete()
	YunbiaoCtrl.Instance = nil

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function YunbiaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHusongInfo, "OnHusongInfo")
	self:RegisterProtocol(SCHusongConsumeInfo, "HusongConsumeInfo")
	self:RegisterProtocol(CSRefreshHusongTask)
	self:RegisterProtocol(CSHusongBuyTimes)
	--Remind.Instance:RegisterOneRemind(RemindId.act_husong, BindTool.Bind1(self.CheckRemind, self))
end

function YunbiaoCtrl:CheckRemind(remind_id)
	if remind_id == RemindId.act_husong then
		return TaskData.Instance:GetTaskRemainTimes(GameEnum.TASK_TYPE_HU)
	end
	return 0
end

function YunbiaoCtrl:Open(tab_index, param_t)
	self.view:Open()

	if param_t ~= nil then
		self.view:SetNpcId(param_t.from_npc_id)
	end
end

function YunbiaoCtrl:Close()
	self.view:Close()
end

-- 刷新护送对象
function YunbiaoCtrl:SendRefreshHusongTask(is_autoflush, is_autobuy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRefreshHusongTask)
	protocol.is_autoflush = is_autoflush
	protocol.is_autobuy = is_autobuy
	protocol.to_color = 5
	protocol:EncodeAndSend()
end

-- 购买次数
function YunbiaoCtrl:SendHusongBuyTimes()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHusongBuyTimes)
	protocol:EncodeAndSend()
end

-- 更新任务的次数
function YunbiaoCtrl:OnLingQuCiShuChangeHandler(value)
	if value then
		local old_data = self.data:GetLingQuCishu()
		if value ~= old_data then
			self.data:SetLingQuCishu(value)
			self.view:Flush()
		end
	end
end

-- 更新购买的次数
function YunbiaoCtrl:OnGouMaiCiShuChangeHandler(value)
	if value then
		local old_data = self.data:GetGouMaiCishu()
		if value ~= old_data then
			self.data:SetGouMaiCishu(value)
			self.view:Flush()
			GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT)
		end
	end
end

-- 更新免费刷新美女的次数
function YunbiaoCtrl:OnChangeRefreshFreeTimeHandler(value)
	if value then
		local old_data = self.data:GetRefreshFreeTime()
		if value ~= old_data then
			self.data:SetRefreshFreeTime(value)
			self.view:Flush()
		end
	end
end

-- 刷新护送对象返回
function YunbiaoCtrl:OnHusongInfo(protocol)
	local role = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= role then
		if protocol.notfiy_reason ~= nil and protocol.notfiy_reason < 5 then
			role:SetAttr("husong_color", protocol.task_color or 0)
			role:SetAttr("husong_taskid", protocol.task_id or 0)
		end
		if role:IsMainRole() then
			self.data:SetAcceptInActivitytime(protocol.accept_in_activitytime)
			self.data:SetIsUseHuDun(protocol.is_use_hudun)
			if self.skill_render then
				self.skill_render:Flush("use_hudun", {protocol.is_use_hudun == 1})
				self.skill_render = nil
			end
			if protocol.notfiy_reason == 1 then			-- 接任务
				TaskCtrl.Instance:DoTask(protocol.task_id)
				local task_view = MainUICtrl.Instance:GetTaskView()
				if task_view then 				--不知道为什么不会自动运镖
					task_view:DoTask(protocol.task_id, TASK_STATUS.COMMIT)
				end
				self.view:Close()
			--elseif protocol.notfiy_reason == 2 then		-- 任务失败
			elseif protocol.notfiy_reason == 3 then		-- 任务成功
				local describe = string.format(Language.YunBiao.Continue, ToColorStr(self.data:GetLingQuCishu(), COLOR.GREEN))
				local yes_func = function() self:MoveToHuShongReceiveNpc(true) end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
			elseif protocol.notfiy_reason == 5 or protocol.notfiy_reason == 6 then 				--小助手功能完成仙女护送 服务器照样会发协议 接收和完成任务
				YunbiaoCtrl:ShowHuSongButton(false)
			end
		end
	end
	if self.view then
		self.view:Flush()
	end
end

-- 刷新护送对象返回
function YunbiaoCtrl:HusongConsumeInfo(protocol)
	if protocol.gold_num > 0 and protocol.bind_gold_num <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.YunBiao.XiaoHao1, protocol.token_num, protocol.gold_num))
	elseif protocol.gold_num <= 0 and protocol.bind_gold_num > 0 then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.YunBiao.XiaoHao2, protocol.token_num, protocol.bind_gold_num))
	elseif protocol.gold_num > 0 and protocol.bind_gold_num > 0 then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.YunBiao.XiaoHao3, protocol.token_num, protocol.gold_num, protocol.bind_gold_num))
	elseif protocol.gold_num == 0 and protocol.bind_gold_num == 0 and protocol.token_num == 0 then
		return
	end
end

-- 求救
function YunbiaoCtrl:QiuJiuHandler()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		local yes_func = function() self:SendGuildSosReq(0) end
		local describe = string.format(Language.Guild.QIUYUAN2)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoGuild)
	end
end

function YunbiaoCtrl:SendGuildSosReq(sos_type)
	GuildCtrl.Instance:SendSendGuildSosReq(sos_type)
	-- local main_role = Scene.Instance.main_role
	-- if main_role then
	-- 	local x, y = main_role:GetLogicPos()
	-- 	local scene_id = Scene.Instance:GetSceneId()
	-- 	local str_format = Language.YunBiao.HelpGuildTxt
	-- 	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	-- 	local content = string.format(str_format, x, y, scene_id, role_id)
	-- 	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content, CHAT_CONTENT_TYPE.TEXT)
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.SosToGuildSuc)
	-- end
end

function YunbiaoCtrl:MoveToHuShongReceiveNpc(ignore_vip)
	-- if not ignore_vip then
	-- 	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG) then
	-- 		ignore_vip = true
	-- 	end
	-- end
	ignore_vip = true

	-- 为了使切场景的时候自动对话
	TaskData.Instance:SetCurTaskId(YunbiaoData.Instance:GetTaskIdByCamp())

	if self.data:GetIsHuShong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.YunBiaoZhong)
	else
		GuajiCtrl.Instance:MoveToNpc(COMMON_CONSTS.NPC_HUSONG_RECEIVE_ID, YunbiaoData.Instance:GetTaskIdByCamp(), nil, ignore_vip, 0)
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		-- self:MoveToNpc(COMMON_CONSTS.NPC_HUSONG_RECEIVE_ID, YunbiaoData.Instance:GetTaskIdByCamp(), nil, ignore_vip, 0)
	end
end

-- 运送施放护盾
function YunbiaoCtrl:SendHuSongAddShieldReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHuSongAddShield)
	protocol:EncodeAndSend()
end


function YunbiaoCtrl:CheckHuSongSkillState()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.husong_taskid ~= 0 and vo.husong_color ~= 0 then
		return true
	end
	return false
end

function YunbiaoCtrl:ShowHuSongButton(state, is_force)
	if not is_force and state == self.husong_state then
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Common then
		state = false
	end

	self.husong_state = state

	if self.husong_state then
		local loader = AllocAsyncLoader(self, "husong_skill_button_loader")
		loader:Load("uis/views/escortview_prefab", "HuSongSkill", function (obj)
			if not IsNil(obj) then
				MainUICtrl.Instance:ShowActivitySkill(obj)
				if self.skill_render then
					self.skill_render:DeleteMe()
					self.skill_render = nil
				end
				self.skill_render = HoSongSkillRender.New(obj)
			end
		end)
	else
		MainUICtrl.Instance:ShowActivitySkill(false)
		if self.skill_render then
			self.skill_render:DeleteMe()
			self.skill_render = nil
		end
	end
end

function YunbiaoCtrl:FlushHuSong()
	if self.skill_render then
		self.skill_render:Flush()
	end
end

--------------------------------------------------
--护送技能
--------------------------------------------------

HoSongSkillRender = HoSongSkillRender or BaseClass(BaseRender)

function HoSongSkillRender:__init()
	
end

function HoSongSkillRender:__delete()
	self:RemoveTimeQuest()
end

function HoSongSkillRender:LoadCallBack()
	self.node_list["BtnHu"].button:AddClickListener(BindTool.Bind(self.OnClickHu, self))
	self.node_list["BtnJiu"].button:AddClickListener(BindTool.Bind(self.OnClickJiu, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickGo, self))
end

function HoSongSkillRender:OnClickHu()
	YunbiaoCtrl.Instance:SendHuSongAddShieldReq()
end

function HoSongSkillRender:OnClickJiu()
	YunbiaoCtrl.Instance:QiuJiuHandler()
end

--继续护送任务
function HoSongSkillRender:OnClickGo()
	local task_view = MainUICtrl.Instance:GetTaskView()
	if task_view then
		task_view:ClickGo()
	end
end

function HoSongSkillRender:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if "use_hudun" == k then
			local state = v[1]
			UI:SetGraphicGrey(self.node_list["BtnHu"], state)
			UI:SetGraphicGrey(self.node_list["ImgDun"], state)
			return
		end
	end

	self:FlushHuSong()
end

function HoSongSkillRender:RemoveTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function HoSongSkillRender:FlushHuSong()
	self:RemoveTimeQuest()
	if self.time_quest == nil then
		self:FlushHuSongTime()
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushHuSongTime, self), 1)
	end
end

function HoSongSkillRender:FlushHuSongTime()
	if nil == self.node_list or nil == self.node_list["TxtTime"] or nil == self.node_list["TxtTime"].text or nil == self.node_list["TxtTime"].text.text then
		return
	end

	local task_id = 24001									 -- 护送的任务ID
	local end_time = TaskData.Instance:GetTaskEndTime(task_id)
	if end_time then
		local time = end_time - TimeCtrl.Instance:GetServerTime()
		if time > 0 then
			self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond(time, 2)
		end
		if end_time <= 0 then
			self:RemoveTimeQuest()
		end
	end
end
