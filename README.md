# GrabzIt

Interfaces with the GrabzIt screenshot service (http://grabz.it)

**This is not the official version of the GrabzIt Ruby Gem. If you want the latest official version please visit: http://grabz.it/api/ruby/download.aspx**

Yard docs can be found at http://www.rubydoc.info/github/cavneb/grabz_it/master/frames

## Installation

Add this line to your application's Gemfile:

    gem 'grabz_it'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grabz_it
    
## Dependencies
* [rspec](https://github.com/rspec/rspec) (used in tests only)

## Usage

### Save Picture

Calls the GrabzIt web service to take the screenshot and saves it to the target path provided. 

*Warning, this is a SYNCHONOUS method and can take up to 5 minutes before a response.*

```ruby
client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
options = {
  :url            => 'http://grabz.it',
  :callback_url   => 'http://example.com/callback',
  :browser_width  => 1024,
  :browser_height => 768,
  :output_width   => 800,
  :output_height  => 600,
  :custom_id      => '12345',
  :format         => 'png',
  :delay          => 1000
}
client.save_picture('/tmp/my_picture.png', options)

puts File.exists?('/tmp/my_picture.png')
# => true
```

### Take Picture

Calls the GrabzIt web service to take the screenshot. It will optionally ping a callback url with the custom id if provided.

```ruby
client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
options = {
  :url            => 'http://grabz.it',
  :callback_url   => 'http://example.com/callback',
  :browser_width  => 1024,
  :browser_height => 768,
  :output_width   => 800,
  :output_height  => 600,
  :custom_id      => '12345',
  :format         => 'png',
  :delay          => 1000
}
response = client.take_picture(options)

puts response.screenshot_id
# => 'Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58'
```

### Get Picture

Get the screenshot image

```ruby
client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
image = client.get_image('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')

puts image.content_type
# => 'image/png'
puts image.size
# => 129347

image.save("/tmp/myimage.png")
File.exist?("/tmp/myimage.png")
# => true
```

### Get Status

Get the current status of a GrabzIt screenshot.

```ruby
client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
status = client.get_status('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')

puts status.failed?
# => false
puts status.available?
# => true
```

### Get Cookie Jar

Get all the cookies that GrabzIt is using for a particular domain. This may include your user set cookies as well.

```ruby
client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
cookie_jar = client.get_cookie_jar('google')

puts cookie_jar.cookies.count
# => 3
puts cookie_jar.cookies[0].name
# => 'secure'
puts cookie_jar.cookies[0].domain
# => 'accounts.google.com'
```

## TODO

* Create the ability to set and delete cookies.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
