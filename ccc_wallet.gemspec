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

  spec.executables   = ['migrate']
  spec.bindir        = 'bin'

  spec.require_paths = ["lib"]
end
