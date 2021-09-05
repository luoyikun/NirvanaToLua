TianShuSkillFinishView = TianShuSkillFinishView or BaseClass(BaseView)

function TianShuSkillFinishView:__init()
	self.ui_config = {{"uis/views/tianshuview_prefab", "TianShuSkillFinishView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.data = nil
end

function TianShuSkillFinishView:LoadCallBack()
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TianShuSkillFinishView:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TianShuSkillFinishView:CloseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TianShuSkillFinishView:OnClickClose()
	local x, y = self.node_list["Openpos"].transform.localPosition.x, self.node_list["Openpos"].transform.localPosition.y
	self.node_list["Effect"]:SetActive(false)
	self.node_list["BtnCancel"]:SetActive(false)
	UITween.MoveToScaleAndShowPanel(self.node_list["ImgOne"], Vector3(0, 0, 0), Vector3(x, y, 0), 0.6, 2, nil, function()
		self:Close()
		self.cal_time_quest = nil
	end , 0.85)
end

function TianShuSkillFinishView:SetData(data)
	self.data = data
	self:Open()
end

function TianShuSkillFinishView:SetIndex(index)
	self.select_index = index
	self:Open()
end


function TianShuSkillFinishView:OpenCallBack()
	self.node_list["ImgOne"].transform.localPosition = Vector3(3, 15, 0)
	self.node_list["ImgOne"].transform.localScale = Vector3(1, 1, 1)
	self.node_list["Effect"]:SetActive(true)
	self.node_list["BtnCancel"]:SetActive(true)
	self:Flush()
end


function TianShuSkillFinishView:OnFlush()
	if nil == self.select_index then return end
	self.node_list["ImgOne"].image:LoadSprite("uis/views/tianshuview/image_atlas", "img_tianshu_skill", function()
			self.node_list["ImgOne"].image:SetNativeSize()
		end)
	local skill_desc = TianShuData.Instance:GetTianShuDescNameByIndex(self.select_index + 1)
	self.node_list["TextExp"].text.text = skill_desc

	self.node_list["ImageTitle"].image:LoadSprite("uis/views/tianshuview/image_atlas", "tilte_skill")
	self:CalTime()
end

function TianShuSkillFinishView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self.node_list["Effect"]:SetActive(false)
			self.node_list["BtnCancel"]:SetActive(false)
			local x, y = self.node_list["Openpos"].transform.localPosition.x, self.node_list["Openpos"].transform.localPosition.y
			UITween.MoveToScaleAndShowPanel(self.node_list["ImgOne"], Vector3(0, 0, 0), Vector3(x, y, 0), 0.6, 2, nil, function()
				self:Close()
				self.cal_time_quest = nil
			end , 0.85)
		end
	end, 0)
end