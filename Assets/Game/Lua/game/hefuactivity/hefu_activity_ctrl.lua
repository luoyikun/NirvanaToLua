require("game/hefuactivity/hefu_activity_data")
require("game/hefuactivity/hefu_activity_view")

HefuActivityCtrl = HefuActivityCtrl or BaseClass(BaseController)

function HefuActivityCtrl:__init()
	if HefuActivityCtrl.Instance ~= nil then
		print_error("[HefuActivityCtrl] Attemp to create a singleton twice !")
	end

	HefuActivityCtrl.Instance = self
	self.view = HefuActivityView.New(ViewName.HefuActivityView)
	self.boss_view = CombineServerBossView.New(ViewName.CombineServerBossView)
	self.data = HefuActivityData.New()
	-- self.scene_load_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SceneLoadComplete, self))
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDay, self))
	self:RegisterAllProtocols()

end

function HefuActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.boss_view then
		self.boss_view:DeleteMe()
		self.boss_view = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)

	HefuActivityCtrl.Instance = nil
end

function HefuActivityCtrl:GetView()
	return self.view
end

function HefuActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCSASubActivityState, "OnCSASubActivityState")					--合服活动子活动状态
	self:RegisterProtocol(SCCSAActivityInfo, "OnCSAActivityInfo")
	self:RegisterProtocol(SCCSARoleInfo, "OnCSARoleInfo")
	self:RegisterProtocol(SCCSARollResult, "OnCSARollResult")
	self:RegisterProtocol(SCCSABossInfo, "OnSCCSABossInfo")
	self:RegisterProtocol(SCCSABossRankInfo, "OnSCCSABossRankInfo")
	self:RegisterProtocol(SCCSABossRoleInfo, "OnSCCSABossRoleInfo")
	self:RegisterProtocol(SCCSATouzijihuaInfo, "OnSCCSATouzijihuaInfo")
	

	self:RegisterProtocol(CSCSAQueryActivityInfo)
	self:RegisterProtocol(CSCSARoleOperaReq)

	--合服基金
	self:RegisterProtocol(SCCSAFoundationInfo, "OnSCCSAFoundationInfo")
end

function HefuActivityCtrl:SendCSAQueryActivityInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCSAQueryActivityInfo)
	protocol:EncodeAndSend()
end

function HefuActivityCtrl:OnSCCSAFoundationInfo(protocol)
	self.data:SetFoundationData(protocol)
	KaifuActivityCtrl.Instance:FlushView()
end

--合服活动角色操作请求
function HefuActivityCtrl:SendCSARoleOperaReq(sub_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCSARoleOperaReq)
	protocol.sub_type = sub_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

--合服活动子活动状态
function HefuActivityCtrl:OnCSASubActivityState(protocol)
	self.data:SetCombineSubActivityState(protocol)
	-- self:UpdataViewAndRemind()
	-- self:UpdataMaiuiIcon()
	if self.view:IsOpen() then
		self.view:Flush()
	end

	KaifuActivityCtrl.Instance:FlushView()
end

--合服活动角色信息
function HefuActivityCtrl:OnCSARoleInfo(protocol)
	self.data:SetCombineRoleInfo(protocol)
	self.data:SetQiangGouBuyNumList(protocol.rank_qianggou_buynum_list)
	self.data:SetKillBossCount(protocol.kill_boss_kill_count)
	self.data:SetRollChongZhiCount(protocol.roll_chongzhi_num, protocol.roll_total_chongzhi_num)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	KaifuActivityCtrl.Instance:FlushView()
	RemindManager.Instance:Fire(RemindName.LucklyTurn)
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

--合服活动信息
function HefuActivityCtrl:OnCSAActivityInfo(protocol)
	self.data:SetQiangGouAllBuyNumList(protocol.qianggou_buynum_list)
	self.data:SetQiangGouRankList(protocol.rank_item_list[1].user_list)
	self.data:SetCityContendWinnerInfo(protocol.csa_gcz_winner_roleid)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	KaifuActivityCtrl.Instance:FlushView()
	self.data:SetCombineActivityInfo(protocol)
	-- self:UpdataViewAndRemind()
end

--合服活动摇奖结果
function HefuActivityCtrl:OnCSARollResult(protocol)
	self.data:SetCombineRollResult(protocol)
	if self.view:IsOpen() then
		self.view:Flush("luckly")
	end
	KaifuActivityCtrl.Instance:FlushView("luckly")
end

--合服Boss信息
function HefuActivityCtrl:OnSCCSABossInfo(protocol)
	self.data:SetCombineBossInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.boss_view:IsOpen() then
		self.boss_view:Flush()
	end
end

--合服Boss排行榜
function HefuActivityCtrl:OnSCCSABossRankInfo(protocol)
	self.data:SetCombineBossRank(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.boss_view:IsOpen() then
		self.boss_view:Flush()
	end
end

--合服Boss击杀
function HefuActivityCtrl:OnSCCSABossRoleInfo(protocol)
	self.data:SetCombineBossKillNum(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.boss_view:IsOpen() then
		self.boss_view:Flush()
	end
end

function HefuActivityCtrl:ServerOpenDay(cur_day, is_new_day)
	if not is_new_day or IS_ON_CROSSSERVER then return end

	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
end

-- 合服投资
function HefuActivityCtrl:OnSCCSATouzijihuaInfo(protocol)
	self.data:SendTouZiInfo(protocol)
	local kaifu_view = KaifuActivityCtrl.Instance:GetView()
	kaifu_view:Flush()
	KaifuActivityCtrl.Instance:FlushHeFuTouZiView()
end

----------End 合服投资