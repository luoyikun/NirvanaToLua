require("game/city_combat/city_combat_view")
require("game/city_combat/city_combat_fb_view")
require("game/city_combat/city_combat_data")
require("game/city_combat/city_reward_view")
require("game/city_combat/city_combat_first_view")
require("game/city_combat/guild_first_view")
require("game/city_combat/hefu_city_combat_tip")
require("game/city_combat/hefu_city_combat_first_view")
require("game/city_combat/xianmengwar_view")
require("game/city_combat/worship_view")

CityCombatCtrl = CityCombatCtrl or BaseClass(BaseController)

function CityCombatCtrl:__init()
	if CityCombatCtrl.Instance then
		print_error("[CityCombatCtrl] Attemp to create a singleton twice !")
	end
	CityCombatCtrl.Instance = self
	self.data = CityCombatData.New()
	self.view = CityCombatView.New(ViewName.CityCombatView)
	self.first_view = CityCombatFirstView.New(ViewName.CityCombatFirstView)
	self.hefu_first_view = HeFuCombatFirstView.New(ViewName.HeFuCombatFirstView)
	self.fb_view = CityCombatFBView.New(ViewName.CityCombatFBView)
	self.reward_view = CityRewardView.New(ViewName.CityReward)
	self.guild_first_view = GuildFirstView.New(ViewName.GuildFirstView)
	self.tequan_tips_view = HeFuCityCombatTip.New()
	self.xian_meng_war_view = XianMengWarView.New(ViewName.XianMengWarView)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.RoleInfo, BindTool.Bind(self.SetCityOwnerAndLoverInfo, self))

	self.activity_change_callback = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_callback)

	self.is_first_rec_worshipinfo = true
end

function CityCombatCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	self.first_view:DeleteMe()
	self.fb_view:DeleteMe()
	self.reward_view:DeleteMe()
	self.guild_first_view:DeleteMe()
	self.hefu_first_view:DeleteMe()
	self.tequan_tips_view:DeleteMe()
	self.xian_meng_war_view:DeleteMe()
	CityCombatCtrl.Instance = nil

	if nil ~= self.gather_delay then
		GlobalTimerQuest:CancelQuest(self.gather_delay)
		self.gather_delay = nil
	end

	if self.activity_change_callback then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_callback)
		self.activity_change_callback = nil
	end
end

function CityCombatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGongChengZhanOwnerInfo, "SetCityOwnerInfo")
	self:RegisterProtocol(SCGCZRoleInfo, "SetSelfInfo")
	self:RegisterProtocol(SCGCZGlobalInfo, "SetGlobalInfo")
	self:RegisterProtocol(SCGCZRewardInfo, "ShowFinalReward")
	self:RegisterProtocol(SCZhanchangLuckyInfo, "OnZhanchangLuckyInfo")
	self:RegisterProtocol(SCTwLuckyRewardInfo, "OnTwLuckyRewardInfo")
	self:RegisterProtocol(SCGBLuckyRewardInfo, "OnGBLuckyRewardInfo")
	self:RegisterProtocol(SCQxdldLuckyRewardInfo, "OnQxdldLuckyRewardInfo")
	self:RegisterProtocol(SCGCZWorshipInfo, "OnGCZWorshipInfo")
	self:RegisterProtocol(SCCSAGONGCHENGZHANInfo, "OnSCCSAGONGCHENGZHANInfo")

	-- 拜谒协议，根据活动类型判断
	self:RegisterProtocol(SCRoleWorshipInfo, "SCRoleWorshipInfo")

	self:RegisterProtocol(SCGongChengZhanFlagInfo, "OnSCGongChengZhanFlagInfo")
	-- 拜谒请求
	self:RegisterProtocol(CSRoleWorshipReq)

	self:RegisterProtocol(CSGCZWorshipReq)
end

function CityCombatCtrl:OnZhanchangLuckyInfo(protocol)
	self.data:SetZhanChangLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("zhanchan_info")
	end
	self:FlushRewradView()

end

function CityCombatCtrl:OnTwLuckyRewardInfo(protocol)
	self.data:SetTWLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("tw_info")
	end
	self:FlushRewradView()

end

function CityCombatCtrl:OnGBLuckyRewardInfo(protocol)
	self.data:SetGBLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("gb_info")
	end
	self:FlushRewradView()
end

function CityCombatCtrl:OnSCCSAGONGCHENGZHANInfo(protocol)
	self.data:SetHefuFirstInfo(protocol)
