OperateListView = OperateListView or BaseClass(BaseView)

local HeightMax = 285						--最大高度
local ButtonMax = 8							--按钮最大数量

function OperateListView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "ListDetailButton"}}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.cell_height = 0
	self.list_spacing = 0
	self.avatar_key = 0
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
end

function OperateListView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end

	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end

	self.cell_list = {}
	self.avatar_key = 0
	self.click_obj = nil
end

function OperateListView:LoadCallBack()
	-- self.node_list["Left"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	-- self.node_list["Right"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	-- self.node_list["Top"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	-- self.node_list["Bottom"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	-- 生成滚动条
	self.scroller_data = {}
	local scroller_delegate = self.node_list["ButtonList"].list_simple_delegate

	self.cell_height = scroller_delegate:GetCellViewSize(self.node_list["ButtonList"].scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.list_spacing = self.node_list["ButtonList"].scroller.spacing										--间距

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data > 8 and #self.scroller_data / 2 or 4
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local detail_cell = self.cell_list[cell]
		if detail_cell == nil then
			detail_cell = ScrollerDetailCell.New(cell.gameObject)
			detail_cell.list_detail_view = self
			-- detail_cell:SetInstanceParent(self.node_list["Btn" .. data_index])
			self.cell_list[cell] = detail_cell
		end

		detail_cell:SetIndex(data_index)
		detail_cell:SetData({self.scroller_data[data_index * 2 - 1], self.scroller_data[data_index * 2]})
	end
	-- for i = 1, ButtonMax do
	-- 	self.node_list["Btn"..i].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self, i))
	-- end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Songhua"].button:AddClickListener(BindTool.Bind(self.Songhua, self))
	self.role_event_system = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushView, self))
end

function OperateListView:FlushBtn()
	if not next(self.scroller_data) then return end
	for i = 1, ButtonMax do
		self.node_list["Btntxt" .. i].text.text = self.scroller_data[i].name
		UI:SetButtonEnabled(self.node_list["Btn" .. i], not self.scroller_data[i].remove)
	end
end

function OperateListView:CloseWindow()
	self:Close()
end

function OperateListView:CloseCallBack()
	if self.click_btn_close_callback then
		self.click_btn_close_callback()
		self.click_btn_close_callback = nil
	end
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.role_name = ""

	self.click_obj = nil

	if not self.root_node then
		return
	end

	-- local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	-- local width = rect.rect.width
	-- local height = rect.rect.height

	-- self.node_list["Left"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, 0, width)
	-- self.node_list["Right"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	-- self.node_list["Top"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, 0, height)
	-- self.node_list["Top"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	-- self.node_list["Bottom"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, 0, height)
	-- self.node_list["Bottom"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

end

function OperateListView:SetRoleName(name)
	self.role_name = name
end

function OperateListView:SetCloseCallBack(callback)
	self.close_call_back = callback
end

function OperateListView:SetBtnCloseCallBack(callback)
	self.click_btn_close_callback = callback
end

function OperateListView:OpenCallBack()
	-- self:ChangeBlock()
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	CheckData.Instance:SetCurrentUserId(role_info.role_id)
	if IS_ON_CROSSSERVER then
		CheckCtrl.Instance:SendCrossQueryRoleInfo(role_info.plat_type, role_info.plat_role_id)
	else
		CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.role_id)
	end

	self:FlushView()
end
-- 给按钮排序
function OperateListView:SoftData(role_info, data)
	local list = {}
	local not_list = {}
	local ignore = {}
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _,v in pairs(data) do
		if not v.remove then
			table.insert(list, v)
			local i
			if v.style == "addfriend" or v.style == "delete" then
				i = v.style == "addfriend" and "delete" or "addfriend"
			elseif v.style == "black" or v.style == "remove_black" then
				i = v.style == "black" and "remove_black" or "black"
			end

			if i then table.insert(ignore,i) end

		else
			table.insert(not_list, v)
			local i
			if v.style == "team" and not ScoietyData.Instance:GetTeamState() then
				if ScoietyData.Instance:IsTeamMember(role_info.role_id) or not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
					i = "team"
				end
			elseif v.style == "addfriend" and (ScoietyData.Instance:IsFriend(role_info.role_name) or ScoietyData.Instance:IsBlackByName(role_info.role_name))then
				i = "addfriend"
			elseif v.style == "delete" and (not ScoietyData.Instance:IsFriend(role_info.role_name) or ScoietyData.Instance:IsBlackByName(role_info.role_name))then
				i = "delete"
			elseif v.style == "kickout_team" and not ScoietyData.Instance:GetTeamState() then
				if not ScoietyData.Instance:IsTeamMember(role_info.role_id) and not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
					i = "kickout_team"
				end
			elseif  v.style == "give_leader" and not ScoietyData.Instance:GetTeamState() then
				if not ScoietyData.Instance:IsTeamMember(role_info.role_id) and not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
					i = "give_leader"
				end
			elseif v.style == "guild_invite" and not GuildData.Instance:GetInvitePower() and ScoietyData.Instance:GetTeamState() then
				i = "guild_invite"		
			-- elseif v.style == "qiuhun" and main_vo.sex == role_info.sex then
			-- 	i = "qiuhun"
			elseif v.style == "black" and (ScoietyData.Instance:IsBlackByName(role_info.role_name) or role_info.role_id == main_vo.lover_uid) then
				i = "black"
			elseif v.style == "remove_black" and not ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				i = "remove_black"
			elseif v.style == "delenemy" then
				i = "delenemy"
			-- elseif v.style == "kickout" then
			-- 	i = "kickout"
			elseif v.style == "change_leader_cross" then
				i = "change_leader_cross"
			end

			if i then table.insert(ignore,i) end

		end
	end

	local count = #list

	if count < ButtonMax or count % 2 ~= 0 then
		for _,v in ipairs(not_list) do
			if #list >= ButtonMax and count % 2 == 0 then
				break
			end
			local is_ignore = false
			for _,v1 in ipairs(ignore) do
				if v.style == v1 then
					is_ignore = true
					break
				end
			end

			if not is_ignore then
				table.insert(list, v)
			end
		end
	end

	return list
end
-- 是否屏蔽某些按钮
function OperateListView:ChangeData(role_info, data, open_type)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for i = #data, 1, -1 do
		local dis_show = false
		local remove = false
		if data[i].style == "chat" then
			if tonumber(role_info.is_online) == 0 then
				-- remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "trade" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.is_online) == 0 or tonumber(role_info.at_cross) == 1 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "sit_mount" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif open_type ~= ScoietyData.DetailType.Default then
				remove = true
			elseif main_vo.multi_mount_res_id == nil or main_vo.multi_mount_res_id <= 0 then
				remove = true
			else
				local role = Scene.Instance:GetObjByUId(role_info.role_id)
				if nil == role or role:IsDead() then
					remove = true
				end
			end
		elseif data[i].style == "team" then
			if tonumber(role_info.is_online) == 0 then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.at_cross) == 1 then
				remove = true
			elseif ScoietyData.Instance:GetTeamState() then
				if ScoietyData.Instance:IsTeamMember(role_info.role_id) then
					remove = true
				elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
					remove = true
				end
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "kickout_team" then
			if role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif not ScoietyData.Instance:GetTeamState() then
				remove = true
			elseif not ScoietyData.Instance:IsTeamMember(role_info.role_id) then
				remove = true
			elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "give_leader" then
			if tonumber(role_info.is_online) == 0 then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif not ScoietyData.Instance:GetTeamState() then
				remove = true
			elseif not ScoietyData.Instance:IsTeamMember(role_info.role_id) then
				remove = true
			elseif not ScoietyData.Instance:IsLeaderById(main_vo.role_id) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "guild_invite" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.is_online) == 0 then
				remove = true
			elseif not GuildData.Instance:GetInvitePower() then
				remove = true
			elseif ScoietyData.Instance:IsTeamMember(role_info.role_id) then
				remove = true
			end
		elseif data[i].style == "flower" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.is_online) == 0 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "addfriend" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif ScoietyData.Instance:IsFriend(role_info.role_name) then
				remove = true
			elseif tonumber(role_info.is_online) == 0 or tonumber(role_info.at_cross) == 1 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "delete" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif not ScoietyData.Instance:IsFriend(role_info.role_name) then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif role_info.role_id == main_vo.lover_uid then
				remove = true
			end
		elseif data[i].style == "delenemy" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif open_type ~= ScoietyData.DetailType.EnemyType then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "trace" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.is_online) == 0 or tonumber(role_info.at_cross) == 1 then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "qiuhun" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif tonumber(role_info.is_online) == 0 or tonumber(role_info.at_cross) == 1 or main_vo.sex == role_info.sex then
				remove = true
			end
		elseif data[i].style == "kickout" then
			dis_show = true
			remove = true
			-- if open_type == ScoietyData.DetailType.Guild then
			if open_type == ScoietyData.DetailType.GuildTuanZhang  or open_type == ScoietyData.DetailType.Guild then
				dis_show = false
				remove = false
			end
			-- end
			-- elseif open_type == ScoietyData.DetailType.CrossTeam then
			-- 	remove = true
			-- end
			-- if open_type == ScoietyData.DetailType.MainChat then
			-- 	dis_show = true
			-- 	remove = true
			-- end
		elseif data[i].style == "change_leader_cross" then
			if open_type ~= ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "info" then
			if open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			end
		elseif data[i].style == "black" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif open_type == ScoietyData.DetailType.CrossTeam then
				remove = true
			elseif ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			elseif role_info.role_id == main_vo.lover_uid then
				remove = true
			end
		elseif data[i].style == "remove_black" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif not ScoietyData.Instance:IsBlackByName(role_info.role_name) then
				remove = true
			end
		elseif data[i].style == "mail" then
			-- if open_type == ScoietyData.DetailType.CrossTeam then
			-- 	remove = true
			-- elseif not ScoietyData.Instance:IsFriend(role_info.role_name) then
			-- 	remove = true
			-- end
			remove = true
		elseif data[i].style == "change_post" then
			dis_show = true
			remove = true
			-- if open_type == ScoietyData.DetailType.Guild then
			if open_type == ScoietyData.DetailType.GuildTuanZhang or open_type == ScoietyData.DetailType.Guild then
			-- 	remove = true
			-- 	dis_show = true
			-- else
				remove = false
				dis_show = false
			end
			if tonumber(role_info.is_online) == 0 then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			end	
			-- end
			-- if open_type == ScoietyData.DetailType.MainChat then
			-- 	dis_show = true
			-- 	remove = true
			-- end
			-- if open_type == ScoietyData.DetailType.RankList then
			-- 	remove = true
			-- end
		elseif data[i].style == "transfer_hui_zhang" then
			if IS_ON_CROSSSERVER then
				remove = true
			elseif role_info.merge_server_id ~= main_vo.merge_server_id then
				remove = true
			elseif open_type ~= ScoietyData.DetailType.GuildTuanZhang or tonumber(role_info.is_online) == 0 then
				remove = true
			end
		end
		data[i].remove = remove
		data[i].disshow = dis_show
	end
