class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.1.34.tar.gz"
  sha256 "542b7127398774cf00938b3bc612aa76d360f79b7600b7a0dac1ad9744495d2d"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "9abd013a96a996b5f6041688083e85ac0f3c854fe21fcf0b7febff688ac1b04f"
    sha256 cellar: :any,                 arm64_ventura:  "de9808bf89a39fa5588550f1db00f8140a44cdb205d683fcefc324d9ef19f21a"
    sha256 cellar: :any,                 arm64_monterey: "0628e66ff4fadae49e9a6cdc27b4ad08b8d8bbf2946bcdfac008284246e35d29"
    sha256 cellar: :any,                 sonoma:         "c95d9759ade396b284b45339283a7d7131dd6b1cbc18834b95327885a38828b6"
    sha256 cellar: :any,                 ventura:        "e6a22f5f5d5a58808aed9614fdcbb77e91fa61a6e88bfa4614ed1d38bde1295c"
    sha256 cellar: :any,                 monterey:       "23ab47c9a14b8706e7918df9d50ea11489b05ea42f9e3cdf2774fb88f45ec989"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "22930501de3b4b0269e313fa6391de202c055aae46acaea2f3ea7518a48ca814"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  uses_from_macos "python" => :test

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"uv", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
