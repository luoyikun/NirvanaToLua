-- J-决斗场系列.xls
return {
other={
{}},

mining_reward={
{consume_gold=20,},
{quality=1,consume_gold=30,name="蓝锥矿",},
{quality=2,name="紫矿石",},
{quality=3,name="金红石",}},

sailing_reward={
{consume_gold=20,},
{quality=1,consume_gold=30,name="横帆船",},
{quality=2,name="桅帆船",},
{quality=3,name="传奇舰",}},

challenge_rank_reward={
{},
{rank=2,reward_item={[0]={item_id=26100,num=7,is_bind=1}},},
{rank=3,reward_item={[0]={item_id=26100,num=5,is_bind=1}},},
{rank=11,reward_item={[0]={item_id=26100,num=3,is_bind=1}},}},

skip_cfg={
{quality=0,consume=30,},
{quality=1,consume=50,},
{quality=2,consume=80,},
{quality=3,consume=120,},
{type=1,quality=0,limit_level=380,consume=30,},
{type=1,quality=1,limit_level=380,consume=50,},
{type=1,quality=2,limit_level=380,consume=80,},
{type=1,quality=3,limit_level=380,consume=120,},
{type=2,},
{type=3,limit_level=380,},
{type=4,}},

other_default_table={dm_scene_id=5003,dm_sponsor_pos_x=25,dm_sponsor_pos_y=26,dm_opponent_pos_x=68,dm_opponent_pos_y=75,dm_day_times=3,dm_buy_time_need_gold=30,dm_cost_time_m=30,dm_rob_times=3,dm_been_rob_times=2,dm_rob_reward_rate=30,sl_scene_id=5004,sl_sponsor_pos_x=16,sl_sponsor_pos_y=34,sl_opponent_pos_x=32,sl_opponent_pos_y=49,sl_day_times=3,sl_buy_time_need_gold=30,sl_cost_time_m=30,sl_rob_times=3,sl_been_rob_times=2,sl_rob_reward_rate=30,cf_scene_id=5003,cf_default_join_times=6,cf_buy_time_need_gold=10,cf_restore_join_times_need_time_m=60,cf_auto_reflush_interval_s=3600,cf_reflush_need_bind_gold=5,cf_win_add_jifen=10,cf_win_add_mojing=0,cf_win_add_exp=1400000,cf_win_item={[0]={item_id=26298,num=1,is_bind=1}},cf_stop_level=1000,},

mining_reward_default_table={quality=0,consume_gold=40,upgrade_rate=100,reward_exp=0,reward_item={},name="磷页石",rob_get_item_count=0,},

sailing_reward_default_table={quality=0,consume_gold=40,upgrade_rate=100,reward_exp=0,reward_item={},name="白帆船",rob_get_item_count=0,},

challenge_rank_reward_default_table={rank=1,reward_item={[0]={item_id=26100,num=10,is_bind=1}},},

skip_cfg_default_table={type=0,quality=-1,limit_level=300,consume=10,}

}

