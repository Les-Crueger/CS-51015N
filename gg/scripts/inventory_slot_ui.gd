extends PanelContainer

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var amount_label: Label = $MarginContainer/Amount

func set_slot(item_name: String, amount: int, icon_path: String) -> void:
	if item_name != "" and amount > 0:
		amount_label.text = str(amount) if amount > 1 else ""
		amount_label.visible = true
		if icon_path != "" and ResourceLoader.exists(icon_path):
			icon_rect.texture = load(icon_path)
			icon_rect.visible = true
		else:
			icon_rect.visible = false
	else:
		amount_label.visible = false
		icon_rect.visible = false
