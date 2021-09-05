--天象
ShenYinTianXiangView = ShenYinTianXiangView or BaseClass(BaseRender)

local season_num = 4

local MOVE_TIME = 0.5	-- 界面动画时间

function ShenYinTianXiangView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-150, -24, 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["OpenBtn"], Vector3(253, 200 , 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right2"], Vector3(-715, -100, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right1"], Vector3(300, -24 , 0 ), MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["MiddleContent"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["MiddleContent"], Vector3(-114, -100, 0 ), MOVE_TIME)
end

function ShenYinTianXiangView:__init()
	self.select_btn = GameEnum.SEASONS_MIN
	self.show_anim_count = 0
	self.cell_list = {}
	self.piece_list = {}

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["CountTxt"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["Txtcapability"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["NumberTxt"])
	for i = 1, 9 do
		local group_obj = self.node_list["PieceContent"].transform:FindHard("Group" .. i)
		self.piece_list[i] = {}
		for j = 1, 9 do
			if nil ~= group_obj:FindHard("piece" .. j) then
				self.piece_list[i][j] = TianXiangItem.New()
				self.piece_list[i][j]:SetInstanceParent(group_obj.transform:FindHard("piece" .. j))
				self.piece_list[i][j].parent_view = self
				if i > 5 then
					self.piece_list[i][j]:SetData({x = j + i - 5, y = i})
				else
					self.piece_list[i][j]:SetData({x = j, y = i})
				end
			end
		end
	end

	self.season_name_list = {}
	self.high_light_list = {}
	for i = 1, season_num do
		self.season_name_list[i] = self.node_list["Txtseason" .. i]
		self.high_light_list[i] = self.node_list["SelectImg" .. i]
		self.node_list["TianXiangBtn" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ClickSeasonBtn, self, i + GameEnum.SEASONS_MIN - 1))
	end

	self.node_list["RightBg"].button:AddClickListener(BindTool.Bind(self.ClickOpenAllAttr,self))
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp,self))
	self.node_list["MaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickCloseDetail,self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.ClickOpenChangeView,self))
	self.node_list["OpenBtn"].button:AddClickListener(BindTool.Bind(self.OpenGroupAttrView,self))
	self.tianxiang_combine_cfg = ShenYinData.Instance:GetTianXiangCombineAttrCfg()
	self.list_view = self.node_list["ListView"]
	self.list_view_delegate = self.node_list["ListView"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self:ShowAnim(1)
	if self.anim_countdown == nil then
		self.anim_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowAnim, self, 1), 1)
	end

	self:SetHaveBollNum()
end

function ShenYinTianXiangView:__delete()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				v1:DeleteMe()
				v1 = nil
			end
		end
	end
	self.piece_list = {}

	self.season_name_list = {}
	self.tianxiang_combine_cfg = {}
	self.select_btn = 1
	self.fangyu_attr = nil
	self.capability = nil
	self.boll_num = nil
	self.max_boll_num = nil
	self.select_data = nil 
	self.cur_type = nil
	self.first_open = true
	self.season_name_list = nil
	self.list_view_delegate = nil
	self.season_name_list = nil
	self.high_light_list = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
	self.fight_text3 = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.anim_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.anim_countdown)
		self.anim_countdown = nil
	end
end

function ShenYinTianXiangView:OpenCallBack()
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.ALL_INFO)
	self:Flush()
end

function ShenYinTianXiangView:OnFlush(param_t)
	self.tianxiang_combine_cfg = ShenYinData.Instance:GetTianXiangCombineAttrCfg()
	for i = 1, season_num do
		local cfg = ShenYinData.Instance:GetTianXiangActiveCfg(self.tianxiang_combine_cfg[GameEnum.SEASONS_MIN + i - 1].seq)
		if cfg then
			self.season_name_list[i].text.text = ("<color=#00ff47ff>" .. (self.tianxiang_combine_cfg[GameEnum.SEASONS_MIN + i - 1].name or "") .. "</color>")
		else
			self.season_name_list[i].text.text = ("<color=#B7D3F9FF>" .. (self.tianxiang_combine_cfg[GameEnum.SEASONS_MIN + i - 1].name or "") .. "</color>")
		end
	end
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end

	local bead_list = ShenYinData.Instance:GetBeadList()
	local att = ShenYinData.Instance:CountAtt()
	local sea, tx, sea_len, tx_len= ShenYinData.Instance:CountSeasonsAndTianXiang()

	local info_data = {}
	table.insert(info_data, att)
	table.insert(info_data, sea)
	table.insert(info_data, tx)
	local combat_power = CommonStruct.Attribute()
	for k, v in pairs(info_data) do
		combat_power = CommonDataManager.AddAttributeAttr(combat_power, v)
	end
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = CommonDataManager.GetCapability(combat_power)
	end
	self:FlushRightView()
	self:FlushPieceView()

	local list = ShenYinData.Instance:GetCombineList()
	if next(list) == nil then
		for i = 1, 9 do
			for j = 1, 9 do
				if self.piece_list[i] and self.piece_list[i][j] then
					self.piece_list[i][j]:SetShowAnim(false)
				end
			end
		end
	end
