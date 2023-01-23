import os, boto3
from dotenv import load_dotenv
load_dotenv() #load environment variables (AWS access key and secret) from local .env file

def get_s3():
    """Establish an S3 object using AWS credentials that have been specified as 
    environment variables in a local .env file at the root of the project"""
    s3 = boto3.resource(
        service_name='s3',
        region_name='us-east-1',
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), #specified in .env file
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY") #specified in .env file
    )
    return s3

def get_s3_files(bucket_name):
    """Return a list of all files inside the specified S3 bucket"""
    bucket_obj = s3.Bucket(bucket_name)
    file_list = list(bucket_obj.objects.all())
    return file_list

if __name__ == '__main__':
    bucket_name='BUCKET_NAME'

    s3 = get_s3()

    files = get_s3_files(bucket_name)
    for file in files: 
        print(file.key)