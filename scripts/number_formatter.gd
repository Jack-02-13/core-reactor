class_name NumberFormatter
extends RefCounted

const SUFFIXES: Array[String] = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg"
]

static func format_value(value: float, mode: String = "compact") -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value):
		return "-∞" if value < 0.0 else "∞"
	if mode == "full":
		return _format_full(value)
	if mode == "scientific":
		return _format_scientific(value)
	var negative := value < 0.0
	var scaled := absf(value)
	var suffix_index := 0
	while scaled >= 1000.0 and suffix_index < SUFFIXES.size() - 1:
		scaled /= 1000.0
		suffix_index += 1
	if scaled >= 1000.0:
		return _format_scientific(value)
	var decimals := 2 if scaled < 10.0 else (1 if scaled < 100.0 else 0)
	var text := _trim_zeros(("%.2f" % scaled) if decimals == 2 else (("%.1f" % scaled) if decimals == 1 else ("%.0f" % scaled)))
	return ("-" if negative else "") + text + SUFFIXES[suffix_index]

static func _format_scientific(value: float) -> String:
	if value == 0.0:
		return "0"
	var exponent := int(floor(log(absf(value)) / log(10.0)))
	var scaled := absf(value) / pow(10.0, exponent)
	if scaled >= 9.9995:
		scaled /= 10.0
		exponent += 1
	var mantissa := _trim_zeros("%.3f" % scaled)
	return ("-" if value < 0.0 else "") + mantissa + "e" + ("+" if exponent >= 0 else "") + str(exponent)

static func _format_full(value: float) -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value):
		return "-∞" if value < 0.0 else "∞"
	var negative := value < 0.0
	var rounded := absf(value)
	var raw := "%.2f" % rounded
	var parts := raw.split(".")
	var whole: String = parts[0]
	var grouped := ""
	for index in range(whole.length()):
		if index > 0 and (whole.length() - index) % 3 == 0:
			grouped += ","
		grouped += whole.substr(index, 1)
	var decimals: String = parts[1]
	while decimals.ends_with("0"):
		decimals = decimals.substr(0, decimals.length() - 1)
	var result := grouped
	if not decimals.is_empty():
		result += "." + decimals
	return ("-" if negative else "") + result

static func _trim_zeros(text: String) -> String:
	var result := text
	while result.contains(".") and result.ends_with("0"):
		result = result.substr(0, result.length() - 1)
	if result.ends_with("."):
		result = result.substr(0, result.length() - 1)
	return result
