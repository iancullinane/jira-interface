extends Node

const WorkItem = preload("res://scripts/work_item.gd")

signal issues_fetched(issues: Array[WorkItem])
signal request_failed(error: String)
signal request_started()

const CONFIG_PATH = "res://config.yaml"
const JSON_ACCEPT_HEADER = "Accept: application/json"
const DEFAULT_MAX_RESULTS := 10

var _http_request: HTTPRequest
var _config: Dictionary = {}


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)
	_load_config()


func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open config at %s" % CONFIG_PATH)
		return
	
	_config.clear()
	while file.get_position() < file.get_length():
		var line := file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var hash_index := line.find("#")
		if hash_index != -1:
			line = line.substr(0, hash_index).strip_edges()
		var colon := line.find(":")
		if colon == -1:
			continue
		var key := line.substr(0, colon).strip_edges()
		var value := line.substr(colon + 1).strip_edges()
		if value.begins_with("\"") and value.ends_with("\"") and value.length() >= 2:
			value = value.substr(1, value.length() - 2)
		_config[key] = value
	file.close()


func fetch_issues(jql: String = "", max_results: int = DEFAULT_MAX_RESULTS, fields: PackedStringArray = []) -> void:
	print("JiraService.fetch_issues() called")
	request_started.emit()
	
	if _config.is_empty():
		print("Config is empty!")
		request_failed.emit("Missing config values for Jira request")
		return
	
	var project_key := String(_config.get("JIRA_PROJECT_KEY", ""))
	if jql.is_empty():
		jql = "project=%s ORDER BY created DESC" % project_key
	
	var url := _build_search_url(jql, max_results, fields)
	var headers := _build_headers()
	
	print("Making request to: %s" % url)
	var err := _http_request.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		print("Request failed: %s" % err)
		request_failed.emit("Request failed to start: %s" % err)


func _build_search_url(jql: String, max_results: int, fields: PackedStringArray = []) -> String:
	var base_url := String(_config.get("JIRA_URL", ""))
	if base_url.ends_with("/"):
		base_url = base_url.substr(0, base_url.length() - 1)
	
	var encoded_jql := jql.uri_encode()
	var url := "%s/rest/api/3/search/jql?jql=%s&maxResults=%d" % [base_url, encoded_jql, max_results]
	
	if not fields.is_empty():
		var fields_str := ",".join(fields)
		url += "&fields=" + fields_str.uri_encode()
		
	return url


func _build_headers() -> PackedStringArray:
	var username := String(_config.get("JIRA_USERNAME", ""))
	var api_token := String(_config.get("JIRA_PASSWORD", ""))
	var auth_source := "%s:%s" % [username, api_token]
	var auth_bytes := auth_source.to_utf8_buffer()
	var auth_b64 := Marshalls.raw_to_base64(auth_bytes)
	
	return PackedStringArray([
		"Authorization: Basic %s" % auth_b64,
		JSON_ACCEPT_HEADER,
		"Content-Type: application/json"
	])


func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("HTTP Response: %d" % response_code)
	if response_code != 200:
		var body_text := body.get_string_from_utf8()
		print("Error response body: %s" % body_text)
		request_failed.emit("HTTP Error: %d" % response_code)
		return
	
	var json_text := body.get_string_from_utf8()
	print(json_text)
	var json := JSON.new()
	var parse_result := json.parse(json_text)
	
	if parse_result != OK:
		request_failed.emit("Failed to parse JSON response")
		return
	
	var data := json.data as Dictionary
	var issues := data.get("issues", []) as Array
	print("Found %d raw issues in response" % issues.size())
	
	# Parse issues into WorkItem resources
	var work_items: Array[WorkItem] = []
	for issue in issues:
		var work_item := _create_work_item(issue)
		if work_item.is_valid():
			work_items.append(work_item)
	
	print("Emitting %d work items" % work_items.size())
	issues_fetched.emit(work_items)


func _create_work_item(issue_data: Dictionary) -> WorkItem:
	var fields := issue_data.get("fields", {}) as Dictionary
	var data := {
		"key": issue_data.get("key", ""),
		"id": issue_data.get("id", ""),
		"summary": fields.get("summary", "")
	}
	return WorkItem.new(data)



