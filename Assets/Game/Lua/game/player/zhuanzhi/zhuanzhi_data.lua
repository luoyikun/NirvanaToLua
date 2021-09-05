ZhuanZhiData = ZhuanZhiData or BaseClass()

CANGLONG = {
	ONE = 7,
	TW0 = 14,
	THREE = 21,
}

local task_id_list = {
	[28001] = 1,
	[28002] = 2,
	[28003] = 3,
	[28004] = 1,
	[28005] = 2,
	[28006] = 3,
	[28007] = 1,
	[28008] = 2,
	[28009] = 3,
	[28010] = 1,
	[28011] = 2,
	[28012] = 3,
	[28013] = 4,
}

function ZhuanZhiData:__init()
	if ZhuanZhiData.Instance ~= nil then
		ErrorLog("[ZhuanZhiData] attempt to create singleton twice!")
		return
	end

	ZhuanZhiData.Instance = self

	self.zhuanzhieuqip_auto_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto")
	self.zhuanzhi_limit_prof_name = ListToMap(self.zhuanzhieuqip_auto_cfg.prof_name, "prof", "zhuan_num")

	local zhuanzhi_desc = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_desc
	self.zhuanzhi_desc = ListToMap(zhuanzhi_desc, "zhuan_num")

	RemindManager.Instance:Register(RemindName.ZhuanZhi, BindTool.Bind(self.GetZhuanZhiRemind, self))
	RemindManager.Instance:Register(RemindName.JueXing, BindTool.Bind(self.GetJueXingRemind, self))
	RemindManager.Instance:Register(RemindName.AllZhuanZhi, BindTool.Bind(self.GetAllZhuanZhiRemind, self))

	self.role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.zhuanzhi_info_list = {}
end

function ZhuanZhiData:__delete()
	-- body
	RemindManager.Instance:UnRegister(RemindName.ZhuanZhi)
	RemindManager.Instance:UnRegister(RemindName.JueXing)
	RemindManager.Instance:UnRegister(RemindName.AllZhuanZhi)

	ZhuanZhiData.Instance = nil
end

function ZhuanZhiData:GetTianMingCfg()
	local index = 0
	local tian_ming_gird = {}
	local tian_ming_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_tianming
	for k,v in pairs(tian_ming_cfg) do
		tian_ming_gird[index] = v
		index = index + 1
	end
	return tian_ming_gird
end

function ZhuanZhiData:GetTianMingAllAttr(level)
	local tian_ming_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_tianming
	if level < 2 then
		return tian_ming_cfg[level]
	else
		local attr_list = TableCopy(tian_ming_cfg[level])
		attr_list.maxhp = attr_list.maxhp - tian_ming_cfg[level - 1].maxhp
		attr_list.gongji = attr_list.gongji - tian_ming_cfg[level - 1].gongji
		attr_list.fangyu = attr_list.fangyu - tian_ming_cfg[level - 1].fangyu
		attr_list.pojia = attr_list.pojia - tian_ming_cfg[level - 1].pojia
		return attr_list
	end
end

function ZhuanZhiData:GetTianMingOtherCfg()
	local tian_ming_other_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").other[1]
	return tian_ming_other_cfg
end

function ZhuanZhiData:GetTianMingCfgByLevel(level)
	local tian_ming_cfg = self:GetTianMingCfg()
	for k,v in pairs(tian_ming_cfg) do
		if level == v.level then
			return v
		end
	end
end

function ZhuanZhiData:GetProfNameCfg(role_prof, zhuan_num)
	local prof_name_list = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").prof_name
	for k,v in pairs(prof_name_list) do
		if v.prof == role_prof and zhuan_num == v.zhuan_num then
			return v.prof_name
		end
	end
	return ""
end

function ZhuanZhiData:GetFaceCfgByZhuanNum(zhuan_num)
	local role_prof, prof_zhuan = PlayerData.Instance:GetRoleBaseProf()
	local prof_face_list = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_interface
	for k,v in pairs(prof_face_list) do
		if v.prof == role_prof and zhuan_num == v.zhuan_num then
			return v
		end
	end
