class ForgejoCli < Formula
  desc "Agent-first client for the Forgejo HTTP API"
  homepage "https://forgejo.softwarepatterns.com"
  version "0.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/softwarepatterns/homebrew-tap/releases/download/forgejo/v0.3.0/forgejo-0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "0524c89faf8b7317a749107344740d2b65957ffc55f096566895e5a019ec81f6"
    else
      url "https://github.com/softwarepatterns/homebrew-tap/releases/download/forgejo/v0.3.0/forgejo-0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "409484b826dfb8d8488f7d35d0d76f55894fedb79fbe22fafb131c1302151199"
    end
  end

  def install
    bin.install "forgejo"
  end

  test do
    assert_match "forgejo", shell_output("#{bin}/forgejo --version")
  end
end
