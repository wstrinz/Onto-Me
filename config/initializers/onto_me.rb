if ENV["RAILS_ENV"] == "production"
  BASE_URL = 'http://onto.strinz.me'
else
  BASE_URL = 'http://localhost:3000'
end

Mime::Type.register "text/rdf+n3" , :n3
Mime::Type.register "text/rdf+n3" , :ttl
Mime::Type.register "text/rdf+xml" , :rdfxml