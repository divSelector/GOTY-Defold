from PIL import Image
import os

# Define the directory containing the frames and the output directory
input_directory = "./original"
output_directory = "."

# Ensure the output directory exists
os.makedirs(output_directory, exist_ok=True)

# Number of pixels to move the content up
pixels_to_move_up = 9

# Iterate over all PNG files in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(".png"):
        file_path = os.path.join(input_directory, filename)
        
        # Open the image
        img = Image.open(file_path)
        
        # Get image dimensions
        width, height = img.size
        
        # Ensure we won't crop into content
        # Create a new image with the same dimensions, initially transparent
        new_img = Image.new("RGBA", (width, height))
        
        # Paste the content from the old image into the new position
        new_img.paste(img, (0, -pixels_to_move_up))
        
        # Save the modified image to the output directory
        output_path = os.path.join(output_directory, filename)
        new_img.save(output_path)

print("Frames have been adjusted and saved to the output directory.")

