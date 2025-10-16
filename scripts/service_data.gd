class_name ServiceData extends Resource

@export var config_repos: Array[String]
@export var source_repos: Array[String]
@export var service_groups: Dictionary
@export var topology: Dictionary

func _init():
	config_repos = []
	source_repos = []
	service_groups = {}
	topology = {}

static func from_dictionary(data: Dictionary) -> ServiceData:
	var service_data = ServiceData.new()
	

	var temp_config_repos : Array[String]= []
	for item in data.get("config-repos", []):
		temp_config_repos.append(str(item))
	service_data.config_repos = temp_config_repos 

	var temp_source_repos : Array[String]= []
	for item in data.get("source-repos", []):
		temp_source_repos.append(str(item))
	service_data.source_repos = temp_source_repos
	
	var service_groups_data = data.get("service-groups", {})
	for group_name in service_groups_data.keys():
		var temp_group_repos : Array[String] = []
		for item in service_groups_data[group_name]:
			temp_group_repos.append(str(item))
		service_data.service_groups[group_name] = temp_group_repos

	var topology_data = data.get("topology", {})
	for key in topology_data.keys():
		var nested_data = topology_data[key]
		var temp_nested_repos : Array[String] = []
		for item in nested_data.get("source-repos", []):
			temp_nested_repos.append(str(item))
		service_data.topology[key] = temp_nested_repos

	return service_data

func get_github_repo_url(repo_name: String) -> String:
	return "https://github.turbine.com/" + repo_name
