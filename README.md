# NexusArtifact

Simple Ruby gem to download/publish arbitrary binary file from/to Nexus server

## Installation

Add this line to your application's Gemfile:

    gem 'nexus_artifact'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexus_artifact

## Usage

Create a nexus.yml file specifying location of artifact in nexus server:

    ---
    :uri:      http://my-maven-server:8081
    :path:     /nexus/content/repositories/some-repo/com/some-company/some_artifact
    :artifact: "%v/any_name.%v.%e"
    :user:     someuser
    :pass:     somepass

In ruby code:

    # Publish the file
    NexusArtifact.instance.publish '/source_dir/my_file.iso', :ver => '3.5.2', :ext => 'iso'

    # Download the file
    NexusArtifact.instance.get '/save_dir/my_file.iso', :ver => '3.5.2', :ext => 'iso'

With the nexus.yml file above, this will publish two files:
1. http://my-maven-server:8081/nexus/content/repositories/some-repo/com/some-company/some_artifact/3.5.2/any_name.3.5.2.iso
2. http://my-maven-server:8081/nexus/content/repositories/some-repo/com/some-company/some_artifact/3.5.2/any_name.3.5.2.iso.sha1

In addition, you can find out what versions are available as well as what the next availble build number is:

    NexusArtifact.instance.versions
    # Will return e.g. ['3.4.1', '3.4.2', '3.5.1', '4.8.12']

    NexusArtifact.instance.next_version('4.8')
    # Will return e.g. '4.8.13'

If you do not wish to use a nexus.yml file, you can also create an instance of this class:

    artifact = NexusArtifact.new 'http://my-maven-server:8081',
                                 '/nexus/content/repositories/some-repo/com/some-company/some_artifact',
                                 '%v/any_name.%v.%e'
    artifact.auth 'someuser', 'somepass' # Only if needed

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
