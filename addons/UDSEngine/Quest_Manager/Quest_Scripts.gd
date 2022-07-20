extends Node
var dict_PlayerQuestData : Dictionary
var dict_quest : Dictionary
var dict_inventory : Dictionary
var dict_enemy : Dictionary
var dict_static_items : Dictionary




func update_all_active_quests():
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	dict_static_items = udsmain.Static_Game_Dict["Items"]
	var quest_number = 0
	
	for i in dict_PlayerQuestData:
		if int(i) != 0:
			quest_number = str(dict_PlayerQuestData[i]["Quest_Number"])
			if dict_PlayerQuestData[i]["Active"] == true:
				if dict_PlayerQuestData[i]["Complete"] == false:
					for k in range(1,5):
						var obj_num = str(k)
						var quest = dict_quest[quest_number]
						if quest.has("Objective_" + obj_num):
							if dict_quest[quest_number]["Objective_" + obj_num] != "empty":
								if dict_PlayerQuestData[i]["Objective_" + obj_num + "_Complete"] == false:
									var item = dict_quest[quest_number]["Objective_item_" + obj_num + "_type"]
									if item == "Currency":
										var currency = dict_inventory["Currency"]["ItemCount"]
										dict_PlayerQuestData[i]["Objective_item_" + obj_num + "_count"] = currency

									var obj_curr_count = get_quest_objective_item_count(quest_number, obj_num)
									var obj_total_count = get_quest_objective_item_total(quest_number, obj_num)
									if str(obj_total_count) != "empty":
										if obj_curr_count >= obj_total_count:
											dict_PlayerQuestData[i]["Objective_" + obj_num + "_Complete"] = true
									

func issue_reward(quest_number, objective_number):
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	quest_number = str(quest_number)
	objective_number = str(objective_number)
	var reward_value = int(dict_quest[quest_number]["Reward_Count_" + objective_number])
	var reward_item = dict_quest[quest_number]["Reward_item_" + objective_number]
	dict_static_items = udsmain.Static_Game_Dict["Items"]
	if dict_static_items.has(reward_item):
		if!dict_inventory.has(reward_item):
			dict_inventory[reward_item] = {"ItemCount" : 0}
		var inv_count = int(dict_inventory[reward_item]["ItemCount"])
		dict_inventory[reward_item]["ItemCount"] =  inv_count + reward_value
#		Global.display_item_gained(reward_item, reward_value)
		for i in dict_PlayerQuestData:
			if int(i) != 0:
				var temp_quest = str(dict_PlayerQuestData[i]["Quest_Number"])
				if temp_quest == quest_number:
					dict_PlayerQuestData[i]["Reward_Recieved"] = true
	elif reward_item == "empty":
		print("No reward set in database")
	else:
		print("item needs to be added to list")


func activate_quest(quest_number, inactive : bool = false):
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	dict_quest = udsmain.Static_Game_Dict["Quest"]
#	dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	var not_valid_quest_number = true
	var already_exists = false
	var key = 0
	var temp_line = []
	
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			already_exists = true
			dict_PlayerQuestData[i]["Active"] = true
			
	for j in dict_quest:
		if j == quest_number:
			not_valid_quest_number = false
			
	if already_exists == false and not_valid_quest_number == false:
		key = str(dict_PlayerQuestData.size())
		temp_line = dict_PlayerQuestData["0"]
		temp_line = temp_line.duplicate(true)
		dict_PlayerQuestData[key] = temp_line
		dict_PlayerQuestData[key]["Quest_Number"] = quest_number
		dict_PlayerQuestData[key]["Active"] = true
		for k in range(1,4):
			var obj_num = str(k)
			get_quest_objective_item_count(quest_number, obj_num)

	if inactive:
		dict_PlayerQuestData[key]["Active"] = false


func is_quest_objective_complete(quest_number, objective_number):
	var complete = false
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			complete = dict_PlayerQuestData[i]["Objective_" + str(objective_number) + "_Complete"]
	return complete

func is_quest_complete(quest_number):
	var complete = false
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			complete = dict_PlayerQuestData[i]["Complete"]
	return complete

func is_reward_recieved(quest_number):
	var complete = false
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			complete = dict_PlayerQuestData[str(i)]["Reward_Recieved"]
	return complete

