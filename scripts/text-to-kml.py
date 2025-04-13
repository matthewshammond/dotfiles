import simplekml
# pip install simplekml


def text_to_multigeometry_kml(text, lat, lon, height_nm, line_spacing=1.5):
    # Convert nautical miles to kilometers for scaling
    height_km = height_nm * 1.852
    width_km = height_km / 2

    # Split text into lines
    lines = text.split("\\n")

    # Calculate total height of the text block
    total_height_km = (len(lines) - 1) * height_km * line_spacing + height_km

    # Calculate the width of the longest line
    max_line_width_km = max(
        len(line.replace(" ", "")) * width_km * 1.5 + line.count(" ") * width_km
        for line in lines
    )

    # Adjust starting positions so the center of the block aligns with (lat, lon)
    y_start = total_height_km / 2  # Vertical center offset

    # KML generation
    kml = simplekml.Kml()

    for line_index, line in enumerate(lines):
        # Calculate the horizontal offset for centering each line
        line_width_km = (
            len(line.replace(" ", "")) * width_km * 1.5 + line.count(" ") * width_km
        )
        x_offset = -line_width_km / 2

        # Calculate the vertical position for the line relative to the center
        y_offset = y_start - line_index * height_km * line_spacing - height_km / 2

        for char in line:
            if char == " ":
                x_offset += width_km
                continue

            # Get the lines that form the character
            letter_lines = letter_to_lines(char, width_km, height_km)

            if not letter_lines:
                x_offset += width_km
                continue

            # Add lines as MultiGeometry
            multigeometry = kml.newmultigeometry(name=f"Letter {char}")
            for line_segment in letter_lines:
                # Offset each line for the character's position and adjust to lat/lon
                adjusted_line = [
                    (lon + (x + x_offset) / 111, lat + (y + y_offset) / 111)
                    for x, y in line_segment
                ]
                multigeometry.newlinestring(coords=adjusted_line)

            x_offset += width_km * 1.5

    return kml


