require "spec_helper"
require "modified_bayes"

describe ModifiedBayes::Model do
  before(:each) do
    # 8 long, 7 sweet, 9 yellow; total 10
    @banana_features =
        [["long", "sweet"]] +
        [["long", "sweet", "yellow"]] * 6 +
        [["long", "yellow"]] +
        [["yellow"]] * 2
    # 0 long, 3 sweet, 6 yellow; total 6 (Note "long" is not present)
    @orange_features =
        [["sweet", "yellow"]] * 3 +
        [["yellow"]] * 3
  end
  
  it "initializes correctly" do
    classifier = ModifiedBayes::Model.new(@banana_features, @orange_features)
    p_pos = 10 / (10 + 6).to_f
    classifier.positive_sample_count.should == 10
    classifier.negative_sample_count.should == 6
    classifier.positive_feature_counts.should == {"long" => 8, "sweet" => 7, "yellow" => 9}
    classifier.negative_feature_counts.should == {"sweet" => 3, "yellow" => 6}
  end

  it "scores a single feature correctly" do
    classifier = ModifiedBayes::Model.new(@banana_features, @orange_features)
    p_pos = 10 / (10 + 6).to_f
    
    expected_score = Math.log(((9 + p_pos * (1 / p_pos)) / (9 + 6 + (1 / p_pos))) / p_pos)
    classifier.score(["yellow"]).should be_within(1e-6).of(expected_score)
  end
  
  it "sums the score across features" do
    classifier = ModifiedBayes::Model.new(@banana_features, @orange_features)
    p_pos = 10 / (10 + 6).to_f
    
    expected_sweet = Math.log(((7 + p_pos * (1 / p_pos)) / (7 + 3 + (1 / p_pos))) / p_pos)
    classifier.score(["sweet"]).should be_within(1e-6).of(expected_sweet)
    
    expected_yellow = Math.log(((9 + p_pos * (1 / p_pos)) / (9 + 6 + (1 / p_pos))) / p_pos)
    classifier.score(["sweet", "yellow"]).should be_within(1e-6).of(expected_sweet + expected_yellow)
  end
  
  it "returns a zero score for novel features" do
    classifier = ModifiedBayes::Model.new(@banana_features, @orange_features)
    p_pos = 10 / (10 + 6).to_f
    
    classifier.score(["stinky"]).should be_within(1e-6).of(0)
    
    expected_sweet = Math.log(((7 + p_pos * (1 / p_pos)) / (7 + 3 + (1 / p_pos))) / p_pos)
    classifier.score(["sweet", "stinky"]).should be_within(1e-6).of(expected_sweet)
  end
  
  it "can reproduce the data from Robert Brown and David Rogers" do
    total_sample_count = 1254
    positive_sample_count = 20
    
    bad_feature = -15491 # features can be strings, integers, whatever
    good_feature = -12907
    
    neg_features = [[bad_feature]] * 360
    neg_features += [[good_feature]] * 8
    neg_features += [[]] * (total_sample_count - positive_sample_count - neg_features.size) # just fill it to the right length
    pos_features = [[good_feature]] * 15 + [[]] * 5
    
    classifier = ModifiedBayes::Model.new(pos_features, neg_features)
    classifier.positive_sample_count.should == positive_sample_count
    classifier.negative_sample_count.should == total_sample_count - positive_sample_count
    
    classifier.score([bad_feature]).should be_within(1e-3).of(-1.908)
    classifier.score([good_feature]).should be_within(1e-3).of(2.46)
    classifier.score([good_feature, bad_feature]).should be_within(1e-3).of(-1.908 + 2.46)
  end
end

describe ModifiedBayes::Model, "#add(positives = [], negatives = [])" do
  before(:each) do
    @positive_samples = [
      ["sweet", "yellow"],
    ]

    @negative_samples = [
      ["sweet", "yellow"],
      ["round"]
    ]
    
    @model = ModifiedBayes::Model.new(@positive_samples, @negative_samples)
    @model.positive_sample_count.should == 1
    @model.negative_sample_count.should == 2
    @model.positive_feature_counts.should == {"sweet"=>1, "yellow"=>1}
    @model.negative_feature_counts.should == {"sweet"=>1, "yellow"=>1, "round"=>1}
    @model.score(["round"]).should be_within(1e-4).of(-0.28768)
  end
  
  it "does nothing when the arguments are empty" do
    @model.add
    @model.add([])
    @model.add([], [])
    @model.positive_sample_count.should == 1
    @model.negative_sample_count.should == 2
    @model.positive_feature_counts.should == {"sweet"=>1, "yellow"=>1}
    @model.negative_feature_counts.should == {"sweet"=>1, "yellow"=>1, "round"=>1}
    @model.score(["round"]).should be_within(1e-4).of(-0.28768)
  end
  
  it "updates the model attributes correctly and uses them for scoring" do
    @model.add([["sweet"]], [["sweet"]])
    @model.add([], [["sweet", "round"]])
    @model.positive_sample_count.should == 2
    @model.negative_sample_count.should == 4
    @model.positive_feature_counts.should == {"sweet"=>2, "yellow"=>1}
    @model.negative_feature_counts.should == {"sweet"=>3, "yellow"=>1, "round"=>2}
    
    @model.score(["sweet", "yellow"]).should be_within(1e-4).of(0.3001)
  end
end

describe ModifiedBayes::Model, "#dump and #load" do
  before(:each) do
    @positive_samples = [
      ["sweet", "yellow"],
      ["sweet"]
    ]

    @negative_samples = [
      ["sweet", "round"],
      ["sweet", "yellow"],
      ["sweet"],
      ["round"]
    ]

    @attribute_hash = {
      :positive_sample_count => 2,
      :negative_sample_count => 4,
      :positive_feature_counts => {"sweet"=>2, "yellow"=>1},
      :negative_feature_counts => {"sweet"=>3, "round"=>2, "yellow"=>1}
    }
  end

  it "dumps to a simple hash of attributes" do
    model = ModifiedBayes::Model.new(@positive_samples, @negative_samples)
    model.dump_hash.should == @attribute_hash
  end
  
  it "loads from the same type of hash" do
    model = ModifiedBayes::Model.load_hash(@attribute_hash)
    model.score(["sweet", "yellow"]).should be_within(1e-4).of(0.3001)
  end
end

describe ModifiedBayes::Model, "#applicability(features)" do
  it "is the fraction of the provided features that were present in the training set, which helps you judge if the model is applicable to this set of features" do
    positive_samples = [
      [1, 2],
      [1, 2, 3]
    ]

    negative_samples = [
      [1, 3],
      [4, 5, 6],
    ]
    
    model = ModifiedBayes::Model.new(positive_samples, negative_samples)
    model.applicability([1, 5]).should == 1.0
    model.applicability([7, 8, 9]).should == 0.0
    model.applicability([1, 7, 8, 9]).should == 0.25
    model.applicability([2, 9]).should == 0.50
  end
end

