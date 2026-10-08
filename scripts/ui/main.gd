extends Control

const ReactorCoreView = preload("res://scripts/ui/reactor_core.gd")
const AmbientBackdrop = preload("res://scripts/ui/ambient_backdrop.gd")
const UI_SETTINGS_PATH := "user://core_reactor_ui.cfg"
const PAGE_ORDER := ["reactor", "prestige", "statistics", "settings"]
const TEXT := {
	"nav_reactor": ["反應爐", "REACTOR"],
	"nav_prestige": ["重生", "PRESTIGE"],
	"nav_statistics": ["統計", "STATS"],
	"nav_settings": ["設定", "SETTINGS"],
	"energy": ["能量", "ENERGY"],
	"rate": ["每秒產量", "PRODUCTION / SEC"],
	"multiplier": ["總產量倍率", "TOTAL PRODUCTION"],
	"core_power": ["核心功率", "CORE POWER"],
	"reactor_speed": ["核心頻率", "CORE FREQUENCY"],
	"efficiency": ["效率", "EFFICIENCY"],
	"core_effect_prefix": ["+", "+"],
	"core_effect_suffix": [" 能量", " Energy/sec"],
	"speed_effect": ["核心頻率 +%s%% / 級", "Core frequency +%s%% per level"],
	"efficiency_effect": ["總 Energy +%s%% / 級", "Total Energy +%s%% per level"],
	"level": ["Lv. ", "Lv. "],
	"upgrade": ["升級 %s · %s E", "UPGRADE %s · %s E"],
	"qty_x1": ["×1", "×1"],
	"qty_x10": ["×10", "×10"],
	"qty_max": ["MAX", "MAX"],
	"rebirth_title": ["重啟核心", "REBIRTH YOUR CORE"],
	"rebirth_subtitle": ["重生以取得永久點數，並強化下一個循環。", "Reset this cycle for permanent points and a stronger next run."],
	"points": ["永久點數", "PRESTIGE POINTS"],
	"available": ["本次可獲得", "AVAILABLE NOW"],
	"run_total": ["本輪總 Energy", "CURRENT RUN ENERGY"],
	"next_point": ["下個點數還差", "ENERGY TO NEXT POINT"],
	"rebirth": ["重生 · +%s PP", "REBIRTH · +%s PP"],
	"rebirth_locked": ["至少需要 %s 本輪 Energy", "NEED %s CYCLE ENERGY"],
	"branches": ["永久強化", "PERMANENT UPGRADES"],
	"prestige_hover_hint": ["移至節點查看效果與 PP 價格", "Hover a node to view its effect and PP cost"],
	"node_price_tooltip": ["價格：%s PP", "Cost: %s PP"],
	"node_max_tooltip": ["已達最高等級", "Maximum level reached"],
	"tree_maxed": ["已滿級", "MAXED"],
	"tree_ready": ["可研究 · %s PP", "READY · %s PP"],
	"tree_locked": ["尚未解鎖", "LOCKED"],
	"tree_next_rank": ["Lv.%s/%s · 下一級 %s PP", "Lv.%s/%s · Next %s PP"],
	"tree_rank_only": ["Lv.%s/%s", "Lv.%s/%s"],
	"production_branch": ["產量", "PRODUCTION"],
	"mastery_name": ["反應爐精通", "REACTOR MASTERY"],
	"mastery_desc": ["每級永久產量 +%s%%（最高 %s 級）", "+%s%% permanent production per level (max %s)"],
	"overdrive_name": ["超頻驅動", "OVERDRIVE"],
	"overdrive_desc": ["每級讓核心頻率效果額外提高 %s%%（最高 %s 級）", "Core Frequency effect gains another %s%% per level (max %s)"],
	"critical_name": ["臨界輸出", "CRITICAL OUTPUT"],
	"critical_desc": ["每級增加 %s%% 機率產生 ×%s Energy（最高 %s%%）", "+%s%% chance per level to produce ×%s Energy (max %s%%)"],
	"core_amplification_name": ["核心增幅", "CORE AMPLIFICATION"],
	"core_amplification_desc": ["每級全域 Energy 產量 +10%，價格按 7.5%% 複利成長；反應爐精通 Lv.10 解鎖", "+10% global Energy per level; cost grows by 7.5% compound; unlocked at Reactor Mastery Lv.10"],
	"automation_branch": ["自動化", "AUTOMATION"],
	"auto_core_name": ["核心自動化", "AUTO CORE"],
	"auto_core_desc": ["解鎖自動購買核心功率", "Unlock automatic Core Power purchases"],
	"auto_frequency_name": ["頻率自動化", "AUTO FREQUENCY"],
	"auto_frequency_desc": ["解鎖自動購買核心頻率", "Unlock automatic Core Frequency purchases"],
	"auto_efficiency_name": ["效率自動化", "AUTO EFFICIENCY"],
	"auto_efficiency_desc": ["解鎖自動購買效率", "Unlock automatic Efficiency purchases"],
	"smart_auto_name": ["智慧自動化", "SMART AUTO"],
	"smart_auto_desc": ["解鎖 Cheapest / Balanced 自動購買策略", "Unlock Cheapest / Balanced auto-buy strategies"],
	"auto_prestige_name": ["自動重生", "AUTO PRESTIGE"],
	"auto_prestige_desc": ["達到設定 PP 門檻與最短本輪時間後自動重生", "Automatically Prestige after both the PP target and minimum run time are met"],
	"offline_auto_name": ["離線自動購買", "OFFLINE AUTOMATION"],
	"offline_auto_desc": ["離線時依啟用的自動購買項目批量購買普通升級", "Batch-buy enabled ordinary upgrades while offline"],
	"auto_prestige_target": ["目標 PP", "TARGET PP"],
	"auto_prestige_minimum": ["最短本輪", "MIN RUN"],
	"runtime_off": ["關閉", "Off"],
	"runtime_1m": ["1 分鐘", "1 minute"],
	"runtime_5m": ["5 分鐘", "5 minutes"],
	"runtime_10m": ["10 分鐘", "10 minutes"],
	"auto_on": ["自動：開", "AUTO: ON"],
	"auto_off": ["自動：關", "AUTO: OFF"],
	"strategy_cheapest": ["Cheapest", "Cheapest"],
	"strategy_balanced": ["Balanced", "Balanced"],
	"offline_branch": ["離線", "OFFLINE"],
	"offline_eff_name": ["離線效率", "OFFLINE EFFICIENCY"],
	"offline_eff_desc": ["每級 +%s%% 離線效率，最高 %s%%", "+%s%% offline efficiency per level, up to %s%%"],
	"offline_cap_name": ["離線容量", "OFFLINE CAPACITY"],
	"offline_cap_desc": ["每級增加 %s 小時離線計算，上限 %s 小時", "+%s hours offline per level, up to %s hours"],
	"offline_boost_name": ["離線增幅", "OFFLINE BOOST"],
	"offline_boost_desc": ["每級離線產量額外 +%s%%（最高 %s 級）", "+%s%% offline production per level (max %s)"],
	"research": ["研究 · %s PP", "RESEARCH · %s PP"],
	"rank": ["Lv. ", "Lv. "],
	"max_level": ["已滿級", "MAX LEVEL"],
	"purchased": ["已解鎖", "UNLOCKED"],
	"confirm_title": ["重生確認", "CONFIRM REBIRTH"],
	"confirm_rebirth": ["重生會清除目前能量與普通升級，並取得 %s 點永久點數。要繼續嗎？", "Rebirth clears current Energy and ordinary upgrades for %s permanent point(s). Continue?"],
	"offline_title": ["離線收益", "OFFLINE REWARD"],
	"offline_time": ["離線時間：%s", "Offline time: %s"],
	"offline_gain": ["獲得 Energy：+%s", "Energy gained: +%s"],
	"offline_efficiency": ["目前離線效率：%s%%", "Offline efficiency: %s%%"],
	"claim": ["領取", "CLAIM"],
	"milestone_core_power": ["核心功率里程碑", "CORE POWER MILESTONE"],
	"milestone_reactor_speed": ["核心頻率里程碑", "CORE FREQUENCY MILESTONE"],
	"milestone_efficiency": ["效率里程碑", "EFFICIENCY MILESTONE"],
	"milestone_level": ["Lv.%s 已達成", "Lv.%s reached"],
	"milestone_effect": ["產量 ×%s", "Production ×%s"],
	"tutorial_energy_title": ["反應爐啟動", "REACTOR ONLINE"],
	"tutorial_energy_body": ["反應爐會自動產生 Energy。", "The reactor produces Energy automatically."],
	"tutorial_upgrade_title": ["強化反應爐", "UPGRADE THE REACTOR"],
	"tutorial_upgrade_body": ["使用 Energy 強化普通升級。", "Spend Energy on ordinary upgrades."],
	"tutorial_milestone_title": ["里程碑已達成", "MILESTONE REACHED"],
	"tutorial_milestone_body": ["Milestone 會提供額外產量倍率。", "Milestones add a production multiplier."],
	"prestige_ready_title": ["Prestige 已解鎖", "PRESTIGE UNLOCKED"],
	"prestige_ready_body": ["重生會失去普通進度，並取得永久 PP。", "Reset ordinary progress to gain permanent PP."],
	"automation_unlocked_title": ["自動化已解鎖", "AUTOMATION UNLOCKED"],
	"automation_unlocked_body": ["普通升級自動購買已可使用。", "Automatic ordinary upgrades are available."],
	"auto_prestige_unlocked_title": ["自動 Prestige 已解鎖", "AUTO PRESTIGE UNLOCKED"],
	"auto_prestige_unlocked_body": ["可在 Prestige 頁設定自動重生。", "Configure automatic Prestige on the Prestige page."],
	"offline_automation_unlocked_title": ["離線自動化已解鎖", "OFFLINE AUTOMATION UNLOCKED"],
	"offline_automation_unlocked_body": ["離線時也會自動購買普通升級。", "Ordinary upgrades can now auto-buy offline."],
	"core_amplification_unlocked_title": ["核心增幅已解鎖", "CORE AMPLIFICATION UNLOCKED"],
	"core_amplification_unlocked_body": ["Production 分支新增後期永久強化。", "A late-game permanent upgrade is available."],
	"auto_prestige_notice": ["自動 Prestige", "AUTO PRESTIGE"],
	"auto_prestige_gained": ["+%s PP 已保留", "+%s PP secured"],
	"reactor_reset": ["REACTOR RESET\n+%s PRESTIGE POINTS", "REACTOR RESET\n+%s PRESTIGE POINTS"],
	"stats_title": ["核心紀錄", "CORE RECORD"],
	"stats_total": ["歷史總 Energy 產生", "TOTAL ENERGY EVER PRODUCED"],
	"stats_rate": ["目前每秒產量", "CURRENT PRODUCTION / SEC"],
	"stats_highest": ["最高每秒產量", "HIGHEST PRODUCTION / SEC"],
	"stats_time": ["遊戲時間", "ACTIVE PLAY TIME"],
	"stats_rebirth": ["重生次數", "REBIRTHS"],
	"stats_cycle": ["本輪 Energy", "CURRENT RUN ENERGY"],
	"stats_points": ["累計取得 Prestige Points", "TOTAL PRESTIGE POINTS EARNED"],
	"stats_offline": ["離線取得 Energy", "TOTAL OFFLINE ENERGY EARNED"],
	"settings_title": ["設定", "SETTINGS"],
	"volume": ["音量", "MASTER VOLUME"],
	"number_format": ["數字格式", "NUMBER FORMAT"],
	"compact_format": ["標準縮寫（K、M、B、T、Qa、Qi）", "Standard suffixes (K, M, B, T, Qa, Qi)"],
	"full_format": ["科學記號", "Scientific notation"],
	"language": ["語言", "LANGUAGE"],
	"confirm": ["確認", "CONFIRM"],
	"cancel": ["取消", "CANCEL"]
}

