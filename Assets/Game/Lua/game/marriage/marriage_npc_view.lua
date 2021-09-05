MarryNpcView = MarryNpcView or BaseClass(BaseView)

function MarryNpcView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","MarryNpcView"}}
	self.is_modal = true
	self.is_any_click_close = true 
end

function MarryNpcView:__delete()

end

function MarryNpcView:LoadCallBack()
	self.node_list["YuyueBtn"].button:AddClickListener(BindTool.Bind(self.OnMarryYuyueBtn, self))
	self.node_list["JiehunBtn"].button:AddClickListener(BindTool.Bind(self.OnMarryJiehunBtn, self))
	self.node_list["LihunBtn"].button:AddClickListener(BindTool.Bind(self.OnMarryLihunBtn, self))
	self.node_list["LeaveBtn"].button:AddClickListener(BindTool.Bind(self.OnMarryLeaveBtn, self))
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function MarryNpcView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BASE_INFO)
	MarriageCtrl.Instance:SendQingyuanBuyLoveContract(LOVE_CONTRACT_REQ_TYPE.LC_REQ_TYPE_INFO)
end
function MarryNpcView:OnMarryYuyueBtn()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end
	ViewManager.Instance:Open(ViewName.MarriageWedding)
	self:Close()
end

function MarryNpcView:OnMarryJiehunBtn()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
	if is_open then
		self:Close()
		ViewManager.Instance:Open(ViewName.Wedding)
	else
		if tips then
			SysMsgCtrl.Instance:ErrorRemind(tips)
		end
	end
end

function MarryNpcView:OnMarryLihunBtn()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end

	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	local divorce_intimacy_dec = MarriageData.Instance:GetIntimacyCost()

	if is_online == 1 then
		local function func()
			MarriageCtrl.Instance:SendDivorceReq(0)
		end
		local des = string.format(Language.Marriage.DivorceQuestionDes, main_role_vo.lover_name)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	else
		local function ok_func()
			MarriageCtrl.Instance:SendDivorceReq(1)
		end
		local diamond_cost = MarriageData.Instance:GetDivorceCost()
		local des = string.format(Language.Marriage.OneSideDivorceQuestion, diamond_cost)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
	end
end

function MarryNpcView:OnMarryLeaveBtn()
	self:Close()
end
