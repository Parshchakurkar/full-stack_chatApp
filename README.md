[![Fork Button](https://img.shields.io/github/forks/iemafzalhassan/full-stack_chatApp?style=social)](https://github.com/iemafzalhassan/full-stack_chatApp/fork)


# Real-Time Chat Application


Welcome to the **Full Stack Realtime Chat App** project, where we're building a scalable and secure real-time chat experience using the latest technologies. Whether you're a seasoned developer or a beginner, we invite you to contribute and be a part of this exciting journey!

## Table of Contents


* [Introduction](#introduction)
* [Features](#features)
* [Tech Stack](#tech-stack)
* [Getting Started](#getting-started)
* [Building the Backend](#building-the-backend)
* [Running the Application](#running-the-application)
* [Contributing](#contributing)
* [Future Plans](#future-plans)
* [License](#license)

## 📝 Introduction

This project aims to provide a real-time chat experience that's both scalable and secure. With a focus on modern technologies, we're building an application that's easy to use and maintain.

## ✨ Features


* **Real-time Messaging**: Send and receive messages instantly using Socket.io 
* **User Authentication & Authorization**: Securely manage user access with JWT 
* **Scalable & Secure Architecture**: Built to handle large volumes of traffic and data 
* **Modern UI Design**: A user-friendly interface crafted with React and TailwindCSS 
* **Profile Management**: Users can upload and update their profile pictures 
* **Online Status**: View real-time online/offline status of users 


## 🛠️ Tech Stack


* **Backend:** Node.js, Express, MongoDB, Socket.io
* **Frontend:** React, TailwindCSS
* **Containerization:** Docker
* **Orchestration:** Kubernetes (planned)
* **Web Server:** Nginx
* **State Management:** Zustand
* **Authentication:** JWT
* **Styling Components:** DaisyUI


### 🔧 Prerequisites


* **[Node.js](https://nodejs.org/)** (v14 or higher)
* **[Docker](https://www.docker.com/get-started)** (for containerizing the app)
* **[Git](https://git-scm.com/downloads)** (to clone the repository)


### 📝 Environment Configuration

Create a `.env` file in the root directory with the following configuration:

```env
# Database Configuration
MONGODB_URI=mongodb://root:admin@mongo:27017/chatApp?authSource=admin&retryWrites=true&w=majority

# JWT Configuration
JWT_SECRET=your_jwt_secret_key

# Server Configuration
PORT=5001
NODE_ENV=production
```

> **Note:** 
> - Replace `your_jwt_secret_key` with a strong secret key
> - For local development without Docker, change `MONGODB_URI` to `mongodb://localhost:27017/chatApp`
> - You can use command ```echo "Text what you want" | base64

### Clone the Repository

```bash
git clone https://github.com/iemafzalhassan/full-stack_chatApp.git
```

🏗️ Build and Run the Application

Follow these steps to build and run the application:

1. Build & Run the Containers:

```bash
cd full-stack_chatApp
```
```bash
docker-compose up -d --build
```

2. Access the application in your browser:

```
http://localhost
```
---

### Run the Frontend container:

```bash
docker run -d --network=full-stack  -p 5173:5173 --name frontend full-stack_frontend:latest
```
#### The frontend will now be accessible on port 5173.


## Run the MongoDB Container:

```bash
docker run -d -p 27017:27017 --name mongo mongo:latest
```
---

## 🛠️ Building the Backend

```bash
cd backend
```

### Build the Backend image:

```bash
docker build -t full-stack_backend .
```

### Run the Backend container:

```bash
docker run -d --network=full-stack --add-host=host.docker.internal:host-gateway -p 5001:5001 --env-file .env full-stack_backend
```
#### This will build and run the backend container, exposing the backendAPI on port 5001.

`Backend API: http://localhost:5001`

### To Verify the conncetion between backend and databse:
```bash
docker-compose logs -f
```

### Once the backend and frontend containers are running, you can access the application in your browser:

`Frontend: http://localhost`


You can now interact with the real-time chat app and start messaging!
---
Azure CLI Commands to create resources (to setup things fast)

`az login` --- login

`az group create --name chatapp-resources --location eastus`

`az storage account create --name chatappresources1 --resource-group chatapp-resources  --location eastus --sku Standard_LRS`

`az storage container create --name terraform --account-name chatappresources1`

then  for azure devops:

az extension add --name azure-devops
az devops configure --defaults organization=https://dev.azure.com/<your-org> project=<your-project>

You also need:
Azure DevOps PAT (or already logged in via az devops login)
Permissions to create service connections


---
After running resourceenv.ps1 script run ACR and then AKS pipeline.
## Terraform
- created AKS modlue currently now for dev environment
### Terraform architecture for pipeline and infrastructure
![alt text](image.png)
- if manually running infrastructre, create terraform.tfvars file have all the varaible values, and run
prerequisite:
i. chatapp-resources --> create resource group in eastUS
ii. create service connection (chatapp) for the resource group
iii. Assign access to the service account
    1. Storage blob data contributor
    2. Storage queue data contributor
    3. resource group level ---> User access Administrator role

```bash
terraform init
```
once initialization is done

```bash
terraform plan
```
and final run 

```bash
terraform apply --auto-approve Y
```

- if want to see the terraform resource graphs, run
```bash
terraform graph
```
put the output in file with extension .dot ex: graph.dot

- Download https://graphviz.org/download/.  to convert graph.dot to .png
- One download complete run:
```bash 
dot -Tpng graph.dot -o graph.png
```

If want to apply everyting with commands from your machine create .tfvars and backendconfig.hcl file in local and run
`terraform init -var-file=test.tfvars -backend-config=backend.hcl`

then 
`terraform validate`

later perform plan:
`terraform plan -var-file=test.tfvars`



### Varisbles:
- varibles required for the terraform pipelie stored in the ```/variable/variable.yml``` file

or simply run the ACR pipeline to create acr resource.

## Kubernetes:
i. Run AKS pipeline to have the aks cluster created.
ii. Run --> az aks get-credentials --resource chatapp-resources --name chatapp-resources-aks 
iii. make sure you have images architecture match with node pool vm architechture.

## 🔮 Future Plans

This project is evolving, and here are a few exciting things on the horizon:

* [ ] **CI/CD Pipelines:** Implement Continuous Integration and Continuous Deployment pipelines to automate testing and deployment.

---

## 📚 Project Snapshots:

![Settings](frontend/public/settings.png)

![chat](frontend/public/chat.png)

![logout](/frontend/public/logout.png)

![Login](/frontend/public/login.png)


## 📜 License


This project is licensed under the MIT License. See the LICENSE file for more details.














