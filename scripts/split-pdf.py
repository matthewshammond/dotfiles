# pip install PyPDF2
from PyPDF2 import PdfReader, PdfWriter
import os


def split_pdf(input_pdf_path, output_dir):
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Read the input PDF file
    reader = PdfReader(input_pdf_path)
    total_pages = len(reader.pages)

    # Split each page into a new PDF
    for page_num in range(total_pages):
        writer = PdfWriter()
        writer.add_page(reader.pages[page_num])

        output_filename = os.path.join(output_dir, f"page_{page_num + 1}.pdf")
        with open(output_filename, "wb") as output_pdf:
            writer.write(output_pdf)

        print(f"Created {output_filename}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Split a PDF into individual pages.")
    parser.add_argument("input_pdf", help="Path to the input PDF file")
    parser.add_argument("output_dir", help="Directory to save the split PDF pages")

    args = parser.parse_args()

    split_pdf(args.input_pdf, args.output_dir)
