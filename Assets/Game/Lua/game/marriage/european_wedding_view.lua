EuropeanWeddingView = EuropeanWeddingView or BaseClass(BaseView)

function EuropeanWeddingView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","EuropeanWeddingView"}}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function EuropeanWeddingView:__delete()
end

function EuropeanWeddingView:LoadCallBack()
	self.select_icon_list = {}
	self.head_list = {}
	local cfg = MarriageData.Instance:GetHunliInfoByType(3)
	for i = 1, 2 do
		self.select_icon_list[i] = WeddingSelectIcon.New(self.node_list["WeddingItem"..i])
		self.select_icon_list[i]:SetIndex(i)
		self.select_icon_list[i]:SetType(i + 2)
		self.select_icon_list[i]:SetData(MarriageData.Instance:GetHunliInfoByType(i + 2))
		self.select_icon_list[i]:SetClickCallBack(BindTool.Bind(self.OnClickSelectIcon, self))

		self.head_list[i] = {}
		self.head_list[i].show_image = self.node_list["ShowImage"..i]
		self.head_list[i].image_res = self.node_list["IconImage"..i]
		self.head_list[i].raw_img_obj = self.node_list["Myhead"..i]
	end
	self.node_list["Buttonquihun"].button:AddClickListener(BindTool.Bind(self.OnClickMakeAProposal,self))
	self.node_list["Buttonchange"].button:AddClickListener(BindTool.Bind(self.OnClickChangeWedding,self))
	self.node_list["Btntip"].button:AddClickListener(BindTool.Bind(self.OnClickHelp,self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClicClose, self))
end

function EuropeanWeddingView:ReleaseCallBack()


	for k,v in pairs(self.select_icon_list) do
		v:DeleteMe()
	end
	self.select_icon_list = {}
	self.head_list = {}
end


function EuropeanWeddingView:OpenCallBack()
	self.index = 0
	self.marriage_type = - 1

	self:Flush()
	self:FlushAvatar()
end

function EuropeanWeddingView:CloseCallBack()
end

function EuropeanWeddingView:OnClickMakeAProposal()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_vo = ScoietyData.Instance:GetFriendInfoByName(main_vo.lover_name) or {}
	if lover_vo.is_online == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end
	if self.marriage_type < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotSelectWeddingDes)
		return
	end
	if not self.gold_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	
	local hunli_info = MarriageData.Instance:GetHunliInfoByType(self.marriage_type)
	local cost = hunli_info.need_gold
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING) then
		if hunli_info and hunli_info.activity_price then
			cost = hunli_info.activity_price
		end
	end
	local des = string.format(Language.Marriage.BuyMarryTypeDes, cost)
	local lover_vo = ScoietyData.Instance:GetFriendInfoById(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	local other_name = lover_vo.gamename
	local other_vo = ScoietyData.Instance:GetFriendInfoByName(other_name) or {}
	local function ok_callback()
		MarriageCtrl.Instance:SendMarryReq(MARRY_REQ_TYPE.MARRY_REQ_TYPE_PROPOSE ,self.marriage_type, other_vo.user_id)
		self:Close()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function EuropeanWeddingView:OnClickChangeWedding()
	ViewManager.Instance:Open(ViewName.Wedding)
	self:Close()
end

function EuropeanWeddingView:OnClicClose()
	self:Close()
end

function EuropeanWeddingView:OnClickHelp()
	local tips_id = 290
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function EuropeanWeddingView:FlushAvatar()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 设置自己的头像
	local role_id = main_role_vo.role_id
	local sex = main_role_vo.sex
	local prof = main_role_vo.prof
	-- AvatarManager.Instance:SetAvatar(role_id, self.head_list[1].show_image, self.head_list[1].image_res, self.head_list[1].raw_img_obj, sex, prof, false)
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["MyRawImage"], self.node_list["MyheadImage"], sex, prof, false)
	-- 设置伴侣的头像
	role_id = main_role_vo.lover_uid
	sex = main_role_vo.sex == GameEnum.MALE and GameEnum.FEMALE or GameEnum.MALE
	prof = MarriageData.Instance:GetLoverProf()
	-- AvatarManager.Instance:SetAvatar(role_id, self.head_list[2].show_image, self.head_list[2].image_res, self.head_list[2].raw_img_obj, sex, prof, false)
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["OtherRawImage"], self.node_list["OtherHeadImage"], sex, prof, false)
end

