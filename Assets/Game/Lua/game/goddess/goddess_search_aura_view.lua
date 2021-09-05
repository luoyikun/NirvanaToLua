require("game/tips/ernie_view")
-- 寻灵视图
GoddessSearchAuraView = GoddessSearchAuraView or BaseClass(BaseView)

function GoddessSearchAuraView:__init()
	self.ui_config = {{"uis/views/aurasearchview_prefab", "GoddessSearchAuraView"}}
	self.play_audio = true
	self.is_Rolling = false
	self.ling_count = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GoddessSearchAuraView:InitScroller()
	self.scroller_list = {}
	local value_list = GoddessData.Instance:GetAuraSearchListInfo()
	for i = 1, 6 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self.node_list["Aura_" .. i]
		self.scroller_list[i].cell = AuraScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
		if value_list ~= nil and value_list[i - 1] ~= nil then
			self.scroller_list[i].cell:SetData({index = value_list[i - 1], key = "start"})
		end
	end

	local num = 0
	if value_list ~= nil then
		for k,v in pairs(value_list) do
			if v == 0 then
				num = num + 1
			end
		end
	end
	self:ShowReward(num)
end


function GoddessSearchAuraView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnReceive"].button:AddClickListener(BindTool.Bind(self.Receive, self))
	self.node_list["BtnSearch"].button:AddClickListener(BindTool.Bind(self.Roll, self))
	self.node_list["BtnHelpButton"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.node_list["SkipToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.SkipAnimation, self))
	self.node_list["DoubleReceiveToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.DoubleReceive, self))


	self.node_list["SkipToggle"].toggle.isOn = GoddessData.Instance:GetAuraAnimationStatus()
	self.node_list["DoubleReceiveToggle"].isOn = GoddessData.Instance:GetAuraDoubleReceive()

	self:InitScroller()
end

function GoddessSearchAuraView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(206)
end

function GoddessSearchAuraView:OpenCallBack()
	local last_info = GoddessData.Instance:GetAuraSearchListInfo()
	self:FlushFreeTimes()
	self:FlushShengYuNums()
	self:FlushReceivedTime()

	local data = GoddessData.Instance:GetAuraSearchListInfo()
	self.ling_count = 0
	for i = 1, 6 do
		if data[i - 1] == 0 then
			self.ling_count = self.ling_count + 1
		end
	end
end

function GoddessSearchAuraView:CloseCallBack()

end

function GoddessSearchAuraView:__delete()
	PlayerPrefsUtil.DeleteKey("GoddessSearchAuraViewTips")
end

function GoddessSearchAuraView:ReleaseCallBack()
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end

	self.scroller_list = {}
	self.receive_nums = nil

	GoddessData.Instance:SetAuraDoubleReceive(false)
end

function GoddessSearchAuraView:SkipAnimation(switch)
	GoddessData.Instance:SetAuraIsPlayAnimation(switch)
end

function GoddessSearchAuraView:CloseView()
	self:Close()
end

function GoddessSearchAuraView:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckIsComplete(6)  then
		self:ShowReward(self.ling_count)
	end
end

function GoddessSearchAuraView:Roll()
	local current_free_time = GoddessData.Instance:GetCurrentFreeTimes() or 0
	if self.receive_nums <= 0 then
		if current_free_time <= 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.AuraSearch.Warning2)
			return
		end
	end

	if self.is_Rolling or self.ling_count >= 6 then 
		if self.ling_count >= 6 then
			self.is_Rolling = false
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.NeedReceiveTip)
		end
		return 
	end

	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.CHOU_LING, 0, 0, 0)
end

