Sure! Below are example `Dockerfile` configurations for each of the microservices in the **QuickEats** online food delivery service scenario. Each service is written in a different language/framework for demonstration purposes.

### 1. User Service (Node.js)

```dockerfile
# User Service Dockerfile
FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Command to run the app
CMD ["npm", "start"]
```

### 2. Restaurant Service (Python Flask)

```dockerfile
# Restaurant Service Dockerfile
FROM python:3.9

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create app directory
WORKDIR /usr/src/app

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the app
CMD ["flask", "run", "--host=0.0.0.0"]
```

### 3. Order Service (Python Flask)

```dockerfile
# Order Service Dockerfile
FROM python:3.9

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create app directory
WORKDIR /usr/src/app

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the app
CMD ["flask", "run", "--host=0.0.0.0"]
```

### 4. Delivery Service (Go)

```dockerfile
# Delivery Service Dockerfile
FROM golang:1.16

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o delivery-service .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the executable
CMD ["./delivery-service"]
```

### 5. Notification Service (Java Spring Boot)

```dockerfile
# Notification Service Dockerfile
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the jar file into the container
COPY target/notification-service.jar notification-service.jar

# Expose the port the app runs on
EXPOSE 8081

# Command to run the app
ENTRYPOINT ["java", "-jar", "notification-service.jar"]
```

### Building and Running the Containers

1. **Build the Docker Images:**
   Each service should have its own directory with the corresponding `Dockerfile`. Navigate to each service's directory and run:

   ```bash
   docker build -t quickeats/user-service .
   docker build -t quickeats/restaurant-service .
   docker build -t quickeats/order-service .
   docker build -t quickeats/delivery-service .
   docker build -t quickeats/notification-service .
   ```

2. **Run the Containers:**
   You can run each container using:

   ```bash
   docker run -p 3000:3000 quickeats/user-service
   docker run -p 5000:5000 quickeats/restaurant-service
   docker run -p 8000:8000 quickeats/order-service
   docker run -p 8080:8080 quickeats/delivery-service
   docker run -p 8081:8081 quickeats/notification-service
   ```

Each service will be accessible on its respective port, allowing you to interact with them as needed in your local development environment. Adjust the ports as necessary based on your setup.