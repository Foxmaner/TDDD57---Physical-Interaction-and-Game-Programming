extends Node2D

func update_values(currentScore, highScore):
	$CurrentValue.text = var2str(currentScore)
	$HighValue.text = var2str(highScore)
