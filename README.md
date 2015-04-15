# setup_rr

# Setup local ruby &amp; rails on Ubuntu, Mint
Setup variables in install_ruby_rails
```

VER_RUBY=2.2.1
VER_RAILS=4.2.1

```
Start install:
```
Usage: ./install_ruby_rails.sh [-f]
Parameters:
  -h Help.
  -f Force mode.
     Remove dirs ~/.rbenv and ~/.gem before install.
```

## After Install

### Setting Up MySQL:
sudo apt-get install mysql-server mysql-client libmysqlclient-dev

### Setting Up PostgreSQL:
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-common
sudo apt-get install postgresql-9.3 libpq-dev

### Final Steps
```
And now for the moment of truth. Let's create your first Rails application:

#### If you want to use SQLite (not recommended)
rails new myapp

#### If you want to use MySQL
rails new myapp -d mysql

#### If you want to use Postgres
# Note that this will expect a postgres user with the same username
# as your app, you may need to edit config/database.yml to match the
# user you created earlier
rails new myapp -d postgresql

# Move into the application directory
cd myapp

# If you setup MySQL or Postgres with a username/password, modify the
# config/database.yml file to contain the username/password that you specified

# Create the database
rake db:create

rails server

```
You can now visit http://localhost:3000 to view your new website!

Now that you've got your machine setup, it's time to start building some Rails applications.

If you received an error that said Access denied for user 'root'@'localhost' (using password: NO) then you need to update your config/database.yml file to match the database username and password.


More details:
  https://gorails.com/setup/ubuntu/14.10
  https://github.com/sstephenson/rbenv
  https://github.com/sstephenson/ruby-build
  https://github.com/sstephenson/rbenv-gem-rehash
