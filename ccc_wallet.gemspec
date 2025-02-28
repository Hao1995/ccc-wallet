Gem::Specification.new do |spec|
  spec.name          = "ccc_wallet"
  spec.version       = "1.0.0"
  spec.authors       = ["Anonymous"]

  spec.summary       = "A reusable library for a centralized wallet system"
  spec.description   = "Provides functionality for deposits, withdrawals, balance checks, and money transfers."
  spec.license       = "MIT"

  spec.files         = Dir[
    "lib/**/*",
    "db/**/*",
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 5.0'
end