end

function OperateListView:SetClickObj(obj)
	self.click_obj = obj
end

function OperateListView:ChangeBlock()
	-- if not self.click_obj then
	-- 	return
	-- end
	-- --获取指引按钮的屏幕坐标
	-- local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	-- local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.click_obj.rect.position)

	-- --转换屏幕坐标为本地坐标
	-- local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	-- local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

	-- --计算高亮框的位置
	-- local height = self.node_list["Left"].rect.rect.height
	-- local width = self.node_list["Left"].rect.rect.width
	-- --local height = self.left.rect.rect.height
	-- --local width = self.left.rect.rect.width

	-- local click_rect = self.click_obj.rect.rect
	-- local btn_height = click_rect.height
	-- local btn_width = click_rect.width
	-- local pos_x = local_pos_tbl.x
	-- local pos_y = local_pos_tbl.y

	-- local left_width = width/2 + pos_x - btn_width/2
	-- local right_width = width/2 - (pos_x + btn_width/2)
	-- local top_height = height/2 - (pos_y + btn_height/2)
	-- local bottom_height = height/2 + pos_y - btn_height/2
	-- self.node_list["Left"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, width - left_width, left_width)
	-- self.node_list["Right"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, width - right_width, right_width)

	-- self.node_list["Top"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, height - top_height, top_height)
	-- self.node_list["Top"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)

	-- self.node_list["Bottom"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, height - bottom_height, bottom_height)
	-- self.node_list["Bottom"].rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)

