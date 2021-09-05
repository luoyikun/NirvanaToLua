WeddingByView = WeddingByView or BaseClass(BaseView)

function WeddingByView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "WeddingByView"}}
	self.view_layer = UiLayer.Pop
	self.vew_cache_time = 0
end

function WeddingByView:__delete()

end
	
function WeddingByView:LoadCallBack()
	self.item_cell = {}
	for i=1,4 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.node_list["ItemReward" .. i])
		self.item_cell[i]:SetParentActive(false)
	end

	self.node_list["BtnAgree"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self, 1))
	self.node_list["BtnDisAgree"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self, 0))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickBtn, self, 0))
end

function WeddingByView:ReleaseCallBack()
	for _,v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function WeddingByView:OpenCallBack()
	self:Flush()
end

function WeddingByView:ClickBtn(is_accept)
	local info = MarriageData.Instance:GetReqWeddingInfo()
	if not next(info) then
		self:Close()
		return
	end
	if is_accept == 1 then
		--同意结婚打开摁指印界面
		local cfg = MarriageData.Instance:GetMarriageConditions()
		if nil == cfg then return end
		local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
		if npc_info then
			MoveCache.end_type = MoveEndType.DoNothing
			MoveCache.param1 = cfg.marry_npc_id
			GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
		end
		ViewManager.Instance:Open(ViewName.WeddingHunShuView)
	end
	MarriageCtrl.Instance:SendMarryRet(info.marry_type, is_accept, info.req_uid)
	self:Close()
end

function WeddingByView:OnFlush()
	local info = MarriageData.Instance:GetReqWeddingInfo()
	for k, v in pairs(self.item_cell) do
		v:SetParentActive(false)
	end
	if not next(info) then
		return
	end
	local from_name = info.GameName
	self.node_list["TxtDes1"].text.text = string.format(Language.Marriage.FromName, from_name)
	local hunli_name = Language.HunLiName[info.marry_type] or ""
	local friend_info = ScoietyData.Instance:GetFriendInfoByName(from_name)
	if next(friend_info) then
		local str = friend_info.sex == 1 and Language.Common.Person[3][1] or Language.Common.Person[3][2]
		self.node_list["TxtDes2"].text.text = string.format(Language.Marriage.Reserve, str, hunli_name)
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local hunli_info = MarriageData.Instance:GetHunliInfoByType(info.marry_type)
	if not next(hunli_info) then
		return
	end

	local reward_item = hunli_info.reward_item
	local reward_info = MarriageData.Instance:GetYuYueRoleInfo().param_ch5
	local reward = bit:d2b(reward_info)
	for k,v in pairs(reward_item) do
		self.item_cell[k + 1]:SetParentActive(true)
		self.item_cell[k + 1]:SetData(v)
		self.item_cell[k + 1]:ShowToLeft(reward[32 - info.marry_type] == 1, ResPath.GetItemQualityTagBg("green"))
		self.item_cell[k + 1]:SetTopLeftDes(Language.Common.YiHuoDe)
	end
end