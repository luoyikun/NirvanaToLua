require("game/kuafu_1v1/kuafu1v1_view_fight")

KuaFu1v1FightView = KuaFu1v1FightView or BaseClass(BaseView)

function KuaFu1v1FightView:__init()
	self.ui_config = {{"uis/views/kuafu1v1_prefab", "KuaFu1v1Fight"}}
	
	self.camera_mode = UICameraMode.UICameraLow
	-- self.view_layer = UiLayer.MainUILow
	self.hide = false
end


function KuaFu1v1FightView:LoadCallBack()
	self.node_list["ExitBtn"].button:AddClickListener(BindTool.Bind(self.ClickExit, self))
	local info = KuaFu1v1Data.Instance:GetCross1v1FightStart()
	if info.timestamp_type == 1 then
		self:StartFight()
		-- self:StartCountDown()
	end

end
function KuaFu1v1FightView:CreartKuaFu1v1ViewFight()
	self.fight_view = KuaFu1v1ViewFight.New(self.node_list["FightPanel"])
end

function KuaFu1v1FightView:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end
end

function KuaFu1v1FightView:OpenCallBack()
	-- self:OpenFightView()
end

function KuaFu1v1FightView:OnFlush(params_t)
	for k, v in pairs(params_t) do
		if k == "fight" then
			self:StartFight()
		elseif k == "close_all_view" then
			self:CloseAllView()
		end
	end
end

function KuaFu1v1FightView:OpenFightView()
	if self:IsOpen() then
		self.node_list["FightPanel"]:SetActive(true)
		self.node_list["Block"]:SetActive(true)
	end
end

function KuaFu1v1FightView:CloseAllView()
	if self.node_list["FightPanel"] then
		self.node_list["FightPanel"]:SetActive(false)
	end
	if self.node_list["Block"] then
		self.node_list["Block"]:SetActive(true)
	end
end

function KuaFu1v1FightView:StartFight()
	self:OpenFightView()
	if self.fight_view then
		self.fight_view:StartCountDown()
	end
end

function KuaFu1v1FightView:OpenRewardPanel(result)
	self:Flush("close_all_view")
	-- self:CloseAllView()
	if self.fight_view then
		self.fight_view:ClearInfo()
	end
end

function KuaFu1v1FightView:ClickExit()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit, nil, nil, false)
end