end

function CityCombatCtrl:SCRoleWorshipInfo(protocol)
	self.data:SetBaiYeInfo(protocol)
	local activity_type = protocol.activity_type
	if activity_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		self.fb_view:Flush("bai_ye")
	elseif activity_type == ACTIVITY_TYPE.GUILDBATTLE then
		GuildFightCtrl.Instance:FlushMvpName("bai_ye")
	elseif activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
		KuafuGuildBattleCtrl.Instance:FlushMvpName("bai_ye")
	elseif activity_type == ACTIVITY_TYPE.QUNXIANLUANDOU then
		ElementBattleCtrl.Instance:FlushByYeView()
	end
end

function CityCombatCtrl:OnSCGongChengZhanFlagInfo(protocol)
	self.data:SetGetGongChengZhanFlagInfo(protocol)
	if self.fb_view then
		self.fb_view:FlushDiaoXiangHp()
	end
end

function CityCombatCtrl:OnQxdldLuckyRewardInfo(protocol)
	self.data:SetQXLDLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("qxld_info")
	end
	self:FlushRewradView()
end

function CityCombatCtrl:SendWorshipReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGCZWorshipReq)
	send_protocol:EncodeAndSend()
end

-- 发送拜谒请求
function CityCombatCtrl:SendBaiYeReq()
	MountCtrl.Instance:SendGoonMountReq(0)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRoleWorshipReq)
	send_protocol:EncodeAndSend()
end

-- 膜拜城主
function CityCombatCtrl:OnGCZWorshipInfo(protocol)
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP) then
		self.is_first_rec_worshipinfo = false
		return
	end
	self.data:SetGCZWorshipInfo(protocol)
	if self.worship then
		self.worship:Flush()
	end
	
	if self.is_first_rec_worshipinfo then
		self.is_first_rec_worshipinfo = false
		return
	end
	self:DoWorship()
end

function CityCombatCtrl:ActivityChangeCallback(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.GONGCHENG_WORSHIP and ACTIVITY_STATUS.CLOSE == status then
		self:ShowMoBaiSkillIcon(false)
	end
end

function CityCombatCtrl:CheckShowMoBaiSkillIcon()
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	if not act_is_open then
		return false
	end

	local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then
		return false
	end

	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	local main_role_pos_x, main_role_pos_y = main_role:GetLogicPos()
	local worship_scene_id, worship_pos_x, worship_pos_y, range = self.data:GetWorshipScenIdAndPosXYAndRang()
	local cur_scene_id = Scene.Instance:GetSceneId()
	if -1 ~= worship_scene_id and -1 ~= worship_pos_x and -1 ~= worship_pos_y and -1 ~= range then
		local cond_1 = math.abs(worship_pos_x - main_role_pos_x) > range
		local cond_2 = math.abs(worship_pos_y - main_role_pos_y) > range
		if cond_1 or cond_2 or worship_scene_id ~= cur_scene_id then
			return false
		else
			return true
		end
	end
	return false
end

function CityCombatCtrl:ShowMoBaiSkillIcon(is_show, is_force)
	if not is_force and is_show == self.is_show_mobai_skill then
		return
	end
	self.is_show_mobai_skill = is_show

	if self.is_show_mobai_skill then
		local loader = AllocAsyncLoader(self, "skill_button_loader")
		loader:Load("uis/views/citycombatview_prefab", "WorshipViewSkill", function (obj)
			if IsNil(obj) then
				return
			end

			MainUICtrl.Instance:ShowActivitySkill(obj)

			if self.worship then
				self.worship:DeleteMe()
				self.worship = nil
			end
			self.worship = WorshipRender.New(obj)
			self.worship:Flush()
		end)
	else
		MainUICtrl.Instance:ShowActivitySkill(false)
		if self.worship then
			self.worship:DeleteMe()
			self.worship = nil
		end
	end
end

function CityCombatCtrl:DoWorship()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	local fight_mount_appeid = main_role_vo.fight_mount_appeid
	if fight_mount_appeid > 0 then
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
	end
	if mount_appeid > 0 then
		MountCtrl.Instance:SendGoonMountReq(0)
	end

	local mainrole = Scene.Instance:GetMainRole()
	local statue = Scene.Instance:GetCityStatue()
	local statue_pos_x, statue_pos_y = CityCombatData.Instance:GetWorshipStatuePosParam()
	if nil ~= mainrole and nil ~= statue and statue_pos_x > 0 and statue_pos_y > 0 then
		local part = mainrole.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		
		local mainrole_root = mainrole:GetRoot()
		if nil == mainrole_root then
			return
		end

		local statue_root = statue:GetRoot()
		if nil == statue_root then
			return
		end

		towards = u3d.vec3(statue_root.transform.position.x, statue_root.transform.position.y, statue_root.transform.position.z)
		mainrole_root.transform:DOLookAt(towards, 0)
		
		if nil ~= self.gather_delay then
			GlobalTimerQuest:EndQuest(self.gather_delay)
			self.gather_delay = nil
		end
		local gather_time = CityCombatData.Instance:GetWorshipGatherTime() or 3
		self.gather_delay = GlobalTimerQuest:AddDelayTimer(function ()
			local mainrole = Scene.Instance:GetMainRole()
			local part = mainrole.draw_obj:GetPart(SceneObjPart.Main)
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)	
		end, gather_time)
	end
