require 'rbconfig'

##########################################################################################
# Configuration. Remove setting before publishing Gem.
##########################################################################################

# set to true if development environment
# $DVLP = true

# Set development dependency: those are gems that are also in development and thus not
# installed in the gem directory.  Need a way of accessing them
# $DVLP_DEPEND=["critbit"]

# Set dependencies from other local gems provided in the vendor directory. 
# $VENDOR_DEPEND=[]

##########################################################################################

# the platform
@platform = 
  case RUBY_PLATFORM
  when /mswin/ then 'windows'
  when /mingw/ then 'windows'
  when /bccwin/ then 'windows'
  when /cygwin/ then 'windows-cygwin'
  when /java/
    require 'java' #:nodoc:
    if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
      'windows-java'
    else
      'default-java'
    end
  else 'default'
  end

#---------------------------------------------------------------------------------------
# Add path to load path
#---------------------------------------------------------------------------------------

def mklib(path, home_path = true)
  
  if (home_path)
    lib = path + "/lib"
  else
    lib = path
  end
  
  $LOAD_PATH.insert(0, lib)

end

##########################################################################################
# Prepare environment to work inside Cygwin
##########################################################################################

if @platform == 'windows-cygwin'
  
  #---------------------------------------------------------------------------------------
  # Return the cygpath of a path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
  end
  
else
  
  #---------------------------------------------------------------------------------------
  # Return  the path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    path
  end
  
end

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class CritbitRB

  @home_dir = File.expand_path File.dirname(__FILE__)

  class << self
    attr_reader :home_dir
  end

  @project_dir = CritbitRB.home_dir + "/.."
  @doc_dir = CritbitRB.home_dir + "/doc"
  @lib_dir = CritbitRB.home_dir + "/lib"
  @src_dir = CritbitRB.home_dir + "/src"
  @target_dir = CritbitRB.home_dir + "/target"
  @test_dir = CritbitRB.home_dir + "/test"
  @vendor_dir = CritbitRB.home_dir + "/vendor"
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
  end

  @build_dir = CritbitRB.src_dir + "/build"

  class << self
    attr_reader :build_dir
  end

  @classes_dir = CritbitRB.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
  end

end

#---------------------------------------------------------------------------------------
# Set dependencies
#---------------------------------------------------------------------------------------

def depend(name)
  
  dependency_dir = CritbitRB.project_dir + "/" + name
  mklib(dependency_dir)
  
end

$VENDOR_DEPEND.each do |dep|
  vendor_depend(dep)
end if $VENDOR_DEPEND

##########################################################################################
# Config gem
##########################################################################################

if ($DVLP == true)

  #---------------------------------------------------------------------------------------
  # Set development dependencies
  #---------------------------------------------------------------------------------------
  
  def depend(name)
    dependency_dir = CritbitRB.project_dir + "/" + name
    mklib(dependency_dir)
  end

  # Add dependencies here
  # depend(<other_gems>)
  $DVLP_DEPEND.each do |dep|
    depend(dep)
  end if $DVLP_DEPEND

  #----------------------------------------------------------------------------------------
  # If we need to test for coverage
  #----------------------------------------------------------------------------------------
  
  if $COVERAGE == 'true'
  
    require 'simplecov'
    
    SimpleCov.start do
      @filters = []
      add_group "CritbitRB", "lib/mdarray"
    end
    
  end

end
