# Wine Wuality Prediction

### Phase 1: Pre-requisites
get the AWS account, credentials and pem file ready (same as last assignment)
Install Apache Maven and Docker Desktop on your PC.

Create a java project with a Jave code file each for training and testing ML models.
Add a pom.xml Maven file that highlights the dependencies required for the project and their sources.
Use `mvn package` command to compile the project into a JAR file containing the code as well as all the required dependencies.
### Phase 2: Copy data to S3
We will copy all the datasets given along with the compiled JAR file of our ML project to sour bucket on S3.

### Phase 3: Establish an EMR Cluster
we will create the EMR cluster and give sufficient permissions to ssh into master node
This includes creating a security key for SSH access as well as adding an inbound rule in our EMR cluster's security group to allow SSH for our local system's IP address.

### Phase 5: Execute Training Code via Spark-submit
Perform a SSH access into the EMR cluster from our local terminal using the command provided by EMR cluster and the SSH key we generated during cluster creation.

We will get all the files from s3
``` 
aws s3 sync s3://myprobucket001/ /path/to/files
```
We will run the training code using spark-submit
```
spark-submit --class com.example.SparkMLTraining --master yarn /path/to/the/jar
```
- Spark will begin, perform model training in parallel using the core nodes and store the optimally trained model in the S3 bucket - Logistic Regression model: s3://prabhath-wine/saved_lr_model
Decision Tree model: s3://prabhath-wine/saved_dt_model
### Phase 6: Docker Image creation
1. we will login to docker from terminal
```
docker login
```
we will build the docker image with the tag in the format of dockerhub image
```
docker build -t <username>/wine-pred .
```
here <username> is the docker hub user name.

we will Upload the image to Docker Hub
```
docker push  <username>/wine-pred
```

### Phase 7: Perform Prediction using docker
we will launch a EC2 machine, ssh into it and configure the aws credentials.

We will ssh into the machine, install ans start docker
```
sudo yum install docker
sudo service docker start
```
we will pull the docker image 
```
docker pull  <username>/wine-pred
```
we will run the docker image for prediction on the ValidationDataset.csv
```
docker run <username>/wine-pred
```
If we have another test file for testing (Testdataset.csv), we will mount the directory having the file to docker image and run it with this file as argument
```
sudo docker run -v $(pwd):/files <username>/wine-pred spark-submit --class com.example.SparkMLInference --master yarn /files/spark-ml-1.0-SNAPSHOT.jar /files/TrainingDataset.csv
```

### Phase 8: Perform Prediction without docker
we will launch a EC2 machine, ssh into it and configure the aws credentials and install spark and pyspark into that machine.

We will copy all the required files and the saved model using ```aws s3 sync``` ( similar to above).
nowm, we will run the spark submit command to run the inference script for prediction
```
spark-submit --class com.example.SparkMLInference --master yarn spark-ml-1.0-SNAPSHOT.jar testDataset.csv
```