const COLOR_BG := Color(0.047, 0.055, 0.056)
const COLOR_PANEL := Color(0.085, 0.094, 0.093)
const COLOR_PANEL_ALT := Color(0.065, 0.073, 0.073)
const COLOR_BORDER := Color(0.18, 0.21, 0.20)
const COLOR_TEXT := Color(0.90, 0.90, 0.86)
const COLOR_MUTED := Color(0.56, 0.59, 0.56)
const COLOR_ORANGE := Color(1.0, 0.43, 0.15)
const COLOR_CYAN := Color(0.28, 0.68, 0.64)

var _language := "zh"
var _active_page := "reactor"
var _page_host: Control
var _nav_buttons: Dictionary = {}
var _refs: Dictionary = {}
var _core_view: Control
var _language_picker: OptionButton
var _energy_value: Label
var _energy_caption: Label
var _rate_caption: Label
var _rate_value: Label
var _last_energy := -1.0
var _last_energy_feedback_msec := -1000
var _energy_tween: Tween
var _upgrade_feedback_tweens: Dictionary = {}
var _prestige_confirm: ConfirmationDialog
var _offline_dialog: ConfirmationDialog
var _milestone_toast: Label
var _milestone_tween: Tween
var _prestige_tooltip: Label
var _hovered_prestige_node := ""
var _status_toast_queue: Array[Dictionary] = []
var _status_toast_busy := false
var _prestige_overlay: ColorRect
var _prestige_reset_label: Label
var _prestige_animating := false
var _deferred_first_prestige_reward := 0
var _quantity_buttons: Dictionary = {}

func _ready() -> void:
	_load_ui_language()
	GameManager.bootstrap()
	PrestigeManager.prestige_performed.connect(_on_prestige_performed)
	PrestigeManager.node_unlocked.connect(_on_permanent_node_unlocked)
	_build_theme()
	_build_shell()
	_open_page("reactor")
	GameManager.state_changed.connect(_refresh_ui)
	_refresh_ui()
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(GameManager.master_volume, 0.0001)))
		AudioServer.set_bus_mute(master_bus, GameManager.master_volume <= 0.001)
	if GameManager.last_offline_seconds > 0.0:
		_show_offline_reward.call_deferred()
	_show_first_play_hints()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.save_now()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		GameManager.save_now()

func _load_ui_language() -> void:
	var config := ConfigFile.new()
	if config.load(UI_SETTINGS_PATH) == OK:
		var saved_language := str(config.get_value("ui", "language", "zh"))
		_language = "en" if saved_language == "en" else "zh"

func _save_ui_language() -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "language", _language)
	var error := config.save(UI_SETTINGS_PATH)
	if error != OK:
		push_warning("Could not save the UI language preference.")

func _build_theme() -> void:
	var theme := Theme.new()
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", COLOR_TEXT)
	theme.set_color("font_color", "Button", COLOR_TEXT)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(0.34, 0.36, 0.34))
	theme.set_stylebox("normal", "Button", _style_box(COLOR_PANEL_ALT, COLOR_BORDER, 1, 9))
	theme.set_stylebox("hover", "Button", _style_box(Color(0.15, 0.16, 0.15), COLOR_ORANGE, 1, 9))
	theme.set_stylebox("pressed", "Button", _style_box(Color(0.18, 0.11, 0.07), COLOR_ORANGE, 1, 9))
	theme.set_stylebox("disabled", "Button", _style_box(Color(0.075, 0.079, 0.076), Color(0.12, 0.13, 0.12), 1, 9))
	theme.set_stylebox("focus", "Button", _style_box(Color(0, 0, 0, 0), COLOR_ORANGE, 1, 9))
	theme.set_color("font_color", "OptionButton", COLOR_TEXT)
	theme.set_stylebox("normal", "OptionButton", _style_box(COLOR_PANEL_ALT, COLOR_BORDER, 1, 7))
	theme.set_stylebox("hover", "OptionButton", _style_box(Color(0.13, 0.14, 0.13), COLOR_ORANGE, 1, 7))
	theme.set_stylebox("pressed", "OptionButton", _style_box(Color(0.15, 0.11, 0.08), COLOR_ORANGE, 1, 7))
	self.theme = theme

