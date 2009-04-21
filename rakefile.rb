require 'rake'
require 'rake/clean'
require 'erb'
require 'batchftp'


TARGET_DIR = 'site'
IMAGES_DIR = 'images'
PLAIN_OLD_FILES = ['stylesheet.css', 'script.js']
FILES = ['index', 'resto', 'hotel', 'info']

class Language
  
  private_class_method :new
  attr_reader :directory, :clobberFiles, :localsFile, :resourcesPrefix

  def initialize(directory, clobberFiles, localsFile, resourcesPrefix)
    @directory, @clobberFiles, @localsFile, @resourcesPrefix = directory, clobberFiles, localsFile, resourcesPrefix
  end

  def Language.foreign(initials)
    new(initials, File::join(TARGET_DIR, initials), initials + ".rb", "..")
  end

  def Language.french
    new(".", FILES.map { |f| File::join(TARGET_DIR, f + ".html") }, "fr.rb", ".")
  end

end

LANGUAGES = [Language.french, Language.foreign('en')]


LANGUAGES.each do |lang|
  CLOBBER.include(lang.clobberFiles)
end

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

def trimSiteDir(path)
  path.sub(TARGET_DIR, '').sub(/^\//,'')
end
def htmlFileName(htmlFilePath)
  File::basename(htmlFilePath)
end
def erbTemplateOf(htmlFilePath)
  File::basename(htmlFilePath, ".*")+".erb"
end
def directoryOf(htmlFilePath)
  dir, _file = File.split(trimSiteDir(htmlFilePath))
  dir
end
def languageOf(htmlFilePath)
  dir = directoryOf(htmlFilePath)
  LANGUAGES.detect {|lang| lang.directory == dir}
end

$currentLocals = {}
def l(key)
  ERB::Util::html_escape($currentLocals[key])
end
def setCurrentLocals(dico)
  $currentLocals = dico
end

$currentFileName = ''
def currentFileName()
  return $currentFileName
end
def setCurrentFileName(value)
  $currentFileName = value
end

LANGUAGES.each do |lang|
  directory File::join(TARGET_DIR, lang.directory)
end

rule '.html' => [proc {|tn| languageOf(tn).localsFile }, proc {|tn| File::join(TARGET_DIR, directoryOf(tn)) }, proc {|tn| erbTemplateOf(tn) } ] do |t|

  language = languageOf(t.name)
  locals = eval(readFileContent( language.localsFile))
  locals[:resPrefix] = language.resourcesPrefix
  
  setCurrentLocals(locals)
  setCurrentFileName( htmlFileName(t.name))

  File.open( t.name, 'w') do |n|
    n.write( erbTransform( erbTemplateOf(t.name)))
  end
end

desc 'Generates file for the multilingual web site'
LANGUAGES.each do |lang|
  FILES.each do |f|
    task :default => File::join(TARGET_DIR, lang.directory, f + '.html')
  end
end

desc 'Deploys the site'
task :deploy => :default do
  verbose('deploying to ftp') do
    puts 'reading ftp password from password.txt'
    password = readFileContent("password.txt")
    Net::FTP.open('ftp-windows.fr.oleane.com', 'admweb@madkatbo.fr.fto', password) do |ftp|
      uploadHierarchy(ftp, 'site', '.', ['.html', '.css', '.js'])
    end
  end
end
