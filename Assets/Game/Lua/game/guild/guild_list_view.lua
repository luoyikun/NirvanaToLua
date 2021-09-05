GuildListView = GuildListView or BaseClass(BaseRender)

function GuildListView:__init(instance)
	if instance == nil then
		return
	end
	self.guild_list_view = instance

	self.row = 5  -- 每一页有多少行，暂定为5行
	self.list_table = {}
	self.variables = {}
	self.is_load = false
		
	local load_count = 0
	for i = 1, self.row do
		local async_loader = AllocAsyncLoader(self, "info_item_loader_" .. i)
		async_loader:SetParent(self.node_list["Infoobj" .. i].transform)
		async_loader:Load("uis/views/guildview_prefab", "GuildListInfo", function(obj)
			if IsNil(obj) then
		 		return
		 	end

			self.list_table[i] = U3DObject(obj)
			self.variables[i] = {}
			
			local name_table = obj:GetComponent(typeof(UINameTable))
			local node_list = U3DNodeList(name_table, self)
			
			self.variables[i].rank_text = node_list["RankText"]
			self.variables[i].rank_1 = node_list["Number1"]
			self.variables[i].rank_2 = node_list["Number2"]
			self.variables[i].rank_3 = node_list["Number3"]
			
			self.variables[i].guild_name = node_list["GuildName"]
			self.variables[i].master_name = node_list["MasterName"]
			self.variables[i].guild_level = node_list["Level"]
			self.variables[i].member_count = node_list["MemberCount"]
			self.variables[i].total_fight_power = node_list["FightPower"]

			load_count = load_count + 1
			if load_count >= self.row then
				self.is_load = true
				self:Flush()
			end
		end)
	end

	self.node_list["ButtonPageUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["ButtonPageDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
end

function GuildListView:__delete()
	self.guild_list_view = nil
end

-- 刷新View
function GuildListView:Flush()
	self.info_list = GuildDataConst.GUILD_INFO_LIST
	self:FlushPageCount()
	self.current_page = 1
	self:FlushPage(self.current_page)
end

-- 刷新页面数目
function GuildListView:FlushPageCount()
	self.info_count = self.info_list.count
	self.page_count = self.info_count / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

function GuildListView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildListView:DoPanelTweenPlay()
	UITween.MoveAlpahShowPanel(self.node_list["TopContent"], GuildData.MemberTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GuildData.MemberTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


-- 更新页面
function GuildListView:FlushPage(page)
	if(page > self.page_count or page < 1) or not self.is_load then
		return
	end
	self.current_page = page
	self.node_list["TextPage"].text.text = self.current_page .. "/" .. self.page_count
	if page == self.page_count then  -- 如果是最后一页
		for i = 1, self.row do
			if(i <= page * self.row - self.info_count) then
				self.list_table[self.row + 1 - i]:SetActive(false)
			else
				self.list_table[self.row + 1 - i]:SetActive(true)
			end
		end
	else
		for i = 1, self.row do
			self.list_table[i]:SetActive(true)
		end
	end
	for i = (page - 1) * self.row + 1, page * self.row do
		if(i > self.info_count) then
			break
		end
		self:FlushRow(i)
	end
end

-- 更新每一行的信息
function GuildListView:FlushRow(index)
	if index <= 0 or not self.is_load then
		return
	end
	local current_row = index % self.row
	if current_row == 0 then
		current_row = self.row
	end

	self.variables[current_row].rank_text.text.text = index
	self.variables[current_row].rank_1:SetActive(index == 1)
	self.variables[current_row].rank_2:SetActive(index == 2)
	self.variables[current_row].rank_3:SetActive(index == 3)
	
	local info = self.info_list.list[index]

	self.variables[current_row].guild_name.text.text = info.guild_name
	self.variables[current_row].master_name.text.text = info.tuanzhang_name
	self.variables[current_row].guild_level.text.text = info.guild_level
	self.variables[current_row].member_count.text.text = info.cur_member_count .. "/" .. info.max_member_count

	self.variables[current_row].total_fight_power.text.text = info.total_capability
end

-- 向上翻页
function GuildListView:OnPageUp()
	self.current_page = self.current_page - 1
	self.current_page = self.current_page < 1 and 1 or self.current_page
	self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildListView:OnPageDown()
	self.current_page = self.current_page + 1
	self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
	self:FlushPage(self.current_page)
end

-- 关闭所有弹窗
function GuildListView:CloseAllWindow()

end
