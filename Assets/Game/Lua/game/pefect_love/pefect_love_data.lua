PefectLoverData = PefectLoverData or BaseClass()

RA_PERFECT_OPERA_TYPE = {
	RA_MARRYME_REQ_INFO = 0,
}
function PefectLoverData:__init()
	if PefectLoverData.Instance then
		print_error("[PefectLoverData] Attempt to create singleton twice!")
		return
	end
	PefectLoverData.Instance = self
	self.info = {
		cur_couple_count = 0,
		couple_list = {},
	}
	self.is_first = true
	self.perfect_lover_type_record_flag = {} 
	self.ra_perfect_lover_name_list = {}
	self.select_time_seq = -1
	-- RemindManager.Instance:Register(RemindName.MarryMe, BindTool.Bind(self.GetMarryMeRemind, self))
end

function PefectLoverData:__delete()
	-- RemindManager.Instance:UnRegister(RemindName.MarryMe)

	PefectLoverData.Instance = nil
end

function PefectLoverData:SetInfo(protocol)
	self.my_rank = protocol.my_rank
	self.lover_name = protocol.lover_name
	self.perfect_lover_type_record_flag = bit:d2b(protocol.perfect_lover_type_record_flag)
	self.ra_perfect_lover_count = protocol.ra_perfect_lover_count
	self.ra_perfect_lover_name_list = protocol.ra_perfect_lover_name_list
end


-- 设置选中
function PefectLoverData:SetPecfectLoveSeq(seq)
	self.select_time_seq = seq
end

-- 获取选中
function PefectLoverData:GetPecfectLoveSeq()
	return self.select_time_seq
end

function PefectLoverData:GetRankInfo()
	return self.ra_perfect_lover_name_list
end


function PefectLoverData:GetMyRankInfo()
	return self.my_rank or 0
end

function PefectLoverData:GetLoverNameInfo()
	return self.lover_name or ""
end

function PefectLoverData:GetIsFirst()
	local state = self.is_first
	self.is_first = false
	return state
end

function PefectLoverData:GetTitleItemId()
	local data_list =  KaifuActivityData.Instance:GetKaifuActivityCfg()
	for k,v in pairs(data_list) do 
		if v.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI then
			return v.reward_item
		end
	end
end

function PefectLoverData:GetSelfActiveCfg(i)
	local data_flag = self.perfect_lover_type_record_flag[32 - i]
	return data_flag == 1
end

function PefectLoverData:GetSelfPerfectActiveCfg()
	local primary_maryy = self:GetSelfActiveCfg(0)
	local midlevel_maryy = self:GetSelfActiveCfg(1)
	local advanced_maryy = self:GetSelfActiveCfg(2)
	local is_show = false
	if primary_maryy and midlevel_maryy and advanced_maryy then
		is_show = true
	end
	return is_show
end
-- function PefectLoverData:GetMarryMeRemind(is_open)
-- 	if GameVoManager.Instance:GetMainRoleVo().lover_uid > 0 then
-- 		return 0
-- 	end
-- 	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
-- 	local remind_day = PlayerPrefsUtil.GetInt("marryme_remind_day") or cur_day

-- 	if not is_open and (cur_day == -1 or cur_day == remind_day) then
-- 		return 0
-- 	end

-- 	local limit_level = 0
-- 	local cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.MARRY_ME)
-- 	if cfg then
-- 		limit_level = cfg.min_level
-- 	end
-- 	return (ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.MARRY_ME) and limit_level <= GameVoManager.Instance:GetMainRoleVo().level) and 1 or 0
-- end

function PefectLoverData:GetNpcInfo(scene_id, npc_id)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene_cfg and scene_cfg.npcs then
		for k,v in pairs(scene_cfg.npcs) do
			if v.id == npc_id then
				return v
			end
		end
	end
end