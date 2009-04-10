require 'rake'
require 'rake/clean'
require 'erb'

LANGUAGES = ['en', 'fr']
FILES = ['index', 'resto', 'hotel', 'contact']

CLOBBER.include(LANGUAGES)

def readFileContent(filePath)
  result = Array.new
  File.open(filePath, 'r') do |file|
    file.each_line do |line|
      result << line
    end
  end
  return result.join('')
end

def erbTransform(filePath)
  template = ERB.new( readFileContent( filePath))
  return template.result(binding)
end

def erbInclude(filePath)
  return erbTransform(filePath)
end

def htmlFileName(htmlFilePath)
  htmlFilePath.sub(/^[^\/]*\//,'')
end
def erbTemplateOf(htmlFilePath)
  htmlFileName(htmlFilePath).sub(/\.html$/, '.erb')
end
def languageOf(htmlFilePath)
  htmlFilePath.sub(/\/.*$/, '')
end
def localsOf(htmlFilePath)
  languageOf(htmlFilePath) + '.rb'
end

$currentLocal = {}
def l(key)
  ERB::Util::html_escape($currentLocal[key])
end
def setCurrentLocal(dico)
  $currentLocal = dico
end

$currentFileName = ''
def currentFileName()
  return $currentFileName
end
def setCurrentFileName(value)
  $currentFileName = value
end

LANGUAGES.each do |lang|
  directory lang
end

rule '.html' => [proc {|tn| localsOf(tn) }, proc {|tn| languageOf(tn) }, proc {|tn| erbTemplateOf(tn) } ] do |t|

  setCurrentLocal( eval(readFileContent( localsOf(t.name))))
  setCurrentFileName( htmlFileName(t.name))

  File.open( t.name, 'w') do |n|
    n.write( erbTransform( erbTemplateOf(t.name)))
  end
end

desc 'Generates file for the multilingual web site'
LANGUAGES.each do |lang|
  FILES.each do |f|
    task :default => lang + '/' + f + '.html'
  end
end

