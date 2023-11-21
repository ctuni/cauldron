import argparse
from Bio import Entrez
import time

def fetch_linked_ids(db_from, db_to, accession_id):
    try:
        handle = Entrez.elink(dbfrom=db_from, db=db_to, id=accession_id)
        record = Entrez.read(handle)
        handle.close()

        # Debugging: print the fetched record
        print(f"Fetched record for {accession_id}: {record}")

        if record and record[0]["LinkSetDb"]:
            linked_ids = [link["Id"] for link in record[0]["LinkSetDb"][0]["Link"]]
            return linked_ids
        else:
            print(f"No linked IDs found for {accession_id} from {db_from} to {db_to}")
            return []
    except Exception as e:
        print(f"Error fetching linked IDs for {accession_id}: {e}")
        return []


def main(input_file, output_file):
    Entrez.email = "cristina.tuni@flomics.com"  # Always provide your email
    gse_accessions = read_gse_accessions(input_file)
    srr_accessions = []

    for gse in gse_accessions:
        print(f"Processing {gse}...")
        gsm_ids = fetch_linked_ids("gds", "gds", gse)
        for gsm_id in gsm_ids:
            srx_ids = fetch_linked_ids("gds", "sra", gsm_id)
            for srx_id in srx_ids:
                srr_ids = fetch_linked_ids("sra", "sra", srx_id)
                srr_accessions.extend(srr_ids)

        time.sleep(1)  # to avoid overloading the server

    with open(output_file, 'w') as file:
        for srr in srr_accessions:
            file.write(f"{srr}\n")

    print(f"Results written to {output_file}")

def read_gse_accessions(file_path):
    with open(file_path, 'r') as file:
        return [line.strip() for line in file]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Retrieve SRR accession numbers for GSE accessions.')
    parser.add_argument('input_file', type=str, help='Path to the file containing GSE accession numbers')
    parser.add_argument('output_file', type=str, help='Path to the output file for SRR accession numbers')
    args = parser.parse_args()

    main(args.input_file, args.output_file)
