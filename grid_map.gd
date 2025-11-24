extends GridMap
class_name Map

# Variables
var settings = GenerationSettings


#creates a simple map out of the grass and water tiles
func create_map(map_positions: Array[Vector3]):
	clear()
	var library = get_mesh_library()
	var orientation = 16
	var item
	var grid_pos : Vector3i
	#goes throug all map points
	for pos in map_positions.size():
		grid_pos.x = int(map_positions[pos].x * 1000)
		grid_pos.z = int(map_positions[pos].z * 1000)
		item = library.find_item_by_name("hex_grass")

		#item = library.find_item_by_name("hex_water")
		set_cell_item(grid_pos, item, orientation)
		print("set_cell_item for map_postiion ", map_positions[pos]," on grid_pos ", grid_pos)

#
## Mark tiles for modification
#func modify_terrain():
	#var edge_tiles : Array[Tile] = []
	#var ocean_tiles : Array[Tile] = []
	#var hills : Array[Tile] = []
	#
	### Find all edges and ocean tiles respectively
	#for t in WorldMap.map:
		#var neighbors = WorldMap.get_tile_neighbors(t)
		#invalidate_ocean_hill_neighbors(t, neighbors)
		#if neighbors.size() < 6: #Find edges
			#edge_tiles.append(t)
			#t.pos_data.hill = false #edges cannot be hills
		#if t.mesh_data.type == Tile.biome_type.Ocean:
			#ocean_tiles.append(t) #Find ocean
		#if t.pos_data.hill == true:
			#hills.append(t) #Find raised tiles
	#
	#create_edges(edge_tiles)
	#create_hills(hills)
	#create_ocean_transitions(ocean_tiles)
	#print("Terrain height and edges have been adjusted")
	#
## Hills and ocean should not spawn next to one another, water takes precedence
#func invalidate_ocean_hill_neighbors(tile: Tile, neighbors: Array[Tile]):
	#for n in neighbors:
		#tile.neighbors.append(n)
		#if tile.pos_data.hill and n.pos_data.water:
			#tile.pos_data.hill = false
#
#
#func create_hills(hills : Array[Tile]):
	#for hill : Tile in hills:
		#hill.position.y = settings.hill_height ## Raise hill
		#
		### Fill gaps
		#for neighbor in hill.neighbors:
			#if not neighbor.pos_data.hill:
				#var filler = OCEAN_GAPFILL.instantiate()
				#var neutral = neighbor.position
				#neutral.y = hill.position.y
				#tile_parent.add_child(filler)
				#filler.position = hill.position
				#filler.look_at(neutral)
#
#
#func create_ocean_transitions(ocean_tiles : Array[Tile]):
	### Fill ocean gaps
	#for water_tile in ocean_tiles:
		#water_tile.placeable = false
		#for neighbor in water_tile.neighbors:
			#if neighbor.mesh_data.type != Tile.biome_type.Ocean:
				#var filler = OCEAN_GAPFILL.instantiate()
				#tile_parent.add_child(filler)
				#filler.position = neighbor.position
				#filler.look_at(water_tile.position)
		#water_tile.position.y = settings.ocean_height
		#
		#
### Function to select a biome based on weighted probabilities
#func select_biome(local_noise: float, weights: Array[float], total: float, noisedata: Vector2) -> int:
	## Normalize the noise value to the total weight range
	#var normalized_noise = ((local_noise - noisedata.x) / (noisedata.y - noisedata.x)) * total
	## Determine the selected biome
	#var selected_biome = 0
	#for i in range(weights.size()):
		#if normalized_noise < weights[i]:
			#selected_biome = i
			#break
	#return selected_biome
#
#
### Function to instantiate a tile based on the selected biome
#func instantiate_tile(selected_biome: int) -> Tile:
	## Get the biome data from settings
	#var data = settings.tiles[selected_biome]
	#
	## Instantiate the biome mesh
	#var biome = data.mesh
	#var t = biome.instantiate()
	#
	## Set up the tile
	#t.set_script(TILE_SCRIPT)
	#t.mesh_data = data
	#t.mesh_data.index = selected_biome
	#return t as Tile
#
#
#func instantiate_ocean_tile():
	#var tile = settings.ocean_tile.mesh.instantiate()
	#
	## Set up the tile
	#tile.set_script(TILE_SCRIPT)
	#tile.mesh_data = settings.ocean_tile
	#tile.mesh_data.index = 99
	#var mesh_instance: MeshInstance3D = tile.get_child(0) as MeshInstance3D
	#if mesh_instance:
		#mesh_instance.material_override = settings.ocean_tile.shader_override
	#
	#return tile as Tile
#
#
	### Add tile script, add to group, position and parent
#func init_tile(tile : Tile, position : PositionData):
	#if not tile.is_in_group("tiles"):
		#tile.add_to_group("tiles")
#
	##Add collider
	#var col = HEX_TILE_COLLIDER.instantiate()
	#tile.add_child(col)
	#col.position = tile.position
	#
	## Set up material override
	#var mesh_instance: MeshInstance3D = tile.get_child(0) as MeshInstance3D
	#if mesh_instance and tile.mesh_data.index != 99: #99 signifies ocean
		#mesh_instance.material_override = tile_materials[tile.mesh_data.index]
#
	#tile.position = position.world_position
	#tile_parent.add_child(tile)
	#tile.pos_data = position
	#tile.biome = Tile.biome_type.find_key(tile.mesh_data.type)
#
#
#func calculate_biome_weights() -> Array[float]:
	#var sum = 0.0
	#var cumulative_weights : Array[float]
	#for weight in settings.biome_weights:
		#sum += weight
		#cumulative_weights.append(sum)
	#return cumulative_weights
#
#
	###Debug and test stuff. Add Labels to show coordinates
#func debug_tile(tile : Tile, grid_position : Vector2):
	#if not settings.debug:
		#return
	##Add a label
	#var label = Label3D.new()
	#tile.add_child(label)
	#label.text = str(grid_position.x) + ", " + str(grid_position.y)
	#label.text += "\n" + str(-grid_position.x - grid_position.y)
	#label.text += "\n" + str(tile.pos_data.world_position) 
	#label.position.y += 0.4
	#tile.debug_label = label
