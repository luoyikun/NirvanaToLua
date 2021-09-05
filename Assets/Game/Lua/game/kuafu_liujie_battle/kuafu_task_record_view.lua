KuafuTaskRecordView = KuafuTaskRecordView or BaseClass(BaseView)

local IndexToMap =
	{
		[0] = 1450,
		[1] = 1460,
		[2] = 1461,
		[3] = 1462,
		[4] = 1463,
		[5] = 1464,
	}

local MAX_RECORD_NUM = 6

function KuafuTaskRecordView:__init()
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "TaksRecordView"}}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuafuTaskRecordView:__delete()

end

function KuafuTaskRecordView:LoadCallBack()
	self.item_list = {}
	local list_delegate = self.node_list["Scroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["CloseWindowBtn"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnSkip"].button:AddClickListener(BindTool.Bind(self.OnClickSkip, self))
	RemindManager.Instance:Bind(self.remind_change, RemindName.ShowKfBattleRemind)
	self.node_list["TxtCost"].text.text = 0
end

function KuafuTaskRecordView:OpenCallBack()
	ClickOnceRemindList[RemindName.ShowKfBattleRemind] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ShowKfBattleRemind)

	self:Flush()
end

function KuafuTaskRecordView:OnFlush()
	if self.node_list["Scroller"] and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:RemainTaskCost()
end

function KuafuTaskRecordView:RemainTaskCost()
	local gold_num = 0
	for i = 1, MAX_RECORD_NUM do
		local task_cfg = KuafuGuildBattleData.Instance:GetTaskCfgInfo(i - 1)
		for k,v in pairs(task_cfg.list) do
			if v.statu ~= 1 then
				gold_num = gold_num + v.cfg.auto_complete_need_gold
			end
		end
	end
	self.gold_num = gold_num
	self.node_list["TxtCost"].text.text = self.gold_num
	local is_can_skip = gold_num > 0
	UI:SetButtonEnabled(self.node_list["BtnSkip"], is_can_skip)
end


function KuafuTaskRecordView:OnClickSkip()
	local str = string.format(Language.Common.ToGoldOneKey, self.gold_num)
	TipsCtrl.Instance:ShowCommonAutoView("", str, function ()
		TaskCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_CROSS_GUIDE)
	end, function ()
		return
	end)
end


function KuafuTaskRecordView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function KuafuTaskRecordView:GetNumberOfCells()
	return MAX_RECORD_NUM
end

function KuafuTaskRecordView:RefreshCell(cell, data_index, cell_index)
	local the_cell = self.item_list[cell]
	if the_cell == nil then
		the_cell = TaskRecordItem.New(cell.gameObject)
		self.item_list[cell] = the_cell
	end

	self.item_list[cell]:SetData((MAX_RECORD_NUM - 1) - data_index)
end

function KuafuTaskRecordView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.ShowKfBattleRemind then
		self:Flush()
	end
end

---------------任务列表对象--------------

TaskRecordItem = TaskRecordItem or BaseClass(BaseRender)

function TaskRecordItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Cellitem"])
end

function TaskRecordItem:__delete( )
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TaskRecordItem:SetData(data_index)
	if nil == data_index then
		return
	end
	self.data = data_index
	local scene_id = IndexToMap[data_index]
	local scene_name = ConfigManager.Instance:GetSceneConfig(scene_id).name
	self.node_list["SceneNameTxt"].text.text = "<color=#FF9E0EFF>" .. scene_name .. "</color>"
	local task_cfg = KuafuGuildBattleData.Instance:GetTaskCfgInfo(data_index)
	if nil ~= task_cfg then
		local finish_num = task_cfg.finish_num
		local total_num = #task_cfg.list
		local flag = finish_num == total_num
		local color = flag and "<color=#89F201>" or "<color=#f9463b>"
		self.node_list["TxtTask"].text.text = "<color=#FFFFFF>" .. "(" .. color .. finish_num .. "</color>" .. "/" .. total_num .. ")" .. "</color>"

		-- if not flag then
			self.node_list["ImgLevel"].image:LoadSprite(ResPath.GetRankTapByIndex(0))
			if data_index == 0 then
				self.node_list["ImgLevel"].image:LoadSprite(ResPath.GetRankTapByIndex(1))
			end
		-- end
		-- self.node_list["ImgLevel"]:SetActive(not flag)

		self.node_list["HasFinish"]:SetActive(flag)
		local data = {item_id = 0, num = 0}
		for k,v in pairs(task_cfg.list) do
			data.item_id = v.cfg.reward_item[0].item_id
			data.num = data.num + v.cfg.reward_item[0].num
			data.is_bind = v.cfg.reward_item[0].is_bind
		end
		self.item_cell:SetData(data)
	end
end