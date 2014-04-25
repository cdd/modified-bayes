$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'modified_bayes'
require 'benchmark'

# We want to benchmark with large arrays of 32-bit integers (ruby actually stores integers
# using 64 bits on my platform, but I'm trying to stay faithful to the real data).
class Rand32
  MAX_INT_32 = (2 ** 32) - 1
  
  def initialize
    @prng = Random.new(42)
  end
  
  # In the real data there are likely to be around 100,000 unique features
  NUMBER_OF_UNIQUE_FEATURES = 100_000
  def rand
    @prng.rand((MAX_INT_32 - NUMBER_OF_UNIQUE_FEATURES)..MAX_INT_32)
  end
end


rand32 = Rand32.new

# Create 1000 positive samples, each with 100 features
positives = (0...1000).map do |_|
  (0...100).map {|_| rand32.rand }
end

# now score 100 unknown samples, each with 100 features
to_score = (0...100).map do |_|
  (0...100).map {|_| rand32.rand }
end

bayes = ModifiedBayes::Model.new(positives)

# Results for 1000 positives, each with 100 features, scoring 100 samples, each with 100 features
# 7.17 - Ruby intersection and union methods: 7.17
# 1.73 - intersection_size method, inferring the union from that
# 0.91 - David's clever hash idea + method inlining
puts Benchmark.measure {
  to_score.each do |features|
    bayes.maximum_similarity(features)
  end
}