class Notmuch < Formula
  desc "Thread-based email index, search, and tagging"
  homepage "https://notmuchmail.org/"
  url "https://notmuchmail.org/releases/notmuch-0.29.3.tar.xz"
  sha256 "d5f704b9a72395e43303de9b1f4d8e14dd27bf3646fdbb374bb3dbb7d150dc35"
  revision 1
  head "https://git.notmuchmail.org/git/notmuch", :using => :git

  bottle do
    cellar :any
    rebuild 1
    sha256 "789d748a2d59bd2df69de4f0f3d5e42fb6fa7e7e739ca2b86fd8a85408088b99" => :catalina
    sha256 "f3fb3267ac22265010553b2f72c1fb1c2b997a31759859a8e68a93cadf3bf9c1" => :mojave
    sha256 "7f2d8203b81fd29dde272a18f98235e31b43c28fc6e847906a79a0fa72219f6b" => :high_sierra
  end

  depends_on "doxygen" => :build
  depends_on "libgpg-error" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  depends_on "glib"
  depends_on "gmime"
  depends_on "python@3.8"
  depends_on "ruby"
  depends_on "talloc"
  depends_on "xapian"
  depends_on "zlib"

  def install
    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --emacslispdir=#{elisp}
      --emacsetcdir=#{elisp}
      --bashcompletiondir=#{bash_completion}
      --zshcompletiondir=#{zsh_completion}
    ]

    ENV.append_path "PYTHONPATH", Formula["sphinx-doc"].opt_libexec/"lib/python3.8/site-packages"

    system "./configure", *args
    system "make", "V=1", "install"

    bash_completion.install "completion/notmuch-completion.bash"

    (prefix/"vim/plugin").install "vim/notmuch.vim"
    (prefix/"vim/doc").install "vim/notmuch.txt"
    (prefix/"vim").install "vim/syntax"

    cd "bindings/python" do
      system Formula["python@3.8"].opt_bin/"python3", *Language::Python.setup_install_args(prefix)
    end

    # Ruby bindings are installed under bindings/ruby/ There is a
    # notmuch.bundle file that needs to be installed under
    # /usr/local/Cellar/ruby/2.7.1_2/lib/ruby/2.7.0/x86_64-darwin18/ However,
    # the automatically generated Makefile that is created in the
    # bindings/ruby/ file uses the wrong install path. In fact, it does
    # correctly define a variable to that path ($(rubyarchdir)) but it doesn't
    # use it. Instead, the `make install` target uses a different variable with the same name in upper
    # case ($(RUBYARCHDIR)) which instead points to
    # /usr/local/lib/ruby/vendor_ruby/2.7.0/x86_64-darwin18, which doesn't
    # exist and therefore fails to install.
    # In order to get this to work, we need to find a way to make `make
    # install` from the bindings/ruby/ directory install to the correct path.
    # Then, it's just a matter of adding
    cd "bindings/ruby" do
      system "make", "install"
    end
    # to this formula!
  end

  test do
    (testpath/".notmuch-config").write "[database]\npath=#{testpath}/Mail"
    (testpath/"Mail").mkpath
    assert_match "0 total", shell_output("#{bin}/notmuch new")
  end
end
