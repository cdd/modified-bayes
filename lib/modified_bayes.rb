require "modified_bayes/version"

module ModifiedBayes
  class Model
    attr_reader :positive_sample_count, :negative_sample_count, :positive_feature_counts, :negative_feature_counts

    def initialize(positives, negatives)
      @positive_sample_count, @negative_sample_count = positives.size, negatives.size

      @positive_feature_counts = positives.each_with_object(Hash.new(0)) do |features, counts|
        features.each { |f| counts[f] += 1 }
      end
      @negative_feature_counts = negatives.each_with_object(Hash.new(0)) do |features, counts|
        features.each { |f| counts[f] += 1 }
      end
    end

    def score(features)
      # Probability a sample is active
      p_positive = @positive_sample_count / (@positive_sample_count.to_f + @negative_sample_count.to_f)
      # The "duplication factor" or the "virtual samples" we will add to correct for under-sampling.
      # Currently uses the "Laplacian correction", but could accept K as a parameter.
      k = 1.0 / p_positive

      features.map do |feature|
        pf = @positive_feature_counts[feature]
        nf = pf + @negative_feature_counts[feature]
        Math.log(((pf + p_positive * k) / (nf + k)) / p_positive)
      end.reduce(&:+)
    end
  end
end
