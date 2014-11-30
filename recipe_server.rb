require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

get '/recipes' do
  query = "SELECT recipes.name, recipes.id
  FROM recipes
  ORDER BY recipes.name;"

  db_connection do |connection|
    @recipes = connection.exec_params(query)
  end

  erb :index
end

get '/recipes/:id' do
  @id = params[:id]

  query = "SELECT ingredients.name FROM ingredients
  JOIN recipes on recipes.id = ingredients.recipe_id
  WHERE recipes.id = $1;"

  recipe_name_query = "SELECT recipes.name AS recipe, recipes.instructions, recipes.description
  FROM recipes
  WHERE recipes.id = $1;"

  db_connection do |connection|
    @ingredients = connection.exec_params(query, [@id])
  end

  db_connection do |connection|
    @recipe_name = connection.exec_params(recipe_name_query, [@id])
  end

  @recipe_name.to_a.each do |recipe|
    @name = recipe["recipe"]
    @instructions = recipe["instructions"]
    @description = recipe["description"]
  end

  erb :recipe
end
