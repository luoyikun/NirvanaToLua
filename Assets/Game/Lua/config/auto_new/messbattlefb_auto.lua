-- L-乱斗战场.xls
return {
other={
{}},

relive_pos={
{},
{relive_pos_x=77,relive_pos_y=154,},
{relive_pos_x=163,relive_pos_y=69,},
{relive_pos_x=31,relive_pos_y=105,},
{relive_pos_x=115,relive_pos_y=21,},
{relive_pos_x=158,relive_pos_y=148,},
{relive_pos_x=47,relive_pos_y=39,}},

kill_boss_get_score={
{},
{min_rank=1,max_rank=1,get_score=400,},
{min_rank=2,max_rank=2,get_score=300,},
{min_rank=3,max_rank=9,get_score=250,},
{min_rank=10,max_rank=999,get_score=200,}},

reward={
{reward_item={[0]={item_id=28967,num=4,is_bind=1}},},
{min_rank=1,max_rank=1,cross_honor=250,shengwang=1800,},
{min_rank=2,max_rank=2,cross_honor=200,shengwang=1600,},
{min_rank=3,max_rank=9,cross_honor=150,shengwang=1400,},
{min_rank=10,max_rank=50,reward_item={[0]={item_id=28967,num=2,is_bind=1}},cross_honor=100,shengwang=1200,}},

rank_title={
{},
{title_id=3020,title_show="uis/icons/title/3000_atlas,Title_3020",item_id=22293,},
{title_id=3021,title_show="uis/icons/title/3000_atlas,Title_3021",item_id=22294,}},

other_default_table={limit_level=460,room_member_limit=99999,kill_item_get_score=50,snatch_score_per=50,min_score=50,max_score=500,scene_id=1650,one_score_to_honor=0,init_score=0,activity_open_dur_s=900,rank_update_interval_s=1,redistribute_interval_time_s=150,boss_id=60057,delay_kick_out_time=10,boss_position_x=97,boss_position_y=87,update_role_interval_s=1,submit_report_limit_score=50,wudi_time_s=5,reward_item={[0]={item_id=26000,num=1,is_bind=1},[1]={item_id=26000,num=1,is_bind=1},[2]={item_id=26000,num=1,is_bind=1},[3]={item_id=26000,num=1,is_bind=1},[4]={item_id=26000,num=1,is_bind=1}},content="周三、五、日21:00-21:15",open_cross_begin_day=1,title_first=3019,title_second=3020,title_third=3021,},

relive_pos_default_table={relive_pos_x=37,relive_pos_y=37,},

kill_boss_get_score_default_table={min_rank=0,max_rank=0,get_score=500,},

reward_default_table={min_rank=0,max_rank=0,reward_item={[0]={item_id=28967,num=3,is_bind=1}},cross_honor=300,shengwang=2000,},

rank_title_default_table={title_id=3019,title_show="uis/icons/title/3000_atlas,Title_3019",item_id=22292,}

}

