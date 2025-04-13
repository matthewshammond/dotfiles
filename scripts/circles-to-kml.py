# pip install simplekml geopy

import simplekml
from geopy.distance import distance
import re


def dms_to_decimal(degrees, minutes, seconds, direction):
    """Convert degrees, minutes, seconds to decimal degrees."""
    decimal = degrees + minutes / 60 + seconds / 3600
    if direction in ["S", "W"]:
        decimal *= -1
    return decimal


def ddm_to_decimal(degrees, decimal_minutes, direction):
    """Convert degrees and decimal minutes to decimal degrees."""
    decimal = degrees + decimal_minutes / 60
    if direction in ["S", "W"]:
        decimal *= -1
    return decimal


def parse_coordinate(coord_str):
    """
    Parse a coordinate string and return decimal degrees.
    Supports:
      - Decimal Degrees (e.g., "34.0522N, 118.2437W")
      - Degrees Decimal Minutes (e.g., "34 3.132N, 118 14.622W")
      - Degrees Minutes Seconds (e.g., "34 3 7.92N, 118 14 37.32W")
    """
    coord_str = coord_str.strip()

    # Decimal Degrees (DD)
    match = re.match(r"(-?\d+\.\d+)([NS]),\s*(-?\d+\.\d+)([EW])", coord_str)
    if match:
        lat = float(match.group(1)) * (-1 if match.group(2) == "S" else 1)
        lon = float(match.group(3)) * (-1 if match.group(4) == "W" else 1)
        return lat, lon

    # Degrees Decimal Minutes (DDM)
    match = re.match(r"(\d+)\s+(\d+\.\d+)([NS]),\s*(\d+)\s+(\d+\.\d+)([EW])", coord_str)
    if match:
        lat = ddm_to_decimal(int(match.group(1)), float(match.group(2)), match.group(3))
        lon = ddm_to_decimal(int(match.group(4)), float(match.group(5)), match.group(6))
        return lat, lon

    # Degrees Minutes Seconds (DMS)
    match = re.match(
        r"(\d+)\s+(\d+)\s+(\d+\.\d+)([NS]),\s*(\d+)\s+(\d+)\s+(\d+\.\d+)([EW])",
        coord_str,
    )
    if match:
        lat = dms_to_decimal(
            int(match.group(1)),
            int(match.group(2)),
            float(match.group(3)),
            match.group(4),
        )
        lon = dms_to_decimal(
            int(match.group(5)),
            int(match.group(6)),
            float(match.group(7)),
            match.group(8),
        )
        return lat, lon

    raise ValueError("Invalid coordinate format")


def generate_circle_kml(center_lat, center_lon, radius_nm, filename="circle.kml"):
    """
    Generate a KML file with a circle of the given radius (in nautical miles)
    centered at (center_lat, center_lon).
    """
    kml = simplekml.Kml()
    pol = kml.newpolygon(name="Circle")

    # Generate circle points
    num_points = 100  # Increase for a smoother circle
    circle_coords = []

    for i in range(num_points + 1):
        angle = i * (360 / num_points)
        point = distance(nautical=radius_nm).destination(
            (center_lat, center_lon), angle
        )
        circle_coords.append((point.longitude, point.latitude))

    # Assign the list of coordinates to the polygon
    pol.outerboundaryis = circle_coords

    # Set styling using the extracted colors from the provided KML
    pol.style.polystyle.color = "4000ff00"  # 25% opacity fill (Green)
    pol.style.linestyle.color = "ff00ff00"  # 100% opacity border (Green)
    pol.style.linestyle.width = 1  # Set border width

    # Save the KML file
    kml.save(filename)
    print(f"KML file saved as {filename}")


if __name__ == "__main__":
    prompt = """
Enter coordinate in one of the following formats:

  • Decimal Degrees (DD): 34.0522N, 118.2437W
  • Degrees Decimal Minutes (DDM): 34 3.132N, 118 14.622W
  • Degrees Minutes Seconds (DMS): 34 3 7.92N, 118 14 37.32W

Coordinate: """

    input_coord = input(prompt)
    radius_nm = float(input("Enter radius in nautical miles: "))

    try:
        lat, lon = parse_coordinate(input_coord)
        generate_circle_kml(lat, lon, radius_nm)
    except ValueError as e:
        print(f"Error: {e}")
