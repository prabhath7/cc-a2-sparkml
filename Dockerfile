# Use a pre-built PySpark Docker image
FROM spark:3.5.0-scala2.12-java17-ubuntu
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
      unzip \
      rsync \
      openjdk-11-jdk \
      build-essential \
      software-properties-common \
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

RUN curl https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz -o spark-3.5.0-bin-hadoop3.tgz \
 && tar xvzf spark-3.5.0-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
 && rm -rf spark-3.5.0-bin-hadoop3.tgz

ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077

COPY conf/spark-defaults.conf "$SPARK_HOME/conf"

ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Make port 8888 available to the world outside this container
EXPOSE 8888

# Run inference.py when the container launches

CMD ["spark-submit", "--class", "com.example.SparkMLInference", "--master", "yarn", "spark-ml-1.0-SNAPSHOT.jar"]
