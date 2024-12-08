from PIL import Image
import os

# Directories
input_dir = './'  # Current directory
output_dir = './cropped_frames/'

# Create the output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Crop dimensions
crop_top = 9
crop_bottom = 9
crop_left = 1
crop_right = 5

# Process each PNG file in the directory
for file_name in os.listdir(input_dir):
    if file_name.endswith('.png'):
        file_path = os.path.join(input_dir, file_name)

        # Open the image
        with Image.open(file_path) as img:
            # Calculate new bounding box
            width, height = img.size
            left = crop_left
            top = crop_top
            right = width - crop_right
            bottom = height - crop_bottom

            # Crop the image
            cropped_img = img.crop((left, top, right, bottom))

            # Save the cropped image
            output_path = os.path.join(output_dir, file_name)
            cropped_img.save(output_path)

print(f"Cropping complete. Cropped frames are saved in '{output_dir}'")

