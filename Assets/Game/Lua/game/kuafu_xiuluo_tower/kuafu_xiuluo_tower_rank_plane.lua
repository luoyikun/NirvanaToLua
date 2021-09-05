KuaFuXiuLuoTowerRankView = KuaFuXiuLuoTowerRankView or BaseClass(BaseView)

function KuaFuXiuLuoTowerRankView:__init()
	self.ui_config = {
		{"uis/views/kuafuxiuluotower_prefab", "XiuLuoRankPanel"}
	}
	self.camera_mode = UICameraMode.UICameraLow

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuaFuXiuLuoTowerRankView:__delete()

end

function KuaFuXiuLuoTowerRankView:LoadCallBack()
	self.rank_info = {}
	for i = 1, 10 do
		local name_table = self.node_list["Info" .. i]:GetComponent(typeof(UINameTable))
		local info_node_list = U3DNodeList(name_table)
		self.rank_info[i] = {}
		self.rank_info[i].name = info_node_list["Name"]
		self.rank_info[i].grade = info_node_list["Score"]
	end
	self.my_rank = XiuLuoMyRankCell.New(self.node_list["MyInfo"])

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseRank, self))
	local title_cfg = KuaFuXiuLuoTowerData.Instance:GetTitleCfg()
	if title_cfg then
		for i = 1,3 do
			local res_id = Split(title_cfg[i].title_show, ",")
			local bundle, asset = res_id[1], res_id[2]
			self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, asset, function()
				self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_cfg[i].title_id, true)
		end
	end
	for i = 1, 3 do
		self.node_list["TuanZhanTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
	end
end

function KuaFuXiuLuoTowerRankView:ReleaseCallBack()
	if self.my_rank then
		self.my_rank:DeleteMe()
		self.my_rank = nil
	end
	if TitleData.Instance ~= nil then
		for i = 1, 3 do
			TitleData.Instance:ReleaseTitleEff(self.node_list["TuanZhanTitle" .. i])
		end
	end
end

function KuaFuXiuLuoTowerRankView:OnFlush(param_t)
	self:FlushRank()
end

function KuaFuXiuLuoTowerRankView:OpenCallBack()
	self:FlushRank()
	self.node_list["Panel"].list_page_scroll2:JumpToPageImmidate(0)
end

function KuaFuXiuLuoTowerRankView:CloseRank()
	self:Close()
end

function KuaFuXiuLuoTowerRankView:FlushRank()
	local global_info = KuaFuXiuLuoTowerData.Instance:GetCossXiuluoTowerRankInfoList()
	if global_info then
		local num = KuaFuXiuLuoTowerData.Instance:GetCossXiuluoTowerRankNum() or 0
		for i = 1, num do
			local info = global_info[i]
			if info then
				self.rank_info[i].name.text.text = info.name
				self.rank_info[i].grade.text.text = TimeUtil.FormatSecond(info.finish_time, 7)
			end
		end

		for i = num + 1, 10 do
			self.rank_info[i].name.text.text = Language.Common.ZanWu
			self.rank_info[i].grade.text.text = 0
		end
		self.my_rank:Flush()
	end
end

function KuaFuXiuLuoTowerRankView:ClickTitle(index)
	local title_cfg = KuaFuXiuLuoTowerData.Instance:GetTitleCfg()
	if title_cfg and title_cfg[index] then
		local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
		TipsCtrl.Instance:OpenItem(data)
	end
end

----------------------------------------------XiuLuoMyRankCell--------------------------------------------
XiuLuoMyRankCell = XiuLuoMyRankCell or BaseClass(BaseCell)

function XiuLuoMyRankCell:LoadCallBack()

end
function XiuLuoMyRankCell:OnFlush()
	local my_rank = 0
	local time = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local global_info = KuaFuXiuLuoTowerData.Instance:GetCossXiuluoTowerRankInfoList()
	if global_info then
		for k,v in pairs(global_info) do
			if v.uuid == vo.role_id or vo.name == v.name then
				my_rank = k
				time = TimeUtil.FormatSecond(v.finish_time, 7)
			end
		end
	end
	if my_rank > 0 and my_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(my_rank)
		self.node_list["RankImage1"].image:LoadSprite(bundle, asset)
		self.node_list["RankImage1"]:SetActive(true)
		self.node_list["Rank"]:SetActive(false)
	elseif my_rank == 0 then
		self.node_list["Rank"].text.text = Language.Guild.NoOpponentGuild
		self.node_list["RankImage1"]:SetActive(false)
	else
		self.node_list["Rank"].text.text = my_rank
		self.node_list["RankImage1"]:SetActive(false)
	end
	self.node_list["Name"].text.text = vo.name
	self.node_list["Score"].text.text = time or Language.Common.NoRank
end
