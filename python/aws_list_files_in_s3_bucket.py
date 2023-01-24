"""
    Given an S3 bucket name, return a list of all file names within that bucket
"""
import os, boto3
from dotenv import load_dotenv

if __name__ == '__main__':

    # Loads environment variables (AWS access key and secret) from the local .env file
    load_dotenv() 

    # Create an S3 resource    
    s3 = boto3.resource(
        service_name='s3',
        region_name='us-east-1',
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),           #specified in .env file
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")    #specified in .env file
    )
   
   # List out the keys (file names) in the data bucket
    bucket_obj = s3.Bucket('jpolkdata-spotify-data')
    for file in list(bucket_obj.objects.all()): 
        print(file.key)