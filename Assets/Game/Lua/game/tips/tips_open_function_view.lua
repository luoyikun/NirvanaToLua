TipOpenFunctionView = TipOpenFunctionModelView or BaseClass(BaseView)

OPEN_FUNCTION_TYPE =
{
	MOUNT = 0, 			--坐骑
	WING = 1,			--羽翼
	HALO = 2,			--光环
	SHEN_GONG = 3,		--神弓
	SHEN_YI = 4,		--神翼
	GODDESS = 5,		--女神
	SPIRIT = 6,			--精灵
	ZHIBAO = 7,			--至宝
	MEDAL = 8,			--勋章
	GODDESS_HALO = 9,	--女神守护
}

OPEN_FUNCTION_TYPE_ID =
{
	MOUNT = 30, 			--坐骑
	WING = 40,				--羽翼
	HALO = 60,				--光环
	SHEN_GONG = 80,			--神弓
	SHEN_YI = 110,			--神翼
	GODDESS = 120,			--女神
	SPIRIT = 130,			--精灵
	ZHIBAO = 160,			--至宝
	MEDAL = 200,			--勋章
}

FUNCTION_NAME =
{
	MOUNT = "mount",
	WING = "wing",
	HALO = "halo",
	SHEN_GONG = "shen_gong",
	SHEN_YI = "shen_yi",
	XIAN_NV = "xian_nv",
	SPRITE = "sprite",
	ZHI_BAO = "zhi_bao",
	XUN_ZHANG = "xun_zhang",
}

function TipOpenFunctionView:__init()
	self.ui_config = {{"uis/views/tips/openfunctiontips_prefab", "OpenFunctionTips"}}
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/other", self.audio_config.other[1].Rewards)
	end
	self.is_modal = true
	self.view_layer = UiLayer.Pop
	self.is_async_load = true
end

--写在open中是因为需要解决打开界面时会有延迟,而导致停下任务也有延迟的问题。
function TipOpenFunctionView:Open(index)
	BaseView.Open(self, index)
	TaskCtrl.Instance:SetAutoTalkState(false)
end

function TipOpenFunctionView:LoadCallBack()
	self.model_display = self.node_list["model_display"]
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.model_display.ui3d_display, MODEL_CAMERA_TYPE.TIPS)
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.RewardOnClick, self))
end

function TipOpenFunctionView:ReleaseCallBack()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	-- 清理变量和对象
	self.model_display = nil
end

function TipOpenFunctionView:SetData(panel_name ,res_type)
	self.panel_name = panel_name
	self.res_type = res_type
end

function TipOpenFunctionView:OpenCallBack()
	self:Flush()
end

function TipOpenFunctionView:CloseCallBack()
	if self.cal_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
	end
	local cfg = OpenFunData.Instance:GetSingleCfg(self.panel_name)
	TaskCtrl.Instance:SetAutoTalkState(true)
	MainUICtrl.Instance:GetView():FlyToDict(cfg)
end

function TipOpenFunctionView:OnFlush()
	if self.panel_name ~= nil then
		self:SetModle()
		self:CalTime()
	end
end

function TipOpenFunctionView:SetModle()
	if self.model_view == nil then
		return
	end
	local cfg = OpenFunData.Instance:GetSingleCfg(self.panel_name)
	if nil == cfg then return end
	self.model_view:SetRotation(Vector3(0, 0, 0))
	local display_type = 0
	if cfg.res_type == "Goddess" then
		display_type = DISPLAY_TYPE.XIAN_NV
	elseif cfg.res_type == "Halo" then
		display_type = DISPLAY_TYPE.HALO
	elseif cfg.res_type == "Spirit" then
		display_type = DISPLAY_TYPE.SPIRIT
	elseif cfg.res_type == "Mount" then
		display_type = DISPLAY_TYPE.MOUNT
		self.model_view:SetRotation(Vector3(0, -50, 0))
	elseif cfg.res_type == "Wing" then
		display_type = DISPLAY_TYPE.WING
	elseif cfg.res_type == "Shenyi" then
		display_type = DISPLAY_TYPE.XIAN_NV
	elseif cfg.res_type == "Shengong" then
		display_type = DISPLAY_TYPE.XIAN_NV
	end
	if cfg.res_type == "Goddess" then
		local info = {}
		info.role_res_id = cfg.res_id
		info.wing_res_id = 13008
		self.model_view:SetGoddessModelResInfo(info)
	elseif cfg.res_type == "Shenyi" then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId() or -1
		info.wing_res_id = cfg.res_id or -1
		self.model_view:SetGoddessModelResInfo(info)
	elseif cfg.res_type == "Shengong" then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId() or -1
		info.weapon_res_id = cfg.res_id or -1
		self.model_view:SetGoddessModelResInfo(info)
	elseif cfg.res_type == "Halo" then
		local vo = TableCopy(GameVoManager.Instance:GetMainRoleVo())
		vo.appearance.halo_used_imageid = HaloData.Instance:GetImageIdByRes(cfg.res_id)
		self.model_view:SetModelResInfo(vo, true, true, nil, true)
	else
		self.model_view:SetMainAsset(ResPath["Get"..self.res_type.."Model"](cfg.res_id))
	end
end

function TipOpenFunctionView:RewardOnClick()
	self:Close()
	if self.cal_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
	end
end

function TipOpenFunctionView:CalTime()
	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal >= 0 then
			local str = string.format(Language.TipsOpenFunction.Time, math.floor(timer_cal))
			self.node_list["TxtRemainTime"].text.text = str
		end
		if timer_cal < 0 then
			self:RewardOnClick()
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end