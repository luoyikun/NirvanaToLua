require("game/guild_fight/guild_fight_view")
require("game/guild_fight/guild_fight_data")
require("game/guild_fight/guild_fight_reward_view")
require("game/guild_fight/guild_fight_rank_view")

GuildFightCtrl = GuildFightCtrl or BaseClass(BaseController)

function GuildFightCtrl:__init()
	if GuildFightCtrl.Instance ~= nil then
		print_error("[GuildFightCtrl] attempt to create singleton twice!")
		return
	end
	GuildFightCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = GuildFightView.New()
	self.reward_view = GuildFightRewardView.New()
	self.rank_view = GuildFightRankView.New(ViewName.GuildFightRankView)
	self.data = GuildFightData.New()

	self:BindGlobalEvent(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoChange, self))
end

function GuildFightCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.reward_view ~= nil then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	if self.rank_view ~= nil then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	GuildFightCtrl.Instance = nil
end

function GuildFightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGBGlobalInfoNew, "OnGlobalInfo")
	self:RegisterProtocol(SCGBRoleInfoNew, "OnRoleInfo")

	--公会争霸
	self:RegisterProtocol(CSFetchGuildBattleDailyReward)
	self:RegisterProtocol(SCSendGuildBattleDailyRewardFlag, "OnSCSendGuildBattleDailyRewardFlag")
end

-- 公会争霸 全局信息（广播）
function GuildFightCtrl:OnGlobalInfo(protocol)
	self.data:SetGlobalInfo(protocol)
	self.view:Flush()
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_rank")

	if protocol.is_finish == 1 then
		if Scene.Instance:GetMainRole():IsDead() then
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
		end
		self.cg_list = {}
		self.cg_role_count = 0
		self.cg_complete_list = {}
		self.role_list = {}
		self.cg_cur_count = 0
		for i,v in ipairs(protocol.rank_list) do
			if i <= 5 and v.uid > 0 then
				self.cg_list[i] = v
				self.cg_role_count = self.cg_role_count + 1
			end
		end
		if self.cg_role_count > 0 then
			self.show_act_cg = true
			for k,v in pairs(self.cg_list) do
				CheckCtrl.Instance:SendQueryRoleInfoReq(v.uid)
			end
		else
			FuBenCtrl.Instance:SendExitFBReq()
		end
	end
end

function GuildFightCtrl:GetIsBaiYe()
	if self.view then
		return self.view:GetIsBaiYe()
	end
	return false
end

--角色信息返回
function GuildFightCtrl:RoleInfoChange(role_id, role_info)
	if self.show_act_cg then
		for k,v in pairs(self.cg_list) do
			if nil == self.role_list[k] and role_id == v.uid then
				self.role_list[k] = TipsData.Instance:GetBorrowVo(role_info)
				self.cg_cur_count = self.cg_cur_count + 1
			end
		end

		if self.cg_cur_count >= self.cg_role_count then
			self.show_act_cg = false
			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GUILDBATTLE)
			for i=1,5 do
				if nil == self.role_list[i] then
					self.role_list[i] = TipsData.Instance:GetBorrowVo(nil)
				end
				if bai_ye_cfg then
					self.role_list[i].pos_x = bai_ye_cfg["statue_pos_x" .. i] or 0
					self.role_list[i].pos_y = bai_ye_cfg["statue_pos_y" .. i] or 0
				end
			end

			local cg_bundle = "cg/w3_zc_xianmengzhengba_prefab"
			local cg_asset = "W3_ZC_XianMengZhengBa_cg01"
			Scene.Instance:CreateCgObj(self.role_list, function(index)
				if nil == self.cg_complete_list[index] then
					self.cg_complete_list[index] = index
				end
				if #self.cg_complete_list >= #self.role_list then
					if not CgManager.Instance:IsCgIng() and EndPlayCgSceneId[Scene.Instance:GetSceneId()] then
						CgManager.Instance:Play(BaseCg.New(cg_bundle, cg_asset), function() 
							local cg_obj_list = Scene.Instance:GetCgObjList()
							if nil ~= cg_obj_list and cg_obj_list[1] then
								cg_obj_list[1]:GetVo().mount_appeid = 1007
								cg_obj_list[1]:SetAttr("mount_appeid", 1007)
							end

							Scene.Instance:ClearUnuseCgObj()
							Scene.Instance:ResetCgObjListPos()
							self.role_list = {}
							self.cg_complete_list = {}
							self.view:SetBaiYeDownTime()
							GuildFightCtrl.Instance:FlushMvpName("bai_ye")
							self.view:SetRemindBubbleActive()
						end)
					end
				end
			end)
		end
	end
end

-- 公会争霸 个人信息
function GuildFightCtrl:OnRoleInfo(protocol)
	self.data:SetRoleInfo(protocol)
	self.view:Flush()
	if FuBenCtrl.Instance.fu_ben_icon_view and FuBenCtrl.Instance.fu_ben_icon_view:IsOpen() then
		FuBenCtrl.Instance.fu_ben_icon_view:FlushGuildZhaoJiRestTime(self.data:GetRemindZhaojiTimes() or 0)
	end
end

function GuildFightCtrl:OpenView()
	if self.view then
		self.view:Open()
	end
end

function GuildFightCtrl:CloseView()
	 self.view:Close()
	local is_finish = GuildFightData.Instance:GetGlobalInfo().is_finish
	if is_finish == 1 then
		self.reward_view:Open()
	end
end

function GuildFightCtrl:OpenRank()
	if self.view:IsOpen() then
		self:OpenRankView()
	end
end

function GuildFightCtrl:OnSCSendGuildBattleDailyRewardFlag(protocol)
	self.data:SetGuildBattleDailyRewardFlag(protocol)
	if TipsCtrl.Instance:GetGuildWarRewardView():IsOpen() then
		TipsCtrl.Instance:GetGuildWarRewardView():Flush()
	end
	TipsCtrl.Instance:FlushRewardTip()
	GuildCtrl.Instance:FlushGuildWarView()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	RemindManager.Instance:Fire(RemindName.GuildWar)
end

function GuildFightCtrl:SendGuildWarOperate(op_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchGuildBattleDailyReward)
	protocol.op_type = op_type or 0
	protocol:EncodeAndSend()
end

-- 召集召集
function GuildFightCtrl:QiuJiuHandler()
	if self.data:IsCanZhaoJi() then

		local cost = self.data:GetZhaoJiIndexCost() or 0
		local yes_func = function() self:SendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE) end
		local describe = string.format(Language.Guild.TuanZhanZhaoji) or ""

		if cost > 0 then
			describe = string.format(Language.Guild.TuanZhanCost, cost) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("guild_fight_sos_auto_buy", describe, yes_func, nil, nil, nil,nil,nil,true,false, nil)
			return
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ZhaoJiTimesZero)
	end
end

function GuildFightCtrl:SendGuildSosReq(sos_type)
	GuildCtrl.Instance:SendSendGuildSosReq(sos_type)
end

function GuildFightCtrl:OpenRankView()
	if self.rank_view then 
		self.rank_view:Open()
		self.rank_view:Flush()
	end
end

function GuildFightCtrl:FlushMvpName(param_t)
	if self.view then
		self.view:Flush(param_t)
	end
end