end

--改变列表长度
function OperateListView:ChangePanelHeight(item_count)
	local panel_Width = self.node_list["Panel"].rect.rect.width
	local panel_height = self.cell_height * item_count + self.list_spacing * (item_count - 1) + 20			--20是listview和底框的间距和
	if panel_height > HeightMax then
		panel_height = HeightMax
	end
	self.node_list["Panel"].rect.sizeDelta = Vector2(panel_Width, panel_height)
end

function OperateListView:FlushView()
	local open_type = ScoietyData.Instance:GetOpenDetailType()
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	local data = TableCopy(ScoietyData.DetailData)
	if next(role_info) then
		self:ChangeData(role_info, data, open_type)
		data = self:SoftData(role_info, data)
	end

	local num =0
	for k,v in pairs(data) do
		num = num + 1
	end

	for i = num, 1, -1 do
		if data[i].disshow then
			table.remove(data, i)
		end
	end

	-- local item_count = #data or 0
	-- self:ChangePanelHeight(item_count)
	self.scroller_data = data
	self.node_list["ButtonList"].scroller:ReloadData(0)
	-- self:FlushBtn()
	self:FlushTouXiang()
end

function OperateListView:FlushTouXiang()
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	local avatar_key = AvatarManager.Instance:GetAvatarKey(role_info.role_id)
	if avatar_key == 0 then
		--展示默认头像
		self.avatar_key = 0
		CommonDataManager.SetAvatarFrame(role_info.role_id, self.node_list["TouXiangKuang"], self.node_list["BgKuang"])
	else
		if avatar_key ~= self.avatar_key then
			self.avatar_key = avatar_key
			CommonDataManager.SetAvatarFrame(role_info.role_id, self.node_list["TouXiangKuang"], self.node_list["BgKuang"])
		end
	end
	AvatarManager.Instance:SetAvatar(role_info.plat_role_id, self.node_list["RawImage"], self.node_list["IconImage"], role_info.sex, role_info.prof, false)
	local check_info = CheckData.Instance:GetRoleInfo()
	self.node_list["Name"].text.text = role_info.role_name
	-- local level_befor = math.floor(role_info.level % 100) ~= 0 and math.floor(role_info.level % 100) or 100
	-- local level_behind = math.floor(role_info.level % 100) ~= 0 and math.floor(role_info.level / 100) or math.floor(role_info.level / 100) - 1
	local str = role_info.is_online == 0 and Language.Society.OperateOutLine or ""
	self.node_list["Level"].text.text = PlayerData.GetLevelString(role_info.level) .. str
	self.node_list["Meili"].text.text = check_info.all_charm or 0
	self.node_list["vip"].text.text = check_info.vip_level or 1
