require 'net/ftp'

def verbose(caption) 
  begin
    puts caption
    yield
  rescue
    puts $!
  end
end

def puttextfile(ftp, local, remote)
  verbose("uploading file #{remote}") { ftp.puttextfile(local, remote) }
end

def putbinaryfile(ftp, local, remote)
  verbose("uploading file #{remote}") { ftp.putbinaryfile(local, remote) }
end

def mkdir(ftp, remote)
  verbose("creating dir #{remote}") { ftp.mkdir(remote) }
end

def uploadHierarchy(ftp, ldir, rdir, txtExts)
  mkdir(ftp, rdir)
  Dir.foreach(ldir) do |file|
    if (file != '.' && file != '..')
      lfile = File.join(ldir, file)
      rfile = File.join(rdir, file)
      if File.directory?(lfile)
        uploadHierarchy(ftp, lfile, rfile, txtExts)
      else
        if txtExts.include?(File.extname(file))
          puttextfile(ftp, lfile, rfile)
        else
          putbinaryfile(ftp, lfile, rfile)
        end
      end
    end
  end
end
