class Soplex < Formula
  desc "The Sequential object-oriented simPlex"
  homepage "http://soplex.zib.de"
  url "http://soplex.zib.de/download/release/soplex-2.2.1.tgz"
  sha256 "c2fffca4095c56f7261820dc2bcc2a31a6a6ff91446a9da083814a913a2a086f"

  option "without-test", "Skip build-time tests (not recommended)"

  depends_on "gcc"
  depends_on "zlib" if OS.linux?
  depends_on "gmp"

  def install
    if OS.mac?
      File.open("make/make.darwin.x86_64.gnu", "a") do |f|
        f.puts "LIBBUILDFLAGS+= -m64 -L/usr/local/lib -lgmp -lz"
      end
    end
    system "make", "SHARED=true", "USRCXXFLAGS=-I/usr/local/include", "USRLDFLAGS=-L/usr/local/lib"
    system "make", "test" if build.with? "test"
    lib.install Dir["lib/libsoplex*"]
    bin.install Dir["bin/soplex*"]
    include.install Dir["src/*.h"]
    pkgshare.install "src/example.cpp"
  end

  def caveats; <<-EOS.undent
      SoPlex is distributed under the ZIB Academic License
      (http://scip.zib.de/academic.txt).
      You are allowed to retrieve SoPlex for research purposes as a member of
      a non-commercial and academic institution.

      We agreed to this license for you.
      If this is unacceptable you should uninstall.
    EOS
  end

  test do
    libs = ["-lsoplex", "-lz", "-lgmp"]
    system ENV["CXX"], "#{pkgshare}/example.cpp", "-oexample", *libs
    system "./example"
  end
end
