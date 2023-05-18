# README
## Prerequisite
- Ruby Version Manager (rvm)
- Postgresql (any version >9.6 should work but ideally version 13 or 14)
- Redis (if sidekiq is enabled)

## Ruby Version Manager
1. ```bash
   gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
   ```
2. ```bash
   \curl -sSL https://get.rvm.io | bash -s stable
   ```
3. Install ruby 
   ```bash
   rvm install 3.0.3
   ```
# Postgresql 
1. ```bash
   brew install postgresql
   ```
2. ```bash
   createuser -s postgres
   ```
3. ```bash
   brew services restart postgresql
   ```
# Redis
1. ```bash
   brew install redis
   ```
2. ```bash
   brew services start redis
   ```

# Installation
1. Configuration    
    - refer .env.example, create your own .env file
2. Install gems
    ```bash
    bundle install
    ```
3. Run server
   ```bash
   rails s
   ```
4. Run console
    ```bash
    rails c
    ```
5. To generate a scaffold (model and migration included)
    ```bash
    rails g faster:scaffold api/v1/products name:string price:monetize
    ```
6. To generate a scaffold_controller (assuming model already exists)  
   Use --skip-pundit option if you want to skip pundit code (e.g. public API)
    ```bash
    rails g faster:scaffold_controller api/v1/products name:string price:monetize { --skip-pundit }
    ```
7. To generate rswag request spec file manually (no need to do this if you use scaffold)  
   For example, api/v1/products_controller
    ```bash
    rails g rspec:swagger Api::V1::Product
    ```
8. To run rspec test and generate swagger.json
    ``` 
    # generate documentation
    bundle exec rspec spec/requests --format Rswag::Specs::SwaggerFormatter --format p
    # just run test without documentation
    bundle exec rspec spec
    ```
9.  To view API documentation, visit http://localhost:3000/redoc