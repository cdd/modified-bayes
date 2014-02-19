# Modified Bayes

A Naïve Bayesian model optimized for sparse datasets, implemented as described in:

Xia X, Maliski EG, Gallant P, Rogers D: Classification of kinase 
inhibitors using a Bayesian model. J Med Chem 2004;47:4463-4470.

In summary, a small-sample correction is applied, (currently the Laplace correction), the probability is normalized, the natural log is taken and the results are summed.

## Installation

Add this line to your application's Gemfile:

    gem 'modified_bayes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install modified_bayes

## Usage

The features in this example are strings, but features can be any kind of object.

    positive_samples = [
      ["sweet", "yellow"],
      ["sweet"]
    ]

    negative_samples = [
      ["sweet", "round"],
      ["sweet", "yellow"],
      ["sweet"],
      ["round"]
    ]

    model = ModifiedBayes::Model.new(positive_samples, negative_samples)
    model.score(["sweet", "yellow"]) #=> 0.3001; this sample is predicted to be positive

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