end

--城主信息
function CityCombatCtrl:SetCityOwnerInfo(protocol)
	self.data:SetCityOwnerInfo(protocol)
	self.data:ClearCityOwnerInfo()

	if 0 ~= protocol.owner_id and protocol.guild_id > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.owner_id)
	end
end

function CityCombatCtrl:SetCityOwnerAndLoverInfo(role_id, role_info)
	local owner_info = self.data:GetCityOwnerInfo()
	local owner_role_info = self.data:GetCityOwnerRoleInfo()
	if nil ~= owner_info and owner_info.owner_id == role_id and nil ~= role_info then
		if Scene.Instance:GetMainRole():IsDead() then
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
		end
		
		self.data:SetCityOwnerRoleInfo(role_info)
		self.view:Flush()

		if 0 ~= role_info.lover_uid then
			CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.lover_uid)
		end

		local city_statue = Scene.Instance:GetCityStatue()
		if nil ~= city_statue then
			city_statue:RefreshCityOwnerStatue()
		end
	end
	
	local lover_uid = self.data:GetCityOwnerLoverRoleId()
	if nil ~= owner_info and nil ~= owner_role_info and lover_uid == role_id then
		self.data:SetLoverRoleInfo(role_info)
		self.view:Flush()
		
		local city_statue = Scene.Instance:GetCityStatue()
		if nil ~= city_statue then
			city_statue:RefreshCityOwnerStatue()
		end
	end

	if self.is_show_cg then
		if self.chengzhu_uid == role_id then
			self.is_show_cg = false
			local role_vo = TipsData.Instance:GetBorrowVo(role_info)
			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GONGCHENGZHAN)
			if bai_ye_cfg then
				role_vo.pos_x = bai_ye_cfg.statue_pos_x1
				role_vo.pos_y = bai_ye_cfg.statue_pos_y1
			end
			
			Scene.Instance:CreateCgObj({role_vo}, function(index)
				local cg_bundle = "cg/w3_hd_liujie_fenchangjing_prefab"
				local cg_asset = "W3_HD_LiuJie_fenchangjing_cg01"
				if not CgManager.Instance:IsCgIng() and EndPlayCgSceneId[Scene.Instance:GetSceneId()] then
					CgManager.Instance:Play(BaseCg.New(cg_bundle, cg_asset), function()
						Scene.Instance:ResetCgObjListPos()
						self.fb_view:Flush("bai_ye")
						self.fb_view:SetRemindBubbleActive()
					end)
				end
			end)
		end
	end
end

-- 退出场景显示奖励界面
function CityCombatCtrl:ExitSceneShowAward()
	if self.cg_info_data and self.cg_info_data.reward_list then
		TipsCtrl.Instance:OpenActivityRewardTip(self.cg_info_data, nil, nil, ACTIVITY_TYPE.GONGCHENGZHAN)
	end
	self.cg_info_data = {}
end

--个人信息
function CityCombatCtrl:SetSelfInfo(protocol)
	self.data:SetSelfInfo(protocol)
	self.fb_view:Flush()
	self:FlushSceneRoleInfo()
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_call")
end

--复位5秒倒计时
function CityCombatCtrl:PoChengReset()
	self.fb_view:PoChengReset()
end

