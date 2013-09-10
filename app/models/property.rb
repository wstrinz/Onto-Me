class Property < ActiveRecord::Base

  # after_initialize do
  #   self.rdf = escape_sub self.rdf
  #   self.save
  # end

  before_save do
    self.rdf = escape_sub self.rdf
    # self.save
  end

  def escape_sub(rdf)
    name = fullname
    rdf.to_s.gsub('#{property}',"<#{name}>").gsub('#{s}',"<#{name}>")
  end

  def turtle_prefixes
    {
       :foaf => "http://xmlns.com/foaf/0.1/",
       :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
       :owl => "http://www.w3.org/2002/07/owl#",
     }
  end

  def fullname
    "#{base_url}/properties/#{self.name}"
  end

  def base_url
    'http://localhost:3000'
  end

  def to_graph
    str = "#{self.rdf}"
    gr = RDF::Repository.new
    
    RDF::Turtle::Reader.new(str, prefixes: turtle_prefixes) do |reader|
      reader.each_statement do |statement|
        gr << statement
      end
    end

    gr
  end

  def prefix_replace(str)
    turtle_prefixes.keys.each{|prefix|
      str.gsub!(/(\s|^)(#{prefix.to_s}):(\S.+)(\s|$)/,'\1' + "#{turtle_prefixes[prefix]}\\3" +'\4')
    }
    str
  end

  def abbreviate
    str = self.rdf.to_s
    turtle_prefixes.each{|prefix,uri|
      str.gsub!(/<#{uri}(\w.+)>/,"#{prefix}:\\1")
    }
    turtle_prefixes.map{|k,v| "@prefix #{k}: <#{v}>"}.join("\n") + "\n\n" + str
  end

  def predicate(predicate)
    name = fullname
    predicate = prefix_replace(predicate)
    results = RDF::Query.execute(to_graph){ pattern [RDF::URI(name), RDF::URI(predicate), :result] }.map(&:result)
    if results.size == 1
      results.first
    else
      results
    end
  end
end
