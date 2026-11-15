class Forgejo < Formula
  desc "Agent-first client for the Forgejo HTTP API"
  homepage "https://forgejo.softwarepatterns.com"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/softwarepatterns/homebrew-tap/releases/download/forgejo/v0.2.0/forgejo-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "4bd86fd8ad5347724e5080c9d18a71f1c809f35d4bb6331da8094cbe1eb88b42"
    else
      url "https://github.com/softwarepatterns/homebrew-tap/releases/download/forgejo/v0.2.0/forgejo-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "f3b1e8d29c9e8f3ab2c0eb515313093ea78dda6cb2edb96e0d94ced6df3908cf"
    end
  end

  def install
    bin.install "forgejo"
  end

  test do
    assert_match "forgejo", shell_output("#{bin}/forgejo --version")
  end
end
