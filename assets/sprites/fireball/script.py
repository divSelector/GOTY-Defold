from PIL import Image

def split_spritesheet(file_path, output_prefix, frame_width, frame_height, rows, cols):
    """
    Splits a sprite sheet into individual frames.

    Args:
        file_path (str): Path to the sprite sheet.
        output_prefix (str): Prefix for the output images.
        frame_width (int): Width of each frame.
        frame_height (int): Height of each frame.
        rows (int): Number of rows in the sprite sheet.
        cols (int): Number of columns in the sprite sheet.
    """
    try:
        sheet = Image.open(file_path)
        frame_count = 0

        for row in range(rows):
            for col in range(cols):
                # Calculate frame box (left, upper, right, lower)
                left = col * frame_width
                upper = row * frame_height
                right = left + frame_width
                lower = upper + frame_height

                frame = sheet.crop((left, upper, right, lower))
                output_file = f"{output_prefix}_{frame_count + 1}.png"
                frame.save(output_file)
                print(f"Saved frame {frame_count + 1}: {output_file}")
                frame_count += 1

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Configuration
    sprite_sheet_path = "./fireball.png"  # Path to your sprite sheet
    output_prefix = "fireball"           # Output file prefix
    frame_width = 128                    # Width of each frame
    frame_height = 128                   # Height of each frame
    rows = 2                             # Number of rows
    cols = 2                             # Number of columns

    # Run the splitter
    split_spritesheet(sprite_sheet_path, output_prefix, frame_width, frame_height, rows, cols)