func set_objective_complete(quest_number, objective_number, giveReward : bool = true):
	quest_number = str(quest_number)
	if !is_quest_active(quest_number):
		activate_quest(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			dict_PlayerQuestData[str(i)]["Objective_" +  str(objective_number) + "_Complete"] = true
	#ISSUE REWARD FOR OBJECTIVE
	if giveReward:
		issue_reward(int(quest_number), objective_number)
	#DETERMINE NUMBER OF OBJECTIVES IN QUEST
	var obj_count = get_quest_objective_total(quest_number)
	#ITERATE THROUGH OBJECTIVES AND DETERMINE IF THE QUEST IS COMPLETE
	var complete = true
	for j in range(1, obj_count + 1):
		if is_quest_objective_complete(quest_number, str(j)) == false:
			complete = false
	#SET QUEST COMPLETE IF ALL OBJECTIVES ARE COMPLETED
	if complete == true:
		set_quest_complete(quest_number)
#	Signal.emit_signal("is_quest_complete_or_active")

func get_quest_objective_total(quest_number):
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	quest_number = str(quest_number)
	var curr_count = 0
	for i in range(1,10):
		if dict_quest[quest_number].has("Objective_" + str(i)):
			if  dict_quest[quest_number]["Objective_" + str(i)] != "empty":
				curr_count += 1
	return curr_count

func get_quest_objective_item_count(quest_number, objective_number):
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	quest_number = str(quest_number)
	objective_number = str(objective_number)
	var curr_count = 0
	for i in dict_PlayerQuestData:
		if int(i) != 0:
			var temp_quest = str(dict_PlayerQuestData[i]["Quest_Number"])
			if temp_quest == quest_number:
				if dict_quest[quest_number].has("Objective_" + objective_number) :
					if  dict_quest[quest_number]["Objective_" + objective_number] != "empty":
						if !dict_PlayerQuestData[i].has("Objective_item_" + str(objective_number) + "_count"):
							dict_PlayerQuestData[i]["Objective_item_" +str(objective_number) + "_count"] = 0
						curr_count = dict_PlayerQuestData[i]["Objective_item_" + str(objective_number) + "_count"]
	return curr_count

func get_quest_objective_item_total(quest_number, objective_number):
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	quest_number = str(quest_number)
	objective_number = str(objective_number)
	var curr_count = 0
	for i in dict_PlayerQuestData:
		if int(i) != 0:
			var temp_quest = str(dict_PlayerQuestData[i]["Quest_Number"])
			if temp_quest == quest_number:
				if dict_quest[quest_number].has("Objective_" + objective_number) :
					if  dict_quest[quest_number]["Objective_" + objective_number] != "empty":
						curr_count = dict_quest[quest_number]["Objective_item_" + objective_number + "_count"]
	return curr_count

func is_objective_with_itemCount_complete(quest_number, object_number):
	var is_complete = false
	var obj_curr_count = get_quest_objective_item_count(quest_number, object_number)
	var obj_total_count = get_quest_objective_item_total(quest_number, object_number)
	if str(obj_total_count) != "empty":
		if obj_curr_count == obj_total_count:
			is_complete = true
	return is_complete


func update_quest_objctive(quest_number, objective_number, value):
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	dict_quest = udsmain.Static_Game_Dict["Quest"]
	quest_number = str(quest_number)
	var curr_count = 0
	for i in dict_PlayerQuestData:
		if int(i) != 0:
			var temp_quest = str(dict_PlayerQuestData[i]["Quest_Number"])
			if temp_quest == quest_number:
				if !dict_PlayerQuestData[i].has("Objective_item_" + str(objective_number) + "_count"):
					dict_PlayerQuestData[i]["Objective_item_" + str(objective_number) + "_count"] = 0
				curr_count = get_quest_objective_item_count(quest_number, objective_number)
				var total = get_quest_objective_item_total(quest_number, objective_number)
				if curr_count < int(total):
					curr_count += value
					dict_PlayerQuestData[i]["Objective_item_" + str(objective_number) + "_count"] = curr_count



func set_quest_complete(quest_number):
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if int(i) != 0:
			var quest_num = str(dict_PlayerQuestData[i]["Quest_Number"])
			if quest_num == quest_number:
				dict_PlayerQuestData[i]["Active"] = false
				dict_PlayerQuestData[i]["Complete"] = true


func is_quest_active(quest_number):
	var quest_status = false
	quest_number = str(quest_number)
	dict_PlayerQuestData = udsmain.Dynamic_Game_Dict["PlayerQuestData"]
	for i in dict_PlayerQuestData:
		if str(dict_PlayerQuestData[i]["Quest_Number"]) == quest_number:
			quest_status = dict_PlayerQuestData[i]["Active"]
	return quest_status

func get_player_character():
	var dict_formation = udsmain.Dynamic_Game_Dict["Formation"]
	var curr_char = dict_formation["1"]["CharName"]
	return curr_char
