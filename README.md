# stressreleasegame

Godot 4 scaffold for **Gentle Tidy**:

- `project.godot`: mobile renderer + portrait base resolution + `GameManager` autoload.
- `scripts/GameManager.gd`: JSON persistence for satisfaction points, unlocked diorama items, and daily task counters.
- `scenes/BubbleTile.tscn` + `scripts/BubbleTile.gd`: reusable tactile bubble tile with pop tween, vibration, and randomized audio pitch.
- `scripts/DioramaCanvas.gd`: isometric diorama item placement with bounce-in tween from unlocked data.