func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var backdrop := AmbientBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 8)
	margin.add_child(shell)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 40
	header.add_theme_constant_override("separation", 10)
	shell.add_child(header)
	header.add_child(_label("CORE REACTOR", 19, COLOR_TEXT))
	var header_space := Control.new()
	header_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_space)
	_language_picker = OptionButton.new()
	_language_picker.custom_minimum_size = Vector2(145, 34)
	_language_picker.add_item("繁體中文")
	_language_picker.set_item_metadata(0, "zh")
	_language_picker.add_item("English")
	_language_picker.set_item_metadata(1, "en")
	_language_picker.select(1 if _language == "en" else 0)
	_language_picker.item_selected.connect(_on_language_selected)
	header.add_child(_language_picker)

	var resources := HBoxContainer.new()
	resources.custom_minimum_size.y = 82
	resources.add_theme_constant_override("separation", 20)
	shell.add_child(resources)
	var energy_column := VBoxContainer.new()
	energy_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	energy_column.alignment = BoxContainer.ALIGNMENT_CENTER
	energy_column.add_theme_constant_override("separation", 0)
	resources.add_child(energy_column)
	_energy_caption = _label(_t("energy"), 12, COLOR_MUTED)
	energy_column.add_child(_energy_caption)
	_energy_value = _label("0", 42, COLOR_ORANGE)
	_energy_value.add_theme_font_size_override("font_size", 42)
	energy_column.add_child(_energy_value)
	_refs["energy_caption"] = _energy_caption

	var rate_column := VBoxContainer.new()
	rate_column.custom_minimum_size.x = 260
	rate_column.alignment = BoxContainer.ALIGNMENT_CENTER
	rate_column.add_theme_constant_override("separation", 2)
	resources.add_child(rate_column)
	_rate_caption = _label(_t("rate"), 12, COLOR_MUTED)
	rate_column.add_child(_rate_caption)
	_rate_value = _label("+1 / sec", 24, COLOR_TEXT)
	rate_column.add_child(_rate_value)
	_refs["rate_caption"] = _rate_caption
	_refs["rate_value"] = _rate_value

	_page_host = Control.new()
	_page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(_page_host)

	var nav_center := CenterContainer.new()
	nav_center.custom_minimum_size.y = 48
	nav_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.add_child(nav_center)
	var nav_row := HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 8)
	nav_center.add_child(nav_row)
	for page_id in PAGE_ORDER:
		var button := Button.new()
		button.text = _nav_text(page_id)
		button.custom_minimum_size = Vector2(142, 40)
		button.pressed.connect(_open_page.bind(page_id))
		nav_row.add_child(button)
		_nav_buttons[page_id] = button

	_milestone_toast = _label("", 14, COLOR_ORANGE)
	_milestone_toast.anchor_left = 0.5
	_milestone_toast.anchor_right = 0.5
	_milestone_toast.offset_left = -260
	_milestone_toast.offset_right = 260
	_milestone_toast.offset_top = 142
	_milestone_toast.offset_bottom = 202
	_milestone_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_milestone_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_milestone_toast.add_theme_font_size_override("font_size", 14)
	_milestone_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_milestone_toast.modulate.a = 0.0
	_milestone_toast.z_index = 30
	add_child(_milestone_toast)

	_prestige_overlay = ColorRect.new()
	_prestige_overlay.color = Color.BLACK
	_prestige_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_prestige_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_prestige_overlay.modulate.a = 0.0
	_prestige_overlay.visible = false
	_prestige_overlay.z_index = 20
	add_child(_prestige_overlay)
	_prestige_reset_label = _label("", 22, COLOR_ORANGE)
	_prestige_reset_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_prestige_reset_label.offset_left = -270
	_prestige_reset_label.offset_right = 270
	_prestige_reset_label.offset_top = -36
	_prestige_reset_label.offset_bottom = 44
	_prestige_reset_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prestige_reset_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prestige_reset_label.modulate.a = 0.0
	_prestige_reset_label.visible = false
	_prestige_overlay.add_child(_prestige_reset_label)

func _nav_text(page_id: String) -> String:
	match page_id:
		"reactor":
			return _t("nav_reactor")
		"prestige":
			return _t("nav_prestige")
		"statistics":
			return _t("nav_statistics")
		"settings":
			return _t("nav_settings")
	return page_id.to_upper()

func _open_page(page_id: String) -> void:
	_active_page = page_id if PAGE_ORDER.has(page_id) else "reactor"
	_refs.clear()
	_quantity_buttons.clear()
	_prestige_tooltip = null
	_hovered_prestige_node = ""
	_refs["energy_caption"] = _energy_caption
	_refs["energy_value"] = _energy_value
	_refs["rate_caption"] = _rate_caption
	_refs["rate_value"] = _rate_value
	_core_view = null
	for child in _page_host.get_children():
		child.queue_free()
	var page: Control
	match _active_page:
		"reactor":
			page = _build_reactor_page()
		"prestige":
			page = _build_prestige_page()
		"statistics":
			page = _build_statistics_page()
		"settings":
			page = _build_settings_page()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_host.add_child(page)
	for nav_id in PAGE_ORDER:
		var button: Button = _nav_buttons[nav_id]
		button.text = _nav_text(nav_id)
		button.add_theme_stylebox_override("normal", _nav_style(nav_id == _active_page))
		button.add_theme_color_override("font_color", COLOR_ORANGE if nav_id == _active_page else COLOR_MUTED)
	AudioManager.bind_ui_tree(self)
	_refresh_ui()

func _show_first_play_hints() -> void:
	if not bool(GameManager.tutorial_flags.get("energy", true)):
		GameManager.mark_tutorial_seen("energy")
		_queue_status_toast(_t("tutorial_energy_title"), _t("tutorial_energy_body"))
	if not bool(GameManager.tutorial_flags.get("upgrade", true)):
		GameManager.mark_tutorial_seen("upgrade")
		_queue_status_toast(_t("tutorial_upgrade_title"), _t("tutorial_upgrade_body"))

func _build_reactor_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 6)
	var breathing_space := Control.new()
	breathing_space.custom_minimum_size.y = 4
	page.add_child(breathing_space)

	var quantity_row := HBoxContainer.new()
	quantity_row.custom_minimum_size.y = 30
	quantity_row.alignment = BoxContainer.ALIGNMENT_CENTER
	quantity_row.add_theme_constant_override("separation", 5)
	page.add_child(quantity_row)
	for mode in ["x1", "x10", "max"]:
		var quantity_button := Button.new()
		quantity_button.text = _t("qty_" + mode)
		quantity_button.custom_minimum_size = Vector2(76, 28)
		quantity_button.pressed.connect(_on_purchase_mode_selected.bind(mode))
		quantity_row.add_child(quantity_button)
		_quantity_buttons[mode] = quantity_button

	var core := ReactorCoreView.new()
	core.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	core.size_flags_vertical = Control.SIZE_EXPAND_FILL
	core.custom_minimum_size.y = 260
	page.add_child(core)
	_core_view = core

	var upgrade_row := HBoxContainer.new()
	upgrade_row.custom_minimum_size.y = 156
	upgrade_row.add_theme_constant_override("separation", 12)
	page.add_child(upgrade_row)
	for upgrade_id in UpgradeManager.get_upgrade_ids():
		var card := _panel(COLOR_PANEL, COLOR_BORDER, 12)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upgrade_row.add_child(card)
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 5)
		card.add_child(content)
		var title := _label(_upgrade_name(upgrade_id), 17, COLOR_TEXT)
		content.add_child(title)
		var level := _label(_t("level") + "0", 12, COLOR_ORANGE)
		content.add_child(level)
		var effect := _label(_upgrade_effect(upgrade_id), 12, COLOR_MUTED)
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		effect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content.add_child(effect)
		var purchase := Button.new()
		purchase.custom_minimum_size.y = 42
		purchase.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		content.add_child(purchase)
		_refs["upgrade_" + upgrade_id] = {"level": level, "effect": effect, "button": purchase}
	return page
