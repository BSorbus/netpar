  #File config/initializers/swagger_docs.rb
  Swagger::Docs::Config.register_apis({
  "1.0" =>  {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public",
    # the URL base path to your API
    :base_path => "http://localhost:3000",
    #The base controller class your project uses; 
    #it or its subclasses will be where you call swagger_controller and swagger_api. 
    #An array of base controller classes may be provided.
    #:controller_base_path => "/app/controllers/api/v1",
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "NETPAR2015 API",
        "description" => "API documention with Swagger UI.",
        "termsOfServiceUrl" => "http://netpar2015.uke.gov.pl/",
        "contact" => "netpar@uke.gov.pl"
      }
    }
  }
})