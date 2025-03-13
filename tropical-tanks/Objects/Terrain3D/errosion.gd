extends Node
class_name Erosion

# Parameters (matching Unity defaults)
@export var seed: int = 0
@export var erosion_radius: int = 8
@export var inertia: float = 0.05
@export var sediment_capacity_factor: float = 4.0
@export var min_sediment_capacity: float = 0.01
@export var erode_speed: float = 0.3
@export var deposit_speed: float = 0.3
@export var evaporate_speed: float = 0.01
@export var gravity: float = 4.0
@export var max_droplet_lifetime: int = 30
@export var initial_water_volume: float = 1.0
@export var initial_speed: float = 1.0
@export var erosion_iterations: int = 50000  # Number of droplets to simulate

# Internal variables for the erosion brush
var erosion_brush_indices = []
var erosion_brush_weights = []
var current_erosion_radius = -1
var current_map_size = -1

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = seed

func initialize_erosion_brush_indices(map_size: int, radius: int) -> void:
	print("Initializing brush indices...")
	
	if current_erosion_radius == radius and current_map_size == map_size:
		return

	erosion_brush_indices.clear()
	erosion_brush_weights.clear()
	current_erosion_radius = radius
	current_map_size = map_size

	# Precompute valid brush offsets and weights (only for offsets inside a circle)
	var brush_offsets = []
	var weight_map = {}

	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var dist_sq = dx * dx + dy * dy
			if dist_sq < radius * radius:
				var weight = 1.0 - (sqrt(dist_sq) / float(radius))
				brush_offsets.append(Vector2(dx, dy))
				weight_map[Vector2(dx, dy)] = weight

	# For each cell on the map, compute the list of valid neighboring indices and normalized weights.
	for y in range(map_size):
		for x in range(map_size):
			var entries = []
			var weights = []
			var weight_sum = 0.0

			for offset in brush_offsets:
				var coord_x = x + int(offset.x)
				var coord_y = y + int(offset.y)
				if coord_x >= 0 and coord_x < map_size and coord_y >= 0 and coord_y < map_size:
					var weight = weight_map[offset]
					weight_sum += weight
					entries.append(coord_y * map_size + coord_x)
					weights.append(weight)

			# Normalize the weights if there was any contribution.
			if weight_sum > 0:
				var inv_weight_sum = 1.0 / weight_sum
				for i in range(weights.size()):
					weights[i] *= inv_weight_sum

			erosion_brush_indices.append(entries)
			erosion_brush_weights.append(weights)

func calculate_height_and_gradient(height_array: Array, map_size: int, pos_x: float, pos_y: float) -> Dictionary:
	var coord_x = clamp(int(pos_x), 0, map_size - 2)
	var coord_y = clamp(int(pos_y), 0, map_size - 2)
	var x = pos_x - coord_x
	var y = pos_y - coord_y

	var index_nw = coord_y * map_size + coord_x
	var index_ne = index_nw + 1
	var index_sw = index_nw + map_size
	var index_se = index_sw + 1

	var height_nw = height_array[index_nw]
	var height_ne = height_array[index_ne]
	var height_sw = height_array[index_sw]
	var height_se = height_array[index_se]

	var gradient_x = (height_ne - height_nw) * (1 - y) + (height_se - height_sw) * y
	var gradient_y = (height_sw - height_nw) * (1 - x) + (height_se - height_ne) * x
	var height = height_nw * (1 - x) * (1 - y) + height_ne * x * (1 - y) + height_sw * (1 - x) * y + height_se * x * y

	return {"height": height, "gradient_x": gradient_x, "gradient_y": gradient_y}

