KuaFu1v1ViewRank = KuaFu1v1ViewRank or BaseClass(BaseRender)

local Count = 4

local ListViewDelegate = ListViewDelegate

function KuaFu1v1ViewRank:__init()
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FpTxt"])
	self.rank_info_list = {}
	for i = 1, Count do
		self.rank_info_list[i] = {}
		local name_table = self.node_list["CellInfo" .. i]:GetComponent(typeof(UINameTable))
		self.rank_info_list[i].no1 = U3DObject(name_table:Find("No1Img"), nil, self)
		self.rank_info_list[i].no2 = U3DObject(name_table:Find("No2Img"), nil, self)
		self.rank_info_list[i].no3 = U3DObject(name_table:Find("No3Img"), nil, self)
		self.rank_info_list[i].rank = U3DObject(name_table:Find("RankTxt"), nil, self)
		self.rank_info_list[i].name = U3DObject(name_table:Find("NameTxt"), nil, self)
		self.rank_info_list[i].grade = U3DObject(name_table:Find("GradeTxt"), nil, self)
		self.rank_info_list[i].ji_fen = U3DObject(name_table:Find("JiFenTxt"), nil, self)
		self.rank_info_list[i].reward = U3DObject(name_table:Find("RewardTxt"), nil, self)
		self.rank_info_list[i].level = U3DObject(name_table:Find("Level"), nil, self)
		self.rank_info_list[i].txt_level = U3DObject(name_table:Find("Txt_level"), nil, self)
	end

	self.rank_info_myself = {}
	local name_table = self.node_list["CellInfoSelf"]:GetComponent(typeof(UINameTable))
	self.rank_info_myself.no1 = U3DObject(name_table:Find("Num1"), nil, self)
	self.rank_info_myself.no2 = U3DObject(name_table:Find("Num2"), nil, self)
	self.rank_info_myself.no3 = U3DObject(name_table:Find("Num3"), nil, self)
	self.rank_info_myself.rank = U3DObject(name_table:Find("RankTxt"), nil, self)
	self.rank_info_myself.name = U3DObject(name_table:Find("NameTxt"), nil, self)
	self.rank_info_myself.grade = U3DObject(name_table:Find("GradeTxt"), nil, self)
	self.rank_info_myself.ji_fen = U3DObject(name_table:Find("JiFenTxt"), nil, self)
	self.rank_info_myself.reward = U3DObject(name_table:Find("RewardTxt"), nil, self)
	self.rank_info_myself.txt_level = U3DObject(name_table:Find("Txt_level"), nil, self)
	self.rank_info_myself.level = U3DObject(name_table:Find("Level"), nil, self)


	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["NextPageBtn"].button:AddClickListener(BindTool.Bind(self.SwitchRankListPage, self,"next"))
	self.node_list["PrePageBtn"].button:AddClickListener(BindTool.Bind(self.SwitchRankListPage, self,"last"))
	self.node_list["JumpPageBtn"].button:AddClickListener(BindTool.Bind(self.OnClickJumpPage, self))
	self.curret_page = 1
	self.total_page = 1

	self.rank_info = {}
	self:LoadSingleTitle(KuaFu1v1Data.Instance:GetTitleId() or 0)
	self:FlushFp()
	self:Flush()
end

function KuaFu1v1ViewRank:LoadCallBack()
	
end

function KuaFu1v1ViewRank:OpenCallBack()
	self:Flush()
	KuaFu1v1Ctrl.Instance:SendGetCross1V1RankListReq()
end

function KuaFu1v1ViewRank:__delete()
	if self.single_obj_transform ~= nil then
		ResMgr:Destroy(self.single_obj_transform.gameObject)
		self.single_obj_transform = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["FirstTitleImg"])
end

function KuaFu1v1ViewRank:OnFlush()
	self.rank_info = KuaFu1v1Data.Instance:GetRankList()
	if self.rank_info then
		local count = #self.rank_info
		self.total_page = count / Count
		self.total_page = math.ceil(self.total_page)
		if self.total_page == 0 then
			self.total_page = 1
		end
	end
	self:FlushSelfInfo()
	self.curret_page = 1
	self:FlushPage(self.curret_page)
	self:FlushModel()
end

function KuaFu1v1ViewRank:FlushSelfInfo()
	self.rank_info_myself.no1:SetActive(false)
	self.rank_info_myself.no2:SetActive(false)
	self.rank_info_myself.no3:SetActive(false)
	self.rank_info_myself.rank.text.text = ""

	self.info_self = KuaFu1v1Data.Instance:GetRoleData()
	if self.rank_info and self.info_self then
		self.rank_info_myself.ji_fen.text.text = self.info_self.cross_score_1v1
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local role_id = vo.role_id
		local rank = 0
		for k,v in pairs(self.rank_info) do
			if v.user_id == role_id then
				rank = k
			end
		end
		if rank == 0 then
			self.rank_info_myself.rank.text.text = Language.Kuafu1V1.NoRank
		else
			if rank == 1 then
				self.rank_info_myself.no1:SetActive(true)
			elseif rank == 2 then
				self.rank_info_myself.no2:SetActive(true)
			elseif rank == 3 then
				self.rank_info_myself.no3:SetActive(true)
			else
				self.rank_info_myself.rank.text.text = rank
			end
		end
		self.rank_info_myself.reward.text.text = vo.capability
		self.rank_info_myself.name.text.text = vo.name
		local config = KuaFu1v1Data.Instance:GetRankByScore(self.info_self.cross_score_1v1)
		if config then
			self.rank_info_myself.grade.text.text = config.name
		else
			self.rank_info_myself.grade.text.text = Language.Common.WuDuanWei
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		self.rank_info_myself.txt_level.text.text = vo.level
		-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(vo.level)
		-- self.rank_info_myself.level.text.text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
		self.rank_info_myself.level.text.text = vo.server_id
		-- local bundle, asset = AvatarManager.GetDefAvatar(vo.prof, false, vo.sex)
		-- self.rank_info_myself.touxiang.image:LoadSprite(bundle, asset)
	end
