require("game/advance/fightmount/fight_mount_data")

FightMountCtrl = FightMountCtrl or BaseClass(BaseController)

function FightMountCtrl:__init()
	if FightMountCtrl.Instance then
		return
	end
	FightMountCtrl.Instance = self

	self:RegisterAllProtocols()
	self.data = FightMountData.New()
end

function FightMountCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	FightMountCtrl.Instance = nil
end

function FightMountCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFightMountInfo, "FightMountInfo");
	self:RegisterProtocol(SCFightMountAppeChange, "FightMountAppeChange");
	self:RegisterProtocol(CSFightMountSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeFightMount)
	self:RegisterProtocol(CSUseFightMountImage)			--请求使用形象
	self:RegisterProtocol(CSFightMountGetInfo)
end

function FightMountCtrl:FightMountInfo(protocol)
	self.data:SetFightMountInfo(protocol)
	AdvanceCtrl.Instance:FlushView("fightmounthuanhua")
	AdvanceCtrl.Instance:FlushView("fightmount")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	-- FightMountHuanHuaCtrl.Instance:FlushView("fightmounthuanhua")

	-- 进阶装备
	RemindManager.Instance:Fire(RemindName.AdvanceEquip)
	RemindManager.Instance:Fire(RemindName.HuanHua)
	RemindManager.Instance:Fire(RemindName.AdvanceFightMount)
	AdvanceCtrl.Instance:FlushEquipView()
end

function FightMountCtrl:FightMountAppeChange(protocol)
	local role = Scene.Instance:GetObj(protocol.objid)
	if role then
		role:SetAttr("fight_mount_appeid", protocol.mount_appeid)
	end
	MainUICtrl.Instance:FlushView("mount_state")
end

-- 发送进阶请求
function FightMountCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeFightMount)
	send_protocol.auto_buy = auto_buy
	if 1 == send_protocol.auto_buy and is_one_key then
		local mount_info = self.data:GetFightMountInfo()
		local grade_info_list = self.data:GetMountGradeCfg(mount_info.grade)
		if nil ~= grade_info_list then
			send_protocol.repeat_times = grade_info_list.pack_num
		else
			send_protocol.repeat_times = 1
		end
	else
		send_protocol.repeat_times = 1
	end

	send_protocol:EncodeAndSend()

end

--发送使用形象请求
function FightMountCtrl:SendUseFightMountImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseFightMountImage)
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function FightMountCtrl:FightMountSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function FightMountCtrl:SendGetFightMountInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountGetInfo)
	send_protocol:EncodeAndSend()
end

-- 发送升星请求
function FightMountCtrl:FightMountUpStarlevelReq(is_auto_buy, stuff_index, loop_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountUpStarLevel)
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.loop_times = loop_times or 1
	send_protocol:EncodeAndSend()
end

function FightMountCtrl:CheckFightMountUpOrDownInCg()
	local fight_id = GameVoManager.Instance:GetMainRoleVo().fight_mount_appeid > 0 and 1 or 0

	if CgManager.Instance:IsCgIng() then
		if 1 == fight_id then
			self:SendGoonFightMountReq(0, true)
			self.mount_downed_in_cg = true
		end
	else
		if self.mount_downed_in_cg then
			self.mount_downed_in_cg = false
			self:SendGoonFightMountReq(1, true)
		end
	end
end

function FightMountCtrl:SendGoonFightMountReq(mount_flag, is_from_cg)
	if not is_from_cg and CgManager.Instance:IsCgIng() then
		return
	end
	if mount_flag == 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.fight_mount_appeid <= 0 then
			return
		end
	end

	-- 是否是变身形象
	if mount_flag and mount_flag == 1 then
		local bianshen_param = GameVoManager.Instance:GetMainRoleVo().bianshen_param
		if bianshen_param ~= "" and bianshen_param ~= 0 then
			return
		end
		local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if scene_cfg.pb_fightmount and 1 == scene_cfg.pb_fightmount then
			return
		end
	end

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoonFightMount)
	send_protocol.goon_mount = mount_flag or 0
	send_protocol:EncodeAndSend()
end

function FightMountCtrl:SendFightMountUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end