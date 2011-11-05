

desc "Remove previous builds artefacts"
task :clean do
  sh "rm -r _site/*"
end

namespace :build do
  
  desc "Build scss files"
  task :css do
    sh "compass compile _sass/aerdhyl.scss"
  end
  
  desc "Build the website"
  task :html => [:clean] do
    sh 'jekyll'
  end
  
  desc "builds the production version of the website"
  task :prod do
    ENV['JEKYLL_ENV'] = "prod"
    Rake::Task["build:all"].invoke
  end 
  
  desc "Builds all"
  task :all => [:css, :html]
end

desc "Send the website live"
task :deploy => ["build:prod"] do
  sh "rsync -vzr _site/ aerdhyl@aerdhyl.eu:/home/aerdhyl/aerdhyl.eu"
end


desc "Serve the website"
task :serve do
  Thread.new { `compass watch _sass/aerdhyl.scss` }
  Thread.new { `jekyll --auto --serve` }
end

task :default => ["build:all"]
