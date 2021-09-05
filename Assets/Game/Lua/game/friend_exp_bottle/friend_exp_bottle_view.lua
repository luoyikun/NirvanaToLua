FriendExpBottleView = FriendExpBottleView or BaseClass(BaseView)

-- 界面逻辑说明：点击后发送请求协议，随后收到协议数据，随后刷新界面，只要界面没有关闭，每三十秒发送一次请求协议
-- 点击逻辑说明: 点击领取,只要满足条件,发送协议,随后收到协议数据，刷新界面;点击征集好友，发送协议，随后关闭该点击按钮，时间满足后，打开该按钮
function FriendExpBottleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/friendexpbottle_prefab", "FriendExpBottleView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.show_flag = true
end

function FriendExpBottleView:__delete()
end

function FriendExpBottleView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(725, 537, 0)
	self.node_list["Txt"].text.text = Language.Title.JingYanPing

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["NeedFriendButton"].button:AddClickListener(BindTool.Bind(self.OnClickNeedFriend, self))
	self.node_list["GetExpButton"].button:AddClickListener(BindTool.Bind(self.OnClickGetExp, self))
	-- other中包括经验总量，好友加成(不会改变的值)

	self.friend_add = FriendExpBottleData.Instance:GetFriendAdd()
	self.bottle_cfg = FriendExpBottleData.Instance.exp_bottle_limit
	self.efficiency = FriendExpBottleData.Instance:GetPerMinuteExp()

	self.role_id = GameVoManager.Instance:GetMainRoleVo().role_id
end

function FriendExpBottleView:ReleaseCallBack()
	if self.flush_timer then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

	if self.flag_timer then
		GlobalTimerQuest:CancelQuest(self.flag_timer)
		self.flag_timer = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	if self.count ~= nil then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	
	self.total_exp = nil
	self.friend_add = nil
	self.bottle_cfg = nil
	self.efficiency = nil
end

-- 打开界面刷新
function FriendExpBottleView:OpenCallBack()
	self.friend_num = FriendExpBottleData.Instance:GetFriendNum()
	--代表气泡的初始状态
	self.open_qipao = false
	if not FriendExpBottleData.Instance:CanGetExp(self.friend_num) then
		-- self.node_list["NeedFriendButtonNode"]:SetActive(true)
		self.open_qipao = true
	end
	self.show_flag = true

	self.flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 30)
	FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.RequireFlush)

	local show_get_btn = FriendExpBottleData.Instance:BottleFull() and FriendExpBottleData.Instance:CanGetExp(self.friend_num)
	if show_get_btn then
		if PlayerPrefsUtil.GetInt(tostring(self.role_id)) == 0 then
		self.node_list["GetExpButtonNode"]:SetActive(true)
		self.node_list["NeedFriendButtonNode"]:SetActive(false)
		PlayerPrefsUtil.SetInt(tostring(self.role_id), 1)
		end
	elseif PlayerPrefsUtil.GetInt(tostring(self.role_id)) == 0 then
		self.node_list["GetExpButtonNode"]:SetActive(false)
		self.node_list["NeedFriendButtonNode"]:SetActive(true)
		PlayerPrefsUtil.SetInt(tostring(self.role_id), 2)
	else
		self.node_list["GetExpButtonNode"]:SetActive(false)
		self.node_list["NeedFriendButtonNode"]:SetActive(false)
	end

	if show_get_btn and PlayerPrefsUtil.GetInt(tostring(self.role_id)) == 2 then
		self.node_list["GetExpButtonNode"]:SetActive(true)
		self.node_list["NeedFriendButtonNode"]:SetActive(false)
		PlayerPrefsUtil.SetInt(tostring(self.role_id), 3)
	end
end

function FriendExpBottleView:FlushNextTime()
	FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.RequireFlush)
end

function FriendExpBottleView:Closen()
	self:Close()
end

function FriendExpBottleView:CloseCallBack()
end

-- 初始化会变化的数据
function FriendExpBottleView:InitData()
	self.cur_exp = FriendExpBottleData.Instance:GetCurExp()
	self.friend_num = FriendExpBottleData.Instance:GetFriendNum()
	self.total_exp = FriendExpBottleData.Instance:GetToTalExp()
end

function FriendExpBottleView:OnFlush()
	self:InitData()
	if FriendExpBottleData.Instance:IsMaxTimes() then
		self:Close()
		return
	end
	self.remind_time = self:CalculateTime()
	local time_cfg = TimeUtil.Format2TableDHM(self.remind_time * 60)
	self.hour = time_cfg.hour
	self.min = time_cfg.min
	self:ShowView()
	self:SetDataView()
end

-- 计算剩余时间
function FriendExpBottleView:CalculateTime()
	local efficiency = self.efficiency + self.friend_num * self.friend_add
	return math.floor((self.total_exp - self.cur_exp) / efficiency)
end

