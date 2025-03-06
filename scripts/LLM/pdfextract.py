import camelot
import os

os.environ["PATH"] += os.pathsep + ""
PDF_PATH = ""
OUTPUT_CSV_PATH = "/"

tables = camelot.read_pdf(PDF_PATH, pages="all")

if tables.n > 0:

    for i, table in enumerate(tables):
        table_path = f""
        table.to_csv(table_path)

    combined_csv_path = ""
    with open(combined_csv_path, "w", encoding="utf-8") as f:
        for i, table in enumerate(tables):
            f.write(f"Table {i+1}\n")
            f.write(table.df.to_csv(index=False))  
            f.write("\n\n") 