function EuropeanWeddingView:FlushLimit()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_vo = ScoietyData.Instance:GetFriendInfoByName(main_vo.lover_name) or {}
	local level = MarriageData.Instance:GetMarryLevelLimit()

	self.node_list["Textfactor1"].text.text = string.format(Language.Marriage.Level, level)

	if lover_vo.is_online == 1 then
		self.online_enough = true
		self.node_list["ImgLevelLimitYes2"]:SetActive(true)
	else
		self.online_enough = false
		self.node_list["ImgLevelLimitYes2"]:SetActive(false)
	end

	local cost_enough, is_bind_gold = MarriageData.Instance:CostEnoughByHunliType(self.marriage_type)
	if cost_enough then
		self.gold_enough = true
		 self.node_list["ImgLevelLimitYes3"]:SetActive(true)
	else
		self.gold_enough = false
		 self.node_list["ImgLevelLimitYes3"]:SetActive(false)
	end
end

function EuropeanWeddingView:OnFlush()
	self:FlushLimit()
	self:FlushSelectedList()
	
	for k,v in pairs(self.select_icon_list) do
		v:Flush()
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING)then
		self.node_list["bg_blue_open"]:SetActive(true)	
		self.node_list["bg_red_open"]:SetActive(true)
		self.node_list["bg_blue"]:SetActive(false)	
		self.node_list["bg_red"]:SetActive(false)			
	else
		self.node_list["bg_blue_open"]:SetActive(false)	
		self.node_list["bg_red_open"]:SetActive(false)
		self.node_list["bg_blue"]:SetActive(true)	
		self.node_list["bg_red"]:SetActive(true)			
	end		
end

function EuropeanWeddingView:OnClickSelectIcon(Icon)
	local index = Icon:GetIndex()
	self.index = index
	self.marriage_type = self.index + 2
	if Icon:GetHasGot() then
		local data = Icon:GetData()
		MarriageCtrl.Instance:OpenEuropeanWeddingTips(data)
	end
	self:Flush()
end

function EuropeanWeddingView:FlushSelectedList()
	for k,v in pairs(self.select_icon_list) do
		v:FlushSelectedHL(self.index)
	end
end

-----------------------------------  选择框  -----------------------------------
WeddingSelectIcon = WeddingSelectIcon or BaseClass(BaseCell)
function WeddingSelectIcon:__init()
	--self.title = self.node_list["Title"].text
	self.cost = self.node_list["CostNum"].text
	self.is_bind_gold = self.node_list["Gold"]
	self.title_asset = self.node_list["TitleModel"]
	self.is_selected = self.node_list["SelectImage"]

	self.item_list = {}
	for i = 0, 1 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item"..i])
	end
	self.node_list["WeddingItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick,self))
	-- self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function WeddingSelectIcon:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleModel"])
end

function WeddingSelectIcon:SetType(wedding_type)
	self.wedding_type = wedding_type or 0
end

function WeddingSelectIcon:OnFlush()
	if self.data == nil then
		return
	end
	if not self.data or not next(self.data) then
		return
	end

	self.root_node.toggle.isOn = false


	--self.node_list["Title"].text.text = Language.EuropeanHunliName[self.index] or ""
	self.node_list["CostNum"].text.text = self.data.need_gold --self.data.need_bind_gold > 0 and self.data.need_bind_gold or self.data.need_gold
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING) and self.data.activity_price then
		self.node_list["ActCostNum"].text.text = self.data.activity_price
		self.node_list["ActCostNum"]:SetActive(true)
		self.node_list["line"]:SetActive(true)
	else
		self.node_list["ActCostNum"]:SetActive(false)
		self.node_list["line"]:SetActive(false)
	end	
	-- self.is_bind_gold:SetActive(self.data.need_bind_gold > 0)
	if self.data.title_id > 0 then
		-- local bunble, asset = ResPath.GetTitleModel(self.data.title_id .. ".png")
		local bunble, asset = ResPath.GetTitleIcon(self.data.title_id)
		self.node_list["TitleModel"].image:LoadSprite(bunble, asset .. ".png")
		TitleData.Instance:LoadTitleEff(self.node_list["TitleModel"], self.data.title_id, true)
	end
	if self.data.reward_type ~= nil then
		for i = 0, 1 do
			if self.data.reward_type[i] then
				self.item_list[i]:SetData(self.data.reward_type[i])
				self.item_list[i]:SetParentActive(true)
			else
				self.item_list[i]:SetParentActive(false)
				self.item_list[i]:SetActive(false)
			end
		end
	end

	self.is_got = MarriageData.Instance:IsCanGetHunliReward(self.wedding_type)
	self.node_list["IsGot"]:SetActive(not self.is_got)
end

function WeddingSelectIcon:FlushSelectedHL(index)
	self.is_selected:SetActive(self.index == index)
end

function WeddingSelectIcon:GetHasGot()
	if self.is_got == nil then
		return true
	end

	return self.is_got
end
function WeddingSelectIcon:Click()
	self.root_node.toggle.isOn = true
end


----------------------------------- 选择框end -----------------------------------