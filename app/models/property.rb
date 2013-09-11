class Property < ActiveRecord::Base

  # after_initialize do
  #   self.rdf = 
  # end

  before_save do
    self.rdf = escape_sub self.rdf
  end

  def escape_sub(rdf)
    name = fullname
    rdf.to_s.gsub('#{property}',"<#{name}>").gsub('#{s}',"<#{name}>")
  end

  def turtle_prefixes
    {
       rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
       :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
       :owl => "http://www.w3.org/2002/07/owl#",
       :foaf => "http://xmlns.com/foaf/0.1/",
       :prop => "#{base_url}/properties/",
     }
  end

  def transform
#     template = <<-EOF
# <xsl:stylesheet version="1.0"
#       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
#       xmlns:skos="http://www.w3.org/2004/02/skos/core#"
#       xmlns:dc="http://purl.org/dc/elements/1.1/"
#       xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
#       xmlns:owl="http://www.w3.org/2002/07/owl#"
#       xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

#   <xsl:template match="/">
#     <html>
#       <body>
#         <h2>
#           <xsl:value-of select="//rdfs:label" />
#         </h2>
#         <xsl:value-of select="//rdfs:description" />
#         <xsl:for-each select="//rdfs:description">
#         <br />
#           <xsl:text>Broader: </xsl:text>
#           <xsl:value-of select="@rdf:resource"/>
#           <br />
#         </xsl:for-each>
#       </body>
#     </html>
#   </xsl:template>
# </xsl:stylesheet>
#     EOF

    doc   = Nokogiri::XML(to_xml)
    xslt  = Nokogiri::XSLT(self.xslt)

    xslt.transform(doc)
  end

  def fullname
    "#{BASE_URL}/properties/#{self.name}"
  end

  def base_url
    # 'http://localhost:3000'
    BASE_URL
  end

  def to_graph
    str = self.rdf
    gr = RDF::Repository.new
    
    RDF::Turtle::Reader.new(str) do |reader|
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
    to_graph.to_ttl(prefixes: turtle_prefixes)
    # str = self.rdf.to_s
    # turtle_prefixes.each{|prefix,uri|
    #   str.gsub!(/<#{uri}(\w.+)>/,"#{prefix}:\\1")
    # }
    # turtle_prefixes.map{|k,v| "@prefix #{k}: <#{v}>"}.join("\n") + "\n\n" + str
  end

  def predicate(predicate)
    name = fullname
    predicate = prefix_replace(predicate)
    results = RDF::Query.execute(to_graph){ pattern [RDF::URI(name), RDF::URI(predicate), :result] }.map(&:result)
    if results.size == 1
      results.first.to_s
    else
      results.map(&:to_s)
    end
  end

  def to_n3
    to_graph.to_ttl
  end

  def to_xml
    to_graph.to_rdfxml
  end

  def to_json
    to_graph.dump(:jsonld, :standard_prefixes => true)
  end

  def to_rdfa
    to_graph.to_rdfa
  end

  def self.dump
    big_graph = RDF::Repository.new
    Property.all.each{|prop|
      reader = RDF::Turtle::Reader.new(prop.rdf)
      big_graph << reader
    }
    big_graph
  end

  def self.to_n3
    dump.to_ttl
  end

  def self.to_xml
    dump.to_rdfxml
  end

  def self.to_rdfa
    dump.to_rdfa
  end

  def self.to_json
    dump.dump(:jsonld, :standard_prefixes => true)
  end
end
