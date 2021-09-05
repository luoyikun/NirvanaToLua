require("game/tomb_explore/tomb_explore_data")
require("game/tomb_explore/tomb_explore_fb_view")

TombExploreCtrl = TombExploreCtrl or BaseClass(BaseController)

function TombExploreCtrl:__init()
	if TombExploreCtrl.Instance then
		print_error("[TombExploreCtrl] Attemp to create a singleton twice !")
	end
	TombExploreCtrl.Instance = self

	self.data = TombExploreData.New()
	self.fb_view = TombExploreFBView.New(ViewName.TombExploreFBView)

	self:RegisterAllProtocols()
end

function TombExploreCtrl:__delete()
	if self.fb_view then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.tomb_count_down then
		CountDown.Instance:RemoveCountDown(self.tomb_count_down)
		self.tomb_count_down = nil
	end

	TombExploreCtrl.Instance = nil
end

function TombExploreCtrl:RegisterAllProtocols()
	self:RegisterProtocol(ScWangLingExploreUserInfo, "SetTombFBInfo")
	self:RegisterProtocol(WangLingExploreBossInfo, "OnWangLingExploreBossInfo")
end

--玩家王陵探险信息
function TombExploreCtrl:SetTombFBInfo(protocol)
	self.data:SetTombFBInfo(protocol)
	self:OperateBuffChange(protocol.gather_buff_time)
	self:IsShowTitle(protocol.gather_buff_time)
	self.fb_view:Flush()

	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if fuben_icon_view and fuben_icon_view:IsOpen() then
		fuben_icon_view:Flush("tomb_explore_wudi")
	end
end

function TombExploreCtrl:NotifyNoBOSS()
	self.fb_view:Flush()
end

function TombExploreCtrl:GoToBoss()
	if self.fb_view ~= nil then
		self.fb_view:BOSSClick()
	end
end

function TombExploreCtrl:OnWangLingExploreBossInfo(protocol)
	self.data:SetWangLingExploreBossInfo(protocol)
	if self.fb_view and self.fb_view:IsOpen() then
		self.fb_view:FlushBossIcon()
	end
end

function TombExploreCtrl:OnTombBuyGatherBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWangLingExploreBuyBuff)
	protocol:EncodeAndSend()
end

function TombExploreCtrl:OperateBuffChange(new_buff_time)
	if new_buff_time then
		local now_time = TimeCtrl.Instance:GetServerTime()
		local seconds = math.floor(new_buff_time - now_time) or 0
		if seconds >= 0 then
			local main_role = Scene.Instance:GetMainRole()
			main_role:ChangeWuDiGather(1, SceneType.TombExplore)
		end
	end
end

function TombExploreCtrl:IsShowTitle(time)
	if nil == time then
		time = 0
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local seconds = math.floor(time - now_time)
	if self.tomb_count_down then
		CountDown.Instance:RemoveCountDown(self.tomb_count_down)
		self.tomb_count_down = nil
	end
	self.tomb_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.TitleBuffTimeCountDown, self))
end

function TombExploreCtrl:TitleBuffTimeCountDown(elapse_time, total_time)
	local diff_timer = total_time - elapse_time
	if diff_timer <= 0 then
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeWuDiGather(0, SceneType.TombExplore)
		if self.tomb_count_down then
			CountDown.Instance:RemoveCountDown(self.tomb_count_down)
			self.tomb_count_down = nil
		end
	end
end

