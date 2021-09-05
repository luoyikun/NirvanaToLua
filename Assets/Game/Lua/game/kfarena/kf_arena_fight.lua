require("game/kfarena/kf_arena_fight_view")

KFArenaFight = KFArenaFight or BaseClass(BaseView)
function KFArenaFight:__init()
	self.ui_config = {{"uis/views/kfarenaview_prefab", "KFArenaFight"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.hide = false
end

function KFArenaFight:__delete()
end

function KFArenaFight:LoadCallBack()
	self.fight_view = KFArenaFightView.New(self.node_list["FightPanel"])
	self.node_list["BtnExit"].button:AddClickListener(BindTool.Bind(self.ClickExit, self))
end

function KFArenaFight:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	self.count_panel = nil
	self.fight_panel = nil
	self.block = nil
end

function KFArenaFight:OpenCallBack()
	self:OpenFightView()
	self.fight_view:OpenCallBack()
end

function KFArenaFight:OnFlush()
end

function KFArenaFight:OpenFightView()
	self:CloseAllView()
	if self.node_list["FightPanel"] then
		self.node_list["FightPanel"]:SetActive(true)
		-- self.fight_view:StartCountDown()
	end
end

function KFArenaFight:StartCountDown()
	if self.fight_view then
		self.fight_view:StartCountDown()
	end
end

function KFArenaFight:CloseAllView()
	if self.node_list then
		if self.node_list["FightPanel"] then
			self.node_list["FightPanel"]:SetActive(false)
		end
		if self.node_list["CountPanel"] then
			self.node_list["CountPanel"]:SetActive(false)
		end
		if self.node_list["Block"] then
			self.node_list["Block"]:SetActive(true)
		end
	end
	if self.fight_view then
		self.fight_view:CloseCallBack()
	end
end

function KFArenaFight:StartFight()
	self:OpenFightView()
	if self.node_list["Block"] then
		self.node_list["Block"]:SetActive(false)
	end
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

function KFArenaFight:OpenRewardPanel()
	self:CloseAllView()
end

function KFArenaFight:ClickExit()
	local func = function()
		self:OpenRewardPanel()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.KFArena.Exit2, nil, nil, false)
end