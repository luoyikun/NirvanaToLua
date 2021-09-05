TipsKillBossView = TipsKillBossView or BaseClass(BaseView)

function TipsKillBossView:__init()
	self.ui_config = {{"uis/views/tips/killbosstips_prefab", "KillBossTip"}}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsKillBossView:__delete()

end

function TipsKillBossView:ReleaseCallBack()
	self.kill_text_list = {}
	self.kill_text_time = {}
	self.data = nil
	self.boss_id = nil
end


function TipsKillBossView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.kill_text_list = {}
	self.kill_text_time = {}
	for i = 1, 5 do
		self.kill_text_list[i] = self.node_list["TxtKillText" .. i]
		self.kill_text_time[i] = self.node_list["TxtKillTimeText" .. i]
	end
end

function TipsKillBossView:OpenCallBack()
	self:Flush()
end

function TipsKillBossView:SetData(data)
	self.data = data
	self:Flush()
end

function TipsKillBossView:OnFlush()
	local count = 1
	local max_killier_time = 0
	local list = {}
	for i,v in ipairs(self.data) do
		if v.killier_time > max_killier_time then
			table.insert(list, 1, v)
			max_killier_time = v.killier_time
		else
			table.insert(list, v)
		end
	end
	self.data = list
	if self.data then
		for i = 1, #self.data do
			if self.data[i].killier_time ~= 0 then
				count = count + 1
			end
		end
		for i = 1, #self.data do
			if self.data[i].killier_time ~= 0 then
				local time = TimeUtil.FormatSecond(self.data[i].killier_time)
				local time_list = os.date("*t",self.data[i].killier_time)
				local time_desc = time_list.hour .. ":" .. time_list.min .. ":" .. time_list.sec
				local kill_name = ToColorStr(self.data[i].killer_name, TEXT_COLOR.YELLOW)
				self.kill_text_time[count - i].text.text = time_desc
				self.kill_text_list[count - i].text.text = Language.Common.Bei.. kill_name .. Language.Dungeon.JiSha
			else
				self.kill_text_list[i].text.text = ""
				self.kill_text_time[i].text.text = ""
			end
		end
		if #self.data <= 0 then
			for i = 1, 5 do
				self.kill_text_list[i].text.text = ""
				self.kill_text_time[i].text.text = ""
			end
		end
		self.node_list["TxtNoKillText"]:SetActive(count == 1)
	end
end

function TipsKillBossView:OnCloseClick()
	self:Close()
end