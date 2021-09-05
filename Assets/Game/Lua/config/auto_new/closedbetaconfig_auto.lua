-- F-封测活动.xls
return {
other={
{}},

login_reward={
{},
{logn_day=2,},
{logn_day=3,},
{logn_day=4,},
{logn_day=5,},
{logn_day=6,},
{logn_day=7,},
{logn_day=8,},
{logn_day=9,},
{logn_day=10,},
{logn_day=11,},
{logn_day=12,},
{logn_day=13,},
{logn_day=14,},
{logn_day=15,},
{logn_day=16,},
{logn_day=17,},
{logn_day=18,},
{logn_day=19,},
{logn_day=20,}},

uplevel_reward={
[0]={seq=0,},
[1]={seq=1,need_level=180,reward_gold=2000,},
[2]={seq=2,need_level=230,reward_gold=2500,},
[3]={seq=3,need_level=260,reward_gold=3000,},
[4]={seq=4,need_level=300,reward_gold=3500,}},

vip_level_cfg={
{},
{role_level=160,vip_level=2,},
{role_level=190,vip_level=3,},
{role_level=230,vip_level=4,},
{role_level=250,vip_level=5,},
{role_level=270,vip_level=6,},
{role_level=300,vip_level=7,},
{role_level=350,vip_level=8,},
{role_level=380,vip_level=9,},
{role_level=400,vip_level=10,}},

join_activity_reward={
[0]={seq=0,},
[1]={seq=1,activity_type=6,}},

online_time_s_reward={
[0]={seq=0,},
[1]={seq=1,need_online_time_s=5400,},
[2]={seq=2,need_online_time_s=7200,},
[3]={seq=3,need_online_time_s=9000,},
[4]={seq=4,need_online_time_s=10800,}},

fb_reward_client_config={
{},
{fb_type=2,fb_name="武器副本",reward_cfg="equipfb_cfg",get_type=9,item_desc="<font size='20' font color='#ffffff'>满星通关武器副本第<limit_value_1>1</limit_value_1>层第10关</font>",item_btn="挑战副本#fuben#fb_weapon",},
{fb_type=3,fb_name="防具副本",reward_cfg="tdfb_cfg",get_type=10,limit="need_level",item_desc="<font size='20' font color='#ffffff'>通关防具副本第<limit_value_1>1</limit_value_1>关可领取</font>",item_btn="挑战副本#fuben#fb_fangju",},
{fb_type=4,fb_name="品质副本",reward_cfg="qualityfb_cfg",get_type=11,limit="need_chapter,need_level",item_desc="<font size='20' font color='#ffffff'>挑战品质副本第<limit_value_1>1</limit_value_1>关可领取</font>",item_btn="挑战副本#fuben#fb_quality",}},

equipfb_cfg={
[0]={seq=0,},
[1]={seq=1,need_chapter=1,reward_gold_bind=200,},
[2]={seq=2,need_chapter=2,reward_gold_bind=300,},
[3]={seq=3,need_chapter=3,reward_gold_bind=400,}},

other_default_table={guild_item={item_id=28416,num=1,is_bind=1},marry_item={item_id=28417,num=1,is_bind=1},},

login_reward_default_table={logn_day=1,reward_gold=1000,},

uplevel_reward_default_table={seq=0,need_level=130,reward_gold=1500,},

vip_level_cfg_default_table={role_level=130,vip_level=1,},

join_activity_reward_default_table={seq=0,activity_type=1,reward_gold=1500,},

online_time_s_reward_default_table={seq=0,need_online_time_s=3600,reward_gold=300,},

fb_reward_client_config_default_table={fb_type=1,fb_name="经验副本",reward_cfg="expfb_cfg",get_type=8,limit="need_chapter,need_level,need_star",item_desc="<font size='20' font color='#ffffff'>满星通关经验副本第<limit_value_1>1</limit_value_1>层</font>",item_btn="挑战副本#fuben#fb_exp",},

equipfb_cfg_default_table={seq=0,need_chapter=0,need_level=7,need_star=3,reward_gold_bind=100,}

}

