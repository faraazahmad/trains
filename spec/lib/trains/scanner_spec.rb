# frozen_string_literal: true

describe Trains::Scanner do
  let(:dir) { "spec/fixtures/barebones" }

  context "Given a valid Rails directory" do
    it "generates a list of all controllers in the repo" do
      scanner = described_class.new(dir)
      result = scanner.scan

      expect(result).to eq(
        Trains::DTO::App.new(
          controllers:
            Set[
              Trains::DTO::Controller.new(
                name: "ApplicationController",
                method_list: []
              ),
              Trains::DTO::Controller.new(
                name: "BoxController",
                method_list: []
              )
            ],
          models: [],
          migrations: Set[],
          helpers: []
        )
      )
    end
  end
end
