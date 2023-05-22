# frozen_string_literal: true

describe Trains::Scanner do
  let(:dir) { 'spec/fixtures/barebones' }

  context 'Given a valid Rails directory' do
    it 'generates a list of all controllers in the repo' do
      scanner = described_class.new(dir)
      result = scanner.scan

      expect(result.controllers).to eq(
        {
          'ApplicationController' => Trains::DTO::Controller.new(
            name: 'ApplicationController', method_list: [], callbacks: []
          ),
          'BoxController' => Trains::DTO::Controller.new(name: 'BoxController',
                                                         method_list: [], callbacks: [])
        }
      )

      expect(result.routes).to eq(
        Set[
          Trains::DTO::Route.new(:get, 'boxes', { to: 'box#index' })
        ]
      )
    end
  end
end
