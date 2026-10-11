# frozen_string_literal: true

require 'ripper'
require 'yard'

RSpec.describe 'Public API documentation' do
  reference = File.read(File.expand_path('../docs/API.md', __dir__))
  source = File.expand_path('../lib/speedy/client_resources.rb', __dir__)
  methods = Speedy::ClientResources.public_instance_methods(false)

  before(:context) do
    YARD::Registry.clear
    YARD.parse(source)
  end

  it 'indexes every endpoint shortcut, with the calculation alias accounted for' do
    indexed = reference.scan(/^### `(\w+)`$/).flatten.map(&:to_sym)
    expect(indexed).to match_array(methods - [:calculate_delivery_fee])
    expect(reference).to include('`calculate_delivery_fee` is an alias of `calculate_delivery`')
  end

  methods.each do |name|
    it "documents #{name} with a return type, arguments and an example" do
      method = YARD::Registry.at("Speedy::ClientResources##{name}")
      expect(method).not_to be_nil
      expect(method.docstring.to_s).not_to be_empty
      expect(method.tag(:return)&.types).not_to be_empty
      expect(method.tags(:example)).not_to be_empty
      documented = method.tags(:param).map(&:name)
      parameters = Speedy::ClientResources.instance_method(name).parameters.map(&:last).map(&:to_s)
      expect(documented).to match_array(parameters)
      method.tags(:example).each { |example| expect(Ripper.sexp(example.text)).not_to be_nil }
    end
  end

  it 'keeps all Markdown Ruby examples syntactically valid without executing them' do
    examples = reference.scan(/```ruby\n(.*?)```/m).flatten
    expect(examples.size).to be >= methods.size
    examples.each_with_index do |example, index|
      expect(Ripper.sexp(example)).not_to be_nil, "Invalid Ruby in API example #{index + 1}"
    end
  end
end