func _build_prestige_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 7)
	var intro := VBoxContainer.new()
	intro.add_theme_constant_override("separation", 2)
	page.add_child(intro)
	intro.add_child(_label(_t("rebirth_title"), 22, COLOR_TEXT))
	intro.add_child(_label(_t("rebirth_subtitle"), 12, COLOR_MUTED))

	var summary := _panel(COLOR_PANEL, COLOR_BORDER, 14)
	summary.custom_minimum_size.y = 156
	page.add_child(summary)
	var summary_content := VBoxContainer.new()
	summary_content.add_theme_constant_override("separation", 8)
	summary.add_child(summary_content)
	var summary_row := HBoxContainer.new()
	summary_row.add_theme_constant_override("separation", 20)
	summary_content.add_child(summary_row)
	var points_column := VBoxContainer.new()
	points_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	points_column.alignment = BoxContainer.ALIGNMENT_CENTER
	points_column.add_child(_label(_t("points"), 11, COLOR_MUTED))
	var points_value := _label("0", 32, COLOR_ORANGE)
	points_column.add_child(points_value)
	summary_row.add_child(points_column)
	_refs["prestige_points"] = points_value
	var available_column := VBoxContainer.new()
	available_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	available_column.alignment = BoxContainer.ALIGNMENT_CENTER
	available_column.add_child(_label(_t("available"), 11, COLOR_MUTED))
	var available_value := _label("0", 32, COLOR_TEXT)
	available_column.add_child(available_value)
	summary_row.add_child(available_column)
	_refs["prestige_pending"] = available_value
	var rebirth := Button.new()
	rebirth.custom_minimum_size = Vector2(230, 46)
	rebirth.pressed.connect(_on_prestige_requested)
	summary_row.add_child(rebirth)
	_refs["prestige_button"] = rebirth
	var cycle_row := HBoxContainer.new()
	cycle_row.add_theme_constant_override("separation", 24)
	summary_content.add_child(cycle_row)
	var cycle_value := _label("", 13, COLOR_TEXT)
	cycle_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cycle_row.add_child(cycle_value)
	_refs["prestige_run"] = cycle_value
	var next_value := _label("", 13, COLOR_MUTED)
	next_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cycle_row.add_child(next_value)
	_refs["prestige_next"] = next_value

	var branch_title := _label(_t("branches"), 14, COLOR_TEXT)
	page.add_child(branch_title)
	var branches_scroll := ScrollContainer.new()
	branches_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	branches_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(branches_scroll)
	_refs["prestige_scroll"] = branches_scroll
	var branch_columns := HBoxContainer.new()
	branch_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	branch_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	branch_columns.add_theme_constant_override("separation", 16)
	branches_scroll.add_child(branch_columns)
	for branch_id in PrestigeManager.get_branch_ids():
		var branch_column := VBoxContainer.new()
		branch_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		branch_column.add_theme_constant_override("separation", 5)
		branch_columns.add_child(branch_column)
		var branch_key := branch_id + "_branch"
		var branch_color := _branch_color(branch_id)
		branch_column.add_child(_label(_t(branch_key), 13, branch_color))
		var branch_rule := ColorRect.new()
		branch_rule.color = branch_color.darkened(0.50)
		branch_rule.custom_minimum_size.y = 2
		branch_column.add_child(branch_rule)
		var node_track := VBoxContainer.new()
		node_track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node_track.add_theme_constant_override("separation", 0)
		branch_column.add_child(node_track)
		var branch_nodes := PrestigeManager.get_branch_nodes(branch_id)
		for node_index in range(branch_nodes.size()):
			var connector: ColorRect = null
			if node_index > 0:
				var connector_row := HBoxContainer.new()
				connector_row.custom_minimum_size.y = 12
				connector_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				node_track.add_child(connector_row)
				var connector_lane := CenterContainer.new()
				connector_lane.custom_minimum_size.x = 16
				connector_lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
				connector_row.add_child(connector_lane)
				connector = ColorRect.new()
				connector.custom_minimum_size = Vector2(2, 12)
				connector.color = branch_color.darkened(0.72)
				connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
				connector_lane.add_child(connector)
				var connector_space := Control.new()
				connector_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				connector_row.add_child(connector_space)
			_build_prestige_node(node_track, branch_id, str(branch_nodes[node_index]), connector)

	var tooltip_rule := ColorRect.new()
	tooltip_rule.color = COLOR_BORDER
	tooltip_rule.custom_minimum_size.y = 1
	page.add_child(tooltip_rule)
	_prestige_tooltip = _label(_t("prestige_hover_hint"), 12, COLOR_MUTED)
	_prestige_tooltip.custom_minimum_size.y = 42
	_prestige_tooltip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prestige_tooltip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prestige_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(_prestige_tooltip)
	_refs["prestige_tooltip"] = _prestige_tooltip
	return page

func _build_prestige_node(parent: VBoxContainer, branch_id: String, node_id: String, connector: ColorRect = null) -> void:
	var definition := _prestige_copy(node_id)
	var node_stack := VBoxContainer.new()
	node_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node_stack.add_theme_constant_override("separation", 3)
	parent.add_child(node_stack)
	var node_line := HBoxContainer.new()
	node_line.custom_minimum_size.y = 46
	node_line.add_theme_constant_override("separation", 6)
	node_stack.add_child(node_line)
	var marker_lane := CenterContainer.new()
	marker_lane.custom_minimum_size = Vector2(16, 46)
	marker_lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_line.add_child(marker_lane)
	var marker := ColorRect.new()
	marker.custom_minimum_size = Vector2(9, 9)
	marker.color = _branch_color(branch_id).darkened(0.72)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker_lane.add_child(marker)
	var node_button := Button.new()
	node_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node_button.custom_minimum_size.y = 46
	node_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node_button.add_theme_font_size_override("font_size", 12)
	node_button.text = str(definition["name"]) + "\n" + _t("tree_locked")
	node_button.pressed.connect(_on_prestige_node_pressed.bind(node_id))
	node_button.mouse_entered.connect(_on_prestige_node_hover.bind(node_id))
	node_button.mouse_exited.connect(_on_prestige_node_exit.bind(node_id))
	node_line.add_child(node_button)
	var toggle: CheckButton = null
	var strategy: OptionButton = null
	var has_actions := false
	var actions: HBoxContainer = null
	if node_id in ["auto_core", "auto_frequency", "auto_efficiency", "smart_auto", "auto_prestige"]:
		actions = HBoxContainer.new()
		actions.add_theme_constant_override("separation", 6)
	if node_id in ["auto_core", "auto_frequency", "auto_efficiency", "auto_prestige"]:
		toggle = CheckButton.new()
		toggle.custom_minimum_size = Vector2(112, 28)
		toggle.toggled.connect(_on_auto_toggle.bind(node_id))
		actions.add_child(toggle)
		has_actions = true
	if node_id == "smart_auto":
		strategy = OptionButton.new()
		strategy.custom_minimum_size = Vector2(130, 28)
		strategy.add_item(_t("strategy_cheapest"))
		strategy.set_item_metadata(0, "cheapest")
		strategy.add_item(_t("strategy_balanced"))
		strategy.set_item_metadata(1, "balanced")
		strategy.item_selected.connect(_on_auto_strategy_selected.bind(strategy))
		actions.add_child(strategy)
		has_actions = true
	var auto_prestige_target: OptionButton = null
	var auto_prestige_minimum: OptionButton = null
	if node_id == "auto_prestige":
		var settings_row := HBoxContainer.new()
		settings_row.add_theme_constant_override("separation", 4)
		settings_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node_stack.add_child(settings_row)
		settings_row.add_child(_label(_t("auto_prestige_target"), 10, COLOR_MUTED))
		auto_prestige_target = OptionButton.new()
		auto_prestige_target.custom_minimum_size = Vector2(76, 26)
		for target in BalanceConfig.AUTO_PRESTIGE_TARGETS:
			auto_prestige_target.add_item(str(target) + " PP")
			auto_prestige_target.set_item_metadata(auto_prestige_target.item_count - 1, target)
		auto_prestige_target.item_selected.connect(_on_auto_prestige_target_selected.bind(auto_prestige_target))
		settings_row.add_child(auto_prestige_target)
		settings_row.add_child(_label(_t("auto_prestige_minimum"), 10, COLOR_MUTED))
		auto_prestige_minimum = OptionButton.new()
		auto_prestige_minimum.custom_minimum_size = Vector2(88, 26)
		var runtime_values := BalanceConfig.AUTO_PRESTIGE_MINIMUM_RUN_TIMES
		var runtime_labels := [_t("runtime_off"), _t("runtime_1m"), _t("runtime_5m"), _t("runtime_10m")]
		for runtime_index in range(runtime_values.size()):
			auto_prestige_minimum.add_item(runtime_labels[runtime_index])
			auto_prestige_minimum.set_item_metadata(runtime_index, runtime_values[runtime_index])
		auto_prestige_minimum.item_selected.connect(_on_auto_prestige_minimum_selected.bind(auto_prestige_minimum))
		settings_row.add_child(auto_prestige_minimum)
	if has_actions:
		var action_indent := HBoxContainer.new()
		action_indent.add_theme_constant_override("separation", 0)
		node_stack.add_child(action_indent)
		var action_spacer := Control.new()
		action_spacer.custom_minimum_size.x = 22
		action_indent.add_child(action_spacer)
		action_indent.add_child(actions)
	_refs["node_" + node_id] = {
		"name": definition["name"],
		"description": definition["description"],
		"button": node_button,
		"toggle": toggle,
		"strategy": strategy,
		"auto_prestige_target": auto_prestige_target,
		"auto_prestige_minimum": auto_prestige_minimum,
		"marker": marker,
		"connector": connector,
		"branch_id": branch_id
	}