--攻城战全局信息
function CityCombatCtrl:SetGlobalInfo(protocol)
	self.data:SetGlobalInfo(protocol)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.GongChengZhan then
			if protocol.is_poqiang == 1 then
				Scene.Instance:CreateDoorList()
				scene_logic:SetBlock(false)
			else
				scene_logic:SetBlock(true)
			end
		end
	end
	self.fb_view:Flush()
	self.fb_view:FlushDefGuildTime()
	self:FlushSceneRoleInfo()
end

function CityCombatCtrl:FlushSceneRoleInfo()
	local main_role = Scene.Instance:GetMainRole()
	local role_list = Scene.Instance:GetRoleList()
	main_role:ReloadSpecialImage()
	main_role:ReloadUIName()
	for k,v in pairs(role_list) do
		v:ReloadSpecialImage()
		v:ReloadUIName()
	end
end

--攻城战结算
function CityCombatCtrl:ShowFinalReward(protocol)
	local data = {}
	data.reward_list = protocol.reward_list
	if protocol.shengwang_reward > 0 then
		local shengwang_data = {}
		shengwang_data.item_id = ResPath.CurrencyToIconId["honor"]
		shengwang_data.num = protocol.shengwang_reward
		table.insert(data.reward_list, shengwang_data)
	end

	if protocol.gold_reward > 0 then
		local gold_data = {}
		gold_data.item_id = ResPath.CurrencyToIconId["diamond"]
		gold_data.num = protocol.gold_reward
		table.insert(data.reward_list, gold_data)
	end

	if protocol.gongxun > 0 then
		local gongxun_data = {}
		gongxun_data.item_id = ResPath.CurrencyToIconId["gongxun"]
		gongxun_data.num = protocol.gongxun
		table.insert(data.reward_list, gongxun_data)
	end

	self.is_show_cg = true
	self.chengzhu_uid = protocol.chengzhu_uid
	self.cg_info_data = data
	self.fb_view:SetBaiYeDownTime()
	if protocol.chengzhu_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.chengzhu_uid)
	else
		TipsCtrl.Instance:OpenActivityRewardTip(data, nil, nil, ACTIVITY_TYPE.GONGCHENGZHAN)
	end
end

--传送到拆旗/资源区
function CityCombatCtrl:QuickChangePlace(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGCZChangePlace)
	protocol.place_type = type
	protocol:EncodeAndSend()
end

function CityCombatCtrl:CloseRewardView()
	if self.reward_view:IsOpen() then
		self.reward_view:Close()
	end
end

function CityCombatCtrl:OpenRewardView()
	if self.reward_view:IsOpen() then
		self.reward_view:Flush()
		return
	end
	ViewManager.Instance:Open(ViewName.CityReward)
end

function CityCombatCtrl:FlushRewradView()
	if self.reward_view:IsOpen() then
		self.reward_view:Flush()
	end
end

function CityCombatCtrl:SetCityCombatFBTimeValue(value)
	self.fb_view:SetCityCombatFBTimeValue(value)
end

function CityCombatCtrl:ShowTequanTips(skill_name, skill_level, now_des, next_des, asset, bunble)
	self.tequan_tips_view:SetSkillName(skill_name)
	self.tequan_tips_view:SetSkillLevel(skill_level)
	self.tequan_tips_view:SetNowDes(now_des)
	self.tequan_tips_view:SetNextDes(next_des)
	self.tequan_tips_view:SetSkillRes(asset, bunble)
	self.tequan_tips_view:Open()
end

--前往膜拜
function CityCombatCtrl:GoWorship()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP) then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.ActivityNotOpen)
		return
	end


	local scene_id, x, y, range = self.data:GetWorshipScenIdAndPosXYAndRang()
	if scene_id < 0 or x < 0 or y < 0 or range < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.SceneError)
		return
	end

	local cur_scene_id = Scene.Instance:GetSceneId()
	local main_role = Scene.Instance:GetMainRole()
	local logic_x, logic_y = main_role:GetLogicPos()
	if cur_scene_id == scene_id and logic_x >= x + 8 and logic_x <= x + 15 and logic_y >= y - 6 and logic_y <= y + 6 then
		return
	end

	ViewManager.Instance:Close(ViewName.CityCombatView)
	GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
	GuajiCtrl.Instance:FlyToScenePos(scene_id, x, y, false, 0, true)
end

function CityCombatCtrl:FlushMvpName(param_t)
	if self.fb_view then
		self.fb_view:Flush(param_t)
	end
end

function CityCombatCtrl:GetIsBaiYe()
	if self.fb_view then
		return self.fb_view:GetIsBaiYe()
	end
	return false
end