-- 界面数据显示
function FriendExpBottleView:SetDataView()
	self.node_list["TxtContent2"].text.text = self.friend_add
	self.node_list["TxtExpBottle"].text.text = string.format(self.cur_exp)
	self.node_list["TxtContent1"].text.text = string.format(Language.ExpBottle.CurEffet, self.efficiency, self.friend_num * self.friend_add)
	-- self.node_list["TxtGetExpButton2"].text.text = string.format(Language.ExpBottle.NeedTime, self.hour, self.min)
	self.node_list["SliderProgressBG"].slider.value = self.cur_exp / self.total_exp
	self.node_list["TxtNeedFriendButton1"].text.text = string.format(Language.ExpBottle.LeastTime, math.floor(FriendExpBottleData.Instance:ColdTime()))
	if FriendExpBottleData.Instance:IsMaxTimes() then
		self.node_list["TxtGetExpButton1"].text.text = string.format(Language.ExpBottle.FriendValue, ToColorStr(self.friend_num,TEXT_COLOR.RED), Language.ExpBottle.Limit)

	else
		local need_friend_number = FriendExpBottleData.Instance:GetFriendLimit()
		local friend_number = ""
		if need_friend_number > self.friend_num then
			friend_num = ToColorStr(self.friend_num,TEXT_COLOR.RED)
		else
			friend_num = ToColorStr(self.friend_num,TEXT_COLOR.GREEN_4)
		end
		self.node_list["TxtGetExpButton1"].text.text = string.format(Language.ExpBottle.FriendValue, friend_num, need_friend_number)
	end
end

-- 界面的显示状态设置
function FriendExpBottleView:ShowView()
	local show_get_btn = FriendExpBottleData.Instance:BottleFull() and FriendExpBottleData.Instance:CanGetExp(self.friend_num)
	UI:SetButtonEnabled(self.node_list["GetExpButton"], show_get_btn and not FriendExpBottleData.Instance:IsMaxTimes())
	self.node_list["GetExpButtonEffect"]:SetActive(show_get_btn)

	self.node_list["TxtGetExpButton1"]:SetActive(not show_get_btn)
	if self.open_qipao and show_get_btn then
		self.open_qipao = false
		-- self.node_list["NeedFriendButtonNode"]:SetActive(false)
	end
	if FriendExpBottleData.Instance:ColdTimeEnd() then
		self.cold_time_end = true
	else
		self.cold_time_end = false
		self.delay_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.DelayTime, self), 1)
	end
	local show_need_friend = self.show_flag and self.cold_time_end
	self.node_list["TxtNeedFriendButton1"]:SetActive(not show_need_friend)
	-- self.node_list["TxtGetExpButton2"]:SetActive(not FriendExpBottleData.Instance:BottleFull())
	self.node_list["TxtGetExpButton1"]:SetActive(FriendExpBottleData.Instance:BottleFull())
	UI:SetButtonEnabled(self.node_list["NeedFriendButton"], show_need_friend)
end

function FriendExpBottleView:OnClickNeedFriend()
	FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.NeedFriend)
	self.node_list["NeedFriendButtonNode"]:SetActive(false)
	self.show_flag = false
	self.delay_time = 10
	self.node_list["TxtNeedFriendButton1"].text.text = string.format(Language.ExpBottle.LeastTime, self.delay_time)
	self.flag_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.WaitNextTime, self), 1)
	self:ShowView()
end

function FriendExpBottleView:WaitNextTime()
	self.delay_time = self.delay_time - 1
	self.node_list["TxtNeedFriendButton1"].text.text = string.format(Language.ExpBottle.LeastTime, self.delay_time)
	if self.delay_time == 0 then
		self:TimeEndCallBack()
		self.delay_time = 10
		if self.flag_timer then
			GlobalTimerQuest:CancelQuest(self.flag_timer)
			self.flag_timer = nil
		end
	end
end

function FriendExpBottleView:DelayTime()
	if FriendExpBottleData.Instance:ColdTime() == 0 then
		if self.delay_timer then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
			self:ShowView()
		end
	else
		if self.node_list["TxtNeedFriendButton1"] then
			self.node_list["TxtNeedFriendButton1"].text.text = string.format(Language.ExpBottle.LeastTime, math.floor(FriendExpBottleData.Instance:ColdTime()))
		end
	end
end

function FriendExpBottleView:TimeEndCallBack()
	self.show_flag = true
	self:ShowView()
end

function FriendExpBottleView:OnClickGetExp()
	if PlayerPrefsUtil.GetInt(tostring(self.role_id)) == 1 then
		self.node_list["NeedFriendButtonNode"]:SetActive(true)
		PlayerPrefsUtil.SetInt(tostring(self.role_id), 3)
	else
		self.node_list["NeedFriendButtonNode"]:SetActive(false)
	end
	self.node_list["GetExpButtonNode"]:SetActive(false)
	FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.GetExp)

	if self.count == nil then
		self.count = CountDown.Instance:AddCountDown(1, 0.5, function ()
			local role_vo = PlayerData.Instance:GetRoleVo()
			self.node_list["slider"].slider.value = role_vo.exp / role_vo.max_exp
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guangdian1")
			TipsCtrl.Instance:ShowFlyEffectManager(ViewName.FriendExpBottleView, bundle_name, asset_name, 
				self.node_list["originObj"], self.node_list["targetObj"], nil, 1)
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
			end)
	end
end