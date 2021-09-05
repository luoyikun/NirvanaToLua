KuafuLiujiePreView = KuafuLiujiePreView or BaseClass(BaseView)
function KuafuLiujiePreView:__init()
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "KuafuLiujiePreView"}}
	self.is_first_open = 1
end

function KuafuLiujiePreView:__delete()

end

function KuafuLiujiePreView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
end

function KuafuLiujiePreView:ReleaseCallBack()
	 if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.ui_title_res)
	self.ui_title_res = nil
	self.ui_title = nil

	self.ui_title_target = nil 
end

function KuafuLiujiePreView:OpenCallBack()
	self.is_first_open = 0
	RemindManager.Instance:Fire(RemindName.ShowKfBattlePreRemind)
	self:SetModel()
end

function KuafuLiujiePreView:SetModel()
	self.current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(0).title_name
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)
	self.model:ResetRotation()
	local res_index = KuafuGuildBattleData.Instance:GetShowImage(1)
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	local role_res_id = 0
	local weapon_id = 0
	local weapon_id2 = 0
	for k, v in pairs(fashion_cfg) do
		if res_index == v.index and v["resouce" .. base_prof .. main_role_vo.sex] then
			if v.part_type == 1 then
				role_res_id = v["resouce" .. base_prof .. main_role_vo.sex]
			else
				weapon_id = v["resouce" .. base_prof .. main_role_vo.sex]
				if base_prof == 3 then
					local t = Split(weapon_id, ",")
					weapon_id = t[1]
					weapon_id2 = t[2] 
				end
			end
		end
	end

	self.model:SetMainAsset(ResPath.GetRoleModel(role_res_id))
	self.model:SetWeaponResid(weapon_id)
	self.model:SetWeapon2Resid(weapon_id2)

	local async_loader = AllocAsyncLoader(self, "PlayerTitle_loader")
	async_loader:Load("uis/views/player_prefab", "PlayerTitle", function(obj)
		if IsNil(obj) then
			return
		end

		self.ui_title = obj
		self.ui_title.transform:SetParent(self.node_list["NodeTitle"].transform, false)
		self.ui_title_target = self.ui_title.transform:GetComponent(typeof(UIFollowTarget))
		local name_table = self.ui_title_target:GetComponent(typeof(UINameTable))
		self.ui_title_res = U3DObject(name_table:Find("Image"))
		self.ui_title:SetActive(true)
	end)
	self.node_list["TxtOpenTime"].text.text = Language.KuafuGuildBattle.KfGuildTips
end


function KuafuLiujiePreView:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function KuafuLiujiePreView:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	if self.ui_title_res then
		self.ui_title_res.image:LoadSprite(bundle, asset .. ".png")
		TitleData.Instance:LoadTitleEff(self.ui_title_res, self.current_title_id, true)
	end
end

function KuafuLiujiePreView:ClickClose()
	self:Close()
end