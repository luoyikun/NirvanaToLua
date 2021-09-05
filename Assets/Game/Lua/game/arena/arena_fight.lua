require("game/arena/arena_fight_view")

ArenaFight = ArenaFight or BaseClass(BaseView)
function ArenaFight:__init()
	self.ui_config = {{"uis/views/arena_prefab", "ArenaFight"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.hide = false
end

function ArenaFight:__delete()
end

function ArenaFight:LoadCallBack()
	self.fight_view = ArenaFightView.New(self.node_list["FightPanel"])
	self.node_list["BtnExit"].button:AddClickListener(BindTool.Bind(self.ClickExit, self))
end

function ArenaFight:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	self.count_panel = nil
	self.fight_panel = nil
	self.block = nil
end

function ArenaFight:OpenCallBack()
	self:OpenFightView()
	self.fight_view:OpenCallBack()
end

function ArenaFight:OnFlush()
end

function ArenaFight:OpenFightView()
	self:CloseAllView()
	if self.node_list["FightPanel"] then
		self.node_list["FightPanel"]:SetActive(true)
		-- self.fight_view:StartCountDown()
	end
end

function ArenaFight:StartCountDown()
	if self.fight_view then
		self.fight_view:StartCountDown()
	end
end

function ArenaFight:CloseAllView()
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

function ArenaFight:StartFight()
	self:OpenFightView()
	if self.node_list["Block"] then
		self.node_list["Block"]:SetActive(false)
	end
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

function ArenaFight:OpenRewardPanel()
	self:CloseAllView()
end

function ArenaFight:ClickExit()
	local func = function()
		self:OpenRewardPanel()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit2, nil, nil, false)
end