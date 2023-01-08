describe Trains::Visitor::Controller do
  let(:valid_controller) { "spec/fixtures/box_controller.rb" }

  context "Given a valid controller file path" do
    it "returns an object with its metadata" do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_controller,
          RUBY_VERSION.to_f
        ).ast
      parser.process(file_ast)

      expect(parser.result).to eq(
        Trains::DTO::Controller.new(name: :BoxController, methods: Set.new)
      )
    end
  end
end
