JueXingView = JueXingView or BaseClass(BaseRender)


function JueXingView:__init(instance, parent_view)
	for i=1, 5 do
		self.node_list["Jue_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickJueBtn, self, i))
	end

	self.base_prof = 1
	self.jue_index = 1

	-- 创建子View
	-- self.juexing_one_view = JueXingOneView.New(self.node_list["JueXing1"])
	-- self.juexing_two_view = JueXingTwoView.New(self.node_list["JueXing2"])
	self.juexing_three_view = JueXingThreeView.New(self.node_list["JueXing1"])
	self.juexing_four_view = JueXingFourView.New(self.node_list["JueXing2"])
	self.juexing_five_view = JueXingFiveView.New(self.node_list["JueXing3"])

	self:InitView()
end

function JueXingView:__delete()
	-- if self.juexing_one_view then
	-- 	self.juexing_one_view:DeleteMe()
	-- 	self.juexing_one_view = nil
	-- end

	-- if self.juexing_two_view then
	-- 	self.juexing_two_view:DeleteMe()
	-- 	self.juexing_two_view = nil
	-- end

	if self.juexing_three_view then
		self.juexing_three_view:DeleteMe()
		self.juexing_three_view = nil
	end

	if self.juexing_four_view then
		self.juexing_four_view:DeleteMe()
		self.juexing_four_view = nil
	end

	if self.juexing_five_view then
		self.juexing_five_view:DeleteMe()
		self.juexing_five_view = nil
	end
end

function JueXingView:FlushByItemChange()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if self.jue_index and (self.jue_index + 5) ~= zhuan + 1 then
		-- 防住物品改变刷新界面
		return
	end
	self:InitView()
end

function JueXingView:InitView()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	self.base_prof = base_prof
	self.jue_index = zhuan < 8 and (zhuan > 4 and zhuan - 4) or 1

	self:InitScroller()
	self:FlushToggleHL(self.jue_index)
	-- self:OnClickJueBtn(self.jue_index)
	self:ShowView()
	self:Flush()
end

-- 初始化界面
function JueXingView:ShowView()
	for i = 1, 3 do
		self.node_list["JueXing" .. i]:SetActive(i == self.jue_index)
	end
end

--初始化滚动条
function JueXingView:InitScroller()
	self.cell_list = {}

	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function JueXingView:GetNumberOfCells()
	local skill_desc_list = ZhuanZhiData.Instance:GetFaceCfgListByZhuanNum(self.jue_index + 5)
	return #skill_desc_list
end

--滚动条刷新
function JueXingView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ZhuanZhiViewScrollCell.New(cell.gameObject) --实例化item
		self.cell_list[cell] = group_cell
		self.cell_list[cell].root_node.toggle.group = self.node_list["Scroller"].toggle_group
	end

	if data_index + 1 == self.index then
		self.cell_list[cell].root_node.toggle.isOn = true
	end

	local skill_desc_list = ZhuanZhiData.Instance:GetFaceCfgListByZhuanNum(self.jue_index + 5)
	local data = skill_desc_list[data_index + 1]
	if data then
		group_cell:SetIndex(data_index)
		group_cell:SetData(data)
	end
end

function JueXingView:FlushBattle()
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function JueXingView:OnFlush()
	self:FlushZhuanZhiLeftView()

	-- if self.jue_index == 1 then
	-- 	self.juexing_one_view:Flush()
	-- elseif self.jue_index == 2 then
	-- 	self.juexing_two_view:Flush()
	if self.jue_index == 1 then
		self.juexing_three_view:Flush()
	elseif self.jue_index == 2 then
		self.juexing_four_view:Flush()
	elseif self.jue_index == 3 then
		self.juexing_five_view:Flush()
	end
end

function JueXingView:OnClickJueBtn(index)
	if index == self.jue_index then
		return
	end

	self.jue_index = index
	self:FlushBattle()
	self.node_list["JueXing1"]:SetActive(false)
	self.node_list["JueXing2"]:SetActive(false)
	self.node_list["JueXing3"]:SetActive(false)
	-- self.node_list["JueXing4"]:SetActive(false)
	-- self.node_list["JueXing5"]:SetActive(false)

	if index == 1 then
		self.node_list["JueXing1"]:SetActive(true)
	elseif index == 2 then
		self.node_list["JueXing2"]:SetActive(true)
	elseif index == 3 then
		self.node_list["JueXing3"]:SetActive(true)
	-- elseif index == 4 then
	-- 	self.node_list["JueXing4"]:SetActive(true)
	-- elseif index == 5 then
	-- 	self.node_list["JueXing5"]:SetActive(true)
	end

	if index ~= 5 then
		ZhuanZhiData.Instance:SetWuZhuanViewFlag(false)
	end

	self:DoPanelTweenPlay()
	self:Flush()
end

function JueXingView:FlushToggleHL(jue_index)
	for i=1, 5 do
		self.node_list["Jue_" .. i].toggle.isOn = (i == jue_index)
	end
end

function JueXingView:FlushZhuanZhiLeftView()
	local now_prof_name = ZhuanZhiData.Instance:GetZhuanZhiLimitProfName(self.base_prof, self.jue_index - 1 + 5)
	local next_prof_name = ZhuanZhiData.Instance:GetZhuanZhiLimitProfName(self.base_prof, self.jue_index + 5)
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()

	self.node_list["now_task_title"]:SetActive(zhuan < self.jue_index + 5)
	self.node_list["zhuanzhichenggong"]:SetActive(zhuan >= self.jue_index + 5)
	-- self.node_list["NowName"].text.text = now_prof_name
	-- self.node_list["NextName"].text.text = next_prof_name

	local res_id  = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(self.base_prof, self.jue_index - 1 + 5)
	local res_id1 = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(self.base_prof, self.jue_index + 5)
	if res_id then
		local bundle, asset = ResPath.GetTransferNameIcon(res_id)
		self.node_list["img_name1"].image:LoadSprite(bundle, asset)
	end
	if res_id1 then
		local bundle1, asset1 = ResPath.GetTransferNameIcon(res_id1)
		self.node_list["img_name2"].image:LoadSprite(bundle1, asset1)
	end

	for i = 1, 3 do
		self.node_list["Jue_" .. i]:SetActive((zhuan + 1) >= i + 5)
	end

	local task_cfg, zhuanzhi_task_status, progress_num = TaskData.Instance:GetNowZhuanZhiTask()
	if task_cfg then
		local desc = ""
		if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
			desc = task_cfg.accept_desc
		elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS and progress_num then
			desc = MainUIViewTask.ChangeTaskProgressString(task_cfg.progress_desc, progress_num, task_cfg.c_param2)
		elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
			desc = task_cfg.commit_desc
		end
		self.node_list["task_des_1"].text.text = desc
		
		for i=1, 3 do
			self.node_list["Jue_" .. i]:SetActive(zhuan >= i + 5 - 1)
		end
	end

	local attr_cfg = ZhuanZhiData.Instance:GetAttrCfgByZhuanNum(self.jue_index + 5) or {}
	local task_id = task_cfg and task_cfg.task_id or attr_cfg.renwu
	local role_info = PlayerData.Instance:GetRoleVo()
	local task_cfg_tmp = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg_tmp == nil then return end
	if role_info.level < task_cfg_tmp.min_level then
		local str_tip = string.format(Language.Player.OpenJueXing, task_cfg_tmp.min_level, self.jue_index)
		self.node_list["task_des_1"].text.text = str_tip
	end
end

function JueXingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	-- if self.jue_index == 1 then
	-- 	self.juexing_one_view:DoPanelTweenPlay()
	-- elseif self.jue_index == 2 then
	-- 	self.juexing_two_view:DoPanelTweenPlay()
	if self.jue_index == 1 then
		self.juexing_three_view:DoPanelTweenPlay()
	elseif self.jue_index == 2 then
		self.juexing_four_view:DoPanelTweenPlay()
	elseif self.jue_index == 3 then
		self.juexing_five_view:DoPanelTweenPlay()
		self.juexing_five_view:InitView()
	end
end