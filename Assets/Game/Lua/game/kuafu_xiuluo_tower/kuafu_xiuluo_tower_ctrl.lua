require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_data")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_fuben_info_view")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_rank_list")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_buy_view")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_rank_plane")

KuaFuXiuLuoTowerCtrl = KuaFuXiuLuoTowerCtrl or BaseClass(BaseController)

function KuaFuXiuLuoTowerCtrl:__init()
	if nil ~= KuaFuXiuLuoTowerCtrl.Instance then
		print_error("[KuaFuXiuLuoTowerCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuXiuLuoTowerCtrl.Instance = self
	self.data = KuaFuXiuLuoTowerData.New()
	self.buy_view = KuaFuXiuLuoTowerBuyView.New(ViewName.FuXiuLuoTowerBuffView)
	self.fuben_info_view = KuaFuXiuLuoTowerFuBenInfoView.New()
	self.xiuluo_rank_view = KuaFuXiuLuoTowerRankView.New()
	self:RegisterAllProtocols()
end

function KuaFuXiuLuoTowerCtrl:__delete()
	if nil ~= self.buy_view then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end
	if nil ~= self.fuben_info_view then
		self.fuben_info_view:DeleteMe()
		self.fuben_info_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if nil ~= self.xiuluo_rank_view then
		self.xiuluo_rank_view:DeleteMe()
		self.xiuluo_rank_view = nil
	end
	KuaFuXiuLuoTowerCtrl.Instance = nil
end

-- 注册协议
function KuaFuXiuLuoTowerCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossXiuluoTowerSelfActivityInfo, "OnXiuLuoSelfInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerRankInfo, "OnXiuLuoRankInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerChangeLayerNotice, "OnXiuLuoLayerChange")
	self:RegisterProtocol(SCCrossXiuluoTowerUserResult, "OnXiuLuoUserResult")
	self:RegisterProtocol(SCCrossXiuluoTowerInfo, "OnXiuLuoInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerBuffInfo, "OnXiuLuoBuffInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerGatherInfo, "OnCrossXiuluoTowerGatherInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerDropLog, "OnXiuLuoTowerLog")
	self:RegisterProtocol(SCCossXiuluoTowerRankTitleInfo, "OnCossXiuluoTowerRankTitleInfo")
	self:RegisterProtocol(SCCossXiuluoTowerBossInfo, "OnCossXiuluoTowerBossInfo")
end

--发送进入修罗塔副本
function KuaFuXiuLuoTowerCtrl:SendEnterXiuLuoTowerFuBen(protocol)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_XIULUO_TOWER)
end

function KuaFuXiuLuoTowerCtrl:OnCossXiuluoTowerBossInfo(protocol)
	self.data:SetCossXiuluoTowerBossInfo(protocol)
	local boss_num = KuaFuXiuLuoTowerData.Instance:GetBossNum()
	if boss_num > 0 then
		local text = ""
		if protocol.max_hp > 0 then
			text = (math.floor(protocol.cur_hp / protocol.max_hp * 100 * 100) / 100) .. "%"
		end
		FuBenCtrl.Instance:ShowMonsterHadFlush(true, text)
	else
		FuBenCtrl.Instance:ShowMonsterHadFlush(false)
	end
end

--跨服修罗塔个人活动信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoSelfInfo(protocol)
	self.data:OnXiuLuoSelfInfo(protocol)
	self.fuben_info_view:OnSelfInfoChange()
	self.data:IsShowTitle(protocol.gather_buff_end_timestamp)
	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if fuben_icon_view:IsOpen() then
		fuben_icon_view:SetXiuLuoBuffBubblesText()
	end
end

function KuaFuXiuLuoTowerCtrl:OnCossXiuluoTowerRankTitleInfo(protocol)
	self.data:SetCossXiuluoTowerRankInfo(protocol)
	if self.xiuluo_rank_view then
		self.xiuluo_rank_view:Flush()
	end
end
--跨服修罗塔排行榜信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoRankInfo(protocol)
	self.data:SetRankList(protocol)
	self.fuben_info_view:FlushRank()
end

--跨服修罗塔改变层提示
function KuaFuXiuLuoTowerCtrl:OnXiuLuoLayerChange(protocol)
	self.fuben_info_view:OnLayerChange(protocol)
end

--跨服修罗塔属性加成
function KuaFuXiuLuoTowerCtrl:OnXiuLuoInfo(protocol)
	self.data:SetAttrInfo(protocol)
	self.buy_view:Flush()
end

--跨服修罗塔BUFF信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoBuffInfo(protocol)
	self.data:SetBuffInfo(protocol)
end

--跨服修罗塔结果
function KuaFuXiuLuoTowerCtrl:OnXiuLuoUserResult(protocol)
	GlobalTimerQuest:AddDelayTimer(function()
		local data = FuBenData.Instance:GetFBDropInfo()
		if data then
			local item_list = {}
			-- local rongyao_item = KuaFuXiuLuoTowerData.Instance:GetRongYaoReward()
			item_list.reward_list = TableCopy(data.item_list)
			-- if rongyao_item then
			-- 	for k,v in pairs(rongyao_item) do
			-- 		table.insert(item_list.reward_list, v)
			-- 	end
			-- end
			TipsCtrl.Instance:OpenActivityRewardTip(item_list)
		end
	end, 0)
end
local inx = 0
--请求积分奖励
function KuaFuXiuLuoTowerCtrl:SendGetScoreReward()
	local can_get, result = KuaFuXiuLuoTowerData.Instance:GetCanGetReward()
	if can_get then
		local protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerScoreRewardReq)
		protocol.index = inx
		inx = inx + 1
		if inx > 5 then
			inx = 0
		end
		protocol:EncodeAndSend()
	else
		if result == 0 then
			--积分不足
			TipsCtrl.Instance:ShowSystemMsg(Language.XiuLuo.NotEnoughScore)
		elseif result == 1 then
			--已领取全部
			TipsCtrl.Instance:ShowSystemMsg(Language.XiuLuo.HaveGotAll)
		end
	end
end

-- 跨服修罗塔购买buff
function KuaFuXiuLuoTowerCtrl:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerBuyBuff)
	send_protocol.is_buy_realive_count = is_buy_realive_count
	send_protocol.is_use_gold_bind = is_use_gold_bind
	send_protocol:EncodeAndSend()
end

function KuaFuXiuLuoTowerCtrl:SendCrossXiuluoTowerLog()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerDropLog)
	send_protocol:EncodeAndSend()
end

function KuaFuXiuLuoTowerCtrl:OpenFubenView()
	if self.fuben_info_view then
		self.fuben_info_view:Open()
	end
end

function KuaFuXiuLuoTowerCtrl:CloseFubenView()
	if self.fuben_info_view then
		self.fuben_info_view:Close()
	end
end

function KuaFuXiuLuoTowerCtrl:OnCrossXiuluoTowerGatherInfo(protocol)
	self.data:SetGatherInfo(protocol)
	if self.fuben_info_view then
		self.fuben_info_view:Flush()
	end
end

function KuaFuXiuLuoTowerCtrl:OnXiuLuoTowerLog(protocol)
	self.data:SendXiuLuoTowerLog(protocol)
	ViewManager.Instance:Open(ViewName.TipsRecordView)
end

function KuaFuXiuLuoTowerCtrl:OpenTimeRankList()
	if self.xiuluo_rank_view then
		self.xiuluo_rank_view:Open()
		self.xiuluo_rank_view:Flush()
	end
end

function KuaFuXiuLuoTowerCtrl:SetMonsterClickGo()
	if self.fuben_info_view then
		self.fuben_info_view:ClickBoss()
	end
end