func _on_prestige_node_hover(node_id: String) -> void:
	_hovered_prestige_node = node_id
	_update_prestige_tooltip(node_id)

func _on_prestige_node_exit(node_id: String) -> void:
	if _hovered_prestige_node != node_id:
		return
	_hovered_prestige_node = ""
	if is_instance_valid(_prestige_tooltip):
		_prestige_tooltip.text = _t("prestige_hover_hint")

func _update_prestige_tooltip(node_id: String) -> void:
	if not is_instance_valid(_prestige_tooltip):
		return
	var definition := _prestige_copy(node_id)
	var rank := PrestigeManager.get_node_rank(node_id)
	var max_rank := PrestigeManager.get_node_max_rank(node_id)
	var cost_text := _t("node_max_tooltip") if max_rank >= 0 and rank >= max_rank else (_t("node_price_tooltip") % _format_number(float(PrestigeManager.get_node_cost(node_id))))
	_prestige_tooltip.text = str(definition["name"]) + "  ·  " + str(definition["description"]) + "  ·  " + cost_text

func _set_tree_node_style(button: Button, branch_color: Color, is_purchased: bool, can_buy: bool) -> void:
	var background := Color(0.055, 0.061, 0.060)
	var border := branch_color.darkened(0.78)
	var font_color := COLOR_MUTED
	if is_purchased:
		background = branch_color.darkened(0.79)
		border = branch_color.darkened(0.16)
		font_color = COLOR_TEXT
	elif can_buy:
		background = branch_color.darkened(0.83)
		border = branch_color
		font_color = branch_color.lightened(0.24)
	button.add_theme_stylebox_override("normal", _style_box(background, border, 1, 6))
	button.add_theme_stylebox_override("hover", _style_box(background.lightened(0.10), branch_color.lightened(0.12), 1, 6))
	button.add_theme_stylebox_override("pressed", _style_box(background.lightened(0.18), branch_color, 1, 6))
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)

func _branch_color(branch_id: String) -> Color:
	match branch_id:
		"production":
			return COLOR_ORANGE
		"automation":
			return Color(0.74, 0.70, 0.54)
		"offline":
			return COLOR_CYAN
	return COLOR_MUTED

func _build_statistics_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	page.add_child(_label(_t("stats_title"), 25, COLOR_TEXT))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 36)
	grid.add_theme_constant_override("v_separation", 16)
	page.add_child(grid)
	var definitions := [
		["stats_total", "stat_total", COLOR_ORANGE],
		["stats_rate", "stat_rate", COLOR_TEXT],
		["stats_highest", "stat_highest", COLOR_TEXT],
		["stats_time", "stat_time", COLOR_TEXT],
		["stats_rebirth", "stat_prestige", COLOR_TEXT],
		["stats_cycle", "stat_run", COLOR_TEXT],
		["stats_points", "stat_points", COLOR_ORANGE],
		["stats_offline", "stat_offline", COLOR_CYAN]
	]
	for entry in definitions:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.custom_minimum_size.y = 82
		cell.add_theme_constant_override("separation", 5)
		grid.add_child(cell)
		cell.add_child(_label(_t(entry[0]), 12, COLOR_MUTED))
		var value := _label("0", 25, entry[2])
		cell.add_child(value)
		_refs[entry[1]] = value
	return page

func _build_settings_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 18)
	page.add_child(_label(_t("settings_title"), 25, COLOR_TEXT))

	var volume_section := VBoxContainer.new()
	volume_section.add_theme_constant_override("separation", 8)
	page.add_child(volume_section)
	volume_section.add_child(_label(_t("volume"), 13, COLOR_MUTED))
	var volume_row := HBoxContainer.new()
	volume_row.add_theme_constant_override("separation", 12)
	volume_section.add_child(volume_row)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = GameManager.master_volume
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.y = 32
	slider.value_changed.connect(_on_volume_changed)
	volume_row.add_child(slider)
	var volume_value := _label("%d%%" % roundi(GameManager.master_volume * 100.0), 13, COLOR_ORANGE)
	volume_value.custom_minimum_size.x = 55
	volume_row.add_child(volume_value)
	_refs["volume_value"] = volume_value

	var format_section := VBoxContainer.new()
	format_section.add_theme_constant_override("separation", 8)
	page.add_child(format_section)
	format_section.add_child(_label(_t("number_format"), 13, COLOR_MUTED))
	var format_picker := OptionButton.new()
	format_picker.custom_minimum_size = Vector2(300, 40)
	format_picker.add_item(_t("compact_format"))
	format_picker.add_item(_t("full_format"))
	format_picker.set_item_metadata(0, "standard")
	format_picker.set_item_metadata(1, "scientific")
	format_picker.select(1 if GameManager.number_format == "scientific" else 0)
	format_picker.item_selected.connect(_on_number_format_selected.bind(format_picker))
	format_section.add_child(format_picker)
	return page

func _upgrade_name(upgrade_id: String) -> String:
	match upgrade_id:
		"core_power":
			return _t("core_power")
		"reactor_speed":
			return _t("reactor_speed")
		"efficiency":
			return _t("efficiency")
	return upgrade_id

func _upgrade_effect(upgrade_id: String) -> String:
	match upgrade_id:
		"core_power":
			var next_levels: Dictionary = GameManager.normal_levels.duplicate(true)
			next_levels["core_power"] = int(next_levels.get("core_power", 0)) + 1
			var per_level_gain := GameManager.calculate_energy_per_second(next_levels) - GameManager.get_energy_per_second()
			return _t("core_effect_prefix") + _format_number(per_level_gain) + _t("core_effect_suffix")
		"reactor_speed":
			return _t("speed_effect") % str(roundi(BalanceConfig.FREQUENCY_PER_LEVEL * 100.0))
		"efficiency":
			return _t("efficiency_effect") % str(roundi(BalanceConfig.EFFICIENCY_PER_LEVEL * 100.0))
	return ""

