import os
import csv
from xml.etree import ElementTree as ET


def parse_kml_to_csv(input_directory):
    """
    Parses all KML files in the input directory and converts each to a CSV with the same name.

    Args:
        input_directory (str): Path to the directory containing KML files.
    """
    # Iterate through all KML files in the input directory
    for filename in os.listdir(input_directory):
        if filename.endswith(".kml"):
            file_path = os.path.join(input_directory, filename)
            output_csv_path = os.path.splitext(file_path)[0] + ".csv"

            extracted_data = []

            try:
                # Parse the KML file
                tree = ET.parse(file_path)
                root = tree.getroot()

                # Define the namespace for KML files
                ns = {"kml": "http://www.opengis.net/kml/2.2"}

                # Extract relevant data from Placemark elements
                for placemark in root.findall(".//kml:Placemark", ns):
                    county_name = None
                    coordinates = None

                    # Extract the County Name from SimpleData
                    for simple_data in placemark.findall(".//kml:SimpleData", ns):
                        if simple_data.get("name") == "County":
                            county_name = simple_data.text

                    # Extract the coordinates (longitude, latitude)
                    coord_elem = placemark.find(".//kml:coordinates", ns)
                    if coord_elem is not None:
                        coordinates = coord_elem.text.strip()

                    # Process and store the data
                    if county_name and coordinates:
                        lon, lat, *_ = coordinates.split(",")
                        extracted_data.append([county_name, lat.strip(), lon.strip()])

                # Write the extracted data to a CSV file
                with open(
                    output_csv_path, "w", newline="", encoding="utf-8"
                ) as csv_file:
                    writer = csv.writer(csv_file)
                    writer.writerow(["County Name", "Latitude", "Longitude"])  # Header
                    writer.writerows(extracted_data)

                print(f"Converted {filename} to {output_csv_path}")

            except Exception as e:
                print(f"Error processing file {filename}: {e}")


if __name__ == "__main__":
    import argparse

    # Set up argument parsing
    parser = argparse.ArgumentParser(
        description="Convert KML files in a directory to CSV files."
    )
    parser.add_argument(
        "input_directory", help="Path to the directory containing KML files."
    )

    args = parser.parse_args()

    # Run the conversion
    parse_kml_to_csv(args.input_directory)
    print("Conversion complete.")
