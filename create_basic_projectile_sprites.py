import pyvips 

colors = [[217, 87, 99, 255], [129, 193, 207, 255], [92, 140, 77, 255], [251, 242, 54, 255]]
fill_points = [[30, 30], [34, 30], [34, 34], [30, 34]]
input_image_path = "basic_projectile.png"
output_image_prefix = "basic_projectile"

in_image = pyvips.Image.new_from_file(input_image_path)

# Create a list of every permutation of four elements of the set {0, 1, 3, 4}
permutations = []
for a in range(4):
	for b in range(4):
		for c in range(4):
			for d in range(4):
				permutations.append([a, b, c, d])

# @found is a 5-dimensional mapping from {0,1,2,3,4}^4 to {True,False}
# that will keep track of combinations we have found. The inputs
# to @found are lists that are histograms of permutations.
found = [0] * 5
for a in range(5):
	found[a] = [0] * 5
	for b in range(5):
		found[a][b] = [0] * 5
		for c in range(5):
			found[a][b][c] = [0] * 5
			for d in range(5):
				found[a][b][c][d] = False

# @keep will contain combinations without repeats. We filter out the repeats by
# using the histogram to keep track of what we've found.
keep = []
for p in permutations:
	count = [0] * 4

	for i in range(4):
		count[p[i]] += 1

	if not found[count[0]][count[1]][count[2]][count[3]]:
		keep.append(p)
		found[count[0]][count[1]][count[2]][count[3]] = True

# The length should be 35
#print(len(keep))

for x in keep:
	print("\"{}_{}_{}_{}\": preload(\"res://{}_{}_{}_{}_{}.png\"), ".format(x[0], x[1], x[2], x[3], output_image_prefix, x[0], x[1], x[2], x[3]), end = "")

# Use the permutations to pick colors and path names for sprites
for p in keep:
	out_path = "{}_{}_{}_{}_{}.png".format(output_image_prefix, p[0], p[1], p[2], p[3]) 
	out_image = in_image
	for i in range(4):
		out_image = out_image.draw_flood(colors[p[i]], fill_points[i][0], fill_points[i][1], equal=True)
	out_image.write_to_file(out_path)
