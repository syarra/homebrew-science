class SuiteSparse < Formula
  desc "Suite of Sparse Matrix Software"
  homepage "http://faculty.cse.tamu.edu/davis/suitesparse.html"
  url "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.5.1.tar.gz"
  sha256 "ac4524b9f69c4f8c2652d720b146c92a414c1943f86d46df49b4ff8377ae8752"

  bottle do
    cellar :any_skip_relocation
    sha256 "2ab3b2ecad9e5c871a0b3e0e70f3bab4e7ee3aab06eb9ace8de2be155dfb11e8" => :el_capitan
    sha256 "ac375ecab7b93e9da612b14dcdd4fa920248dce10794f9131d8d2774967fefdd" => :yosemite
    sha256 "828dbaf089f5e98c31a9434748ab3d913aa018d473797b2b3e2d3c90ea52b0fb" => :mavericks
  end

  option "with-matlab", "Install Matlab interfaces and tools"
  option "with-matlab-path=", "Path to Matlab executable (default: matlab)"
  option "with-openmp", "Build with OpenMP support"

  depends_on "metis"  # SuiteSparse must be compiled with metis 5.
                      # It is shipped with metis-5.1.0
  depends_on "cmake" => :build
  depends_on "tbb" => :recommended
  depends_on "openblas" => :optional

  depends_on :fortran if build.with? "matlab"
  needs :openmp if build.with? "openmp"

  def install
    cflags = "#{ENV.cflags}"
    cflags += "-fopenmp" if build.with? "openmp"
    cflags += " -I#{Formula["tbb"].opt_include}" if build.with? "tbb"

    make_args = ["CFLAGS=#{cflags}",
                 "INSTALL_LIB=#{lib}",
                 "INSTALL_INCLUDE=#{include}",
                 "RANLIB=echo",
                ]
    if build.with? "openblas"
      make_args << "BLAS=-L#{Formula["openblas"].opt_lib} -lopenblas"
    elsif OS.mac?
      make_args << "BLAS=-framework Accelerate"
    else
      make_args << "BLAS=-lblas -llapack"
    end

    make_args << "LAPACK=$(BLAS)"
    make_args += ["SPQR_CONFIG=-DHAVE_TBB",
                  "TBB=-L#{Formula["tbb"].opt_lib} -ltbb"] if build.with? "tbb"

    # SuiteSparse is shipped with metis-5.1.0 but it can use Homebrew's version by
    # setting MY_METIS_LIB and MY_METIS_INC variables.
    make_args += ["MY_METIS_LIB=-L#{Formula["metis"].opt_lib} -lmetis",
                  "MY_METIS_INC=#{Formula["metis"].opt_include}"]

    # Demos failed to compile. Thus only building libraries.
    system "make", "library", *make_args
    lib.mkpath
    include.mkpath
    system "make", "install",  *make_args

    if build.with? "matlab"
      matlab = ARGV.value("with-matlab-path") || "matlab"
      system matlab,
             "-nodesktop", "-nosplash",
             "-r", "run('SuiteSparse_install(false)'); exit;"

      # Install Matlab scripts and Mex files.
      %w[AMD BTF CAMD CCOLAMD CHOLMOD COLAMD CSparse CXSparse KLU LDL SPQR UMFPACK].each do |m|
        (share / "suite-sparse/matlab/#{m}").install Dir["#{m}/MATLAB/*"]
      end

      mdest = share / "suite-sparse/matlab"
      mdest.install "MATLAB_Tools"
      mdest.install "RBio/RBio"
      (doc/"matlab").install Dir["MATLAB_Tools/Factorize/Doc/*"]
    end
  end

  def caveats
    s = ""
    if build.with? "matlab"
      s += <<-EOS.undent
        Matlab interfaces and tools have been installed to

          #{pkgshare}/matlab

        It is possible that the SPQR interface fail to compile
        if you use the defaults mexopts.sh or if your mexopts.sh
        does not use gcc-4.9.
      EOS
    end
    s
  end
end