function GoddessSearchAuraView:ScrollerRoll(info,time)
	self.ling_count=0
	local animation_time=time or 3

	if self.node_list["SkipToggle"].toggle.isOn then 
		for i = 1, 6 do
			if info ~= nil and info[i - 1] ~= nil and self.scroller_list[i] ~= nil then
				self.scroller_list[i].cell:SetData({index = info[i - 1], key = "start"})
				if info[i - 1] == 0 then
					self.ling_count = self.ling_count + 1
				end
			end
		end
		self.is_Rolling = false
		self:ShowReward(self.ling_count)
		return
	end
		self.is_Rolling=true
		local info_list=info
		for i= 0,5 do
			info_list[i]=tonumber(info_list[i]) + 1
			if not self.node_list["SkipToggle"].toggle.isOn then
				animation_time = animation_time + (i - 1) / 5
			end
			self.scroller_list[i + 1].cell:StartScoller(animation_time,info_list[i])
			if info[i] == 1 then 
				self.ling_count=self.ling_count + 1
				self.scroller_list[i + 1].cell.flag=true
			end 
		end

	self.complete_list = {}
 end


function GoddessSearchAuraView:OnFlush(params)
	for k,v in pairs(params) do
		if k=="miling_list" then
			self:ScrollerRoll(v, 0.5)
		elseif k == "reset_eff" then
			self:ResetEff()
			return
		end
	end

	self:FlushFreeTimes()
	self:FlushReceivedTime()
	self:FlushShengYuNums()
end

function GoddessSearchAuraView:ResetEff()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(false)
		end
	end

	local data = GoddessData.Instance:GetAuraSearchListInfo()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(data[i - 1] == 0)
		end
	end
end

function GoddessSearchAuraView:FlushFreeTimes()
	local current_free_time = GoddessData.Instance:GetCurrentFreeTimes() or 0
	if self.node_list["TxtFreeTimes"] ~= nil then
		local str = string.format(Language.Goddess.FreeTimesTip, current_free_time)
		self.node_list["TxtFreeTimes"].text.text = current_free_time == 0 and "" or str
	end

	if self.node_list["NodeShowConsume"] ~= nil then
		self.node_list["NodeShowConsume"]:SetActive(current_free_time == 0)
	end

	if self.node_list["TextConsumeValue"] ~= nil then
		self.node_list["TextConsumeValue"].text.text = GoddessData.Instance:GetAuraSearchConsume()
	end

	if  current_free_time ~= 0 then
		self.node_list["ImgCostSearch"]:SetActive(false)
		self.node_list["ImgFreeSearch"]:SetActive(true)
	else
		self.node_list["ImgCostSearch"]:SetActive(true)
		self.node_list["ImgFreeSearch"]:SetActive(false)
	end
	
end

function GoddessSearchAuraView:FlushAuraNums(ling_value)
	self.node_list["TxtAuraNums"].text.text = ling_value
end

function GoddessSearchAuraView:FlushShengYuNums()
	local value = GoddessData.Instance:GetOtherByStr("double_ling_gold")
	self.node_list["TxtDoubleReceive"].text.text = string.format(Language.Goddess.DoubleRewardTip, value or 0)
end

function GoddessSearchAuraView:CheckIsComplete(count)
	local flag = true
	local start = 1 + self.ling_count
	start = start > 6 and 6 or start

	for i = start, count do
		if  not self.complete_list[i]  then
			flag = false
			break
		end
	end

	return flag
end

function GoddessSearchAuraView:ShowReward(nums)
	self.is_Rolling = false
	local ling_value=GoddessData.Instance:GetAuraNumsByLingNums(nums)
	self:FlushAuraNums(ling_value)
end

function GoddessSearchAuraView:Receive()

	if self.receive_nums <= 0 then 
		TipsCtrl.Instance:ShowSystemMsg(Language.AuraSearch.Warning)
		return
	end 

	if self.is_Rolling then 
		return 
	end

	if self.ling_count==6 then self.is_Rolling = false end
	if GoddessData.Instance:GetAuraDoubleReceive() then 
		for i = 1, 6 do
			self.scroller_list[i].cell.flag=false
		end
		GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_LING, 1, 0, 0)
	else
		local func = function()
			for i = 1, 6 do
				self.scroller_list[i].cell.flag=false
			end
			GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_LING, 0, 0, 0)
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.AuraSearch.Remind1, nil, nil, true, nil, "GoddessSearchAuraViewTips")
	end 
end

function GoddessSearchAuraView:DoubleReceive(switch)
	GoddessData.Instance:SetAuraDoubleReceive(switch)
	self.is_Rolling = false
end

