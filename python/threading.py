from concurrent.futures import ThreadPoolExecutor
import logging

def split_into_batches(data, batch_size):
    for i in range(0, len(data), batch_size):
        yield data[i:i + batch_size]

def run_batches_in_parallel(data, batch_size):
    batches = list(split_into_batches(data, batch_size))
    with ThreadPoolExecutor(max_workers=4) as executor:
        for i, batch in enumerate(batches):
            executor.submit(process_batch, batch, i)

def process_batch(batch, batch_id):
    logging.info(f"== Processing batch {batch_id} with {len(batch)} records ==")
    # PROCESSING LOGIC HERE
    for item in batch:
        logging.info(f"Processing item {item} in batch {batch_id}")

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(message)s"
    )
    data = list(range(100))  # Example data
    batch_size = 10
    run_batches_in_parallel(data, batch_size)