func _prestige_copy(node_id: String) -> Dictionary:
	match node_id:
		"reactor_mastery":
			var percent := str(roundi(BalanceConfig.REACTOR_MASTERY_PER_LEVEL * 100.0))
			return {"name": _t("mastery_name"), "description": _t("mastery_desc") % [percent, str(BalanceConfig.REACTOR_MASTERY_MAX_LEVEL)]}
		"overdrive":
			var percent := str(roundi(BalanceConfig.OVERDRIVE_FREQUENCY_BONUS_PER_LEVEL * 100.0))
			return {"name": _t("overdrive_name"), "description": _t("overdrive_desc") % [percent, str(BalanceConfig.OVERDRIVE_MAX_LEVEL)]}
		"critical_output":
			var chance := str(roundi(BalanceConfig.CRITICAL_OUTPUT_CHANCE_PER_LEVEL * 100.0))
			var maximum_chance := str(roundi(BalanceConfig.CRITICAL_OUTPUT_CHANCE_PER_LEVEL * BalanceConfig.CRITICAL_OUTPUT_MAX_LEVEL * 100.0))
			var multiplier := str(roundi(BalanceConfig.CRITICAL_OUTPUT_MULTIPLIER))
			return {"name": _t("critical_name"), "description": _t("critical_desc") % [chance, multiplier, maximum_chance]}
		"core_amplification":
			return {"name": _t("core_amplification_name"), "description": _t("core_amplification_desc")}
		"auto_core":
			return {"name": _t("auto_core_name"), "description": _t("auto_core_desc")}
		"auto_frequency":
			return {"name": _t("auto_frequency_name"), "description": _t("auto_frequency_desc")}
		"auto_efficiency":
			return {"name": _t("auto_efficiency_name"), "description": _t("auto_efficiency_desc")}
		"smart_auto":
			return {"name": _t("smart_auto_name"), "description": _t("smart_auto_desc")}
		"auto_prestige":
			return {"name": _t("auto_prestige_name"), "description": _t("auto_prestige_desc")}
		"offline_automation":
			return {"name": _t("offline_auto_name"), "description": _t("offline_auto_desc")}
		"offline_efficiency":
			var percent := str(roundi(BalanceConfig.OFFLINE_EFFICIENCY_PER_LEVEL * 100.0))
			var maximum := str(roundi(minf(1.0, BalanceConfig.OFFLINE_EFFICIENCY_BASE + BalanceConfig.OFFLINE_EFFICIENCY_MAX_LEVEL * BalanceConfig.OFFLINE_EFFICIENCY_PER_LEVEL) * 100.0))
			return {"name": _t("offline_eff_name"), "description": _t("offline_eff_desc") % [percent, maximum]}
		"offline_capacity":
			var per_level := str(roundi(BalanceConfig.OFFLINE_CAPACITY_HOURS_PER_LEVEL))
			var maximum_hours := str(roundi(BalanceConfig.OFFLINE_CAPACITY_BASE_HOURS + BalanceConfig.OFFLINE_CAPACITY_MAX_LEVEL * BalanceConfig.OFFLINE_CAPACITY_HOURS_PER_LEVEL))
			return {"name": _t("offline_cap_name"), "description": _t("offline_cap_desc") % [per_level, maximum_hours]}
		"offline_boost":
			var percent := str(roundi(BalanceConfig.OFFLINE_BOOST_PER_LEVEL * 100.0))
			return {"name": _t("offline_boost_name"), "description": _t("offline_boost_desc") % [percent, str(BalanceConfig.OFFLINE_BOOST_MAX_LEVEL)]}
	return {"name": node_id, "description": ""}
func _refresh_ui() -> void:
	if not is_inside_tree():
		return
	if is_instance_valid(_energy_caption):
		_energy_caption.text = _t("energy")
	if is_instance_valid(_rate_caption):
		_rate_caption.text = _t("rate")
	var current_energy := GameManager.energy
	if is_instance_valid(_energy_value):
		_energy_value.text = _format_number(current_energy)
		var now_msec := Time.get_ticks_msec()
		if _last_energy >= 0.0 and current_energy > _last_energy and now_msec - _last_energy_feedback_msec >= 800:
			_last_energy_feedback_msec = now_msec
			_play_energy_feedback()
	_last_energy = current_energy

	var rate := GameManager.get_energy_per_second()
	var total_upgrade_level := 0
	for upgrade_id in UpgradeManager.get_upgrade_ids():
		total_upgrade_level += int(GameManager.normal_levels.get(upgrade_id, 0))
	if _refs.has("rate_value"):
		var suffix := " / 秒" if _language == "zh" else " / sec"
		(_refs["rate_value"] as Label).text = "+" + _format_number(rate) + suffix
	if is_instance_valid(_core_view):
		_core_view.set_production_rate(rate)
		_core_view.set_visual_level(total_upgrade_level)
		_core_view.set_multiplier_text(_t("multiplier") + "  ×" + _format_number(rate))
	if not _prestige_animating:
		var available_reward := PrestigeManager.get_available_reward()
		if available_reward > 0:
			_show_prestige_unlock_notification(available_reward)

	for upgrade_id in UpgradeManager.get_upgrade_ids():
		var key := "upgrade_" + upgrade_id
		if not _refs.has(key):
			continue
		var controls: Dictionary = _refs[key]
		var level := int(GameManager.normal_levels.get(upgrade_id, 0))
		(controls["level"] as Label).text = _t("level") + NumberFormatter.format_value(float(level), "full")
		(controls["effect"] as Label).text = _upgrade_effect(upgrade_id)
		var button: Button = controls["button"]
		var amount := GameManager.get_selected_purchase_quantity(upgrade_id)
		var cost := UpgradeManager.get_bulk_cost(upgrade_id, amount) if amount > 0 else 0.0
		var mode_caption := _t("qty_" + GameManager.purchase_quantity_mode)
		if GameManager.purchase_quantity_mode == "max":
			mode_caption += " ×" + str(amount)
		button.text = _t("upgrade") % [mode_caption, _format_number(cost)]
		_set_purchase_button(button, amount > 0 and cost <= GameManager.energy)
	for mode in _quantity_buttons:
		_set_quantity_button(_quantity_buttons[mode], GameManager.purchase_quantity_mode == mode)

	if _refs.has("prestige_points"):
		(_refs["prestige_points"] as Label).text = NumberFormatter.format_value(float(GameManager.prestige_points), "full")
		(_refs["prestige_pending"] as Label).text = NumberFormatter.format_value(float(PrestigeManager.get_available_reward()), "full")
		(_refs["prestige_run"] as Label).text = _t("run_total") + ": " + _format_number(GameManager.run_energy_earned)
		(_refs["prestige_next"] as Label).text = _t("next_point") + ": " + _format_number(PrestigeManager.get_energy_until_next_point())
		var prestige_button: Button = _refs["prestige_button"]
		var reward := PrestigeManager.get_available_reward()
		prestige_button.text = _t("rebirth") % str(reward) if reward > 0 else _t("rebirth_locked") % _format_number(BalanceConfig.PRESTIGE_FIRST_THRESHOLD)
		_set_purchase_button(prestige_button, reward > 0)
	for node_id in PrestigeManager.get_node_ids():
		var key := "node_" + node_id
		if not _refs.has(key):
			continue
		var controls: Dictionary = _refs[key]
		var rank := PrestigeManager.get_node_rank(node_id)
		var max_rank := PrestigeManager.get_node_max_rank(node_id)
		var cost := PrestigeManager.get_node_cost(node_id)
		var completed := max_rank >= 0 and rank >= max_rank
		var node_color := _branch_color(str(controls["branch_id"]))
		var node_name := str(controls["name"])
		var rank_limit := "∞" if max_rank < 0 else str(max_rank)
		var button: Button = controls["button"]
		var can_buy := PrestigeManager.can_purchase_node(node_id)
		var status_line := _t("tree_locked")
		if completed:
			status_line = _t("tree_maxed")
		elif rank > 0:
			status_line = _t("tree_next_rank") % [str(rank), rank_limit, str(cost)]
		elif can_buy:
			status_line = _t("tree_ready") % str(cost)
		button.text = node_name + "\n" + status_line
		button.disabled = false
		_set_tree_node_style(button, node_color, rank > 0, can_buy)
		var marker: ColorRect = controls["marker"]
		marker.color = node_color if rank > 0 or can_buy else node_color.darkened(0.72)
		var connector: Variant = controls.get("connector")
		if is_instance_valid(connector):
			var siblings := PrestigeManager.get_branch_nodes(str(controls["branch_id"]))
			var node_index := siblings.find(node_id)
			var previous_is_purchased := node_index > 0 and PrestigeManager.get_node_rank(str(siblings[node_index - 1])) > 0
			connector.color = node_color.darkened(0.22) if rank > 0 or previous_is_purchased else node_color.darkened(0.72)
		var toggle: CheckButton = controls["toggle"]
		if is_instance_valid(toggle):
			var enabled := _get_auto_toggle_value(node_id)
			toggle.set_pressed_no_signal(enabled)
			toggle.text = _t("auto_on") if enabled else _t("auto_off")
			toggle.disabled = rank <= 0
		var strategy: OptionButton = controls["strategy"]
		if is_instance_valid(strategy):
			var selected_strategy := GameManager.auto_strategy
			for option_index in range(strategy.item_count):
				if str(strategy.get_item_metadata(option_index)) == selected_strategy:
					strategy.select(option_index)
					break
			strategy.disabled = rank <= 0
		var target_picker: OptionButton = controls["auto_prestige_target"]
		if is_instance_valid(target_picker):
			for option_index in range(target_picker.item_count):
				if int(target_picker.get_item_metadata(option_index)) == GameManager.auto_prestige_target_pp:
					target_picker.select(option_index)
					break
			target_picker.disabled = rank <= 0
		var minimum_picker: OptionButton = controls["auto_prestige_minimum"]
		if is_instance_valid(minimum_picker):
			for option_index in range(minimum_picker.item_count):
				if int(minimum_picker.get_item_metadata(option_index)) == GameManager.auto_prestige_minimum_run_time:
					minimum_picker.select(option_index)
					break
			minimum_picker.disabled = rank <= 0
	if not _hovered_prestige_node.is_empty():
		_update_prestige_tooltip(_hovered_prestige_node)

	var stats := {
		"stat_total": _format_number(GameManager.total_energy_earned),
		"stat_rate": "+" + _format_number(rate) + (" 能量/秒" if _language == "zh" else " Energy/sec"),
		"stat_highest": "+" + _format_number(GameManager.highest_energy_per_second) + (" 能量/秒" if _language == "zh" else " Energy/sec"),
		"stat_time": _format_duration(GameManager.total_play_time_seconds),
		"stat_prestige": str(GameManager.prestige_count),
		"stat_run": _format_number(GameManager.run_energy_earned),
		"stat_points": NumberFormatter.format_value(float(GameManager.total_prestige_points_earned), "full"),
		"stat_offline": _format_number(GameManager.total_offline_energy_earned)
	}
	for key in stats:
		if _refs.has(key):
			(_refs[key] as Label).text = stats[key]