func apply_erosion(heightImage: Image, map_size: int) -> void:
	print("Starting erosion...")

	# Initialize height array from the image's red channel (assumed to be in the range 0–1)
	var height_array = []
	# Pre-fill the array with zeros
	for i in range(map_size * map_size):
		height_array.append(0.0)
		
	for y in range(map_size):
		for x in range(map_size):
			height_array[y * map_size + x] = heightImage.get_pixel(x, y).r

	# Ensure the erosion brush indices are up-to-date.
	initialize_erosion_brush_indices(map_size, erosion_radius)

	# Reset the RNG seed for reproducibility.
	rng.seed = seed

	# Simulate erosion droplets.
	for iteration in range(erosion_iterations):
		var pos_x = rng.randf_range(0, map_size - 1)
		var pos_y = rng.randf_range(0, map_size - 1)
		var dir_x = 0.0
		var dir_y = 0.0
		var speed = initial_speed
		var water = initial_water_volume
		var sediment = 0.0

		if(iteration % 10000 == 0 && iteration != 0):
			print("Currently processed iteration " + str(iteration))

		for lifetime in range(max_droplet_lifetime):
			var node_x = int(pos_x)
			var node_y = int(pos_y)
			var droplet_index = node_y * map_size + node_x
			var cell_offset_x = pos_x - node_x
			var cell_offset_y = pos_y - node_y

			var grad = calculate_height_and_gradient(height_array, map_size, pos_x, pos_y)
			# Removed grad.empty() check as grad always returns the required keys.

			# Update droplet direction with inertia
			dir_x = dir_x * inertia - grad["gradient_x"] * (1 - inertia)
			dir_y = dir_y * inertia - grad["gradient_y"] * (1 - inertia)
			var len_dir = sqrt(dir_x * dir_x + dir_y * dir_y)
			if len_dir != 0:
				dir_x /= len_dir
				dir_y /= len_dir
			else:
				break

			pos_x += dir_x
			pos_y += dir_y

			# Check if droplet has left the map.
			if pos_x < 0 or pos_x >= map_size - 1 or pos_y < 0 or pos_y >= map_size - 1:
				break

			# Get new height and compute change.
			var new_grad = calculate_height_and_gradient(height_array, map_size, pos_x, pos_y)
			# Removed new_grad.empty() check as well.
			var delta_height = new_grad["height"] - grad["height"]

			# Update speed based on gravity and height difference.
			speed = sqrt(max(speed * speed + delta_height * gravity, 0.0))
			# Calculate sediment capacity.
			var sediment_capacity = max(-delta_height * speed * water * sediment_capacity_factor, min_sediment_capacity)

			if sediment > sediment_capacity or delta_height > 0:
				# Deposit sediment.
				var amount_to_deposit = 0.0
				if delta_height > 0:
					amount_to_deposit = min(delta_height, sediment)
				else:
					amount_to_deposit = (sediment - sediment_capacity) * deposit_speed
				sediment -= amount_to_deposit

				# Deposit sediment to the four nodes using bilinear interpolation.
				height_array[droplet_index] += amount_to_deposit * (1 - cell_offset_x) * (1 - cell_offset_y)
				height_array[droplet_index + 1] += amount_to_deposit * cell_offset_x * (1 - cell_offset_y)
				height_array[droplet_index + map_size] += amount_to_deposit * (1 - cell_offset_x) * cell_offset_y
				height_array[droplet_index + map_size + 1] += amount_to_deposit * cell_offset_x * cell_offset_y
			else:
				# Erode terrain.
				var amount_to_erode = min((sediment_capacity - sediment) * erode_speed, -delta_height)
				if amount_to_erode > 0:
					var indices = erosion_brush_indices[droplet_index]
					var weights = erosion_brush_weights[droplet_index]
					for i in range(indices.size()):
						var weighed_erode = amount_to_erode * weights[i]
						var delta_sediment = min(height_array[indices[i]], weighed_erode)
						height_array[indices[i]] -= delta_sediment
						sediment += delta_sediment

			# Evaporate water.
			water *= (1 - evaporate_speed)
			if water < 0.01:
				break

	# Write the modified height values back into the image.
	for y in range(map_size):
		for x in range(map_size):
			var h = clamp(height_array[y * map_size + x], 0.0, 1.0)
			heightImage.set_pixel(x, y, Color(h, 0, 0))
