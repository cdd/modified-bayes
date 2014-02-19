require "modified_bayes/version"

module ModifiedBayes
  class Model
    attr_reader :p_positive, :k, :positive_counts, :negative_counts

    def initialize(positives, negatives)
      # Probability a sample is active
      @p_positive = positives.size / (positives.size + negatives.size.to_f)
      # The "duplication factor" or the "virtual samples" we will add to correct for under-sampling.
      # Currently uses the "Laplacian correction", but could accept K as a parameter.
      @k = 1.0 / @p_positive 

      @positive_counts = positives.each_with_object(Hash.new(0)) do |features, counts|
        features.each { |f| counts[f] += 1 }
      end
      @negative_counts = negatives.each_with_object(Hash.new(0)) do |features, counts|
        features.each { |f| counts[f] += 1 }
      end
    end

    def score(features)
      features.map do |feature|
        pf = @positive_counts[feature]
        nf = pf + @negative_counts[feature]
        Math.log(((pf + @p_positive * @k) / (nf + k)) / @p_positive)
      end.reduce(&:+)
    end
  end
end
