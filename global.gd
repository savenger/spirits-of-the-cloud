extends Node

signal field_fully_watered(offset: int)
signal field_lost(offset: int)

signal weather_influenced(duration: float)

var fields_saved = 0
var fields_lost = 0

func reset():
	fields_saved = 0
	fields_lost = 0

const MARGIN_LEFT = 250.0
const MARGIN_RIGHT = 50000.0
const MARGIN_TOP = 500.0
const MARGIN_BOTTOM = 2500.0

const CLOUD_AREA_LEFT = 250.0
const CLOUD_AREA_RIGHT = 2500.0
const CLOUD_AREA_TOP = 250.0
const CLOUD_AREA_BOTTOM = 1000.0
const CLOUD_COUNT_PER_ROW = 5
const CLOUD_ROWS = 2

const TREE_COUNT = 5

const VIEW_WIDTH = 5760
const VIEW_HEIGHT = 3240