end

function ZhuanZhiData:GetAttrCfgByZhuanNum(zhuan_num)
	local prof_attr_list = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_attr
	for k,v in pairs(prof_attr_list) do
		if zhuan_num == v.task_complete_count then
			return v
		end
	end
end

function ZhuanZhiData:GetFaceCfgListByZhuanNum(zhuan_num)
	local list_len = 5			-- 策划配置每转最大显示五个
	local face_cfg = self:GetFaceCfgByZhuanNum(zhuan_num)
	local face_cfg_list = {}
	if face_cfg then
		for i = 1, list_len do
			if face_cfg["skill_" .. i] ~= 0 and face_cfg["desc_" .. i] ~= 0 then
				table.insert(face_cfg_list, {["skill"] = face_cfg["skill_" .. i], 
												["desc"] = face_cfg["desc_" .. i], 
												["skill_type"] = face_cfg["skill_type_" .. i],
												["scale"] = face_cfg["scale_" .. i]})
			end
		end
	end
	return face_cfg_list
end

--判断标签是否显示
function ZhuanZhiData:GetZhuanzhiTabIsOpen(zhuan_num)
	local zhuanzhi_task_list = TaskData.Instance:GetZhuanzhiCfg()

	if nil == zhuanzhi_task_list or nil == next(zhuanzhi_task_list) then return false end

	if zhuan_num == 1 then return true end 		-- 1转默认开启

	local last_task_is_finish = TaskData.Instance:GetTaskIsCompleted(zhuanzhi_task_list[zhuan_num - 1].end_task)
	local now_first_task_can_accept = TaskData.Instance:GetTaskStatus(zhuanzhi_task_list[zhuan_num].first_task) ~= GameEnum.TASK_STATUS_NONE
	local now_first_task_is_finish = TaskData.Instance:GetTaskIsCompleted(zhuanzhi_task_list[zhuan_num].first_task)

	return last_task_is_finish and (now_first_task_can_accept or now_first_task_is_finish)
end

function ZhuanZhiData:GetZhuanZhidesByZhuanNum(zhuan_num)
	local zhuanzhi_list = {}
	local zhuanzhi_des_list = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_desc
	for k,v in pairs(zhuanzhi_des_list) do
		if zhuan_num == v.zhuan_num then
			table.insert(zhuanzhi_list, v)
		end
	end
	return zhuanzhi_list
end

