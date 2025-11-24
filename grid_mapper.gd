extends Object
class_name GridMapper

var world_position : Vector3 #point in a 3-axis grid for hexagonal tiles

#shows the coordinates for all neighbor hex-tiles. Note: the movement allways adds to zero and the are in the first outer layer
#coordinates x(r), y(r), z(s) 
#0=down right, 1=up right, 2=up
#3=up left, 4=down left, 5=down
var hex_direction_vectors = [
	Vector3i(+1, 0, -1), Vector3i(+1, -1, 0), Vector3i(0, -1, +1), 
	Vector3i(-1, 0, +1), Vector3i(-1, +1, 0), Vector3i(0, +1, -1), 
]

#shows the coordinates for all diagnonal neighbor hex-tiles. Note: the movement allways adds to zero and they are in the second outer layer on the points of the hex tile
#coordinates x(r), y(r), z(s) 
#0=right, 1=up right, 2=up left
#3=left, 4=down left, 5=down right
var hex_diagonal_vectors = [
	Vector3i(+2, -1, -1), Vector3i(+1, -2, +1), Vector3i(-1, -1, +2), 
	Vector3i(-2, +1, +1), Vector3i(-1, +2, -1), Vector3i(+1, +1, -2), 
] 




#gives the direction vector to an int
func hex_direction(direction: int): 
	return hex_direction_vectors[direction]
	
#goes from the hex starting coordinates and adds the vector to it
func hex_add(hex: Vector3i, vec: Vector3i): 
	return Vector3i(hex.x + vec.x, hex.y + vec.y, hex.z + vec.z)
	
#returns the coordinates of the neighbor of hex in a specific direcion
func hex_neighbor(hex: Vector3i, direction: int): 
	return hex_add(hex, hex_direction(direction))
	
#gives the product of one vector. For faster movements
func hex_scale(hex: Vector3i, factor: int):
	return Vector3i(hex.x * factor, hex.y * factor, hex.z * factor)

#gives a ring of hex tiles for a center tile and a given radius (not 0)
func hex_ring(center: Vector3i, radius: int):
	var results: Array[Vector3i] = []
	# sets the startpoint for the loops at the down left corner
	var hex = hex_add(center, hex_scale(hex_direction(4), radius))
	#the direction start by down right and go counter clockwise to down left
	for i in 6:
		for j in radius:
			results.append(hex)
			hex = hex_neighbor(hex, i)
	return results

func hex_spiral(center: Vector3i, radius: int):
	var results: Array[Vector3i] = [center]
	for k in range(1,radius):
		results.append_array(hex_ring(center, k))
	return results

#gives the start index for euch ring gives is radius except 0
func spiralindex_start_of_ring(radius: int):
	return 1 + 3 * radius * (radius - 1)

#gives the radius of the ring for the index for a tile in the ring
func spiralindex_to_radius(index: int):
	#solved for 'radius' in equation: index = 1 + 3 * radius * (radius-1)
	return floor((sqrt(12 * index - 3) + 3) / 6)

func hex_to_2d_map(size: int, hex_list: Array[Vector3i]):
	var results: Array[Vector3] = []

	for i in hex_list.size():
		#hex to cartesian
		var x = (     3./2 * hex_list[i].x                    )
		var z = (sqrt(3)/2 * hex_list[i].x  +  sqrt(3) * hex_list[i].y)
		#scale cartesian coordinates
		x = x * size
		z = z * size
		world_position = Vector3(x , 0, z)
		results.append(world_position)
	return results

### Apply ocean noise, hills noise and find buffer tiles
#func modify_position(pos : PositionData, buffer_filter):
	#var c = pos.grid_position.x
	#var r = pos.grid_position.y
	#pos.noise = noise_at_tile(c, r, settings.biome_noise)
	#
	###We prioritize water since hills cannot be created with surrounding ocean anyway
	#if settings.create_water and noise_at_tile(c, r, settings.ocean_noise) > settings.ocean_treshold:
		#pos.water = true
	#elif noise_at_tile(c, r, settings.heightmap_noise) > settings.heightmap_treshold:
		#pos.hill = true
