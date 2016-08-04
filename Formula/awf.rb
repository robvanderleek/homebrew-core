class Awf < Formula
  desc "'A Widget Factory' is a theme preview application for gtk2 and gtk3"
  homepage "https://github.com/valr/awf"
  url "https://github.com/valr/awf/archive/v1.3.1.tar.gz"
  sha256 "62a0b02170109c81ffbd4420b9385470d62de6fffa39002795e6992fcb4e36d8"
  head "https://github.com/valr/awf.git"

  bottle do
    cellar :any
    sha256 "f5e776bc03dd49f0b090f2e5a7c0a58ba366043497d61f6a9167f2c805b52937" => :el_capitan
    sha256 "ff5d8ccd439f2274927c4c42e3a813fdbd9318a0b98c40a76b00c1a2a9bc18ef" => :yosemite
    sha256 "01f0e493f6b090949b5ac48f71205d0350e2e98e1a9756927ff60650d0d07db9" => :mavericks
    sha256 "882d85a7b0f2411ab6ce2d43f1bcd0e3f878ca67e269a6f00520ba7f93bf8bdb" => :mountain_lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gtk+"
  depends_on "gtk+3"

  def install
    inreplace "src/awf.c", "/usr/share/themes", "#{HOMEBREW_PREFIX}/share/themes"
    system "./autogen.sh"
    rm "README.md" # let's not have two copies of README
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert (bin/"awf-gtk2").exist?
    assert (bin/"awf-gtk3").exist?
  end
end
