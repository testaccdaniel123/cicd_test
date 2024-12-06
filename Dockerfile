# Use an official Ubuntu as a parent image
FROM ubuntu:latest

LABEL org.opencontainers.image.source="https://github.com/testaccdaniel123/cicd_test"

# Install dependencies and Python
RUN apt-get update && \
    apt-get install -y sysbench python3 python3-pip python3-venv build-essential libatlas-base-dev

# Install Python packages system-wide
RUN apt-get install -y python3-pandas python3-matplotlib

# Clean up to reduce image size
RUN apt-get clean

# Set the default command to run when the container starts
CMD ["python3"]