end

function OperateListView:Songhua()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end

	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	if role_info.is_online == 0 then
		return SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
	end

	if role_info.at_cross == 1 then
		return SysMsgCtrl.Instance:ErrorRemind(Language.Common.ObjectInCross)
	end

	FlowersCtrl.Instance:SetFriendInfo(role_info)
	ViewManager.Instance:Open(ViewName.Flowers)
	self:Close()
end

----------------------------------------------------------------------------
--ScrollerDetailCell 		列表滚动条格子
----------------------------------------------------------------------------

ScrollerDetailCell = ScrollerDetailCell or BaseClass(BaseCell)

function ScrollerDetailCell:__init()
	self.list_detail_view = nil
	
	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self, 1))
	self.node_list["Btn2"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self, 2))

end

function ScrollerDetailCell:__delete()
	self.list_detail_view = nil
end

function ScrollerDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.node_list["Text1"].text.text = self.data[1].name
	self.node_list["Text2"].text.text = self.data[2].name
	for i=1,2 do
		UI:SetButtonEnabled(self.node_list["Btn" .. i], not self.data[i].remove)
	end
end

function ScrollerDetailCell:OnButtonClick(i)
	self.list_detail_view:Close()
	local style = self.data[i].style
	local role_info = ScoietyData.Instance:GetSelectRoleInfo()
	if not next(role_info) then
		return
	end
	local flag = true
	if style == "chat" then						-- 私聊
		-- 判断等级是否足够
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
			return
		end
		flag = false
		local private_obj = {}
		if nil == ChatData.Instance:GetPrivateObjByRoleId(role_info.plat_role_id) then
			private_obj = ChatData.CreatePrivateObj()
			private_obj.plat_type = role_info.plat_type
			private_obj.role_id = role_info.plat_role_id
			private_obj.username = role_info.role_name
			private_obj.sex = role_info.sex
			private_obj.camp = role_info.camp
			private_obj.prof = role_info.prof
			private_obj.avatar_key_small = role_info.avatar_key_small
			private_obj.level = role_info.level
			private_obj.create_time = TimeCtrl.Instance:GetServerTime()
			ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
		end
		ChatData.Instance:SetCurrentId(role_info.plat_role_id)

		if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
			ViewManager.Instance:FlushView(ViewName.ChatGuild, "select_traget", {true})
		else
			ViewManager.Instance:Open(ViewName.ChatGuild)
		end

	elseif style == "trade" then				-- 交易
		-- 暂时屏蔽交易
		AvatarManager.Instance:SetAvatarKey(role_info.role_id, role_info.avatar_key_big, role_info.avatar_key_small)
		TradeCtrl.Instance:SendTradeRouteReq(role_info.role_id)

	elseif style == "info" then
		if role_info.plat_role_id ~= 0 then
			CheckData.Instance:SetCurrentUserId(role_info.plat_role_id)
			-- CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.role_id)
			CheckCtrl.Instance:SendCrossQueryRoleInfo(role_info.plat_type, role_info.plat_role_id)
			ViewManager.Instance:Open(ViewName.CheckEquip)
		end
	elseif style == "mail" then					-- 发送邮件
		-- ScoietyData.Instance:SetSendName(role_info.role_name)
		-- if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
		-- 	ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.write_mail)
		-- else
		-- 	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.write_mail)
		-- end

	elseif style == "team" then					-- 组队邀请
		if not ScoietyData.Instance:GetTeamState() then
			if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
				ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.society_team)
			else
				ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
			end
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 1
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUniqueUserReq(role_info.role_id, role_info.plat_type)

	elseif style == "kickout_team" then					-- 请出队伍
		local function ok_func()
			ScoietyCtrl.Instance:KickOutOfTeamReq(role_info.role_id)
		end
		local des = string.format(Language.Society.KickOutTeam, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("kick_out_of_team", des, ok_func)

	elseif style == "give_leader" then					-- 移交队长
		local function ok_func()
			ScoietyCtrl.Instance:ChangeTeamLeaderReq(role_info.role_id)
		end
		local des = string.format(Language.Society.ChangeLeader, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)

	elseif style == "guild_invite" then				-- 公会邀请
		GuildCtrl.Instance:SendInviteGuildReq(role_info.role_id)

	elseif style == "flower" then				-- 赠送鲜花
		FlowersCtrl.Instance:SetFriendInfo(role_info)
		ViewManager.Instance:Open(ViewName.Flowers)

	elseif style == "black" then				-- 黑名单
		local function yes_func()
			ScoietyCtrl.Instance:AddBlackReq(role_info.role_id)
		end

		local describe = string.format(Language.Society.AddBlackDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	elseif style == "remove_black" then			-- 移除黑名单
		local function yes_func()
			ScoietyCtrl.Instance:DeleteBlackReq(role_info.role_id)
		end
		local describe = string.format(Language.Society.DeleteBlackDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)

	elseif style == "addfriend" then			-- 添加好友
		ScoietyCtrl.Instance:AddFriendReq(role_info.role_id)

	elseif style == "delete" then				-- 删除好友
		local function yes_func()
			ScoietyCtrl.Instance:DeleteFriend(role_info.role_id)
		end

		local describe = string.format(Language.Society.DelFriendDes, role_info.role_name)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)

	elseif style == "delenemy" then				-- 删除仇人
		ScoietyCtrl.Instance:EnemyDeleteReq(role_info.plat_type, role_info.role_id)

	elseif style == "trace" then				-- 追踪
		--当前场景无法传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= SceneType.Common then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end

		local function ok_func()
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local need_item_data = ShopData.Instance:GetShopItemCfg(27582)
			if not need_item_data then
				return
			end
			local item_num = ItemData.Instance:GetItemNumInBagById(27582)
			-- if main_vo.gold < need_item_data.gold then
			-- 	--元宝不足
			-- 	TipsCtrl.Instance:ShowLackDiamondView()
			-- 	return
			if item_num <= 0 then
				--材料不足，弹出购买
				if main_vo.bind_gold >= need_item_data.bind_gold then
					local function close_call_back()
						PlayerCtrl.Instance:SendSeekRoleWhere(role_info.role_name or "")
					end
					TipsCtrl.Instance:ShowShopView(27582, 1, close_call_back)
				else
					local function close_call_back()
						if main_vo.gold >= need_item_data.gold then
							PlayerCtrl.Instance:SendSeekRoleWhere(role_info.role_name or "")
						end
					end
					TipsCtrl.Instance:ShowShopView(27582, 2, close_call_back)
				end
			else
				PlayerCtrl.Instance:SendSeekRoleWhere(role_info.role_name or "")
			end
		end

		local str = string.format(Language.Role.TraceConfirm, role_info.role_name or "")
		TipsCtrl.Instance:ShowCommonAutoView("", str, ok_func)

	elseif style == "kickout" then
		GuildCtrl.Instance:OnClickKickout(role_info.role_id,role_info.role_name)

	elseif style == "qiuhun" then
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(function ()
			local cfg = MarriageData.Instance:GetMarriageConditions()
			if nil == cfg then return end
			local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
			if npc_info then
				MoveCache.end_type = MoveEndType.NpcTask
				MoveCache.param1 = cfg.marry_npc_id
				local callback = function()
					GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
				end
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
			end
		end, self), nil, Language.Marriage.GoToMarryTip[1])

	elseif style == "change_leader_cross" then

	elseif style == "change_post" then
		TipsCtrl.Instance:ShowTipsGuildTransferView(role_info.role_id, role_info.role_name)

	elseif style == "transfer_hui_zhang" then
		GuildCtrl.Instance:OnClickTransfer(role_info.role_id,role_info.role_name)

	elseif style == "sit_mount" then
		MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_INVITE_RIDE, role_info.role_id)
	end
	if flag then
		ViewManager.Instance:Close(ViewName.Chat)
	end
end