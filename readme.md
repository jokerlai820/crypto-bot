 <!-- GETTING STARTED -->
# Getting Started

## Prerequisite
  - Python3
  - Docker
  - DevContainer(vscode extension)
    - devcontainer.json
      ```json
      // ./ft_userdata/.devcontainer/devcontainer.json
      {
        "name": "My Freqtrade Docker Env",
        "build": {
          "dockerfile": "Dockerfile",
          "context": "../",
          "args": { 
            // Update 'VARIANT' to pick a Python version: 3, 3.6, 3.7, 3.8, 3.9
            "VARIANT": "3.9",
          }
        },

        // Set *default* container specific settings.json values on container create.
        "settings": { 
          "python.languageServer": "Pylance",
        },

        // Add the IDs of extensions you want installed when the container is created.
        "extensions": [
          "ms-python.python",
          "ms-python.vscode-pylance"
        ],

        // Use 'forwardPorts' to make a list of ports inside the container available locally.
        // "forwardPorts": [],

        // Use 'postCreateCommand' to run commands after the container is created.
        // "postCreateCommand": "pip3 install --user -r requirements.txt",

        // Comment out connect as root instead. More info: https://aka.ms/vscode-remote/containers/non-root.
        // "remoteUser": "vscode"
      }
      ```
    - Dockerfile
      ```Dockerfile
        # ./ft_userdata/.devcontainer/Dockerfile
        # syntax=docker/dockerfile:1
        FROM freqtradeorg/freqtrade:develop_plot
      ```
  - Terraform
  - AWS

## Initialization

#### Creating the project folder 
  ```sh
  mkdir ft_userdata
  ```
#### Access to the directory 
  ```sh
  cd ft_userdata/
  ```
#### Download docker compose from the repository 
  ```sh
  curl https://raw.githubusercontent.com/freqtrade/freqtrade/stable/docker-compose.yml -o docker-compose.yml
  ```
#### Obtaining the freqtrade image 
  ```sh
  docker-compose pull
  ```
#### Create subdirectory 
  ```sh
  docker-compose run --rm freqtrade create-userdir --userdir user_data
  ```
#### Launch the interactive bot configuration 
  ```sh
  docker-compose run --rm freqtrade new-config --config user_data/config.json
  ```

## Configuration
  ```sh
  // ./variable.tfvars.json
  {
    "env": "",
    "strategy": "SuperTrend",
    "aws_var": {
    "private_key": "",
    "access_key":"",
    "secret_key":"",
    "ec2": {
      "user": "ec2-user",
      "ami": "",
      "instance_type": "",
      "subnet_id": "",
      "security_group_ids": [""],
      "key_name": "",
      "ip_v4": ""
    }
    "github": {
      "repo": ""
    } 
  }
  ```

## Deployment
#### Preview the changes
  ```sh
  terraform plan -var-file="<env>.variable.tfvars.json" 
  ```
#### Update the changes 
  ```sh
  terraform apply -var-file="<env>.variable.tfvars.json"     
  ```

## Build
#### Run on local
  ```sh
  docker-compose -f docker-compose.yml -f docker-compose.local.yml up
  ```
  OR
  ```sh
  ./run.sh local <strategy>
  ```

#### Run on AWS EC2
  ```sh
  docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
  ```
    OR
  ```sh
  ./run.sh prod <strategy>
  ```

## Connection 
#### EC2
  ```sh
  ssh -i "freqtradebot.pem" <user>@ec2-<public_ip>.compute-1.amazonaws.com
  ```

## Backtesting 
#### Download price data
  ```sh
  freqtrade download-data --config {{path/to/config.json}} --timerange YYYYMMDD-YYYYMMDD --timeframe {{1m 5m}}
  freqtrade download-data --config ./user_data/config.json --timerange 20190101-20230930 --timeframe 30m
  ```

#### Run testing
  ```sh
  freqtrade backtesting --config {{path/to/config.json}} --strategy {{Strategy}}
  freqtrade backtesting --config ./user_data/config.json --strategy Bollinger --timerange 20190101-20230930
  freqtrade backtesting --config ./user_data/config.json --strategy Bollinger --timerange 20230101-20230930 --timeframe 30m
  
  ```


