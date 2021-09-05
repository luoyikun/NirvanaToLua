-- 血战
FuBenPushAllView = FuBenPushAllView or BaseClass(BaseRender)

function FuBenPushAllView:__init(instance)
	self.all_view_selected_index = FuBenData.Instance:GetShowPushIndex()
	self:InitView()
end

function FuBenPushAllView:InitView()
	self.node_list["special_content_view"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.special_content_view = PushSpecialView.New(obj)
	end)

	self.push_all_toggle_list = {}
	for i = 0, 1 do
		self.push_all_toggle_list[i] = self.node_list["push_all_toggle_" .. i]
		self.node_list["push_all_toggle_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickPushButton, self,i))
	end

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
end

function FuBenPushAllView:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
		self.get_ui_callback = nil
	end

	if self.common_content_view then
		self.common_content_view:DeleteMe()
		self.common_content_view = nil
	end

	if self.special_content_view then
		self.special_content_view:DeleteMe()
		self.special_content_view = nil
	end

	self.push_all_toggle_list = nil
	self.special_content_go = nil
end

function FuBenPushAllView:ShowOrHideTab()
	local open_fun_data = OpenFunData.Instance
	self.node_list["push_all_toggle_0"]:SetActive(false)
	self.node_list["push_all_toggle_1"]:SetActive(open_fun_data:CheckIsHide("fb_push_special"))
end


function FuBenPushAllView:OpenCallBack()
	-- if self.push_all_toggle_list then
	-- 	self:ShowOrHideTab()
	-- end
	if self.all_view_selected_index == 1 and self.special_content_view then
		self.special_content_view:OpenCallBack()
	elseif self.all_view_selected_index == 0 and self.common_content_view then
		self.common_content_view:OpenCallBack()
	end
	
	GlobalTimerQuest:AddDelayTimer(function ()
		self.push_all_toggle_list[self.all_view_selected_index].toggle.isOn = true
		self:UpdataView()
	end, 0)
end
function FuBenPushAllView:ShowIndexCallBack()
	self.all_view_selected_index = FuBenData.Instance:GetShowPushIndex()
end

function FuBenPushAllView:CloseCallBack()
	if self.all_view_selected_index == 1 and self.special_content_view then
		self.special_content_view:CloseCallBack()
	elseif self.all_view_selected_index == 0 and self.common_content_view then
		self.common_content_view:CloseCallBack()
	end
end

-- 1为普通，2为炼狱
function FuBenPushAllView:OnClickPushButton(index)
	self:CloseCallBack()

	self.all_view_selected_index = index

	self:OpenCallBack()
	self:UpdataView()
end

function FuBenPushAllView:OnSelectedView()
	if not self.push_all_toggle_list[self.all_view_selected_index].toggle.isOn then
		self.push_all_toggle_list[self.all_view_selected_index].toggle.isOn = true
	end
	self:UpdataView()
end

function FuBenPushAllView:UpdataView()
	if self.all_view_selected_index == 1 then
		self:UpdataSpecialView()
		RemindManager.Instance:AddNextRemindTime(RemindName.FBPush2, nil, RemindName.FuBenSingle)

	elseif self.all_view_selected_index == 0 then
		self:UpdataCommonView()
		RemindManager.Instance:AddNextRemindTime(RemindName.FBPush1, nil, RemindName.FuBenSingle)
	end
end

function FuBenPushAllView:UpdataCommonView()
	if self.common_content_view then
		self.common_content_view:Flush()
	end
end

function FuBenPushAllView:UpdataSpecialView()
	if self.special_content_view then
		self.special_content_view:Flush()
	end
end

function FuBenPushAllView:GetUiCallBack(ui_name, ui_param)
	if ui_name == GuideUIName.ToggleYuansu then
		if self.push_all_toggle_list[0].gameObject.activeInHierarchy then
			return self.push_all_toggle_list[0]
		end
	elseif ui_name == GuideUIName.ToggleWujin then
		if self.push_all_toggle_list[1].gameObject.activeInHierarchy then
			return self.push_all_toggle_list[1]
		end
	end

	return nil
end