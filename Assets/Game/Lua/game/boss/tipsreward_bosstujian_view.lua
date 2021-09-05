TipsRewardBossTujianView = TipsRewardBossTujianView or BaseClass(BaseView)

function TipsRewardBossTujianView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "BossTujianRewardTip"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsRewardBossTujianView:__delete()

end
function TipsRewardBossTujianView:ReleaseCallBack()
	if self.reward_item then
		self.reward_item = nil
	end
end


function TipsRewardBossTujianView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["reward_item"])
end

function TipsRewardBossTujianView:OpenCallBack()
	self:Flush()
end

function TipsRewardBossTujianView:SetData(data, is_got)
	-- self.content = str
	self.reward_data = data
	self.is_got = is_got
	self:Open()
end

function TipsRewardBossTujianView:OnFlush()
	self.reward_item:SetData(self.reward_data)
	self.node_list["tab_hasgot"]:SetActive(self.is_got)
	self.node_list["Desc"]:SetActive(not self.is_got)
	-- self.node_list["Txt_reward"].text.text = self.content and self.content or ""
end

function TipsRewardBossTujianView:OnCloseClick()
	self:Close()
end