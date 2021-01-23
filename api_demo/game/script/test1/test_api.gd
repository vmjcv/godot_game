extends Node

class_name BaseNode
# 基本示例类的注释代码
# 给大佬们提供注释规范使用

signal door_opened # 门打开的时候发出信号
signal _door_closed # 门关闭的时候发出信号,不会导出，因为是_开头
enum MoveDirection {UP, DOWN=30, LEFT, RIGHT} # 移动方向
const MOVE_SPEED: float = 50.0 # 移动速度常量
export var move_time: float = 50.0 # 移动时间，编辑器中可用变量
var player_node: Node2D # 玩家节点
onready var score = 0 # 总分数

func to_api(a: int,b: int)-> int:
	# @:公开方法使用蛇形命名法,通过静态类型指定传入参数和传出参数
	# @a:向量方向
	# @b:向量大小
	# @return:向量归一化值
	var value = a + b
	return value

