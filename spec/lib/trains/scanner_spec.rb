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
          'BoxController' => Trains::DTO::Controller.new(
            name: 'BoxController',
            method_list: [Trains::DTO::Method.new('index')],
            callbacks: []
          )
        }
      )

      expect(result.models['Person']).to eq(
        Trains::DTO::Model.new(
          'Person',
          [
            Trains::DTO::Field.new(:id, :bigint),
            Trains::DTO::Field.new(:name, :string),
            Trains::DTO::Field.new(:age, :integer),
            Trains::DTO::Field.new(:job, :string),
            Trains::DTO::Field.new(:bio, :text),
            Trains::DTO::Field.new(:created_at, :datetime),
            Trains::DTO::Field.new(:updated_at, :datetime),
            Trains::DTO::Field.new(:cars, :bigint)
          ],
          7.0
        )
      )

      expect(result.routes).to eq(
        Set[
          Trains::DTO::Route.new(:get, 'boxes', { to: 'box#index' })
        ]
      )
    end
  end
end
