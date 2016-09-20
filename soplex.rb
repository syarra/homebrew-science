class Soplex < Formula
  desc "The Sequential object-oriented simPlex"
  homepage "http://soplex.zib.de"
  url "http://soplex.zib.de/download/release/soplex-2.2.1.tgz"
  sha256 "c2fffca4095c56f7261820dc2bcc2a31a6a6ff91446a9da083814a913a2a086f"

  option "without-test", "Skip build-time tests (not recommended)"

  depends_on "gcc"
  depends_on "zlib"
  depends_on "gmp"

  def install
    system "make", "SHARED=true"
    system "make", "test" if build.with? "test"
    lib.install Dir["lib/libsoplex*"]
    bin.install Dir["bin/soplex*"]
    include.install Dir["src/*.h"]
    pkgshare.install "src/example.cpp"
  end

  test do
    libs = ["-lsoplex", "-lz", "-lgmp"]
    system ENV["CXX"], "#{pkgshare}/example.cpp", "-oexample", *libs
    system "./example"
  end
end
