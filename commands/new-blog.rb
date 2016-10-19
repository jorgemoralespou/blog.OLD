summary     'creates a new blog post'
description <<desc
This command creates a new blog post under content/posts/{year}-{month}-{day}-{title}.adoc.
You can additionally pass in the description, the tags and the creation date.
desc
usage     'new-blog name [options]'

option :a, :author,  'Author for the blog', :argument => :optional
option :t, :tags,         'tags for this blog post (ex. "these,are,tags")', :argument => :optional
option :c, :categories,   'categories for this blog post (ex. "these,are,categories")', :argument => :optional
option :d, :created_at,   'creation date for this blog post (ex. "2013-01-03 10:24")', :argument => :optional

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

# ---
# title: "Title"
# kind: article
# created_at: 2016-10-17 09:00:00 +0000
# author_name: "Jorge Morales"
# read_time: 10 minutes
# categories: [devexp]
# tags: [openshift,origin,applications,templates]
# excerpt: "Excerpt...."
# ---

run do |opts, args, cmd|
  # requirements
  require 'stringex'
  require 'highline'

  # load up HighLine
  line = HighLine.new

  # get the name and description parameter or the default
  name = args[0] || "New blog post"
  author = opts[:author] || "Jorge Morales"

  # convert the tags and categories string to and array of trimmed strings
  tags = opts[:tags].split(",").map(&:strip) rescue []
  categories = opts[:categories].split(",").map(&:strip) rescue []

  # convert the created_at parameter to a Time object or use now
  timestamp = DateTime.parse(opts[:created_at]).to_time rescue Time.now

  # make the directory for the new blog post
  dir = "content/posts"
  FileUtils.mkdir_p dir

  # make the full file name
  filename = "#{dir}/#{timestamp.year}-#{'%02d' % timestamp.month}-#{'%02d' % timestamp.day}-#{name.to_url}.adoc"

  # check if the file exists, and ask the user what to do in that case
  if File.exist?(filename) && line.ask("#{filename} already exists. Want to overwrite? (y/n)", ['y','n']) == 'n'

    # user pressed 'n', abort!
    puts "Blog post creation aborted!"
    exit 1
  end

  # ---
  # title: "Title"
  # kind: article
  # created_at: 2016-10-17 09:00:00 +0000
  # author_name: Jorge Morales
  # read_time: 10 minutes
  # categories: [devexp]
  # tags: [openshift,origin,applications,templates]
  # excerpt: "Excerpt...."
  # ---

  # write the scaffolding
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{name}"
    post.puts "kind: article"
    post.puts "created_at: #{timestamp}"
    post.puts "author_name: #{author}"
    post.puts "read_time: 10 minutes"
    post.puts "tags: #{tags.inspect}"
    post.puts "tags: #{categories.inspect}"
    post.puts "excerpt: Excerpt go here..."
    post.puts "---\n\n"
  end
end
