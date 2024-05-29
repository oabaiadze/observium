# Observium Docker Setup

This repository contains the necessary files to set up Observium Community Edition using Docker and Docker Compose. It includes an Observium container and a MariaDB container for the database.

## Prerequisites

- Docker
- Docker Compose

## Setup

### Step 1: Clone the Repository

```sh
git clone <repository-url>
cd <repository-directory>
```

### Step 2: Configure the Environment

Create a `.env` file in the root directory of the repository and add the following environment variables:

```sh

vim .env

```

### Step 3: Start the Containers

```sh
docker-compose up -d
```