func _play_energy_feedback() -> void:
	if is_instance_valid(_energy_tween) and _energy_tween.is_running():
		return
	_energy_tween = create_tween()
	_energy_value.pivot_offset = _energy_value.size * 0.5
	_energy_tween.tween_property(_energy_value, "scale", Vector2(1.018, 1.018), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_energy_tween.tween_property(_energy_value, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _on_upgrade_pressed(upgrade_id: String) -> void:
	var amount := GameManager.get_selected_purchase_quantity(upgrade_id)
	if amount <= 0:
		return
	var old_level := int(GameManager.normal_levels.get(upgrade_id, 0))
	if not UpgradeManager.purchase(upgrade_id, amount):
		return
	GameManager.save_now()
	_play_upgrade_feedback(upgrade_id)
	var new_level := int(GameManager.normal_levels.get(upgrade_id, 0))
	var achieved: Array[String] = []
	for milestone in BalanceConfig.MILESTONE_LEVELS:
		if old_level < milestone and new_level >= milestone:
			achieved.append("Lv." + str(milestone))
	if not achieved.is_empty():
		AudioManager.play_milestone()
		if not bool(GameManager.tutorial_flags.get("milestone", true)):
			GameManager.mark_tutorial_seen("milestone")
			_queue_status_toast(_t("tutorial_milestone_title"), _t("tutorial_milestone_body"))
		_show_milestone_toast(upgrade_id, achieved)
	else:
		AudioManager.play_upgrade_purchase()
	if is_instance_valid(_core_view):
		_core_view.trigger_pulse()

func _on_purchase_mode_selected(mode: String) -> void:
	GameManager.set_purchase_quantity_mode(mode)

func _show_milestone_toast(upgrade_id: String, levels: Array[String]) -> void:
	var title_key := "milestone_" + upgrade_id
	var multiplier := "%.1f" % BalanceConfig.MILESTONE_MULTIPLIER
	for level_text in levels:
		var numeric_level := level_text.trim_prefix("Lv.")
		var body := _t("milestone_level") % numeric_level
		body += "\n" + (_t("milestone_effect") % multiplier)
		_queue_status_toast(_t(title_key), body, 2.0)

func _queue_status_toast(title: String, body: String, duration: float = 2.0) -> void:
	if not is_instance_valid(_milestone_toast):
		return
	_status_toast_queue.append({"title": title, "body": body, "duration": duration})
	_show_next_status_toast()

func _show_next_status_toast() -> void:
	if _status_toast_busy or _status_toast_queue.is_empty() or not is_instance_valid(_milestone_toast):
		return
	_status_toast_busy = true
	var entry: Dictionary = _status_toast_queue.pop_front()
	_milestone_toast.text = str(entry.get("title", "")) + "\n" + str(entry.get("body", ""))
	_milestone_toast.modulate.a = 0.0
	_milestone_tween = create_tween()
	_milestone_tween.tween_property(_milestone_toast, "modulate:a", 1.0, 0.16)
	_milestone_tween.tween_interval(float(entry.get("duration", 2.0)))
	_milestone_tween.tween_property(_milestone_toast, "modulate:a", 0.0, 0.22)
	_milestone_tween.tween_callback(func():
		_status_toast_busy = false
		_show_next_status_toast()
	)

func _show_prestige_unlock_notification(reward: int) -> void:
	if reward <= 0:
		return
	var tutorial_unseen := not bool(GameManager.tutorial_flags.get("prestige", true))
	var unlock_unseen := not bool(GameManager.unlock_notification_flags.get("prestige", true))
	if not tutorial_unseen and not unlock_unseen:
		return
	if tutorial_unseen:
		GameManager.mark_tutorial_seen("prestige")
	if unlock_unseen:
		GameManager.mark_unlock_notified("prestige")
	_queue_status_toast(_t("prestige_ready_title"), _t("prestige_ready_body"))

func _show_unlock_notification(flag_id: String, title_key: String, body_key: String) -> void:
	if bool(GameManager.unlock_notification_flags.get(flag_id, true)):
		return
	GameManager.mark_unlock_notified(flag_id)
	_queue_status_toast(_t(title_key), _t(body_key))

func _on_permanent_node_unlocked(node_id: String) -> void:
	match node_id:
		"auto_core":
			_show_unlock_notification("automation", "automation_unlocked_title", "automation_unlocked_body")
		"auto_prestige":
			_show_unlock_notification("auto_prestige", "auto_prestige_unlocked_title", "auto_prestige_unlocked_body")
		"offline_automation":
			_show_unlock_notification("offline_automation", "offline_automation_unlocked_title", "offline_automation_unlocked_body")
		"core_amplification":
			_show_unlock_notification("core_amplification", "core_amplification_unlocked_title", "core_amplification_unlocked_body")

func _on_prestige_performed(reward: int, is_auto: bool) -> void:
	if GameManager.prestige_count == 1 and not bool(GameManager.unlock_notification_flags.get("prestige", true)):
		if _prestige_animating:
			_deferred_first_prestige_reward = reward
		else:
			_show_prestige_unlock_notification(reward)
	if is_auto:
		AudioManager.play_prestige_pulse(true)
		var gained_text := _t("auto_prestige_gained") % str(reward)
		_queue_status_toast(_t("auto_prestige_notice"), gained_text, 1.5)

func _show_offline_reward() -> void:
	if GameManager.last_offline_seconds <= 0.0:
		return
	if _offline_dialog == null:
		_offline_dialog = ConfirmationDialog.new()
		_offline_dialog.confirmed.connect(_on_offline_claimed)
		add_child(_offline_dialog)
	_offline_dialog.title = _t("offline_title")
	var efficiency_percent := str(roundi(PrestigeManager.offline_efficiency() * 100.0))
	_offline_dialog.dialog_text = "\n".join([
		_t("offline_time") % _format_duration(GameManager.last_offline_seconds),
		_t("offline_gain") % _format_number(GameManager.last_offline_gain),
		_t("offline_efficiency") % efficiency_percent
	])
	_offline_dialog.get_ok_button().text = _t("claim")
	_offline_dialog.get_cancel_button().visible = false
	AudioManager.bind_ui_tree(self)
	_offline_dialog.popup_centered(Vector2i(500, 220))

func _on_offline_claimed() -> void:
	GameManager.last_offline_gain = 0.0
	GameManager.last_offline_seconds = 0.0

func _play_upgrade_feedback(upgrade_id: String) -> void:
	var key := "upgrade_" + upgrade_id
	if not _refs.has(key):
		return
	var controls: Dictionary = _refs[key]
	var level_label: Label = controls["level"]
	var button: Button = controls["button"]
	var previous_tween: Variant = _upgrade_feedback_tweens.get(upgrade_id)
	if previous_tween is Tween and previous_tween.is_running():
		previous_tween.kill()

	level_label.pivot_offset = level_label.size * 0.5
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(level_label, "scale", Vector2(1.09, 1.09), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(level_label, "modulate", Color(1.35, 1.16, 0.82), 0.07)
	tween.tween_property(button, "scale", Vector2(0.985, 0.94), 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "self_modulate", Color(1.18, 1.06, 0.88), 0.045)
	tween.chain()
	tween.tween_property(level_label, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(level_label, "modulate", Color.WHITE, 0.16)
	tween.parallel().tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(button, "self_modulate", Color.WHITE, 0.12)
	_upgrade_feedback_tweens[upgrade_id] = tween

func _on_prestige_requested() -> void:
	var reward := PrestigeManager.get_available_reward()
	if reward <= 0:
		return
	if _prestige_confirm == null:
		_prestige_confirm = ConfirmationDialog.new()
		_prestige_confirm.confirmed.connect(_confirm_prestige)
		add_child(_prestige_confirm)
	_prestige_confirm.title = _t("confirm_title")
	_prestige_confirm.dialog_text = _t("confirm_rebirth") % str(reward)
	_prestige_confirm.get_ok_button().text = _t("confirm")
	_prestige_confirm.get_cancel_button().text = _t("cancel")
	AudioManager.bind_ui_tree(self)
	_prestige_confirm.popup_centered(Vector2i(480, 180))

func _confirm_prestige() -> void:
	var reward := PrestigeManager.get_available_reward()
	if reward <= 0 or _prestige_animating:
		return
	_prestige_animating = true
	GameManager.manual_prestige_pending = true
	if not is_instance_valid(_core_view):
		_open_page("reactor")
	_prestige_overlay.color = Color.BLACK
	_prestige_overlay.modulate.a = 0.0
	_prestige_overlay.visible = true
	AudioManager.play_prestige_charge()
	_prestige_reset_label.visible = false
	_prestige_reset_label.modulate.a = 0.0
	_prestige_reset_label.scale = Vector2(0.96, 0.96)
	if is_instance_valid(_core_view):
		_core_view.set_prestige_concentration(0.0)
		_core_view.set_prestige_burst(0.0)
	var tween := create_tween()
	if is_instance_valid(_core_view):
		tween.tween_method(Callable(_core_view, "set_prestige_concentration"), 0.0, 1.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_prestige_overlay, "modulate:a", 0.58, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(_core_view):
		tween.tween_method(Callable(_core_view, "set_prestige_burst"), 0.0, 1.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		AudioManager.play_prestige_pulse()
		var gained := PrestigeManager.perform_prestige(true, false)
		_prestige_reset_label.text = _t("reactor_reset") % str(gained)
		_prestige_reset_label.visible = true
	)
	tween.tween_property(_prestige_reset_label, "modulate:a", 1.0, 0.14)
	tween.parallel().tween_property(_prestige_reset_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.34)
	tween.tween_property(_prestige_overlay, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_instance_valid(_core_view):
		tween.parallel().tween_method(Callable(_core_view, "set_prestige_concentration"), 1.0, 0.0, 0.25)
	tween.tween_callback(func():
		_prestige_overlay.visible = false
		_prestige_reset_label.visible = false
		_prestige_animating = false
		GameManager.manual_prestige_pending = false
		if is_instance_valid(_core_view):
			_core_view.set_prestige_concentration(0.0)
			_core_view.set_prestige_burst(0.0)
		_refresh_ui()
		if _deferred_first_prestige_reward > 0:
			var first_reward := _deferred_first_prestige_reward
			_deferred_first_prestige_reward = 0
			_show_prestige_unlock_notification(first_reward)
	)

func _on_prestige_node_pressed(node_id: String) -> void:
	if PrestigeManager.purchase_node(node_id):
		GameManager.save_now()

func _on_auto_toggle(enabled: bool, node_id: String) -> void:
	match node_id:
		"auto_core":
			GameManager.set_auto_core_enabled(enabled)
		"auto_frequency":
			GameManager.set_auto_frequency_enabled(enabled)
		"auto_efficiency":
			GameManager.set_auto_efficiency_enabled(enabled)
		"auto_prestige":
			GameManager.set_auto_prestige_enabled(enabled)

func _get_auto_toggle_value(node_id: String) -> bool:
	match node_id:
		"auto_core":
			return GameManager.auto_core_enabled
		"auto_frequency":
			return GameManager.auto_frequency_enabled
		"auto_efficiency":
			return GameManager.auto_efficiency_enabled
		"auto_prestige":
			return GameManager.auto_prestige_enabled
	return false

func _on_auto_prestige_target_selected(index: int, picker: OptionButton) -> void:
	GameManager.set_auto_prestige_target(int(picker.get_item_metadata(index)))

func _on_auto_prestige_minimum_selected(index: int, picker: OptionButton) -> void:
	GameManager.set_auto_prestige_minimum_run_time(int(picker.get_item_metadata(index)))

func _on_auto_strategy_selected(index: int, picker: OptionButton) -> void:
	GameManager.set_auto_strategy(str(picker.get_item_metadata(index)))

func _on_volume_changed(value: float) -> void:
	GameManager.set_master_volume(value)
	if _refs.has("volume_value"):
		(_refs["volume_value"] as Label).text = "%d%%" % roundi(value * 100.0)

func _on_number_format_selected(index: int, picker: OptionButton) -> void:
	GameManager.set_number_format(str(picker.get_item_metadata(index)))
	GameManager.save_now()

func _on_language_selected(index: int) -> void:
	var selected_language := str(_language_picker.get_item_metadata(index))
	if selected_language == _language:
		return
	_language = selected_language
	_save_ui_language()
	_open_page(_active_page)

func _set_purchase_button(button: Button, affordable: bool) -> void:
	button.disabled = not affordable
	if affordable:
		button.add_theme_stylebox_override("normal", _style_box(COLOR_ORANGE, COLOR_ORANGE, 1, 9))
		button.add_theme_stylebox_override("hover", _style_box(Color(1.0, 0.55, 0.23), Color(1.0, 0.68, 0.39), 1, 9))
		button.add_theme_stylebox_override("pressed", _style_box(Color(0.78, 0.28, 0.08), COLOR_ORANGE, 1, 9))
		button.add_theme_color_override("font_color", Color(0.13, 0.08, 0.05))
	else:
		button.add_theme_stylebox_override("disabled", _style_box(Color(0.075, 0.079, 0.076), Color(0.12, 0.13, 0.12), 1, 9))
		button.add_theme_color_override("font_disabled_color", Color(0.38, 0.39, 0.36))

func _set_quantity_button(button: Button, selected: bool) -> void:
	if selected:
		button.add_theme_stylebox_override("normal", _style_box(Color(0.22, 0.13, 0.08), COLOR_ORANGE, 1, 5))
		button.add_theme_stylebox_override("hover", _style_box(Color(0.28, 0.16, 0.09), COLOR_ORANGE, 1, 5))
		button.add_theme_color_override("font_color", COLOR_ORANGE)
	else:
		button.add_theme_stylebox_override("normal", _style_box(COLOR_PANEL_ALT, COLOR_BORDER, 1, 5))
		button.add_theme_stylebox_override("hover", _style_box(Color(0.15, 0.16, 0.15), COLOR_BORDER, 1, 5))
		button.add_theme_color_override("font_color", COLOR_MUTED)

func _metric_column(caption: String, value: Label) -> Control:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 3)
	column.add_child(_label(caption, 11, COLOR_MUTED))
	column.add_child(value)
	return column

func _panel(background: Color, border: Color, padding: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style_box(background, border, 1, padding))
	return panel

func _style_box(background: Color, border: Color, border_width: int, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(2)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _nav_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.12, 0.11) if selected else Color(0, 0, 0, 0)
	style.border_color = COLOR_ORANGE
	style.set_border_width_all(0)
	style.border_width_bottom = 2 if selected else 0
	style.set_corner_radius_all(0)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _format_number(value: float) -> String:
	return NumberFormatter.format_value(value, GameManager.number_format)

func _format_duration(seconds: float) -> String:
	var total := maxi(0, int(floor(seconds)))
	var days := int(total / 86400)
	var hours := int((total % 86400) / 3600)
	var minutes := int((total % 3600) / 60)
	var remaining_seconds := total % 60
	var day_suffix := "天" if _language == "zh" else "d"
	if days > 0:
		return "%d%s %02d:%02d:%02d" % [days, day_suffix, hours, minutes, remaining_seconds]
	return "%02d:%02d:%02d" % [hours, minutes, remaining_seconds]

func _t(key: String) -> String:
	var pair: Array = TEXT.get(key, [key, key])
	return str(pair[0] if _language == "zh" else pair[1])