function GoddessSearchAuraView:FlushReceivedTime()
	local nums = GoddessData.Instance:GetAuraSearchReveivedTimes()
	local all_nums = GoddessData.Instance:GetOtherByStr("fetch_ling_time") or 0
	self.receive_nums = all_nums - nums
	local str = string.format(Language.Goddess.FreeTimesTip2, self.receive_nums)

	self.node_list["TxtReceive"].text.text = str
end

--------------------------------------------------------------------------------------------------
AuraScroller = AuraScroller or BaseClass(BaseCell)

-- 每个格子的高度
local cell_hight = 100
-- 每个格子之间的间距
local distance = 15
-- 格子起始间距
local offset = 0
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 999

local IconCount=5

local icon_name="Icon_Aura"

local icon_path="uis/views/aurasearchview_prefab"
--------------------------------------------------------------------------------------------------
AuraScroller = AuraScroller or BaseClass(BaseCell)

function AuraScroller:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["DoTween"].transform.position = Vector3(0, 0, 0)

	local original_hight = self.root_node.rect.sizeDelta.y
	local hight = IconCount * cell_hight
	self.percent = cell_hight / (hight - original_hight)

	self.node_list["Rect"].rect.sizeDelta = Vector2(self.node_list["Rect"].rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local parent = self.node_list["Rect"].transform
	for i = 1, IconCount + 3 do
		local async_loader = AllocAsyncLoader(self, "icon_loader_" .. i)
		async_loader:SetParent(parent)
		async_loader:Load(icon_path, icon_name, function(obj)
			if IsNil(obj) then
				return
			end

			local obj_transform = obj.transform
			obj_transform.localPosition = Vector3(0, -(i - 1) * cell_hight+offset , 0)

			local res_id = i - 1

			if res_id > IconCount then
				res_id = res_id % IconCount
			end
			if res_id == 0 then
				res_id = IconCount
			end
			--设置每个obj的图片
			local list = U3DNodeList(obj_transform:GetComponent(typeof(UINameTable)), self)
			list["ImgIcon"].image:LoadSprite(ResPath.GetAuraImage(res_id))
			list["ImgIcon"].image:SetNativeSize()
		end)
	end

	 self.target_x = 0
	self.target = 1
	self.falg = false
	self.is_start = true
	self.is_ling = false
end

function AuraScroller:__delete()
	self:RemoveCountDown()

	self.rect = nil
	self.do_tween_obj = nil
	self.is_start = true
	self.effect = nil
	self.is_ling = false
end

function AuraScroller:OnValueChange(value)
	local x = value.y
end

function AuraScroller:StartScoller(time, target)
	if self.flag then 
		self.is_ling = true
		if self.effect then
			self.effect:SetActive(true)
		end
		return 
	end

	self.is_ling = target == 1
	if self.effect then
		self.effect:SetActive(false)
	end

	self.node_list["DoTween"].transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end

	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.node_list["DoTween"].transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function AuraScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.node_list["DoTween"].transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)

	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
		if self.index ~= nil and self.index == 6 then
			GoddessCtrl.Instance:ResetEff()
		end
	end
end

function AuraScroller:IndexToValue(index)
	return 1 - (self.percent * index % 3)
end

function AuraScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function AuraScroller:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function AuraScroller:SetIndex(index)
	self.index = index
end

function AuraScroller:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.data.key == "start" then
		local value = self:IndexToValue(self.data.index)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		self.is_start = false
		if self.data.index == 0 then
			if self.effect then
				self.effect:SetActive(true)
				self.is_ling = true
			end
			self.flag = true
		end

		self:ShowEffect(self.data.index == 0)
	end
end

function AuraScroller:ShowEffect(flag)
	if not self.effect then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_zhishengyijie_002")
		self.async_loader = self.async_loader or AllocAsyncLoader(self, "effect_loader")
		self.async_loader:SetParent(self.root_node.transform)
		self.async_loader:Load(bundle_name, asset_name, function (obj)
			if IsNil(obj) then
				return
			end

			local transform = obj.transform
			self.effect = obj.gameObject
			self.is_loading = false
			self.effect:SetActive(flag)
		end)
	else
		self.effect:SetActive(flag)
	end
end