end

function ShenYinTianXiangView:SetHaveBollNum()
	if self.first_open then return end
	local level_limit_cfg = ShenYinData.Instance:GetLevelLimitCfg()
	local bead_num = ShenYinData.Instance:GetHaveBollNum()

	self.node_list["Txtbollnum"].text.text = bead_num .. " / " .. level_limit_cfg[1].bead_num

	self.first_open = false
end

function ShenYinTianXiangView:GetNumberOfCells()
	return #self.tianxiang_combine_cfg - season_num
end

function ShenYinTianXiangView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = TianXiangBtnRander.New(cell.gameObject)
		group_cell:SetToggleGroup(self.node_list["ToggleGroup"].toggle_group)
		group_cell:SetParent(self)
		self.cell_list[cell] = group_cell
	end

	if data_index < GameEnum.SEASONS_MIN - 1 then
		self.cell_list[cell]:SetData(self.tianxiang_combine_cfg[data_index + 1] or {})
	else
		self.cell_list[cell]:SetData(self.tianxiang_combine_cfg[data_index + GameEnum.SEASONS_MAX + 2 - GameEnum.SEASONS_MIN] or {})
	end
	self.cell_list[cell]:Flush()
	self.cell_list[cell]:FlushSelect()
end

function ShenYinTianXiangView:ClickSeasonBtn(i)
	self.select_btn = i
	for k,v in pairs(self.high_light_list) do
		if self.select_btn == k + GameEnum.SEASONS_MIN - 1 then
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end

	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end

	self:FlushRightView()
end

function ShenYinTianXiangView:GetSelectBtn()
	return self.select_btn
end

function ShenYinTianXiangView:FlushRightView()
	self.node_list["Txtselect"].text.text = self.tianxiang_combine_cfg[self.select_btn].name

	local need_boll_list = ShenYinData.Instance:GetAllBollGroupByBollType(self.select_btn)
	local str = ""
	for k,v in pairs(need_boll_list) do
		local name = ShenYinData.Instance:GetBead(k).name
		if str == "" then
			str = string.format(Language.ShenYin.SeasonBollDec2, name, v)
		else
			str = str .."\t".. string.format(Language.ShenYin.SeasonBollDec2, name, v)
		end
	end
	str = str .. "   "

	self.node_list["Txtneed"].text.text = str

	self.node_list["Txthp"].text.text = string.format(Language.ShenYin.Hp,self.tianxiang_combine_cfg[self.select_btn].maxhp)

	self.node_list["Txtgongji"].text.text = string.format(Language.ShenYin.GongJi,self.tianxiang_combine_cfg[self.select_btn].gongji)

	self.node_list["Txtfangyu"].text.text = string.format(Language.ShenYin.FangYu,self.tianxiang_combine_cfg[self.select_btn].fangyu)
	local capability = CommonDataManager.GetCapability(self.tianxiang_combine_cfg[self.select_btn])
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = capability
	end

	local bundle, asset = ResPath.GetShenYin("page_"..self.select_btn)
	self.node_list["Imgasset"].image:LoadSprite(bundle, asset, function()
			self.node_list["Imgasset"].image:SetNativeSize()
		end)
end