end

function KuaFu1v1ViewRank:FlushPage(page)
	if page > self.total_page then
		return
	end
	self:ClearPage()
	self.curret_page = page
	self.node_list["PageTxt"].text.text = self.curret_page .. "/" .. self.total_page
	for i = 1, Count do
		local info = self.rank_info[(page - 1) * Count + i]
		if not info then return end
		if page == 1 then
			if i <= 3 then
				self.rank_info_list[i]["no" .. i]:SetActive(true)
			else
				self.rank_info_list[i].rank.text.text = (page - 1) * Count + i
			end
		else
			self.rank_info_list[i].rank.text.text = (page - 1) * Count + i
		end
		local num = (page - 1) * Count + i
		if num == 1 and num <= 10 then
			num = 1
		elseif num <= 50  then
			num = 2
		elseif num <= 100  then
			num = 3
		end
		local is_show = info.user_name == ""
		-- self.rank_info_list[i].touxiang_node:SetActive(not is_show)

		self.rank_info_list[i].reward.text.text = info.flexible_ll
		self.rank_info_list[i].name.text.text = info.user_name
		self.rank_info_list[i].ji_fen.text.text =  info.rank_value
		self.rank_info_list[i].txt_level.text.text = info.level
		local config = KuaFu1v1Data.Instance:GetRankByScore(info.rank_value)
		if config then
			self.rank_info_list[i].grade.text.text = config.name
		else
			self.rank_info_list[i].grade.text.text = Language.Common.WuDuanWei
		end
		-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(info.level)
		-- self.rank_info_list[i].level.text.text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
		self.rank_info_list[i].level.text.text = info.server_id
		local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
		-- self.rank_info_list[i].touxiang.image:LoadSprite(bundle, asset)
	
		
	end
end

function KuaFu1v1ViewRank:ClearPage()
	for i = 1, Count do
		self.rank_info_list[i].no1:SetActive(false)
		self.rank_info_list[i].no2:SetActive(false)
		self.rank_info_list[i].no3:SetActive(false)
		self.rank_info_list[i].rank.text.text = ""
		self.rank_info_list[i].name.text.text = ""
		self.rank_info_list[i].grade.text.text = ""
		self.rank_info_list[i].ji_fen.text.text = ""
		self.rank_info_list[i].reward.text.text = ""
		self.rank_info_list[i].level.text.text = ""
		self.rank_info_list[i].txt_level.text.text = ""
		-- self.rank_info_list[i].touxiang_node:SetActive(false)
	end
end

function KuaFu1v1ViewRank:SwitchRankListPage(key)
	if "next" == key then
		self.curret_page = self.curret_page + 1
	elseif "last" == key then
		self.curret_page = self.curret_page - 1
	end

	if self.curret_page < 1 then
		self.curret_page = 1
	elseif self.curret_page > self.total_page then
		self.curret_page = self.total_page
	end
	self:FlushPage(self.curret_page)
end

function KuaFu1v1ViewRank:OnClickJumpPage()
end

function KuaFu1v1ViewRank:InputEnd(count)
	self.curret_page = count or self.curret_page
	self:FlushPage(self.curret_page)
end

function KuaFu1v1ViewRank:OnClickGetReward()
end

function KuaFu1v1ViewRank:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(94)
end


function KuaFu1v1ViewRank:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["DisPlay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if self.role_model then
		self.role_model:ResetRotation()
		if self.rank_info and self.rank_info[1] then
			self.node_list["firstImg"]:SetActive(false)
			self.role_model:SetModelResInfo(self.rank_info[1], false, true, true)
		else
			self.node_list["firstImg"]:SetActive(true)
			if self.role_model then
				self.role_model:ClearModel()
			end
		end
	end
end

function KuaFu1v1ViewRank:FlushFp()
	local shizhuang_id = KuaFu1v1Data.Instance:GetShiZhuangId() or 0
	local shizhuang_cfg = FashionData.Instance:GetClothingConfig(shizhuang_id) or {}
	local fp = CommonDataManager.GetCapability(shizhuang_cfg) or 0
	local title_id = KuaFu1v1Data.Instance:GetTitleId() or 0
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id) or {}
	local title_fp = CommonDataManager.GetCapability(title_cfg) or 0
	fp = fp + title_fp
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = title_fp
	end
end

function KuaFu1v1ViewRank:LoadSingleTitle(title_id)
	local bundle, asset = ResPath.GetTitleIcon(title_id)
	self.node_list["FirstTitleImg"].image:LoadSprite(bundle, asset, function()
		self.node_list["FirstTitleImg"].image:SetNativeSize()
		end)
	TitleData.Instance:LoadTitleEff(self.node_list["FirstTitleImg"], title_id, true)
end