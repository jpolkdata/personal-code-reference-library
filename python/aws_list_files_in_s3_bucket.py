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
   
   # Iterate through the keys (files) in the data bucket and retrieve file metadata
    bucket = s3.Bucket('jpolkdata-spotify-data')
    for obj in list(bucket.objects.all()): 
        
        file_details={}

        # The 'obj' is an ObjectSummary, it only has a few datapoints
        file_details['key']=obj.key
        file_details['storage_class']=obj.storage_class
        file_details['last_modified']=obj.last_modified.strftime('%Y%m%d_%H%M%S')

        # Get additional details by accessing the Object() sub-resource
        # available options - https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#object
        file_details['content_length']=obj.Object().content_length
        file_details['e_tag']=obj.Object().e_tag

        print(file_details)
