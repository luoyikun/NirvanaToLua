-- 闯关爬塔排行榜-TowerRank
FuBenTowerRank = FuBenTowerRank or BaseClass(BaseView)

function FuBenTowerRank:__init()
	self.ui_config = {
		{"uis/views/fubenview_prefab", "TowerRank"}
	}
	self.play_audio = true
	self.is_any_click_close = false
end

function FuBenTowerRank:__delete()

end

function FuBenTowerRank:ReleaseCallBack()
	for k, v in pairs(self.tower_rank_item_list) do
		v:DeleteMe()
	end
	self.tower_rank_item_list = {}
end

function FuBenTowerRank:LoadCallBack()
	self.node_list["BtnCloseBg"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.tower_data_list = {}
	self.tower_rank_item_list = {}
	local rank_list_delegate = self.node_list["ListView"].list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetItemNumber, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshItem, self)

end

function FuBenTowerRank:CloseWindow()
	UITween.MoveToShowPanel(self.node_list["Panel"], Vector3(265, -27.8, 0), Vector3(-265, -27.8, 0), 0.8, nil,  
		function()
			self:Close()
			local tower_view = GaoZhanCtrl.Instance:GetFuBenTowerView()
			tower_view:SetBtnRankState(true)
		end)
end

function FuBenTowerRank:OpenCallBack()
	RankCtrl.Instance:SendTowerRankOpera(PERSON_RANK_TYPE.PERSON_RANK_TYPE_ROLE_PATA_LAYER)
	UITween.MoveToShowPanel(self.node_list["Panel"], Vector3(-265, -27.8, 0), Vector3(265, -27.8, 0), 0.8)
end

function FuBenTowerRank:CloseCallBack()

end

function  FuBenTowerRank:OnFlush()
	if self.node_list["ListView"] then
	 	self.tower_data_list = FuBenData.Instance:SortTowerRankInfo()
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	self:FlushMyInfo(self.tower_data_list)
end

function FuBenTowerRank:GetItemNumber(value)
	local tower_rank_info = FuBenData.Instance:GetTowerRankInfo()
	if nil == tower_rank_info then
		return 0
	end

	return #tower_rank_info <= 50 and  #tower_rank_info or 50
end

function FuBenTowerRank:RefreshItem(item, index)
	local tower_rank_item = self.tower_rank_item_list[item]
	index = index + 1
	if nil == tower_rank_item then
		tower_rank_item = TowerRankItem.New(item.gameObject)
		self.tower_rank_item_list[item] = tower_rank_item
	end

	local data = self.tower_data_list[index]
	tower_rank_item:SetIndex(index)
	tower_rank_item:SetData(data)
end

function FuBenTowerRank:FlushMyInfo(tower_data_list)
	local game_role = GameVoManager.Instance:GetMainRoleVo()
	local index = 0
	for k, v in pairs(tower_data_list) do
		if v.user_id == game_role.role_id then
			index = k
		end
	end

	self.node_list["ImgIndex"]:SetActive(false)
	if index <= 0 or index > 50 then
		self.node_list["TxtRankLevel"].text.text = "50+"
	elseif index >= 1 and index <=3 then
		local bundle, asset = ResPath.GetTowerRankIcon(index)
		self.node_list["ImgIndex"].image:LoadSprite(bundle, asset)
		self.node_list["TxtRankLevel"].text.text = ""
		self.node_list["ImgIndex"]:SetActive(true)
	elseif index >= 1 and index <=50 then
		self.node_list["TxtRankLevel"].text.text = index
	else
		self.node_list["TxtRankLevel"].text.text = "50+"
	end

	self.node_list["TxtMyName"].text.text = game_role.role_name

	if game_role.vip_level > 0 then
		local asset, bundle = ResPath.GetVipLevelIcon(game_role.vip_level)
		self.node_list["ImgVIP"].image:LoadSprite(asset, bundle .. ".png")
		self.node_list["ImgVIP"]:SetActive(true)
	end

	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	if not fb_info then
		return
	end

	self.node_list["TxtLevel"].text.text = string.format(Language.GaoZhanFuBen.LevelCount, fb_info.pass_level)
	self.node_list["TxtFightPower"].text.text = string.format(Language.GaoZhanFuBen.TxtFightPower, game_role.capability)

end

---------------------------TowerRankItem------------------------------------
TowerRankItem = TowerRankItem or BaseClass(BaseCell)
function TowerRankItem:__init()

end

function TowerRankItem:__delete()

end

function TowerRankItem:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["ImgIndex"]:SetActive(false)
	self.node_list["TxtIndex"].text.text = self.index
	if self.index >= 1 and self.index<= 3 then
		local bundle, asset = ResPath.GetTowerRankIcon(self.index)
		self.node_list["ImgIndex"].image:LoadSprite(bundle, asset)
		self.node_list["TxtIndex"].text.text = ""
		self.node_list["ImgIndex"]:SetActive(true)
	end

	self.node_list["TxtName"].text.text = self.data.user_name
	self.node_list["TxtLevel"].text.text = string.format(Language.GaoZhanFuBen.LevelCount, self.data.rank_value)

	local vip_level = self.data.vip_level or 0
	vip_level = IS_AUDIT_VERSION and 0 or vip_level
	self.node_list["ImgVIP"]:SetActive(vip_level ~= 0)
	
	local asset, bundle = ResPath.GetVipLevelIcon(vip_level)
	self.node_list["ImgVIP"].image:LoadSprite(asset, bundle .. ".png")

	self.node_list["TxtFightPower"].text.text = string.format(Language.GaoZhanFuBen.TxtFightPower, self.data.flexible_int)
end

