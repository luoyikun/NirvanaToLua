TipsGuildWarSmallView = TipsGuildWarSmallView or BaseClass(BaseView)
function TipsGuildWarSmallView:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "GuildRewardSmallTips"}}
	self.item_list = {}
	self.play_audio = true
	-- self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsGuildWarSmallView:__delete()
	self.item_list = {}
end

function TipsGuildWarSmallView:LoadCallBack()
	for i = 1, 3 do
		local item_obj = self.node_list["Item" .. i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))
end

function TipsGuildWarSmallView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v.item_cell:DeleteMe()
	end
	self.item_list = {}
end

function TipsGuildWarSmallView:CloseView()
    self:Close()
end

function TipsGuildWarSmallView:ClickReward()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function TipsGuildWarSmallView:CloseCallBack()
 	if self.close_callback then
 		self.close_callback()
 	end
end

function TipsGuildWarSmallView:OpenCallBack()
	self:Flush()
end

function TipsGuildWarSmallView:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end

		if self.show_button_value == nil then
			self.node_list["BtnGet"]:SetActive(false)
		else
			self.node_list["BtnGet"]:SetActive(self.show_button_value)
			self.node_list["TxtAllGet"]:SetActive(not self.show_button_value)
		end
		if self.show_redpoint == nil then
			self.node_list["red_point"]:SetActive(false)
		else
			self.node_list["red_point"]:SetActive(self.show_redpoint)
		end

		local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
		if guild_war_info then
			local flag = guild_war_info.had_fetch == 1
			self.node_list["TxtBtn"].text.text = flag and Language.RecordRank.Havecollect or Language.RecordRank.Collect
			UI:SetButtonEnabled(self.node_list["BtnGet"], not flag)
			self.node_list["red_point"]:SetActive(not flag)
		end

		if self.top_title then
			self.node_list["TxtCanGet"].text.text = string.format(Language.Guild.TipsCanGet, self.top_title)
		end
	end
end

function TipsGuildWarSmallView:SetData(items, show_gray, ok_callback, show_button, top_title_id, show_redpoint, close_callback)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.top_title = top_title_id
	self.show_redpoint = show_redpoint
	self.close_callback = close_callback
end