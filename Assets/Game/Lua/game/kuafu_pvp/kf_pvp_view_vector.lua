KFPVPViewVector = KFPVPViewVector or BaseClass(BaseView)
EXITTIME = 10 	 -- 退出场景时间
function KFPVPViewVector:__init(instance)
	self.ui_config = {{"uis/views/kuafu3v3_prefab", "KuaFu3v3Vector"}}
	-- self.camera_mode = UICameraMode.UICameraLow
	-- self.view_layer = UiLayer.MainUILow
	self.play_audio = true
	self.rank_list = {}
	self.is_modal = true
	
end

function KFPVPViewVector:__delete()

end

function KFPVPViewVector:LoadCallBack()
	self.node_list["OnClickBtn"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	local list_delegate = self.node_list["RankListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell,self)
	self:SetRestTimeChu(EXITTIME)
end

function KFPVPViewVector:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if nil ~= self.count_down_chu then
		GlobalTimerQuest:CancelQuest(self.count_down_chu)
		self.count_down_chu = nil
	end

	if self.rank_list then
		for k,v in pairs(self.rank_list) do
			v:DeleteMe()
		end
	end
	self.rank_list = {}
	
end

function KFPVPViewVector:CloseCallBack()
	if nil ~= self.count_down_chu then
		GlobalTimerQuest:CancelQuest(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function KFPVPViewVector:OpenCallBack()
	self:Flush()
end

function KFPVPViewVector:OnFlush()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:OnClick() end, EXITTIME)
	self.node_list["RankListView"].scroller:ReloadData(0)
	local role_info = KuafuPVPData.Instance:GetRoleInfo()
	local macth_info = KuafuPVPData.Instance:GetPrepareInfo()
	local img = "icon_lose"
	local img2 = "bg_lose"
	if role_info.self_side == macth_info.win_side then
		img = "icon_victory"
		img2 = "bg_victory"
	end
	self.node_list["FinishImg"].image:LoadSprite(ResPath.GetKf3V3(img))
	self.node_list["FinishImgTitle"].raw_image:LoadSprite(ResPath.GetKf3V3FinishImg(img2))
end


function KFPVPViewVector:OnClick()
	self:Close()
	CrossServerCtrl.Instance:GoBack()
end


function KFPVPViewVector:SetRestTimeChu(diff_time)
	if self.count_down_chu == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				return
			end
			local time_str = ""
			time_str = string.format(Language.Kuafu3V3.EndTime, left_time)
			if self.node_list then
				self.node_list["TextEndTime"].text.text = time_str
			end
		end
		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function KFPVPViewVector:GetNumberOfCells()
	return #KuafuPVPData.Instance:GetPrepareInfo().user_info_list
end

function KFPVPViewVector:RefreshCell(cellobj, index)
	local cell = self.rank_list[cellobj]
	if cell == nil then
		cell = RankItemCell.New(cellobj.gameObject)
		cell.parent_view = self
		self.rank_list[cellobj] = cell

	end
	cell:SetData(KuafuPVPData.Instance:GetUserInfoList(index + 1))
end

----------------RankItemCell-----------------------
RankItemCell = RankItemCell or BaseClass(BaseCell)
function RankItemCell:__init()

end


function RankItemCell:__delete()
	self.parent_view = nil
end

function RankItemCell:OnFlush()
	if not self.data then
		return
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["Name"].text.text = self.data.name

	local my_team = KuafuPVPData.Instance:GetRoleTeamIndex()
	if my_team ~= nil and self.data.team == my_team then
		self.node_list["RankItem"].image:LoadSprite(ResPath.GetKf3V3("blue_jifen_bg"))
		if main_role_id.obj_id == self.data.obj_id then
			self.node_list["RankItem"].image:LoadSprite(ResPath.GetKf3V3("myjiesuan_bg"))
		end
	else
		self.node_list["RankItem"].image:LoadSprite(ResPath.GetKf3V3("red_jifen_bg"))
	end

	self.node_list["JiSha"].text.text = self.data.kills
	self.node_list["ZhuGong"].text.text = self.data.assist
	self.node_list["GongXun"].text.text = self.data.add_gongxun
	self.node_list["JiFen"].text.text = self.data.add_score
	self.node_list["Mvp"]:SetActive(self.data.is_mvp == 1)

end