TowerSelectView = TowerSelectView or BaseClass(BaseView)

function TowerSelectView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "TeamFBTowerSelect"}}
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = true							-- 是否点击其它地方要关闭界面
end

function TowerSelectView:__delete()

end

function TowerSelectView:LoadCallBack()
	self.panel = self.node_list["Panel"]
	self.node_list["BtnGongJi"].button:AddClickListener(BindTool.Bind(self.SendGongJi, self))
	self.node_list["BtnFangYu"].button:AddClickListener(BindTool.Bind(self.SendFangYu, self))
	self.node_list["BtnJiaXue"].button:AddClickListener(BindTool.Bind(self.SendZiDong, self))
	self.node_list["BtnFuZhu"].button:AddClickListener(BindTool.Bind(self.SendFuZhu, self))
end

function TowerSelectView:ReleaseCallBack()
	self.panel = nil
end

function TowerSelectView:OpenCallBack()
	self:SetPos()
end

function TowerSelectView:SetPos()
	local pos = FuBenData.Instance:GetPos()
	self.panel.transform.position = Vector3(pos.x - 8, pos.y - 3, pos.z)
end

function TowerSelectView:SendGongJi()
	local exist_flag = FuBenData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_GONGJI)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = FuBenData.Instance:GetID()
	FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_SET_ATTR_TYPE, id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_GONGJI)
	self:Close()
end

function TowerSelectView:SendFangYu()
	local exist_flag = FuBenData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_FANGYU)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = FuBenData.Instance:GetID()
	FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_SET_ATTR_TYPE, id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_FANGYU)
	self:Close()
end

function TowerSelectView:SendZiDong()
	local id = FuBenData.Instance:GetID()
	FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_SET_ATTR_TYPE, id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_INVALID)
	self:Close()
end

function TowerSelectView:SendFuZhu()
	local exist_flag = FuBenData.Instance:IsAttrTypeExist(TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_ASSIST)
	if exist_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.PleaseSelectRightSkill)
		return
	end
	local id = FuBenData.Instance:GetID()
	FuBenCtrl.Instance:SendTeamTowerDefendSetAttrType(TEAM_TOWER_DEFEND_OPREAT_REQ_TYPE.TEAM_TOWER_DEFEND_SET_ATTR_TYPE, id, TEAM_TOWERDEFEND_ATTRTYPE.TEAM_TOWERDEFEND_ATTRTYPE_ASSIST)
	self:Close()
end