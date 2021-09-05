-- J-角色跨服目标.xls
return {
other={
{}},

cross_goal_item={
{cond_type=1,open_panel="ShenYuBossView#kf_boss",},
{index=1,cond_param=3,},
{index=2,cond_type=4,},
{index=3,cond_type=1,cond_param=5,open_panel="ShenYuBossView#kf_boss",},
{index=4,cond_param=6,},
{index=5,cond_type=4,cond_param=5,},
{index=6,cond_param=10,},
{index=7,cond_type=4,cond_param=10,},
{index=8,cond_type=100,cond_param="0,1,2,3,4,5,6,7",reward_item={[0]={item_id=17201,num=1,is_bind=1}},open_panel="",}},

guild_goal_item={
{},
{index=1,cond_type=6,cond_param=2,open_panel="Map#map_world",},
{index=2,cond_param=20,},
{index=3,cond_type=6,cond_param=5,open_panel="Map#map_world",},
{index=4,cond_param=40,},
{index=5,cond_type=6,open_panel="Map#map_world",},
{index=6,cond_param=60,},
{index=7,cond_type=6,cond_param=20,open_panel="Map#map_world",},
{index=8,cond_type=100,cond_param="0,1,2,3,4,5,6,7",reward_item={[0]={item_id=17801,num=1,is_bind=1}},open_panel="",}},

other_default_table={open_day_beg=3,open_day_end=6,open_level=170,},

cross_goal_item_default_table={index=0,cond_type=3,cond_param=2,reward_item={[0]={item_id=34118,num=1,is_bind=1}},open_panel="Map#map_world",},

guild_goal_item_default_table={index=0,cond_type=5,cond_param=10,reward_item={[0]={item_id=34118,num=1,is_bind=1}},open_panel="ShenYuBossView#kf_boss",}

}

