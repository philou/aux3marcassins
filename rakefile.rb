require 'rake'
require 'erb'

def readFileContent(filePath)
  result = Array.new
  File.open(filePath, 'r') do |file|
    file.each_line do |line|
      result << line
    end
  end
  return result.join('')
end

def erbTransform(filePath, bindings)
  template = ERB.new( readFileContent( filePath))
  return template.result(bindings)
end

def erbInclude(filePath)
  return erbTransform(filePath, binding)
end

def originErbFilePath(htmlFilePath)
  htmlFilePath.sub(/^[^\/]*\//,'').sub(/\.html$/, '.erb')
end

directory 'fr'

rule '.html' => [proc {|tn| tn.sub(/\/.*$/, '') }, proc {|tn| originErbFilePath(tn) } ] do |t|
  File.open( t.name, 'w') do |n|
    n.write( erbTransform( originErbFilePath(t.name), binding))
  end
end

task :default => ['fr/index.html', 'fr/resto.html', 'fr/hotel.html', 'fr/contact.html' ]

task :clean do |t|
  sh "rm -rf fr"
end