def letter_to_lines(char, width, height):
    # Define line segments for all characters (relative coordinates)
    characters = {
        ":": [
            [
                (width / 2, height * 3 / 4 - height / 10),
                (width / 2, height * 3 / 4 + height / 10),
            ],  # Top dot (bigger size)
            [
                (width / 2, height / 4 - height / 10),
                (width / 2, height / 4 + height / 10),
            ],  # Bottom dot (bigger size)
        ],
        ".": [
            [
                (width / 2 - width / 10, 0),
                (width / 2 + width / 10, 0),
            ],  # Centered dot with larger size
        ],
        "0": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
        ],
        "1": [
            [(width / 2, 0), (width / 2, height)],  # Vertical line
        ],
        "2": [
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, height / 2)],  # Right vertical
            [(width, height / 2), (0, 0)],  # Diagonal
            [(0, 0), (width, 0)],  # Bottom horizontal
        ],
        "3": [
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, 0)],  # Right vertical
            [(width, height / 2), (0, height / 2)],  # Middle horizontal
            [(width, 0), (0, 0)],  # Bottom horizontal
        ],
        "4": [
            [(0, height), (0, height / 2)],  # Left vertical
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
            [(width, 0), (width, height)],  # Right vertical
        ],
        "5": [
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, height / 2)],  # Left vertical
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
            [(width, height / 2), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
        ],
        "6": [
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, 0)],  # Left vertical
            [(0, 0), (width, 0)],  # Bottom horizontal
            [(width, 0), (width, height / 2)],  # Right vertical
            [(width, height / 2), (0, height / 2)],  # Middle horizontal
        ],
        "7": [
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (0, 0)],  # Diagonal
        ],
        "8": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
        ],
        "9": [
            [(0, 0), (width, 0)],  # Bottom horizontal
            [(width, 0), (width, height)],  # Right vertical
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, height / 2)],  # Left vertical
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
        ],
        "A": [
            [(0, 0), (width / 2, height)],  # Left diagonal
            [(width / 2, height), (width, 0)],  # Right diagonal
            [(width / 4, height / 2), (3 * width / 4, height / 2)],  # Middle bar
        ],
        "B": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width / 2, height)],  # Top horizontal
            [(width / 2, height), (width, 3 * height / 4)],  # Top curve
            [(width, 3 * height / 4), (width / 2, height / 2)],  # Middle curve
            [(width / 2, height / 2), (width, height / 4)],  # Bottom curve
            [(width, height / 4), (width / 2, 0)],  # Bottom curve to bottom
            [(width / 2, 0), (0, 0)],  # Bottom horizontal
        ],
        "C": [
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, 0)],  # Left vertical
            [(0, 0), (width, 0)],  # Bottom horizontal
        ],
        "D": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width / 2, height)],  # Top curve
            [(width / 2, height), (width, height / 2)],  # Right curve
            [(width, height / 2), (width / 2, 0)],  # Bottom curve
            [(width / 2, 0), (0, 0)],  # Bottom horizontal
        ],
        "E": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(0, height / 2), (width / 2, height / 2)],  # Middle horizontal
            [(0, 0), (width, 0)],  # Bottom horizontal
        ],
        "F": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(0, height / 2), (width / 2, height / 2)],  # Middle horizontal
        ],
        "G": [
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, 0)],  # Left vertical
            [(0, 0), (width, 0)],  # Bottom horizontal
            [(width, 0), (width, height / 2)],  # Right vertical
            [(width, height / 2), (width / 2, height / 2)],  # Inside horizontal
        ],
        "H": [
            [(0, 0), (0, height)],  # Left vertical
            [(width, 0), (width, height)],  # Right vertical
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
        ],
        "I": [
            [(width / 2, 0), (width / 2, height)],  # Vertical line
        ],
        "J": [
            [(width, height), (width, 0)],  # Right vertical
            [(width, 0), (width / 2, 0)],  # Bottom curve
            [(width / 2, 0), (0, height / 4)],  # Bottom-left curve
        ],
        "K": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height / 2), (width, height)],  # Diagonal up
            [(0, height / 2), (width, 0)],  # Diagonal down
        ],
        "L": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, 0), (width, 0)],  # Bottom horizontal
        ],
        "M": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width / 2, 0)],  # Middle peak
            [(width / 2, 0), (width, height)],  # Right peak
            [(width, height), (width, 0)],  # Right vertical
        ],
        "N": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, 0)],  # Diagonal
            [(width, 0), (width, height)],  # Right vertical
        ],
        "O": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
        ],
        "P": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, height / 2)],  # Right vertical
            [(width, height / 2), (0, height / 2)],  # Middle horizontal
        ],
        "Q": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
            [(width / 2, 0), (width, -height / 4)],  # Tail
        ],
        "R": [
            [(0, 0), (0, height)],  # Left vertical
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (width, height / 2)],  # Right vertical
            [(width, height / 2), (0, height / 2)],  # Middle horizontal
            [(0, height / 2), (width, 0)],  # Diagonal
        ],
        "S": [
            [(width, height), (0, height)],  # Top horizontal
            [(0, height), (0, height / 2)],  # Left vertical
            [(0, height / 2), (width, height / 2)],  # Middle horizontal
            [(width, height / 2), (width, 0)],  # Right vertical
            [(width, 0), (0, 0)],  # Bottom horizontal
        ],
        "T": [
            [(width / 2, 0), (width / 2, height)],  # Vertical line
            [(0, height), (width, height)],  # Top horizontal
        ],
        "U": [
            [(0, height), (0, 0)],  # Left vertical
            [(0, 0), (width, 0)],  # Bottom horizontal
            [(width, 0), (width, height)],  # Right vertical
        ],
        "V": [
            [(0, height), (width / 2, 0)],  # Left diagonal
            [(width / 2, 0), (width, height)],  # Right diagonal
        ],
        "W": [
            [(0, height), (width / 4, 0)],  # Left peak
            [(width / 4, 0), (width / 2, height / 2)],  # Middle peak
            [(width / 2, height / 2), (3 * width / 4, 0)],  # Right peak
            [(3 * width / 4, 0), (width, height)],  # Right vertical
        ],
        "X": [
            [(0, height), (width, 0)],  # Diagonal
            [(0, 0), (width, height)],  # Opposite diagonal
        ],
        "Y": [
            [(0, height), (width / 2, height / 2)],  # Left diagonal
            [(width / 2, height / 2), (width, height)],  # Right diagonal
            [(width / 2, height / 2), (width / 2, 0)],  # Bottom vertical
        ],
        "Z": [
            [(0, height), (width, height)],  # Top horizontal
            [(width, height), (0, 0)],  # Diagonal
            [(0, 0), (width, 0)],  # Bottom horizontal
        ],
    }

    return characters.get(char.upper())


def export_kml(kml, output_file):
    kml.save(output_file)


if __name__ == "__main__":
    # Input from the user
    text = (
        input(
            "Enter the word/phrase (use \n for multiple lines, default is 'NO FLY ZONE'):\n"
        ).strip()
        or "NO FLY ZONE"
    )
    lat = float(input("Enter the latitude (decimal degrees) of the center point: "))
    lon = float(input("Enter the longitude (decimal degrees) of the center point: "))
    height_nm = float(input("Enter the height of the word/phrase in nautical miles: "))

    # Generate KML with MultiGeometry
    kml = text_to_multigeometry_kml(text, lat, lon, height_nm)

    # Save the KML
    output_file = "output.kml"
    export_kml(kml, output_file)
    print(f"KML file saved as {output_file}")
