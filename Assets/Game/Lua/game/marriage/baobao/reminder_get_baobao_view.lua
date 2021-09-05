-- 提示对方领取宝宝
ReminderGetBaobaoView = ReminderGetBaobaoView or BaseClass(BaseView)
function ReminderGetBaobaoView:__init()
	self.ui_config = {
		{"uis/views/marriageview/baobao_prefab", "ReminderGetBaobaoView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = true
	self.is_modal = true
	self.is_check_reduce_mem = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.protocol_param_1 = nil
end

function ReminderGetBaobaoView:ReleaseCallBack()
	if self.baobao_model then
		self.baobao_model:DeleteMe()
		self.baobao_model = nil
	end
end

function ReminderGetBaobaoView:__delete()
	self.protocol_param_1 = nil
end

function ReminderGetBaobaoView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGetBaobao, self))
	
	self.baobao_model = RoleModel.New()
	self.baobao_model:SetDisplay(self.node_list["BaobaoDisplay"].ui3d_display)
end

-- 点击获取宝宝
function ReminderGetBaobaoView:OnClickGetBaobao()
	BaobaoCtrl.Instance:SendBabyBlessRet(self.protocol_param_1, 1)
	self:Close()
end


function ReminderGetBaobaoView:SetData(param1)
	self.protocol_param_1 = param1
	self:Flush()
end

function ReminderGetBaobaoView:OpenCallBack()
	self:Flush()
end

function ReminderGetBaobaoView:OnFlush(param_list)
	local baobao_cfg = BaobaoData.Instance:GetBabyInfoCfg(self.protocol_param_1 - 1)
	if not baobao_cfg then
		return
	end

	self.node_list["TextTip"].text.text = string.format(Language.Marriage.BabyBornAlert, PlayerData.Instance.role_vo.lover_name or "", baobao_cfg and ToColorStr(baobao_cfg.name or "",BAOBAO_COLOR[self.protocol_param_1]))
	self.node_list["FightPower"].text.text = CommonDataManager.GetCapability(baobao_cfg) * 2

	local res_id = BaobaoData.BabyModel[baobao_cfg.id + 1] or BaobaoData.BabyModel[1]
	self.baobao_model:SetMainAsset(ResPath.GetSpiritModel(res_id))
	self.baobao_model:ResetRotation()
	self.baobao_model:SetRotation(Vector3(0, -30, 0))
end

