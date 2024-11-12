# Little Shop | Final Project | Backend Starter Repo

This repository is the completed API for use with the Mod 2 Group Project. The FE repo for Little Shop lives [here](https://github.com/turingschool-examples/little-shop-fe-vite).

This repo can be used as the starter repo for the Mod 2 final project.

## Setup

```ruby
bundle install
rails db:{drop,create,migrate,seed}
rails db:schema:dump
```

This repo uses a pgdump file to seed the database. Your `db:seed` command will produce lots of output, and that's normal. If all your tests fail after running `db:seed`, you probably forgot to run `rails db:schema:dump`. 

Run your server with `rails s` and you should be able to access endpoints via localhost:3000.

### Project Description
In this solo project, Coupon Codes, I worked to add coupons to the already existing Little Shop. This focused on building on an already existing E-Commerce application using service-oriented architecture to add coupon functionality.

### System Dependencies and Tools
* Ruby version: 3.2.2
* Rails: 7.4.x 
* Database: PostgreSQL 
* Additional Gems: `pry, debug, simplecov, rspec-rails, shoulda-matchers, faker, factory_bot`
* Testing/Sending HTTP requests: Postman

### Setup
```ruby
bundle install
rails db:{drop,create,migrate,seed}
rails db:schema:dump
```

This repo uses a pgdump file to seed the database. Your `db:seed` command will produce lots of output, and that's normal. If all your tests fail after running `db:seed`, you probably forgot to run `rails db:schema:dump`. 

Run your server with `rails s` and you should be able to access endpoints via localhost:3000.

### Learning Goals
* Write migrations to create tables and relationships between tables
* Implement CRUD functionality for a resource
* Use MVC to organize code effectively, limiting the amount of logic included in serializers and controllers
* Use built-in ActiveRecord methods to join tables of data, make calculations, and group data based on one or more attributes
* Write model tests that fully cover the data logic of the application
* Write request tests that fully cover the functionality of the application
* Display data for users in a frontend application by targeting DOM elements

