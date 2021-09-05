require("game/kuafu_borderland_act/kuafu_borderland_data")
require("game/kuafu_borderland_act/kuafu_borderland_view")
require("game/kuafu_borderland_act/kuafu_borderland_zhaoji_view")

KuaFuBorderlandCtrl = KuaFuBorderlandCtrl or BaseClass(BaseController)

function KuaFuBorderlandCtrl:__init()
	if KuaFuBorderlandCtrl.Instance then
		print_error("[KuaFuBorderlandCtrl]:Attempt to create singleton twice!")
	end
	KuaFuBorderlandCtrl.Instance = self

	self.data = KuaFuBorderlandData.New()
	self.view = KuaFuBorderlandView.New(ViewName.KuaFuBorderland)
	self.zhaoji_view = KuaFuBorderlandZhaojiView.New()

	self:RegisterAllProtocols()
end

function KuaFuBorderlandCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.kf_borderland_count_down then
		CountDown.Instance:RemoveCountDown(self.kf_borderland_count_down)
		self.kf_borderland_count_down = nil
	end

	KuaFuBorderlandCtrl.Instance = nil
end

function KuaFuBorderlandCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossBianJingZhiDiUserInfo, "OnSCCrossBianJingZhiDiUserInfo")
	self:RegisterProtocol(SCCrossBianJingZhiDiBossInfo, "OnSCCrossBianJingZhiDiBossInfo")
	self:RegisterProtocol(SCCrossBianJingZhiDiBossHurtInfo, "OnSCCrossBianJingZhiDiBossHurtInfo")
	self:RegisterProtocol(SCCrossServerBianJingZhiDiBossInfo, "OnSCCrossServerBianJingZhiDiBossInfo")
end

function KuaFuBorderlandCtrl:OnSCCrossBianJingZhiDiUserInfo(protocol)
	self.data:SetSCCrossBianJingZhiDiUserInfo(protocol)
	self:OperateBuffChange(protocol.gather_buff_time)
	self:IsShowTitle(protocol.gather_buff_time)
	self.view:Flush()

	-- 屏蔽无敌采集
	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if fuben_icon_view and fuben_icon_view:IsOpen() then
		fuben_icon_view:Flush()
	end
end

function KuaFuBorderlandCtrl:OnSCCrossBianJingZhiDiBossInfo(protocol)
	self.data:SetSCCrossBianJingZhiDiBossInfo(protocol)
	self.view:Flush()
end

function KuaFuBorderlandCtrl:OnSCCrossBianJingZhiDiBossHurtInfo(protocol)
	self.data:SetSCCrossBianJingZhiDiBossHurtInfo(protocol)
	self.view:Flush("flush_rank")
end

function KuaFuBorderlandCtrl:OperateBuffChange(new_buff_time)
	if new_buff_time then
		local now_time = TimeCtrl.Instance:GetServerTime()
		local seconds = math.floor(new_buff_time - now_time) or 0
		if seconds >= 0 then
			local main_role = Scene.Instance:GetMainRole()
			main_role:ChangeWuDiGather(1, SceneType.KF_Borderland)
		end
	end
end

function KuaFuBorderlandCtrl:IsShowTitle(time)
	if nil == time then
		time = 0
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local seconds = math.floor(time - now_time)
	if self.kf_borderland_count_down then
		CountDown.Instance:RemoveCountDown(self.kf_borderland_count_down)
		self.kf_borderland_count_down = nil
	end
	self.kf_borderland_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.TitleBuffTimeCountDown, self))
end

function KuaFuBorderlandCtrl:TitleBuffTimeCountDown(elapse_time, total_time)
	local diff_timer = total_time - elapse_time
	if diff_timer <= 0 then
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeWuDiGather(0, SceneType.KF_Borderland)
		if self.kf_borderland_count_down then
			CountDown.Instance:RemoveCountDown(self.kf_borderland_count_down)
			self.kf_borderland_count_down = nil
		end
	end
end

-- 跨服边境之地买buff
function KuaFuBorderlandCtrl:SendCSCrossBianJingZhiDiBuyBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossBianJingZhiDiBuyBuff)
	protocol:EncodeAndSend()
end

-- 跨服边境BOSS信息
function KuaFuBorderlandCtrl:SendCSCrossBianJingZhiDiBossInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerBianJingZhiDiBossInfoReq)
	protocol:EncodeAndSend()
end

function KuaFuBorderlandCtrl:OnSCCrossServerBianJingZhiDiBossInfo(protocol)
	self.data:SetSCCrossServerBianJingZhiDiBossInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Map, "global_map")
end


function KuaFuBorderlandCtrl:OpenKFBorderlandZhaojiView(protocol)
			self.zhaoji_view:Open()
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- if vo and vo.role_id == protocol.member_uid then
	-- 	return
	-- end
	-- if Scene.Instance:GetSceneType() == SceneType.KF_Borderland then
	-- 	KuaFuBorderlandData.Instance:SetKFBorderlandZhaojiData(protocol)

	-- 	if not self.zhaoji_view:IsOpen() then
	-- 		self.zhaoji_view:Open()
	-- 	end
	-- end
end