function ShenYinTianXiangView:ShowAnim(index)
	if index > 14 then return end
	self.show_anim_count = (self.show_anim_count + 1) % 14
	local show_anim_list = ShenYinData.Instance:GetTianXiangAllActiveCfg(self.show_anim_count)
	if show_anim_list == nil then 
		self:ShowAnim(index + 1)
		return 
	end
	local data = {}
	for i = 1, 9 do
		data = {}
		for j = 1, 9 do
			if self.piece_list[i] and self.piece_list[i][j] then
				self.piece_list[i][j]:SetShowAnim(false)
				data = self.piece_list[i][j]:GetData()
				for k,v in pairs(show_anim_list) do
					if v.x == data.x - 1 and v.y == data.y - 1 then
						self.piece_list[i][j]:SetShowAnim(true)
					end
				end
			end
		end
	end
end

function ShenYinTianXiangView:OnClickCloseDetail()
	if self.node_list["DetailTxt"] then
		self.node_list["DetailTxt"]:SetActive(false)
	end
end

function ShenYinTianXiangView:ClickOpenAllAttr()
	ViewManager.Instance:Open(ViewName.ShenYinTianXiangAttrView)
end

function ShenYinTianXiangView:ClickOpenChangeView()
	local shenyin_other_cfg = ShenYinData.Instance:GetOtherCFG()
	local describe = string.format(Language.ShenYin.ChangeSpend, shenyin_other_cfg.change_bead_type_need_gold)
	TipsCtrl.Instance:ShowCommonAutoView(Language.Common.DontTip, describe, BindTool.Bind(self.ClickYes, self))
end

function ShenYinTianXiangView:ClickYes()
	local other_cfg = ShenYinData.Instance:GetOtherTianxianBoll(self.cur_type)
	local index = math.random(1, 4)
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.CHANGE_BEAD_TYPE, self.select_data.x - 1, self.select_data.y - 1, other_cfg[index].type)

	if self.node_list["DetailTxt"] then
		self.node_list["DetailTxt"]:SetActive(false)
	end
end

function ShenYinTianXiangView:OpenGroupAttrView()
	ViewManager.Instance:Open(ViewName.TianXiangGroupAttrView)
end

function ShenYinTianXiangView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(240)
end

function ShenYinTianXiangView:FlushPieceView()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				v1:OnFlush()
			end
		end
	end
end

function ShenYinTianXiangView:CloseDetail()
	self.node_list["DetailTxt"]:SetActive(false)
end

function ShenYinTianXiangView:SelectChange(data, cur_type)
	if data == nil then return end

	self.select_data = data
	self.cur_type = cur_type
	local boll_cfg = ShenYinData.Instance:GetBead(cur_type)
	if boll_cfg then 
		self.node_list["DetailTxt"]:SetActive(true)
		self.node_list["Txtshowhp"]:SetActive(boll_cfg.maxhp > 0)
		self.node_list["Txtshowgongji"]:SetActive(boll_cfg.gongji > 0)
		self.node_list["Txtshowfangyu"]:SetActive(boll_cfg.fangyu > 0)
		self.node_list["Txtshowmingzhong"]:SetActive(boll_cfg.mingzhong > 0)
		self.node_list["ShanbiNode"]:SetActive(boll_cfg.shanbi > 0)
		self.node_list["BaojiNode"]:SetActive(boll_cfg.baoji > 0)
		self.node_list["KangBaoNode"]:SetActive(boll_cfg.jianren > 0)
		self.node_list["HpTxt"].text.text = string.format(Language.ShenYin.HpValue,boll_cfg.maxhp)
		self.node_list["GongJiTxt"].text.text = string.format(Language.ShenYin.GongJiValue,boll_cfg.gongji)
		self.node_list["FangYuTxt"].text.text = string.format(Language.ShenYin.FangYuValue,boll_cfg.fangyu)
		self.node_list["MingZhongTxt"].text.text = string.format(Language.ShenYin.MingZhongValue,boll_cfg.mingzhong)
		self.node_list["ShanBiTxt"].text.text = string.format(Language.ShenYin.ShanBiValue,boll_cfg.shanbi)
		self.node_list["KangBaoTxt"].text.text = string.format(Language.ShenYin.KangBaoValue,boll_cfg.jianren)
		self.node_list["BaoJiTxt"].text.text = string.format(Language.ShenYin.BaoJiValue,boll_cfg.baoji)

		self.node_list["Txtpiece"].text.text = boll_cfg.name
		self.node_list["Imgboll"].image:LoadSprite(ResPath.GetTianXiangPieceIcon(cur_type))
		if self.fight_text3 and self.fight_text3.text then
			self.fight_text3.text.text = Language.Common.ZhanLi .. ":" .. CommonDataManager.GetCapability(boll_cfg)
		end
	end