-- 获取转职任务id列表
function ZhuanZhiData:GetZhuanzhiTaskIdList()
	if nil == self.zhuanzhi_task_id_list then
		local zhuanzhi_task_list = TaskData.Instance:GetZhuanzhiCfg()
		if nil == zhuanzhi_task_list or nil == next(zhuanzhi_task_list) then return nil end

		self.zhuanzhi_task_id_list = {}
		for k,v in pairs(zhuanzhi_task_list) do
			for i=v.first_task, v.end_task do
				self.zhuanzhi_task_id_list[#self.zhuanzhi_task_id_list + 1] = i
			end
		end

		-- 升序排序
		table.sort(self.zhuanzhi_task_id_list, function(a, b)
			return tonumber(a) < tonumber(b)
		end)
	end

	return self.zhuanzhi_task_id_list
end

function ZhuanZhiData:GetFirstTaskZhuanZhi()
	local task_cfg = TaskData.Instance:GetNowZhuanZhiTask()
	if task_cfg == nil then return false end

	local is_first = TaskData.Instance:GetIsFirstZhuanZhi(task_cfg.task_id)
	return not is_first
end

-- 判断主界面是否出现转职按钮
function ZhuanZhiData:GetZhuanzhiMainIconCanShow(level)
	local zhuanzhi_task_list = TaskData.Instance:GetZhuanzhiCfg()
	if nil == zhuanzhi_task_list or nil == next(zhuanzhi_task_list) then return false end

	local can_show_list = {}
	for k,v in pairs(zhuanzhi_task_list) do
		local is_level_enough = level >= TaskData.Instance:GetTaskConfig(v.first_task).min_level
		local role_prof, prof_zhuan = PlayerData.Instance:GetRoleBaseProf()
		local zhuan_task_is_finish = TaskData.Instance:GetTaskIsCompleted(v.end_task)
		local zhuan_is_completed = prof_zhuan >= k
		can_show_list[k] = is_level_enough and not (zhuan_task_is_finish or zhuan_is_completed)
	end

	local can_show = false
	for k,v in pairs(can_show_list) do
		can_show = can_show or v
	end
	return can_show
end

function ZhuanZhiData:GetLevelupRemindByLevel(level)
	local tian_ming_level = PlayerData.Instance:GetRoleTianMingLevel()
	if level == tian_ming_level then
		local tianming_data_list = self:GetTianMingCfg()
		if tianming_data_list[level] then
			local item_num = ItemData.Instance:GetItemNumInBagById(tianming_data_list[level].need_stuff_id)
			if item_num >= tianming_data_list[level].need_stuff_num then
				return 1
			end
			local role_exp = GameVoManager.Instance:GetMainRoleVo().exp
			if role_exp >= tianming_data_list[level].need_exp then
				return 1
			end
		end
	end
	return 0
end

function ZhuanZhiData:GetTianMingRemind()
	local tian_ming_level = PlayerData.Instance:GetRoleTianMingLevel()
	local tianming_data_list = self:GetTianMingCfg()
	if tianming_data_list[tian_ming_level] then
		local item_num = ItemData.Instance:GetItemNumInBagById(tianming_data_list[tian_ming_level].need_stuff_id)
		if item_num >= tianming_data_list[tian_ming_level].need_stuff_num then
			return 1
		end
		local role_exp = GameVoManager.Instance:GetMainRoleVo().exp
		if role_exp >= tianming_data_list[tian_ming_level].need_exp then
			return 1
		end
	end
	return 0
end

function ZhuanZhiData:GetRoleProfNameCfg(zhuan_num, role_prof)
	local prof_name_list = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").prof_name
	for k,v in pairs(prof_name_list) do
		if v.prof == role_prof and zhuan_num == v.zhuan_num then
			return v.prof_name
		end
	end
	return ""
end


-- 五转苍龙
function ZhuanZhiData:SetCangLongList()
	if self.canglong_list_cfg == nil then
		local key = 1
		local index = 0
		self.canglong_list_cfg = {}
		for i,v in ipairs(self.canglong_cfg) do
			if self.canglong_list_cfg[key] == nil then
				self.canglong_list_cfg[key] = {}
			end
			self.canglong_list_cfg[key][index] = v
			index = index + 1
			if #self.canglong_list_cfg[key] >= 6 then
				key = key + 1
				index = 0
			end
		end
	end
end

function ZhuanZhiData:GetJueXingOneTypeKey()
	local key = 1
	if TaskData.Instance:GetTaskIsCompleted(28011) or TaskData.Instance:GetTaskIsAccepted(28011) then
		key = 3
	elseif TaskData.Instance:GetTaskIsCompleted(28010) or TaskData.Instance:GetTaskIsAccepted(28010) then
		key = 2
	end
	return key
end

function ZhuanZhiData:GetCangLongListByKey(key)
	if self.canglong_list_cfg then
		return self.canglong_list_cfg[key]
	end
end

function ZhuanZhiData:GetCangLongCfgByLevel(level)
	for k,v in pairs(self.canglong_cfg) do
		if v.level == level then
			return v
		end
	end
end

function ZhuanZhiData:GetCangLongAllAttr(level)
	if level < 2 then
		return self.canglong_cfg[level]
	else
		local attr_list = TableCopy(self.canglong_cfg[level])
		attr_list.maxhp = attr_list.maxhp - self.canglong_cfg[level - 1].maxhp
		attr_list.gongji = attr_list.gongji - self.canglong_cfg[level - 1].gongji
		attr_list.fangyu = attr_list.fangyu - self.canglong_cfg[level - 1].fangyu
		attr_list.pojia = attr_list.pojia - self.canglong_cfg[level - 1].pojia
		return attr_list
	end
end

function ZhuanZhiData:GetCangLongTitle()
	local is_finish_1 = TaskData.Instance:GetTaskIsCompleted(29014)
	local is_finish_2 = TaskData.Instance:GetTaskIsCompleted(29016)
	if is_finish_2 then
		return true, true, true
	elseif is_finish_1 then
		return true, true, false
	else
		return true, false, false
	end
end

function ZhuanZhiData:GetZhuanZhiViewIndexByTaskCfg(task_cfg)

end

function ZhuanZhiData:GetZhuanZhiTaskCfg()
	return self.task_cfg
end

function ZhuanZhiData:SetZhuanZhiTaskCfg(task_cfg)
	self.task_cfg = task_cfg
end

function ZhuanZhiData:GetZhuanZhiTaskData()
	return self.task_data
end

function ZhuanZhiData:SetZhuanZhiTaskData(task_data)
	self.task_data = task_data
end

function ZhuanZhiData:GetRoleBaseProf(prof)
	prof = prof or self.role_vo.prof
	return prof % 10, math.floor(prof / 10)
end

-- 获得转职装备的职业要求
function ZhuanZhiData:GetZhuanZhiLimitProfName(limit_prof, order)
	local cfg = self.zhuanzhi_limit_prof_name[limit_prof]
	return cfg and cfg[order].prof_name or Language.Common.AllProf
end

-- 获得转职装备的职业要求
function ZhuanZhiData:GetZhuanZhiLimitProfImg(limit_prof, order)
	local cfg = self.zhuanzhi_limit_prof_name[limit_prof]
	return cfg and cfg[order].pic_1
end


function ZhuanZhiData:SetZhuanZhiAllInfo(protocol)
	self.zhuanzhi_info_list = {}
	self.zhuanzhi_info_list[5] = protocol.zhuanzhi_level_fire
	self.zhuanzhi_info_list[6] = protocol.zhuanzhi_level_six
	self.zhuanzhi_info_list[7] = protocol.zhuanzhi_level_seven
	self.zhuanzhi_info_list[8] = protocol.zhuanzhi_level_eight
	self.zhuanzhi_info_list[9] = protocol.zhuanzhi_level_nine
	self.zhuanzhi_info_list[10] = protocol.zhuanzhi_level_ten
end

function ZhuanZhiData:GetSingleZhuanZhiInfo(zhuan)
	return self.zhuanzhi_info_list[zhuan]
end

function ZhuanZhiData:GetWuZhuanCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_tianming
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetJueXingOneCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_canglong
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetJueXingTwoCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_shengxiao
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetJueXingThreeCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_yuanqi
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetJueXingFourCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_shenqi
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetJueXingFiveCfgByIndex(index)
	local zhuanzhi_cfg = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_xingxiu
	if zhuanzhi_cfg[index] then
		return zhuanzhi_cfg[index]
	end
end

function ZhuanZhiData:GetZhuanZhiSingleCfgByZhuan(zhuan, index)
	if zhuan == 5 then
		return self:GetWuZhuanCfgByIndex(index)
	elseif zhuan == 6 then
		return self:GetJueXingOneCfgByIndex(index)
	elseif zhuan == 7 then
		return self:GetJueXingTwoCfgByIndex(index)
	elseif zhuan == 8 then
		return self:GetJueXingThreeCfgByIndex(index)
	elseif zhuan == 9 then
		return self:GetJueXingFourCfgByIndex(index)
	elseif zhuan == 10 then
		return self:GetJueXingFiveCfgByIndex(index)
	end
end

function ZhuanZhiData:GetJueXingOneProgress()
	local is_Completed_1 = TaskData.Instance:GetTaskIsCompleted(28009)
	local is_Completed_2 = TaskData.Instance:GetTaskIsCompleted(28010)
	return is_Completed_1, is_Completed_2
end

function ZhuanZhiData:GetJueXingWuProgress()
	local is_finish_1 = TaskData.Instance:GetTaskIsCompleted(28020)
	local is_finish_2 = TaskData.Instance:GetTaskIsCompleted(28021)
	local is_finish_3 = TaskData.Instance:GetTaskIsCompleted(28022)
	local is_finish_4 = TaskData.Instance:GetTaskIsCompleted(28023)
	local is_accepted_1 = is_finish_1 or TaskData.Instance:GetTaskIsAccepted(28020)
	local is_accepted_2 = is_finish_2 or TaskData.Instance:GetTaskIsAccepted(28021)
	local is_accepted_3 = is_finish_3 or TaskData.Instance:GetTaskIsAccepted(28022)
	local is_accepted_4 = is_finish_4 or TaskData.Instance:GetTaskIsAccepted(28023)
	return is_accepted_1, is_accepted_2, is_accepted_3, is_accepted_4
end

function ZhuanZhiData:GetZhuanZhiJieDuanDes(task_id, zhuan_index)
	local zhuanzhi_desc = ConfigManager.Instance:GetAutoConfig("zhuanzhicfg_auto").zhuanzhi_desc
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if zhuan_index <= zhuan then
		return self.zhuanzhi_desc[zhuan_index] and self.zhuanzhi_desc[zhuan_index].desc
	end
	
	if task_id then
		for k,v in pairs(zhuanzhi_desc) do
			if v.task_id == task_id then
				return v.desc
			end
		end
	end
end

function ZhuanZhiData:GetZhuanZhiRemind()
	return self:CmmonZhuanZhiRemind(1)
end

function ZhuanZhiData:GetJueXingRemind()
	return self:CmmonZhuanZhiRemind(0)
end

function ZhuanZhiData:CmmonZhuanZhiRemind(zhuanzhi_or_juexing)			-- 策划说有可接可提交或正在进行时的任务是转职副本或点亮任务可以点亮时提示红点
	local task_cfg, zhuanzhi_task_status, progress_num = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == task_cfg then
		return 0
	end

	local now_zhuan_num = TaskData.Instance:GetZhuanZhiRedRemind(task_cfg.task_id)
	if nil == now_zhuan_num then
		return 0
	end

	if zhuanzhi_or_juexing == 1 and now_zhuan_num > 5 then
		return 0
	elseif zhuanzhi_or_juexing == 0 and now_zhuan_num <= 5 then
		return 0
	end

	if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
		return 1
	elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
		local info_num = now_zhuan_num > 2 and (now_zhuan_num + 2) or now_zhuan_num
		local zhuanzhi_info = self:GetSingleZhuanZhiInfo(info_num)
		local can_lighten_ball
		if zhuanzhi_info then
			can_lighten_ball = self:GetBallRedPointRemind(info_num, zhuanzhi_info + 1)
		end
		if task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB_LAYE or (task_cfg.condition == TASK_COMPLETE_CONDITION.REACH_STATE and can_lighten_ball) then
			return 1
		end

		return 0
	elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
		return 1
	end

	return 0
end

function ZhuanZhiData:GetAllZhuanZhiRemind()
	if self:GetZhuanZhiRemind() == 1 or self:GetJueXingRemind() == 1 then
		return 1
	end
	return 0
end

function ZhuanZhiData:SetWuZhuanViewFlag(flag)
	self.exp_view_is_open = flag
end

function ZhuanZhiData:GetWuZhuanViewFlag()
	return self.exp_view_is_open or false
end

function ZhuanZhiData:GetBallRedPointRemind(zhuan, index)
	local zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(zhuan, index)
	if zhuanzhi_cfg then
		local item_num = ItemData.Instance:GetItemNumInBagById(zhuanzhi_cfg.need_stuff_id)
		if item_num >= zhuanzhi_cfg.need_stuff_num then
			return true
		end
	end
	return false
end
