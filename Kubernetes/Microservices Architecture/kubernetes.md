Below are the Kubernetes configuration files required to deploy the **QuickEats** microservices on a Kubernetes cluster. Each service will have its own deployment and service configuration.

### 1. User Service

**user-service-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: quickeats/user-service:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: user-service
```

### 2. Restaurant Service

**restaurant-service-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restaurant-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: restaurant-service
  template:
    metadata:
      labels:
        app: restaurant-service
    spec:
      containers:
      - name: restaurant-service
        image: quickeats/restaurant-service:latest
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: restaurant-service
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 5000
  selector:
    app: restaurant-service
```

### 3. Order Service

**order-service-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: quickeats/order-service:latest
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8000
  selector:
    app: order-service
```

### 4. Delivery Service

**delivery-service-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: delivery-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: delivery-service
  template:
    metadata:
      labels:
        app: delivery-service
    spec:
      containers:
      - name: delivery-service
        image: quickeats/delivery-service:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: delivery-service
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: delivery-service
```

### 5. Notification Service

**notification-service-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notification-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: notification-service
  template:
    metadata:
      labels:
        app: notification-service
    spec:
      containers:
      - name: notification-service
        image: quickeats/notification-service:latest
        ports:
        - containerPort: 8081
---
apiVersion: v1
kind: Service
metadata:
  name: notification-service
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8081
  selector:
    app: notification-service
```

### Steps to Deploy

1. **Save the YAML Files:**
   - Save each deployment and service configuration in separate YAML files as mentioned above.

2. **Apply the Configurations:**
   Navigate to the directory containing the YAML files and run the following command for each file:

   ```bash
   kubectl apply -f user-service-deployment.yaml
   kubectl apply -f restaurant-service-deployment.yaml
   kubectl apply -f order-service-deployment.yaml
   kubectl apply -f delivery-service-deployment.yaml
   kubectl apply -f notification-service-deployment.yaml
   ```

3. **Verify Deployments:**
   You can check the status of your deployments and services by running:

   ```bash
   kubectl get deployments
   kubectl get services
   ```

### Notes
- Each service is exposed as a `ClusterIP`, which means it will be accessible within the Kubernetes cluster. You may want to change the service type to `LoadBalancer` or `NodePort` if you need external access.
- Adjust the number of replicas based on your expected load and resource availability.
- Ensure that the images are built and pushed to a container registry (e.g., Docker Hub, Amazon ECR) before deploying.