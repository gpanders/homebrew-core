class Fnc < Formula
  desc "Interactive text-based user interface for Fossil"
  homepage "https://fnc.bsdbox.org"
  url "https://fnc.bsdbox.org/uv/dl/fnc-0.15.tar.gz"
  version "0.15"
  sha256 "764aba958cd5a336e565d24349c3229cf0aa94e759373a388d4b9500421d553a"
  license "MIT"

  depends_on "ncurses"

  def install
    system "make"
    # The Makefile install target does not automatically create the bin directory
    system "install", "-d", "#{bin}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "repository database required", shell_output("#{bin}/fnc", 1).chomp
  end
end