end

TianXiangItem = TianXiangItem or BaseClass(BaseCell)

function TianXiangItem:__init()
	local bundle, asset = ResPath.GetMiscPreloadRes("TianXiangItem")
	local obj = ResPoolMgr:TryGetGameObject(bundle, asset)
	self:SetInstance(obj)

	self.parent_view = nil
	self.node_list["Item"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickItem, self))
	self.icon = self.node_list["icon"]
	self.icon.image.enabled = false
	self.bg = self.node_list["Item"]
	self.node_list["hlImg"]:SetActive(false)

	self.drag_event = BindTool.Bind(self.DragEvent, self)
	self.bg.uidrag:ListenDropCallback(self.drag_event)
	self.icon.uidrag:ListenDropCallback(self.drag_event)
end

function TianXiangItem:__delete()
	self.parent_view = nil

	self.bg.uidrag:UnListenDropCallback(self.drag_event)
	self.icon.uidrag:UnListenDropCallback(self.drag_event)
end

function TianXiangItem:DragEvent(drag_data, drag_obj)
	if self.data == nil then return end

	if nil ~= drag_data then
		local x = math.floor(drag_data / 100)
		local y = drag_data % 100

		local cur_type = ShenYinData.Instance:GetTianxianInfoByPos(self.data.y, self.data.x)
		local drag_type = ShenYinData.Instance:GetTianxianInfoByPos(y, x)
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.CHANGE_BEAD, x - 1, y - 1, self.data.x - 1, self.data.y - 1)
	end
end

function TianXiangItem:OnFlush()
	if self.data == nil then
		return
	end
	
	self.node_list["hlImg"]:SetActive(false)
	self.icon.image.enabled = false
	local cur_type = ShenYinData.Instance:GetTianxianInfoByPos(self.data.y, self.data.x)
	if cur_type > 0 then
		self.icon.image.enabled = true
		self.node_list["icon"].image:LoadSprite(ResPath.GetTianXiangPieceIcon(cur_type))
	end

	self.icon.uidrag:SetDragData(self.data.x * 100 + self.data.y)

	self.icon.uidrag:SetIsCanDrag(true)
end

function TianXiangItem:SetImgAssetByType(cur_type)
	if self.image_path and cur_type > 0 then
		self.icon.image.enabled = true
		self.image_path.image:LoadSprite(ResPath.GetTianXiangPieceIcon(cur_type))
	end
end

function TianXiangItem:SetShowAnim(is_show)
	self.node_list["Node"]:SetActive(is_show)
end

function TianXiangItem:OnClickItem()
	local cur_type = ShenYinData.Instance:GetTianxianInfoByPos(self.data.y, self.data.x)
	if cur_type <= 0 then return end
	self.parent_view:SelectChange(self.data, cur_type)
end

function TianXiangItem:GetData()
	return self.data
end


------------------------------------------------
TianXiangBtnRander = TianXiangBtnRander or BaseClass(BaseRender)

function TianXiangBtnRander:__init()
	self.node_list["Click"].toggle:AddValueChangedListener(BindTool.Bind(self.Click, self))
end

function TianXiangBtnRander:__delete()
end

function TianXiangBtnRander:SetData(data)
	self.data = data
	
end

function TianXiangBtnRander:OnFlush()
	local cfg = ShenYinData.Instance:GetTianXiangActiveCfg(self.data.seq)
	if cfg then
		self.node_list["NameTxt"].text.text = ToColorStr(self.data.name or "",TEXT_COLOR.GREEN_4)
	else
		self.node_list["NameTxt"].text.text = ToColorStr(self.data.name or "",TEXT_COLOR.GRAY_WHITE)
	end
end

function TianXiangBtnRander:FlushSelect()
	if self.data == nil then return end
	self.node_list["HighlightImg"]:SetActive(self.data.seq + 1 == self.parent:GetSelectBtn())
end

function TianXiangBtnRander:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TianXiangBtnRander:SetParent(parent)
	self.parent = parent
end

function TianXiangBtnRander:Click()
	self.parent:ClickSeasonBtn(self.data.seq + 1)
end
