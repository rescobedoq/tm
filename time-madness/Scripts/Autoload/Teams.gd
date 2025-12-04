extends Node

const TEAM_COLORS := {
	0: Color.RED,
	1: Color.BLUE,
	2: Color.GREEN,
	3: Color.YELLOW,
	4: Color.PURPLE,
	5: Color.ORANGE,
}

func get_team_color(team_id: int) -> Color:
	return TEAM_COLORS.get(team_id, Color.WHITE)
