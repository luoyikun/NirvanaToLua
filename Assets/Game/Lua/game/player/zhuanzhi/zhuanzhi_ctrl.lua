require("game/player/zhuanzhi/zhuanzhi_data")

--------------------------------------------------------------
--转职相关
--------------------------------------------------------------
ZhuanZhiCtrl = ZhuanZhiCtrl or BaseClass(BaseController)

local zhuanzhi_cg_list = {
	[1] = {"cg/zz_nanjian_prefab", "Zz_nanjian"},
	[2] = {"cg/zz_nanqin_prefab", "Zz_nanqin"},
	[3] = {"cg/zz_nvshuangjian_prefab", "Zz_nvshuangjian"},
	[4] = {"cg/zz_nvpao_prefab", "Zz_nvpao"},
}
function ZhuanZhiCtrl:__init()
	if ZhuanZhiCtrl.Instance then
		print_error("[ZhuanZhiCtrl] Attemp to create a singleton twice !")
	end
	ZhuanZhiCtrl.Instance = self

	self.data = ZhuanZhiData.New()

	self:RegisterAllProtocols()

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.ZhuanZhiTaskChange, self))

	-- 首次刷新数据
	self:PlayerDataChangeCallback("prof", PlayerData.Instance.role_vo["prof"])

	-- 干嘛初始化就抛事件？根本没响应
	-- RemindManager.Instance:Fire(RemindName.ZhuanZhi)
	-- RemindManager.Instance:Fire(RemindName.JueXing)
	-- RemindManager.Instance:Fire(RemindName.AllZhuanZhi)
end

function ZhuanZhiCtrl:__delete()
	ZhuanZhiCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end
end

function ZhuanZhiCtrl:RegisterAllProtocols()
	-- 转职
	self:RegisterProtocol(CSRoleZhuanZhiReq)

	self:RegisterProtocol(SCRoleZhuanZhiInfo, "OnSCRoleZhuanZhiInfo")
	self:RegisterProtocol(SCZhuanzhiSkillTrigger, "OnZhuanzhiSkillTrigger")
end

 -- 转职点亮请求
function ZhuanZhiCtrl:SendRoleZhuanZhi(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleZhuanZhiReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

-- 转职信息
function ZhuanZhiCtrl:OnSCRoleZhuanZhiInfo(protocol)
	self.data:SetZhuanZhiAllInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Player)
end

-- 转职信息
function ZhuanZhiCtrl:OnZhuanzhiSkillTrigger(protocol)


end

function ZhuanZhiCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if IS_AUDIT_VERSION then
		return
	end
	if attr_name == "prof" then
		local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
		if value and old_value and value > old_value then
			if not CgManager.Instance:IsCgIng() then
				local asset, name = zhuanzhi_cg_list[base_prof][1], zhuanzhi_cg_list[base_prof][2]
				CgManager.Instance:Play(BaseCg.New(asset, name), function() end,
					function(cg_obj)
						ViewManager.Instance:CloseAll()
						local main_role = Scene.Instance:GetMainRole()
						cg_obj.transform.position = main_role:GetDrawObj():GetRoot().transform.position

						GuajiCtrl.Instance:CancelSelect()
						local variable_table = U3DNodeList(cg_obj.transform:Find("UI"):GetComponent(typeof(UINameTable)))
						local is_zhuanzhi = zhuan <= 8
						variable_table["zhuan"]:SetActive(is_zhuanzhi)
						variable_table["zhi"]:SetActive(is_zhuanzhi)
						variable_table["jue"]:SetActive(not is_zhuanzhi)
						variable_table["xing"]:SetActive(not is_zhuanzhi)
					end)
			end
		end
	end
end

function ZhuanZhiCtrl:ZhuanZhiTaskChange(task_event_type, task_id)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHUANZHI then
		RemindManager.Instance:Fire(RemindName.ZhuanZhi)
		RemindManager.Instance:Fire(RemindName.JueXing)
		RemindManager.Instance:Fire(RemindName.AllZhuanZhi)
		if TASK_ZHUANZHI_AUTO and task_cfg.task_type == TASK_TYPE.ZHUANZHI and TaskData.Instance:GetTaskIsCanCommint(task_id) then
			local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
			if zhuan < TASK_AUTO_ZHUANZHI_LEVEL then
				local callback = function()
					TaskCtrl.Instance:DoTask(task_id)
				end
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
				callback()
			end
		end
	end
end
