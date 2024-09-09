# Remove the 'dist' directory and its contents
Remove-Item -Path 'dist' -Recurse -Force

# Build the Docker image without cache and tag it as 'go-spider-export'
docker build --no-cache -t go-spider-export .

# Run a container from the 'go-spider-export' image
docker run --name go-spider-export-container go-spider-export

# Copy the 'dist' directory from the container to the current directory
docker cp go-spider-export-container:/src/dist .

# Remove the container
docker rm go-spider-export-container

# Remove the Docker image
docker rmi go-spider-export
